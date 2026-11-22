import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/session_controller.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/fleet/presentation/add_driver_screen.dart';
import '../../features/fleet/presentation/add_taxi_screen.dart';
import '../../features/fleet/presentation/fleet_screen.dart';
import '../../features/fleet/presentation/route_screens.dart';
import '../../features/fleet/presentation/taxi_detail_screen.dart';
import '../../features/inbox/presentation/inbox_screen.dart';
import '../../features/merchant/presentation/approval_status_screen.dart';
import '../../features/merchant/presentation/dashboard_screen.dart';
import '../../features/operations/presentation/live_taxi_screen.dart';
import '../../features/operations/presentation/operations_screen.dart';
import '../../features/operations/presentation/start_operation_screen.dart';
import '../../features/payments/presentation/payments_screen.dart';
import '../../features/settings/presentation/more_screen.dart';
import '../widgets/common.dart';

/// Where a session is allowed to be. Pure, so it is unit-tested on its own.
String? redirectFor(AsyncValue<Session?> session, String location) {
  const public = {'/login', '/register'};
  if (session.isLoading && !session.hasValue) return location == '/splash' ? null : '/splash';
  final s = session.value;
  if (s == null) return public.contains(location) ? null : '/login';
  if (s.me.mustChangePassword) return location == '/change-password' ? null : '/change-password';
  if (!s.merchant.approved) return location == '/status' ? null : '/status';
  if (public.contains(location) || const {'/splash', '/status', '/change-password'}.contains(location)) return '/home';
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<AsyncValue<Session?>>(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(refresh.value, state.matchedLocation),
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/change-password', builder: (_, _) => const ChangePasswordScreen()),
      GoRoute(path: '/status', builder: (_, _) => const ApprovalStatusScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const DashboardScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/operate', builder: (_, _) => const OperationsScreen(), routes: [
              GoRoute(path: 'start', builder: (_, _) => const StartOperationScreen()),
              GoRoute(path: 'taxi/:id', builder: (_, s) => LiveTaxiScreen(taxiId: int.parse(s.pathParameters['id']!))),
            ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/fleet', builder: (_, _) => const FleetScreen(), routes: [
              GoRoute(path: 'taxis/new', builder: (_, _) => const AddTaxiScreen()),
              GoRoute(path: 'taxis/:id', builder: (_, s) => TaxiDetailScreen(taxiId: int.parse(s.pathParameters['id']!))),
              GoRoute(path: 'drivers/new', builder: (_, _) => const AddDriverScreen()),
              GoRoute(path: 'routes/new', builder: (_, _) => const AddRouteScreen()),
              GoRoute(path: 'routes/:id', builder: (_, s) => RouteDetailScreen(routeId: int.parse(s.pathParameters['id']!))),
            ]),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/payments', builder: (_, _) => const PaymentsScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (_, _) => const MoreScreen(), routes: [
              GoRoute(path: 'notifications', builder: (_, _) => const InboxScreen()),
            ]),
          ]),
        ],
      ),
    ],
  );
});

class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: l10n.tabHome),
          NavigationDestination(icon: const Icon(Icons.local_taxi_outlined), selectedIcon: const Icon(Icons.local_taxi), label: l10n.tabOperate),
          NavigationDestination(icon: const Icon(Icons.garage_outlined), selectedIcon: const Icon(Icons.garage), label: l10n.tabFleet),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: l10n.tabPayments),
          NavigationDestination(icon: const Icon(Icons.menu), label: l10n.tabMore),
        ],
      ),
    );
  }
}
