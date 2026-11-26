import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/session_controller.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/fleet/data/fleet_models.dart';
import '../../features/fleet/presentation/add_driver_screen.dart';
import '../../features/fleet/presentation/add_taxi_screen.dart';
import '../../features/fleet/presentation/edit_seats_screen.dart';
import '../../features/fleet/presentation/fleet_screen.dart';
import '../../features/fleet/presentation/qr_poster_screen.dart';
import '../../features/fleet/presentation/route_screens.dart';
import '../../features/fleet/presentation/taxi_detail_screen.dart';
import '../../features/inbox/presentation/inbox_screen.dart';
import '../../features/merchant/data/merchant_models.dart';
import '../../features/merchant/presentation/approval_status_screen.dart';
import '../../features/merchant/presentation/business_setup_screen.dart';
import '../../features/merchant/presentation/payout_screen.dart';
import '../../features/merchant/presentation/dashboard_screen.dart';
import '../../features/operations/presentation/live_taxi_screen.dart';
import '../../features/operations/presentation/operations_screen.dart';
import '../../features/operations/presentation/start_operation_screen.dart';
import '../live/live_banner.dart';
import '../live/live_events.dart';
import '../live/live_refresh.dart';
import '../push/push_service.dart';
import '../widgets/app_bottom_bar.dart';
import '../../features/payments/presentation/payments_screen.dart';
import '../../features/settings/presentation/more_screen.dart';
import '../widgets/common.dart';
import '../theme/app_icons.dart';

/// Where a session is allowed to be. Pure, so it is unit-tested on its own.
String? redirectFor(AsyncValue<Session?> session, String location) {
  const public = {'/login', '/register'};
  if (session.isLoading && !session.hasValue) return location == '/splash' ? null : '/splash';
  final s = session.value;
  if (s == null) return public.contains(location) ? null : '/login';
  if (s.me.mustChangePassword) return location == '/change-password' ? null : '/change-password';
  // A suspended business is locked out; otherwise the owner sets things up from home (reminders).
  if (s.context.status == MerchantStatus.suspended) return location == '/status' ? null : '/status';
  final home = s.isDriver ? '/operate' : '/home';
  if (public.contains(location) || const {'/splash', '/change-password'}.contains(location)) return home;
  if (s.isDriver) {
    // Drivers run their taxis: Operate and More only.
    const driverAreas = ['/operate', '/more'];
    if (!driverAreas.any((a) => location == a || location.startsWith('$a/'))) return home;
  }
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
      GoRoute(path: '/setup/business', builder: (_, _) => const BusinessSetupScreen()),
      GoRoute(path: '/setup/payout', builder: (_, _) => const PayoutScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const DashboardScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/operate', builder: (_, _) => const OperationsScreen(), routes: [
              GoRoute(path: 'start', builder: (_, s) => StartOperationScreen(taxiId: int.tryParse(s.uri.queryParameters['taxi'] ?? ''))),
              GoRoute(path: 'taxi/:id', builder: (_, s) => LiveTaxiScreen(taxiId: int.parse(s.pathParameters['id']!))),
            ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/fleet', builder: (_, _) => const FleetScreen(), routes: [
              GoRoute(path: 'taxis/new', builder: (_, _) => const AddTaxiScreen()),
              GoRoute(
                path: 'taxis/:id',
                builder: (_, s) => TaxiDetailScreen(taxiId: int.parse(s.pathParameters['id']!)),
                routes: [
                  GoRoute(path: 'qr', builder: (_, s) => QrPosterScreen(taxiId: int.parse(s.pathParameters['id']!))),
                  GoRoute(path: 'seats', builder: (_, s) => EditSeatsScreen(taxiId: int.parse(s.pathParameters['id']!))),
                  GoRoute(path: 'edit', builder: (_, s) => AddTaxiScreen(initial: s.extra as Taxi?)),
                ],
              ),
              GoRoute(path: 'drivers/new', builder: (_, _) => const AddDriverScreen()),
              GoRoute(path: 'drivers/:id', builder: (_, s) => AddDriverScreen(initial: s.extra as Driver?)),
              GoRoute(path: 'routes/new', builder: (_, _) => const AddRouteScreen()),
              GoRoute(
                path: 'routes/:id',
                builder: (_, s) => RouteDetailScreen(routeId: int.parse(s.pathParameters['id']!)),
                routes: [
                  GoRoute(path: 'prices', builder: (_, s) => RoutePricesScreen(routeId: int.parse(s.pathParameters['id']!))),
                  GoRoute(path: 'edit', builder: (_, s) => AddRouteScreen(initial: s.extra as RouteInfo?)),
                ],
              ),
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

class _HomeShell extends ConsumerWidget {
  const _HomeShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDriver = ref.watch(sessionProvider).value?.isDriver ?? false;
    // Something happened (a payment, a review): reload what it touches and say so.
    ref.listen(liveEventsProvider, (_, event) {
      if (event == null) return;
      refreshFor(ref, event.event);
      showLiveBanner(context, event);
    });
    // A tapped push notification waiting for the app to be ready.
    ref.listen(pendingLinkProvider, (_, link) {
      if (link == null) return;
      ref.read(pendingLinkProvider.notifier).take();
      openLink(context, link);
    });
    return Scaffold(
      body: LiveEventsLifecycle(child: shell),
      bottomNavigationBar: AppBottomBar(
        currentIndex: shell.currentIndex,
        onSelect: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        // Display order: Home, Fleet, [Operate], Payments, More — branch indices stay as declared.
        items: isDriver
            ? [
                BottomBarItem(branch: 1, icon: AppIcons.localTaxi, activeIcon: AppIcons.localTaxi, label: l10n.tabOperate),
                BottomBarItem(branch: 4, icon: AppIcons.personOutline, activeIcon: AppIcons.person, label: l10n.tabMore),
              ]
            : [
          BottomBarItem(branch: 0, icon: AppIcons.homeOutlined, activeIcon: AppIcons.homeRounded, label: l10n.tabHome),
          BottomBarItem(branch: 2, icon: AppIcons.garageOutlined, activeIcon: AppIcons.garageRounded, label: l10n.tabFleet),
          BottomBarItem(branch: 3, icon: AppIcons.receiptLongOutlined, activeIcon: AppIcons.receiptLong, label: l10n.tabPayments),
          BottomBarItem(branch: 4, icon: AppIcons.personOutline, activeIcon: AppIcons.person, label: l10n.tabMore),
        ],
        center: isDriver ? null : BottomBarItem(branch: 1, icon: AppIcons.localTaxi, activeIcon: AppIcons.localTaxi, label: l10n.tabOperate),
      ),
    );
  }
}
