import '../../../core/utils/json.dart';

/// The logged-in user (`GET /api/auth/me`).
class Me {
  Me({
    required this.id,
    required this.type,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    required this.preferredLanguage,
    required this.marketingOptIn,
    required this.telegramLinked,
    required this.mustChangePassword,
    required this.permissions,
  });

  final int id;
  final String type;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String preferredLanguage;
  final bool marketingOptIn;
  final bool telegramLinked;
  final bool mustChangePassword;
  final Set<String> permissions;

  factory Me.fromJson(Json j) => Me(
        id: (j['id'] as num).toInt(),
        type: j['type'] as String,
        fullName: j['fullName'] as String,
        phoneNumber: j['phoneNumber'] as String,
        email: j['email'] as String?,
        preferredLanguage: (j['preferredLanguage'] as String?) ?? 'en',
        marketingOptIn: (j['marketingOptIn'] as bool?) ?? true,
        telegramLinked: (j['telegramLinked'] as bool?) ?? false,
        mustChangePassword: (j['mustChangePassword'] as bool?) ?? false,
        permissions: ((j['permissions'] as List?) ?? const []).map((e) => e as String).toSet(),
      );
}

class AuthTokens {
  AuthTokens({required this.accessToken, required this.refreshToken, required this.user});

  final String accessToken;
  final String refreshToken;
  final Me user;

  factory AuthTokens.fromJson(Json j) => AuthTokens(
        accessToken: j['accessToken'] as String,
        refreshToken: j['refreshToken'] as String,
        user: Me.fromJson(j['user'] as Json),
      );
}
