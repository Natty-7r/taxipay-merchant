import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:taxipay_merchant/core/storage/token_storage.dart';

/// In-memory token storage (the real one needs the platform keystore).
class FakeTokenStorage extends TokenStorage {
  String? access;
  String? refresh;
  int clears = 0;

  @override
  Future<String?> accessToken() async => access;

  @override
  Future<String?> refreshToken() async => refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    clears++;
    access = null;
    refresh = null;
  }
}

/// Answers requests from a handler and records them.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final (int, Object?) Function(RequestOptions request) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (status, body) = handler(options);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> ok(Object? data) => {'success': true, 'data': data};

Map<String, Object?> apiError(String code, String message, {List<String>? details}) =>
    {'success': false, 'errorCode': code, 'message': message, 'details': ?details, 'traceId': 'abc123'};
