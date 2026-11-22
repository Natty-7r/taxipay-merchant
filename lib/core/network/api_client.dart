import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../logging/app_logger.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'page.dart';

/// Thin layer over Dio for the Taxi Pay API:
/// * unwraps the `{ success, data }` envelope and turns errors into [ApiException];
/// * sends `Authorization: Bearer …` and an `X-Request-Id` (trace id) on every call;
/// * on 401 with an expired token, refreshes once (rotating the refresh token) and retries;
///   if that fails, [onSessionExpired] signs the user out.
class ApiClient {
  ApiClient(this._tokens, {Dio? dio, String? baseUrl}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl ?? Env.apiBaseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers['Accept'] = 'application/json';
    _dio.interceptors.add(QueuedInterceptorsWrapper(onRequest: _onRequest, onError: _onError));
    if (Env.logHttp && !kReleaseMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false, // never log passwords or tokens
        responseBody: false,
        logPrint: (o) => appLogger.d(o),
      ));
    }
  }

  final Dio _dio;
  final TokenStorage _tokens;
  final _random = Random.secure();

  /// Called when the session can't be renewed (refresh token expired / revoked).
  VoidCallback? onSessionExpired;

  // ------------------------------------------------------------ requests

  Future<T> get<T>(String path, {Map<String, dynamic>? query, required T Function(dynamic data) map}) =>
      _send(() => _dio.get(path, queryParameters: _clean(query)), map);

  Future<Page<T>> getPage<T>(String path, T Function(Map<String, dynamic>) item, {Map<String, dynamic>? query}) =>
      get(path, query: query, map: (d) => Page.fromJson(d as Map<String, dynamic>, item));

  Future<T> post<T>(String path, {Object? body, Map<String, dynamic>? headers, required T Function(dynamic data) map}) =>
      _send(() => _dio.post(path, data: body, options: Options(headers: headers)), map);

  Future<T> put<T>(String path, {Object? body, required T Function(dynamic data) map}) =>
      _send(() => _dio.put(path, data: body), map);

  Future<void> delete(String path) => _send(() => _dio.delete(path), (_) {});

  /// Multipart upload of one file field named `file`.
  Future<T> upload<T>(String path, {required Uint8List bytes, required String filename,
      Map<String, dynamic>? query, required T Function(dynamic data) map}) {
    final form = FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: filename)});
    return _send(() => _dio.post(path, data: form, queryParameters: query), map);
  }

  /// Raw bytes (images, QR codes, documents).
  Future<Uint8List> bytes(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get<List<int>>(path, queryParameters: query,
          // The client default is Accept: application/json; files are images / PDFs.
          options: Options(responseType: ResponseType.bytes, headers: {'Accept': '*/*'}));
      return Uint8List.fromList(res.data ?? const []);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<T> _send<T>(Future<Response<dynamic>> Function() call, T Function(dynamic data) map) async {
    try {
      final res = await call();
      final body = res.data;
      return map(body is Map ? body['data'] : body);
    } on DioException catch (e) {
      final error = ApiException.fromDio(e);
      appLogger.w('API ${e.requestOptions.method} ${e.requestOptions.path} failed: $error');
      throw error;
    }
  }

  // ------------------------------------------------------------ interceptors

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['X-Request-Id'] = _traceId();
    final token = await _tokens.accessToken();
    if (token != null && options.extra['noAuth'] != true) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  Future<void> _onError(DioException e, ErrorInterceptorHandler handler) async {
    final code = e.response?.data is Map ? (e.response!.data as Map)['errorCode'] : null;
    final expired = e.response?.statusCode == 401 && (code == 'INVALID_TOKEN' || code == 'TOKEN_EXPIRED');
    if (!expired || e.requestOptions.extra['retried'] == true) return handler.next(e);

    if (await _refresh()) {
      final retry = e.requestOptions..extra['retried'] = true;
      retry.headers['Authorization'] = 'Bearer ${await _tokens.accessToken()}';
      try {
        return handler.resolve(await _dio.fetch(retry));
      } on DioException catch (again) {
        return handler.next(again);
      }
    }
    await _tokens.clear();
    onSessionExpired?.call();
    handler.next(e);
  }

  /// Rotates the refresh token. Uses a bare Dio so it doesn't recurse through the interceptor.
  Future<bool> _refresh() async {
    final refresh = await _tokens.refreshToken();
    if (refresh == null) return false;
    try {
      final bare = Dio(BaseOptions(baseUrl: _dio.options.baseUrl))..httpClientAdapter = _dio.httpClientAdapter;
      final res = await bare.post('/api/auth/refresh', data: {'refreshToken': refresh});
      final data = (res.data as Map)['data'] as Map;
      await _tokens.save(access: data['accessToken'] as String, refresh: data['refreshToken'] as String);
      appLogger.i('Session refreshed');
      return true;
    } catch (e) {
      appLogger.w('Session refresh failed: $e');
      return false;
    }
  }

  String _traceId() => List.generate(16, (_) => _random.nextInt(16).toRadixString(16)).join();

  static Map<String, dynamic>? _clean(Map<String, dynamic>? q) =>
      q == null ? null : (Map.of(q)..removeWhere((_, v) => v == null));
}
