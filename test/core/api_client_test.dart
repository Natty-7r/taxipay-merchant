import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxipay_merchant/core/network/api_client.dart';
import 'package:taxipay_merchant/core/network/api_exception.dart';

import '../support/fakes.dart';

void main() {
  late FakeTokenStorage tokens;

  ApiClient client(FakeAdapter adapter) {
    final dio = Dio()..httpClientAdapter = adapter;
    return ApiClient(tokens, dio: dio, baseUrl: 'http://api.test');
  }

  setUp(() => tokens = FakeTokenStorage()
    ..access = 'old-access'
    ..refresh = 'old-refresh');

  test('unwraps the data envelope and sends the token and a trace id', () async {
    final adapter = FakeAdapter((_) => (200, ok({'unread': 3})));
    final count = await client(adapter).get('/api/notifications/unread-count', map: (d) => (d as Map)['unread']);

    expect(count, 3);
    expect(adapter.requests.single.headers['Authorization'], 'Bearer old-access');
    expect(adapter.requests.single.headers['X-Request-Id'], matches(RegExp(r'^[0-9a-f]{16}$')));
  });

  test('maps the error envelope to ApiException with details and trace id', () async {
    final adapter = FakeAdapter((_) => (400, apiError('VALIDATION_FAILED', 'Request validation failed', details: ['tin: must be 10 digits'])));
    final call = client(adapter).post('/api/merchant/taxis', body: {}, map: (d) => d);

    await expectLater(call, throwsA(isA<ApiException>()
        .having((e) => e.code, 'code', 'VALIDATION_FAILED')
        .having((e) => e.status, 'status', 400)
        .having((e) => e.traceId, 'traceId', 'abc123')
        .having((e) => e.userMessage, 'userMessage', contains('tin: must be 10 digits'))));
  });

  test('an expired token is refreshed once (rotating both tokens) and the call retried', () async {
    final adapter = FakeAdapter((r) {
      if (r.path == '/api/auth/refresh') {
        expect(r.data, {'refreshToken': 'old-refresh'});
        return (200, ok({'accessToken': 'new-access', 'refreshToken': 'new-refresh'}));
      }
      return r.headers['Authorization'] == 'Bearer new-access'
          ? (200, ok('fine'))
          : (401, apiError('TOKEN_EXPIRED', 'Token has expired'));
    });

    final result = await client(adapter).get('/api/merchant/dashboard', map: (d) => d);

    expect(result, 'fine');
    expect(tokens.access, 'new-access');
    expect(tokens.refresh, 'new-refresh');
    expect(adapter.requests.map((r) => r.path), ['/api/merchant/dashboard', '/api/auth/refresh', '/api/merchant/dashboard']);
  });

  test('when the refresh fails the session ends', () async {
    var expired = false;
    final adapter = FakeAdapter((r) => r.path == '/api/auth/refresh'
        ? (401, apiError('INVALID_REFRESH_TOKEN', 'Refresh token is invalid'))
        : (401, apiError('INVALID_TOKEN', 'Access token is invalid or expired')));
    final api = client(adapter)..onSessionExpired = () => expired = true;

    await expectLater(api.get('/api/auth/me', map: (d) => d), throwsA(isA<ApiException>().having((e) => e.isUnauthorized, '401', true)));
    expect(expired, isTrue);
    expect(tokens.clears, 1);
  });

  test('a wrong password (401 without a token problem) does not try to refresh', () async {
    final adapter = FakeAdapter((_) => (401, apiError('INVALID_CREDENTIALS', 'Invalid phone/email or password')));
    await expectLater(client(adapter).post('/api/auth/login', body: {}, map: (d) => d),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'INVALID_CREDENTIALS')));
    expect(adapter.requests, hasLength(1));
  });

  test('no connection becomes a friendly NETWORK error', () {
    final e = ApiException.fromDio(DioException.connectionError(
        requestOptions: RequestOptions(path: '/x'), reason: 'refused'));
    expect(e.code, 'NETWORK');
    expect(e.isNetwork, isTrue);
  });
}
