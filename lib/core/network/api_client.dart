import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../logging/app_logger.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'page.dart';
import 'secure_channel.dart';

/// Thin layer over Dio for the Taxi Pay API:
/// * unwraps the `{ success, data }` envelope and turns errors into [ApiException];
/// * sends `Authorization: Bearer …` and an `X-Request-Id` (trace id) on every call;
/// * on 401 with an expired token, refreshes once (rotating the refresh token) and retries;
///   if that fails, [onSessionExpired] signs the user out;
/// * with the secure channel on, JSON bodies both ways are end-to-end encrypted (see
///   [SecureSession]); the session is negotiated on first use and renewed when it expires.
class ApiClient {
  ApiClient(this._tokens, {Dio? dio, String? baseUrl, bool? secureChannel, String? serverKey})
      : _dio = dio ?? Dio(),
        _secureOn = secureChannel ?? Env.secureChannel,
        _serverKey = serverKey ?? Env.secureChannelServerKey {
    _dio.options
      ..baseUrl = baseUrl ?? Env.apiBaseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers['Accept'] = 'application/json';
    _dio.interceptors.add(QueuedInterceptorsWrapper(onRequest: _onRequest, onResponse: _onResponse, onError: _onError));
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
  final bool _secureOn;
  final String _serverKey;
  SecureSession? _secure;
  Uint8List? _pinned;

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

  /// Opens a server-sent event stream and yields its text as it arrives (auth and token refresh
  /// as for any call). Cancel [cancelToken] to close it.
  Future<Stream<String>> openEventStream(String path, CancelToken cancelToken) async {
    final res = await _dio.get<ResponseBody>(path,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: Duration.zero,
          headers: {'Accept': 'text/event-stream', 'Cache-Control': 'no-cache'},
        ));
    return res.data!.stream.cast<List<int>>().transform(const Utf8Decoder(allowMalformed: true));
  }

  // ------------------------------------------------------------ interceptors

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['X-Request-Id'] = _traceId();
    final token = await _tokens.accessToken();
    if (token != null && options.extra['noAuth'] != true) options.headers['Authorization'] = 'Bearer $token';
    if (_wantsSecure(options)) {
      try {
        _seal(options, await _secureSession());
      } catch (e) {
        // Fail closed: never fall back to plain JSON when the channel can't be set up.
        appLogger.w('Secure channel unavailable: $e');
        return handler.reject(DioException(requestOptions: options, error: e, message: 'Secure channel unavailable'));
      }
    }
    handler.next(options);
  }

  void _onResponse(Response<dynamic> res, ResponseInterceptorHandler handler) {
    try {
      _open(res);
    } catch (e) {
      appLogger.w('Secure channel: response for ${res.requestOptions.path} could not be opened: $e');
      return handler.reject(DioException(requestOptions: res.requestOptions, response: res, error: e,
          message: 'Response failed the integrity check'));
    }
    handler.next(res);
  }

  Future<void> _onError(DioException e, ErrorInterceptorHandler handler) async {
    if (e.response != null) {
      try {
        _open(e.response!); // error bodies are sealed too
      } catch (_) {
        return handler.next(e);
      }
    }
    final code = e.response?.data is Map ? (e.response!.data as Map)['errorCode'] : null;
    final expired = e.response?.statusCode == 401 && (code == 'INVALID_TOKEN' || code == 'TOKEN_EXPIRED');
    // The API restarted or the session timed out: new handshake, same request.
    if (e.response?.statusCode == 428 && code == 'SECURE_SESSION_EXPIRED' && e.requestOptions.extra['scRetried'] != true) {
      _secure = null;
      try {
        return handler.resolve(await _dio.fetch(e.requestOptions..extra['scRetried'] = true));
      } on DioException catch (again) {
        return handler.next(again);
      }
    }
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

  // ------------------------------------------------------------ secure channel

  bool _wantsSecure(RequestOptions o) =>
      _secureOn &&
      o.extra['noSecure'] != true &&
      o.responseType != ResponseType.stream &&
      !o.path.startsWith('/api/secure/') &&
      !o.path.startsWith('/api/events');

  /// Current session, or a new handshake (requests are queued, so only one runs at a time).
  Future<SecureSession> _secureSession() async {
    final current = _secure;
    if (current != null && current.usable) return current;
    final bare = Dio(BaseOptions(baseUrl: _dio.options.baseUrl, connectTimeout: _dio.options.connectTimeout))
      ..httpClientAdapter = _dio.httpClientAdapter;
    _pinned ??= await _serverPublicKey(bare);
    final session = await SecureSession.establish(
      pinnedServerKey: _pinned!,
      post: (body) async => ((await bare.post('/api/secure/handshake', data: body)).data as Map)['data'] as Map<String, dynamic>,
    );
    appLogger.i('Secure channel established');
    return _secure = session;
  }

  Future<Uint8List> _serverPublicKey(Dio bare) async {
    if (_serverKey.isNotEmpty) return base64Decode(_serverKey);
    appLogger.w('SECURE_CHANNEL_SERVER_KEY not set — trusting the key the API sends (development only)');
    final res = await bare.get('/api/secure/key');
    return base64Decode(((res.data as Map)['data'] as Map)['publicKey'] as String);
  }

  /// Session headers, and the JSON body encrypted. The plain body is kept so a retry re-seals it.
  void _seal(RequestOptions o, SecureSession session) {
    final seq = session.nextSeq();
    o.headers['X-Secure-Session'] = session.id;
    o.headers['X-Secure-Seq'] = '$seq';
    o.extra['scSeq'] = seq;
    o.extra['scSession'] = session;
    if (!o.extra.containsKey('scPlain')) o.extra['scPlain'] = o.data;
    final plain = o.extra['scPlain'];
    if (plain == null || plain is FormData) {
      o.data = plain; // uploads go as they are (still bound to the session)
      return;
    }
    o.data = session.sealJson(plain, o.method, o.uri.path, seq);
    o.contentType = Headers.jsonContentType;
  }

  void _open(Response<dynamic> res) {
    if (res.headers.value('x-secure-response') != '1') return;
    final session = res.requestOptions.extra['scSession'] as SecureSession?;
    final seq = res.requestOptions.extra['scSeq'] as int?;
    if (session == null || seq == null || res.data is! Map) throw StateError('unexpected sealed response');
    res.data = session.openJson(Map<String, dynamic>.from(res.data as Map), seq);
  }

  String _traceId() => List.generate(16, (_) => _random.nextInt(16).toRadixString(16)).join();

  static Map<String, dynamic>? _clean(Map<String, dynamic>? q) =>
      q == null ? null : (Map.of(q)..removeWhere((_, v) => v == null));
}
