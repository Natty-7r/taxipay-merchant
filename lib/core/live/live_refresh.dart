import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/fleet/presentation/fleet_providers.dart';
import '../../features/inbox/presentation/inbox_screen.dart';
import '../../features/merchant/presentation/dashboard_screen.dart';
import '../../features/operations/presentation/live_taxi_screen.dart';
import '../../features/operations/presentation/operations_screen.dart';
import '../../features/payments/presentation/payments_screen.dart';

/// Reloads what an event can change. Screens that are open fetch again at once; the others the
/// next time they are shown.
void refreshFor(WidgetRef ref, String event) {
  ref.invalidate(unreadCountProvider);
  ref.invalidate(inboxProvider);
  switch (event) {
    case 'PAYMENT_RECEIVED':
      ref.invalidate(dashboardProvider);
      ref.invalidate(liveTaxiProvider);
      ref.invalidate(activeOperationsProvider);
      ref.invalidate(paymentsProvider);
    case 'ROUTE_APPROVED' || 'ROUTE_REJECTED' || 'FARE_CHANGE_APPROVED' || 'FARE_CHANGE_REJECTED':
      ref.invalidate(routesProvider);
      ref.invalidate(routeProvider);
      ref.invalidate(taxiRoutesProvider);
      ref.invalidate(dashboardProvider);
    case 'TAXI_APPROVED' || 'TAXI_REJECTED':
      ref.invalidate(taxisProvider);
      ref.invalidate(taxiProvider);
      ref.invalidate(taxiQrProvider);
      ref.invalidate(dashboardProvider);
    default:
      ref.invalidate(dashboardProvider);
  }
}

/// Everything — after coming back to the app.
void refreshAll(WidgetRef ref) {
  for (final e in ['PAYMENT_RECEIVED', 'ROUTE_APPROVED', 'TAXI_APPROVED']) {
    refreshFor(ref, e);
  }
}
