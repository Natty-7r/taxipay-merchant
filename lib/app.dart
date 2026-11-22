import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/locale.dart';
import 'core/localization.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/live/live_events.dart';
import 'core/push/push_service.dart';
import 'core/theme/theme_mode.dart';
import 'features/auth/presentation/session_controller.dart';
import 'l10n/app_localizations.dart';

class TaxiPayMerchantApp extends ConsumerWidget {
  const TaxiPayMerchantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Push notifications follow the session: register after sign-in, unregister on sign-out.
    ref.listen(sessionProvider, (previous, next) {
      final wasIn = previous?.value != null;
      final isIn = next.value != null;
      if (isIn && !wasIn) ref.read(pushServiceProvider).start();
      if (!isIn && wasIn) {
        ref.read(pushServiceProvider).stop();
        ref.read(liveEventsProvider.notifier).stop();
      }
    });
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: appLocalizationsDelegates,
      debugShowCheckedModeBanner: false,
    );
  }
}
