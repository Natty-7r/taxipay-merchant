import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxipay_merchant/core/router/app_router.dart';
import 'package:taxipay_merchant/features/auth/data/auth_models.dart';
import 'package:taxipay_merchant/features/auth/presentation/session_controller.dart';
import 'package:taxipay_merchant/features/merchant/data/merchant_models.dart';

Session session({String status = 'APPROVED', bool mustChangePassword = false}) => Session(
      me: Me.fromJson({
        'id': 1, 'type': 'MERCHANT', 'fullName': 'Abebe', 'phoneNumber': '251911223344',
        'mustChangePassword': mustChangePassword, 'permissions': <String>[],
      }),
      merchant: Merchant.fromJson({
        'id': 7, 'businessName': 'Abebe Taxi', 'businessType': 'INDIVIDUAL', 'tin': '0012345678',
        'contactPerson': 'Abebe', 'phoneNumber': '251911223344', 'city': 'Addis Ababa', 'status': status,
        'documents': <Object>[],
      }),
    );

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

  test('pending, rejected and suspended businesses stay on the status screen', () {
    for (final status in ['PENDING', 'REJECTED', 'SUSPENDED']) {
      expect(redirectFor(AsyncData(session(status: status)), '/fleet'), '/status', reason: status);
      expect(redirectFor(AsyncData(session(status: status)), '/status'), isNull, reason: status);
    }
  });

  test('an approved merchant goes home and can use the app', () {
    expect(redirectFor(AsyncData(session()), '/login'), '/home');
    expect(redirectFor(AsyncData(session()), '/status'), '/home');
    expect(redirectFor(AsyncData(session()), '/operate/taxi/3'), isNull);
  });
}
