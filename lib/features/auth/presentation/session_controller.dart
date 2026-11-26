import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json.dart';
import '../../merchant/data/merchant_api.dart';
import '../../merchant/data/merchant_models.dart';
import '../data/auth_api.dart';
import '../data/auth_models.dart';

/// Who is signed in: the user, whether they are the owner or a driver, and (for the owner) the business.
class Session {
  Session({required this.me, required this.context, this.merchant});

  final Me me;

  /// Role and setup checklist; drives the reminders and what a driver can reach.
  final AppContext context;

  /// The full business profile; only the owner reads it.
  final Merchant? merchant;

  bool get isDriver => context.isDriver;

  String get businessName => merchant?.businessName ?? context.businessName;
}

/// Sign-in state for the whole app. `null` = signed out.
class SessionController extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() async {
    ref.read(apiClientProvider).onSessionExpired = () {
      appLogger.i('Session expired — signing out');
      state = const AsyncData(null);
    };
    final token = await ref.read(tokenStorageProvider).accessToken();
    if (token == null) return null;
    try {
      return await _load();
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await ref.read(tokenStorageProvider).clear();
        return null;
      }
      rethrow;
    }
  }

  Future<void> login(String identifier, String password) async {
    final tokens = await ref.read(authApiProvider).login(identifier, password);
    await _signedIn(tokens);
  }

  Future<void> register(Json request) async {
    final tokens = await ref.read(authApiProvider).register(request);
    await _signedIn(tokens);
  }

  Future<void> changePassword(String current, String next) async {
    final tokens = await ref.read(authApiProvider).changePassword(current, next);
    await _signedIn(tokens);
  }

  /// Re-read user and business (e.g. after an approval notification or a profile change).
  Future<void> reload() async {
    state = await AsyncValue.guard(_load);
  }

  Future<void> logout() async {
    final storage = ref.read(tokenStorageProvider);
    final refresh = await storage.refreshToken();
    if (refresh != null) {
      try {
        await ref.read(authApiProvider).logout(refresh);
      } catch (e) {
        appLogger.w('Logout call failed (signing out locally anyway): $e');
      }
    }
    await storage.clear();
    state = const AsyncData(null);
  }

  Future<void> _signedIn(AuthTokens tokens) async {
    await ref.read(tokenStorageProvider).save(access: tokens.accessToken, refresh: tokens.refreshToken);
    state = AsyncData(await _load());
  }

  Future<Session> _load() async {
    final me = await ref.read(authApiProvider).me();
    final context = await ref.read(merchantApiProvider).context();
    final merchant = context.isDriver ? null : await ref.read(merchantApiProvider).profile();
    appLogger.i('Signed in as user ${me.id} (${context.isDriver ? 'driver' : 'owner'}), merchant ${context.merchantId} '
        '(${context.status.name})');
    return Session(me: me, context: context, merchant: merchant);
  }
}

final sessionProvider = AsyncNotifierProvider<SessionController, Session?>(SessionController.new);
