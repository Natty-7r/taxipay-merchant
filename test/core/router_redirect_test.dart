import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxipay_merchant/core/router/app_router.dart';
import 'package:taxipay_merchant/features/auth/data/auth_models.dart';
import 'package:taxipay_merchant/features/auth/presentation/session_controller.dart';
import 'package:taxipay_merchant/features/merchant/data/merchant_models.dart';

Session session({String status = 'APPROVED', bool mustChangePassword = false, bool driver = false}) {
  final context = AppContext.fromJson({
    'role': driver ? 'DRIVER' : 'OWNER', 'merchantId': 7, 'businessName': 'Abebe Taxi', 'status': status,
    'setup': {'businessSetUp': status != 'DRAFT', 'approved': status == 'APPROVED', 'payoutAccount': true},
    if (driver) 'driver': {'id': 3, 'fullName': 'Kebede', 'taxiIds': [5]},
  });
  return Session(
    me: Me.fromJson({
      'id': 1, 'type': 'MERCHANT', 'fullName': 'Abebe', 'phoneNumber': '251911223344',
      'mustChangePassword': mustChangePassword, 'permissions': <String>[],
    }),
    context: context,
    merchant: driver
        ? null
        : Merchant.fromJson({
            'id': 7, 'businessName': 'Abebe Taxi', 'businessType': 'INDIVIDUAL', 'contactPerson': 'Abebe',
            'phoneNumber': '251911223344', 'status': status, 'documents': <Object>[],
          }),
  );
}

void main() {
  test('while the session loads, everything waits on the splash screen', () {
    expect(redirectFor(const AsyncLoading(), '/home'), '/splash');
    expect(redirectFor(const AsyncLoading(), '/splash'), isNull);
  });

  test('signed out: only login and register', () {
    expect(redirectFor(const AsyncData(null), '/home'), '/login');
    expect(redirectFor(const AsyncData(null), '/register'), isNull);
  });

  test('an initial password must be changed first', () {
    expect(redirectFor(AsyncData(session(mustChangePassword: true)), '/home'), '/change-password');
  });

  test('a business being set up or reviewed uses the app; home shows what is left', () {
    for (final status in ['DRAFT', 'PENDING', 'REJECTED']) {
      expect(redirectFor(AsyncData(session(status: status)), '/login'), '/home', reason: status);
      expect(redirectFor(AsyncData(session(status: status)), '/fleet'), isNull, reason: status);
      expect(redirectFor(AsyncData(session(status: status)), '/setup/business'), isNull, reason: status);
      expect(redirectFor(AsyncData(session(status: status)), '/status'), isNull, reason: status);
    }
  });

  test('a suspended business stays on the status screen', () {
    expect(redirectFor(AsyncData(session(status: 'SUSPENDED')), '/fleet'), '/status');
    expect(redirectFor(AsyncData(session(status: 'SUSPENDED', driver: true)), '/operate'), '/status');
    expect(redirectFor(AsyncData(session(status: 'SUSPENDED')), '/status'), isNull);
  });

  test('an approved merchant goes home and can use the app', () {
    expect(redirectFor(AsyncData(session()), '/login'), '/home');
    expect(redirectFor(AsyncData(session()), '/operate/taxi/3'), isNull);
  });

  test('a driver only operates: Operate and More', () {
    final driver = AsyncData(session(driver: true));
    expect(redirectFor(driver, '/login'), '/operate');
    expect(redirectFor(driver, '/home'), '/operate');
    expect(redirectFor(driver, '/fleet'), '/operate');
    expect(redirectFor(driver, '/payments'), '/operate');
    expect(redirectFor(driver, '/operate/taxi/5'), isNull);
    expect(redirectFor(driver, '/operate/start'), isNull);
    expect(redirectFor(driver, '/more/notifications'), isNull);
  });
}
