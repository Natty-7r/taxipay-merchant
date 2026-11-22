import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../auth/presentation/session_controller.dart';
import '../../inbox/presentation/inbox_screen.dart';
import '../../operations/presentation/operations_screen.dart';
import '../data/merchant_api.dart';
import '../data/merchant_models.dart';
import '../../../core/theme/app_theme.dart';

final dashboardProvider = FutureProvider.autoDispose<Dashboard>((ref) => ref.watch(merchantApiProvider).dashboard());

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = ref.watch(sessionProvider).value?.merchant.businessName ?? '';
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    final operations = ref.watch(activeOperationsProvider);

    Future<void> refresh() async {
      ref.invalidate(dashboardProvider);
      ref.invalidate(activeOperationsProvider);
      ref.invalidate(unreadCountProvider);
      await ref.read(dashboardProvider.future);
    }

    return Scaffold(
      appBar: AppBar(title: Text(name), actions: [
        IconButton(
          icon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.notifications)),
          tooltip: l10n.notifications,
          onPressed: () => context.push('/more/notifications'),
        ),
      ]),
      body: AsyncBody(
        value: ref.watch(dashboardProvider),
        onRefresh: refresh,
        builder: (d) => ListView(padding: const EdgeInsets.all(16), children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              StatCard(label: l10n.revenue, value: money(d.revenue), icon: Icons.payments),
              StatCard(label: l10n.passengers, value: '${d.passengers}', icon: Icons.people),
              StatCard(label: l10n.completedTrips, value: '${d.completedTrips}', icon: Icons.route),
              StatCard(label: l10n.activeTaxis, value: '${d.activeTaxis}/${d.totalTaxis}', icon: Icons.local_taxi),
            ],
          ),
          if (d.pendingTaxis > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Card(child: ListTile(
                leading: const Icon(Icons.hourglass_top, color: AppTheme.warning),
                title: Text('${d.pendingTaxis} · ${l10n.pendingTaxis}'),
                onTap: () => context.go('/fleet'),
              )),
            ),
          const SizedBox(height: 20),
          Text(l10n.onTheRoad, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          switch (operations) {
            AsyncData(:final value) when value.isEmpty => Text(l10n.noActiveOperations),
            AsyncData(:final value) => Column(children: [for (final op in value) OperationTile(op)]),
            AsyncError(:final error) => Text('$error'),
            _ => const LinearProgressIndicator(),
          },
        ]),
      ),
    );
  }
}
