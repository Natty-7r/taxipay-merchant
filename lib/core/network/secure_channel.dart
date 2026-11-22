import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Client side of the API's app-layer secure channel (on top of TLS).
///
/// Handshake: ephemeral P-256 key + 16-byte nonce → the server's ephemeral key, nonce, session
/// id and an ECDSA-SHA256 signature made with its long-term key, which must match the pinned
/// key. Keys: HKDF-SHA256(ECDH, clientNonce‖serverNonce, version‖" keys"‖sessionId) → 64 bytes
/// (client→server ‖ server→client). Bodies: AES-256-GCM; request AAD `req|METHOD|path|seq|session`,
/// response AAD `res|seq|session`.
class SecureCrypto {
  SecureCrypto._();

  static const version = 'taxipay-sc-v1';
  static final ECDomainParameters _curve = ECDomainParameters('secp256r1');
  static final SecureRandom _random = _seededRandom();

  static SecureRandom _seededRandom() {
    final seed = Random.secure();
    return FortunaRandom()..seed(KeyParameter(Uint8List.fromList(List.generate(32, (_) => seed.nextInt(256)))));
  }

  static Uint8List randomBytes(int n) => _random.nextBytes(n);

  static AsymmetricKeyPair<ECPublicKey, ECPrivateKey> newKeyPair() {
    final gen = ECKeyGenerator()..init(ParametersWithRandom(ECKeyGeneratorParameters(_curve), _random));
    final pair = gen.generateKeyPair();
    return AsymmetricKeyPair(pair.publicKey, pair.privateKey);
  }

  /// 0x04‖X‖Y.
  static Uint8List rawPoint(ECPublicKey key) => key.Q!.getEncoded(false);

  static ECPublicKey fromRawPoint(Uint8List raw) {
    if (raw.length != 65 || raw[0] != 0x04) throw const FormatException('Not an uncompressed P-256 point');
    final q = _curve.curve.decodePoint(raw);
    if (q == null || q.isInfinity) throw const FormatException('Invalid point');
    // decodePoint does not validate uncompressed points: check y² = x³ + ax + b.
    final x = q.x!, y = q.y!, a = _curve.curve.a!, b = _curve.curve.b!;
    if (y * y != x * x * x + a * x + b) throw const FormatException('Point is not on P-256');
    return ECPublicKey(q, _curve);
  }

  /// ECDH shared secret: the X coordinate, 32 bytes big-endian (same as the JDK).
  static Uint8List ecdh(ECPrivateKey mine, ECPublicKey theirs) {
    final agreement = ECDHBasicAgreement()..init(mine);
    return _bigIntTo32(agreement.calculateAgreement(theirs));
  }

  /// RFC 5869.
  static Uint8List hkdf(Uint8List ikm, Uint8List salt, Uint8List info, int length) {
    HMac hmac(Uint8List key) => HMac(SHA256Digest(), 64)..init(KeyParameter(key));
    final prk = hmac(salt.isEmpty ? Uint8List(32) : salt).process(ikm);
    final out = BytesBuilder();
    var t = Uint8List(0);
    for (var i = 1; out.length < length; i++) {
      t = hmac(prk).process(Uint8List.fromList([...t, ...info, i]));
      out.add(t);
    }
    return Uint8List.sublistView(out.toBytes(), 0, length);
  }

  static Uint8List seal(Uint8List key, Uint8List iv, Uint8List plaintext, Uint8List aad) {
    final gcm = GCMBlockCipher(AESEngine())..init(true, AEADParameters(KeyParameter(key), 128, iv, aad));
    return gcm.process(plaintext);
  }

  static Uint8List open(Uint8List key, Uint8List iv, Uint8List ciphertext, Uint8List aad) {
    final gcm = GCMBlockCipher(AESEngine())..init(false, AEADParameters(KeyParameter(key), 128, iv, aad));
    return gcm.process(ciphertext); // throws InvalidCipherTextException when tampered
  }

  /// ECDSA-SHA256 with a raw r‖s signature (64 bytes).
  static bool verify(ECPublicKey key, Uint8List message, Uint8List signature) {
    if (signature.length != 64) return false;
    final signer = ECDSASigner(SHA256Digest())..init(false, PublicKeyParameter<ECPublicKey>(key));
    final r = _bytesToBigInt(signature.sublist(0, 32));
    final s = _bytesToBigInt(signature.sublist(32));
    return signer.verifySignature(message, ECSignature(r, s));
  }

  static Uint8List transcript(Uint8List clientPub, Uint8List serverPub, Uint8List clientNonce, Uint8List serverNonce,
          String sessionId) =>
      Uint8List.fromList([...utf8.encode(version), ...clientPub, ...serverPub, ...clientNonce, ...serverNonce, ...utf8.encode(sessionId)]);

  static Uint8List requestAad(String method, String path, int seq, String sessionId) =>
      Uint8List.fromList(utf8.encode('req|${method.toUpperCase()}|$path|$seq|$sessionId'));

  static Uint8List responseAad(int seq, String sessionId) => Uint8List.fromList(utf8.encode('res|$seq|$sessionId'));

  static Uint8List _bigIntTo32(BigInt v) {
    final out = Uint8List(32);
    var x = v;
    for (var i = 31; i >= 0; i--) {
      out[i] = (x & BigInt.from(0xff)).toInt();
      x = x >> 8;
    }
    return out;
  }

  static BigInt _bytesToBigInt(List<int> bytes) => bytes.fold(BigInt.zero, (acc, b) => (acc << 8) | BigInt.from(b));
}

/// An established session: keys, id and the next sequence number.
class SecureSession {
  SecureSession({required this.id, required this.clientToServer, required this.serverToClient, required this.expiresAt});

  final String id;
  final Uint8List clientToServer;
  final Uint8List serverToClient;
  final DateTime expiresAt;
  int _seq = 0;

  bool get usable => DateTime.now().isBefore(expiresAt.subtract(const Duration(minutes: 1)));

  int nextSeq() => ++_seq;

  /// `{"iv","ct"}` for a JSON body.
  Map<String, String> sealJson(Object body, String method, String path, int seq) {
    final iv = SecureCrypto.randomBytes(12);
    final ct = SecureCrypto.seal(clientToServer, iv, Uint8List.fromList(utf8.encode(jsonEncode(body))),
        SecureCrypto.requestAad(method, path, seq, id));
    return {'iv': base64Encode(iv), 'ct': base64Encode(ct)};
  }

  Object? openJson(Map<String, dynamic> sealed, int seq) {
    final plain = SecureCrypto.open(serverToClient, base64Decode(sealed['iv'] as String), base64Decode(sealed['ct'] as String),
        SecureCrypto.responseAad(seq, id));
    return jsonDecode(utf8.decode(plain));
  }

  /// Runs the handshake. [post] sends JSON to /api/secure/handshake and returns `data`.
  static Future<SecureSession> establish({
    required Uint8List pinnedServerKey,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic> body) post,
  }) async {
    final mine = SecureCrypto.newKeyPair();
    final myPub = SecureCrypto.rawPoint(mine.publicKey);
    final myNonce = SecureCrypto.randomBytes(16);
    final h = await post({'clientPublicKey': base64Encode(myPub), 'clientNonce': base64Encode(myNonce)});
    final sessionId = h['sessionId'] as String;
    final serverPub = base64Decode(h['serverPublicKey'] as String);
    final serverNonce = base64Decode(h['serverNonce'] as String);
    final signed = SecureCrypto.verify(SecureCrypto.fromRawPoint(pinnedServerKey),
        SecureCrypto.transcript(myPub, serverPub, myNonce, serverNonce, sessionId), base64Decode(h['signature'] as String));
    if (!signed) throw StateError('Secure channel: the server is not who it claims to be (signature mismatch)');
    final keys = SecureCrypto.hkdf(SecureCrypto.ecdh(mine.privateKey, SecureCrypto.fromRawPoint(serverPub)),
        Uint8List.fromList([...myNonce, ...serverNonce]),
        Uint8List.fromList([...utf8.encode('${SecureCrypto.version} keys'), ...utf8.encode(sessionId)]), 64);
    return SecureSession(
      id: sessionId,
      clientToServer: Uint8List.sublistView(keys, 0, 32),
      serverToClient: Uint8List.sublistView(keys, 32, 64),
      expiresAt: DateTime.parse(h['expiresAt'] as String).toLocal(),
    );
  }
}
