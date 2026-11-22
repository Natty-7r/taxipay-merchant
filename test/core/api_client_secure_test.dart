import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';
import 'package:taxipay_merchant/core/network/api_client.dart';
import 'package:taxipay_merchant/core/network/api_exception.dart';
import 'package:taxipay_merchant/core/network/secure_channel.dart';

import '../support/fakes.dart';

/// A fake API speaking the secure-channel protocol (the server side of SecureChannelFilter).
class FakeSecureServer implements HttpClientAdapter {
  FakeSecureServer(this.handler, {AsymmetricKeyPair<ECPublicKey, ECPrivateKey>? identity})
      : identity = identity ?? SecureCrypto.newKeyPair();

  final (int, Object?) Function(RequestOptions request, Object? plainBody) handler;
  final AsymmetricKeyPair<ECPublicKey, ECPrivateKey> identity;
  final sessions = <String, SecureSession>{};
  final seen = <String>[];
  final wire = <Object?>[];
  var handshakes = 0;

  String get publicKey => base64Encode(SecureCrypto.rawPoint(identity.publicKey));

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    seen.add(o.path);
    if (o.path == '/api/secure/handshake') return _json(200, ok(_handshake(o.data as Map)));

    final sid = o.headers['X-Secure-Session'] as String?;
    if (sid == null) return _json(428, apiError('SECURE_CHANNEL_REQUIRED', 'Use the secure channel'));
    final session = sessions[sid];
    if (session == null) return _json(428, apiError('SECURE_SESSION_EXPIRED', 'expired'));
    final seq = int.parse(o.headers['X-Secure-Seq'] as String);
    wire.add(o.data);
    Object? plain;
    if (o.data != null) {
      final sealed = o.data as Map;
      plain = jsonDecode(utf8.decode(SecureCrypto.open(session.clientToServer, base64Decode(sealed['iv'] as String),
          base64Decode(sealed['ct'] as String), SecureCrypto.requestAad(o.method, o.uri.path, seq, sid))));
    }
    final (status, body) = handler(o, plain);
    final iv = SecureCrypto.randomBytes(12);
    final ct = SecureCrypto.seal(session.serverToClient, iv, Uint8List.fromList(utf8.encode(jsonEncode(body))),
        SecureCrypto.responseAad(seq, sid));
    return _json(status, {'iv': base64Encode(iv), 'ct': base64Encode(ct)}, sealed: true);
  }

  Map<String, Object?> _handshake(Map body) {
    handshakes++;
    final clientPub = base64Decode(body['clientPublicKey'] as String);
    final clientNonce = base64Decode(body['clientNonce'] as String);
    final eph = SecureCrypto.newKeyPair();
    final serverPub = SecureCrypto.rawPoint(eph.publicKey);
    final serverNonce = SecureCrypto.randomBytes(16);
    final sid = 'sid-$handshakes';
    final signer = ECDSASigner(SHA256Digest(), HMac(SHA256Digest(), 64))
      ..init(true, PrivateKeyParameter<ECPrivateKey>(identity.privateKey));
    final sig = signer.generateSignature(SecureCrypto.transcript(clientPub, serverPub, clientNonce, serverNonce, sid)) as ECSignature;
    final keys = SecureCrypto.hkdf(SecureCrypto.ecdh(eph.privateKey, SecureCrypto.fromRawPoint(clientPub)),
        Uint8List.fromList([...clientNonce, ...serverNonce]), Uint8List.fromList(utf8.encode('${SecureCrypto.version} keys$sid')), 64);
    sessions[sid] = SecureSession(id: sid, clientToServer: keys.sublist(0, 32), serverToClient: keys.sublist(32), expiresAt: DateTime(2100));
    return {
      'sessionId': sid,
      'serverPublicKey': base64Encode(serverPub),
      'serverNonce': base64Encode(serverNonce),
      'expiresAt': DateTime.now().add(const Duration(minutes: 30)).toUtc().toIso8601String(),
      'signature': base64Encode([..._b32(sig.r), ..._b32(sig.s)]),
      'version': SecureCrypto.version,
    };
  }

  static List<int> _b32(BigInt v) => [for (var i = 31; i >= 0; i--) ((v >> (8 * i)) & BigInt.from(0xff)).toInt()];

  ResponseBody _json(int status, Object? body, {bool sealed = false}) => ResponseBody.fromString(jsonEncode(body), status, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        if (sealed) 'x-secure-response': ['1'],
      });

  @override
  void close({bool force = false}) {}
}

void main() {
  ApiClient client(FakeSecureServer server, {String? key}) =>
      ApiClient(FakeTokenStorage()..access = 'tok', dio: Dio()..httpClientAdapter = server, baseUrl: 'http://api.test',
          secureChannel: true, serverKey: key ?? server.publicKey);

  test('bodies travel encrypted both ways and the app sees plain JSON', () async {
    final server = FakeSecureServer((o, body) => (200, ok({'echo': body, 'path': o.path})));
    final api = client(server);

    final out = await api.post('/api/merchant/taxis', body: {'plate': 'AA-12345'}, map: (d) => d);
    expect(out, {'echo': {'plate': 'AA-12345'}, 'path': '/api/merchant/taxis'});
    expect(jsonEncode(server.wire.single), isNot(contains('AA-12345')));

    expect(await api.get('/api/merchant/dashboard', map: (d) => (d as Map)['path']), '/api/merchant/dashboard');
    expect(server.handshakes, 1); // session reused
  });

  test('sealed error bodies become ApiExceptions', () async {
    final server = FakeSecureServer((_, _) => (409, apiError('TAXI_EXISTS', 'Plate already registered')));
    await expectLater(client(server).post('/api/merchant/taxis', body: {}, map: (d) => d),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'TAXI_EXISTS')));
  });

  test('an expired session is renegotiated and the request re-sealed', () async {
    final server = FakeSecureServer((o, body) => (200, ok(body)));
    final api = client(server);
    await api.post('/api/consumer/x', body: {'n': 1}, map: (d) => d);
    server.sessions.clear(); // API restarted
    expect(await api.post('/api/consumer/x', body: {'n': 2}, map: (d) => d), {'n': 2});
    expect(server.handshakes, 2);
  });

  test('refuses a server that does not hold the pinned key', () async {
    final server = FakeSecureServer((_, _) => (200, ok('secret')));
    final impostorPin = base64Encode(SecureCrypto.rawPoint(SecureCrypto.newKeyPair().publicKey));
    await expectLater(client(server, key: impostorPin).get('/api/merchant/dashboard', map: (d) => d), throwsA(isA<ApiException>()));
    expect(server.seen, ['/api/secure/handshake']); // the request itself never left
  });
}
