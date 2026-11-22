import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Access + refresh tokens in the platform keystore (Android Keystore / iOS Keychain).
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  static const _access = 'access_token';
  static const _refresh = 'refresh_token';

  final FlutterSecureStorage _storage;
  String? _cachedAccess;

  Future<String?> accessToken() async => _cachedAccess ??= await _storage.read(key: _access);

  Future<String?> refreshToken() => _storage.read(key: _refresh);

  Future<void> save({required String access, required String refresh}) async {
    _cachedAccess = access;
    await _storage.write(key: _access, value: access);
    await _storage.write(key: _refresh, value: refresh);
  }

  Future<void> clear() async {
    _cachedAccess = null;
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }
}
