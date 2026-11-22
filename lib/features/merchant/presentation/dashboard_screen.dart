import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import '../../auth/presentation/session_controller.dart';
import '../../inbox/presentation/inbox_screen.dart';
import '../../operations/presentation/operations_screen.dart';
import '../../payments/presentation/payments_screen.dart';
import '../data/merchant_api.dart';
import '../data/merchant_models.dart';
import '../../../core/theme/app_icons.dart';

final dashboardProvider = FutureProvider.autoDispose<Dashboard>((ref) => ref.watch(merchantApiProvider).dashboard());

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider).value;
    final fullName = session?.me.fullName ?? '';
    final firstName = fullName.trim().split(RegExp(r'\s+')).first;
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    final operations = ref.watch(activeOperationsProvider);
    final payments = ref.watch(paymentsProvider(null));

    Future<void> refresh() async {
      ref.invalidate(dashboardProvider);
      ref.invalidate(activeOperationsProvider);
      ref.invalidate(unreadCountProvider);
      ref.invalidate(paymentsProvider(null));
      await ref.read(dashboardProvider.future);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncBody(
          value: ref.watch(dashboardProvider),
          onRefresh: refresh,
          builder: (d) => ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
            GreetingHeader(
              name: fullName,
              title: l10n.hello(firstName),
              subtitle: session?.merchant.businessName ?? '',
              trailing: CircleIconButton(
                icon: AppIcons.notificationsNoneRounded,
                badge: unread,
                tooltip: l10n.notifications,
                onPressed: () => context.push('/more/notifications'),
              ),
            ),
            const SizedBox(height: 22),
            HeroCard(
              label: l10n.totalCollected,
              value: amount(d.revenue),
              unit: 'ETB',
              caption: l10n.fromPassengers(d.passengers),
              footer: Row(children: [
                Expanded(child: HeroStat(value: '${d.completedTrips}', label: l10n.completedTrips)),
                Expanded(child: HeroStat(value: '${d.activeTaxis}/${d.totalTaxis}', label: l10n.activeTaxis)),
              ]),
            ),
            if (d.pendingTaxis > 0) ...[
              const SizedBox(height: 14),
              SoftCard(
                onTap: () => context.go('/fleet'),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  const Icon(AppIcons.hourglassTopRounded, color: AppTheme.warning),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${d.pendingTaxis} · ${l10n.pendingTaxis}', style: const TextStyle(fontWeight: FontWeight.w700))),
                  const Icon(AppIcons.chevronRight),
                ]),
              ),
            ],
            SectionLabel(l10n.yourFleet),
            TwoUp(
              MetricTile(icon: AppIcons.localTaxiOutlined, value: '${d.totalTaxis}', label: l10n.taxis, onTap: () => context.go('/fleet')),
              MetricTile(icon: AppIcons.badgeOutlined, value: '${d.drivers}', label: l10n.drivers, onTap: () => context.go('/fleet')),
            ),
            const SizedBox(height: 12),
            TwoUp(
              MetricTile(icon: AppIcons.altRoute, value: '${d.approvedRoutes}', label: l10n.approvedRoutes, onTap: () => context.go('/fleet')),
              MetricTile(icon: AppIcons.groupsOutlined, value: '${d.passengers}', label: l10n.passengers, onTap: () => context.go('/payments')),
            ),
            SectionLabel(l10n.onTheRoad, action: l10n.start, onAction: () => context.push('/operate/start')),
            switch (operations) {
              AsyncData(:final value) when value.isEmpty => SoftCard(
                  child: Row(children: [
                    const IconTile(AppIcons.localTaxi),
                    const SizedBox(width: 14),
                    Expanded(child: Text(l10n.noActiveOperations)),
                  ]),
                ),
              AsyncData(:final value) => ListCard(children: [for (final op in value) OperationTile(op)]),
              AsyncError(:final error) => AppErrorCard(error: error, onRetry: () => ref.invalidate(activeOperationsProvider)),
              _ => const LinearProgressIndicator(),
            },
            SectionLabel(l10n.recentPayments, action: l10n.seeAll, onAction: () => context.go('/payments')),
            switch (payments) {
              AsyncData(:final value) when value.isEmpty => SoftCard(child: Text(l10n.noPaymentsYet)),
              AsyncData(:final value) => ListCard(children: [
                  for (var i = 0; i < value.length && i < 5; i++) PaymentRow(value[i], highlight: i == 0),
                ]),
              AsyncError(:final error) => AppErrorCard(error: error, onRetry: () => ref.invalidate(paymentsProvider(null))),
              _ => const LinearProgressIndicator(),
            },
          ]),
        ),
      ),
    );
  }
}
