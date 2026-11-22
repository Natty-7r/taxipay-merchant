import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json.dart';
import 'auth_models.dart';

class AuthApi {
  AuthApi(this._api);

  final ApiClient _api;

  /// `userType: MERCHANT` makes the API refuse admin / consumer accounts in this app.
  Future<AuthTokens> login(String identifier, String password) => _api.post('/api/auth/login',
      body: {'identifier': identifier.trim(), 'password': password, 'userType': 'MERCHANT'},
      map: (d) => AuthTokens.fromJson(d as Json));

  /// Merchant self-registration; returns tokens — the new merchant is signed in.
  Future<AuthTokens> register(Json request) => _api.post('/api/public/merchants/register',
      body: request, map: (d) => AuthTokens.fromJson((d as Json)['auth'] as Json));

  Future<Me> me() => _api.get('/api/auth/me', map: (d) => Me.fromJson(d as Json));

  Future<void> logout(String refreshToken) =>
      _api.post('/api/auth/logout', body: {'refreshToken': refreshToken}, map: (_) {});

  Future<AuthTokens> changePassword(String current, String next) => _api.post('/api/auth/password/change',
      body: {'currentPassword': current, 'newPassword': next}, map: (d) => AuthTokens.fromJson(d as Json));

  Future<void> updateMe({required String fullName, String? email, String? language, bool? marketingOptIn}) =>
      _api.put('/api/auth/me', body: {
        'fullName': fullName,
        'email': email,
        'preferredLanguage': language,
        'marketingOptIn': marketingOptIn,
      }..removeWhere((_, v) => v == null), map: (_) {});
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(apiClientProvider)));
