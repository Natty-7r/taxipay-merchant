import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taxipay_merchant/core/localization.dart';
import 'package:taxipay_merchant/features/auth/presentation/login_screen.dart';
import 'package:taxipay_merchant/features/auth/presentation/session_controller.dart';
import 'package:taxipay_merchant/l10n/app_localizations.dart';

/// Records the login instead of calling the API.
class _FakeSession extends SessionController {
  final calls = <(String, String)>[];

  @override
  Future<Session?> build() async => null;

  @override
  Future<void> login(String identifier, String password) async => calls.add((identifier, password));
}

void main() {
  Future<_FakeSession> pump(WidgetTester tester, {Locale locale = const Locale('en')}) async {
    final fake = _FakeSession();
    await tester.pumpWidget(ProviderScope(
      overrides: [sessionProvider.overrideWith(() => fake)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    return fake;
  }

  testWidgets('both fields are required', (tester) async {
    final fake = await pump(tester);
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pump();
    expect(find.text('Required'), findsNWidgets(2));
    expect(fake.calls, isEmpty);
  });

  testWidgets('submits the identifier and password', (tester) async {
    final fake = await pump(tester);
    await tester.enterText(find.byKey(const Key('login.identifier')), '0911223344');
    await tester.enterText(find.byKey(const Key('login.password')), 'Merchant@123');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pump();
    expect(fake.calls, [('0911223344', 'Merchant@123')]);
  });

  testWidgets('speaks Amharic', (tester) async {
    await pump(tester, locale: const Locale('am'));
    expect(find.text('ግባ'), findsOneWidget);
  });
}
