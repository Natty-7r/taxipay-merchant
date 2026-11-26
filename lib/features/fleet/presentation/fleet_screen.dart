import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import '../../merchant/presentation/setup_guard.dart';
import 'fleet_providers.dart';
import '../../../core/theme/app_icons.dart';

/// Taxis, drivers and routes in three tabs.
class FleetScreen extends ConsumerWidget {
  const FleetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.tabFleet),
            bottom: TabBar(tabs: [Tab(text: l10n.taxis), Tab(text: l10n.drivers), Tab(text: l10n.routes)]),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final tab = DefaultTabController.of(context).index;
              // Taxis and routes need an approved business; drivers only a set-up one.
              if (!await ensureSetup(context, ref, needsApproval: tab != 1) || !context.mounted) return;
              context.push(['/fleet/taxis/new', '/fleet/drivers/new', '/fleet/routes/new'][tab]);
            },
            child: const Icon(AppIcons.addRounded, size: 28),
          ),
          body: const TabBarView(children: [_TaxisTab(), _DriversTab(), _RoutesTab()]),
        );
      }),
    );
  }
}

class _TaxisTab extends ConsumerWidget {
  const _TaxisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncBody(
        value: ref.watch(taxisProvider),
        onRefresh: () => ref.refresh(taxisProvider.future),
        builder: (taxis) => taxis.isEmpty
            ? EmptyView(icon: AppIcons.localTaxi, message: context.l10n.addTaxi)
            : ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 96), children: [
                ListCard(children: [
                  for (final t in taxis)
                    EntityRow(
                      icon: AppIcons.localTaxi,
                      title: t.title,
                      subtitle: '${t.manufacturer} ${t.model} · ${t.capacity} ${context.l10n.seats}',
                      trailing: StatusChip(t.status == 'APPROVED' && !t.active ? 'INACTIVE' : t.status),
                      onTap: () => context.push('/fleet/taxis/${t.id}'),
                    ),
                ]),
              ]),
      );
}

class _DriversTab extends ConsumerWidget {
  const _DriversTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncBody(
        value: ref.watch(driversProvider),
        onRefresh: () => ref.refresh(driversProvider.future),
        builder: (drivers) => drivers.isEmpty
            ? EmptyView(icon: AppIcons.badge, message: context.l10n.addDriver)
            : ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 96), children: [
                ListCard(children: [
                  for (final d in drivers)
                    EntityRow(
                      icon: AppIcons.badgeOutlined,
                      title: d.fullName,
                      subtitle: '${d.phoneNumber} · ${d.licenseNumber}'
                          '${d.taxiIds.isEmpty ? '' : ' · ${d.taxiIds.length} ${context.l10n.taxis.toLowerCase()}'}',
                      onTap: () => context.push('/fleet/drivers/${d.id}', extra: d),
                      trailing: d.licenseExpired
                          ? Tooltip(message: context.l10n.licenseExpired, child: const Icon(AppIcons.warningAmberRounded, color: AppTheme.warning))
                          : !d.active
                              ? const StatusChip('INACTIVE')
                              : d.canLogin
                                  ? Tooltip(message: context.l10n.canSignIn, child: const Icon(AppIcons.keyRound, color: AppTheme.blue, size: 20))
                                  : null,
                    ),
                ]),
              ]),
      );
}

class _RoutesTab extends ConsumerWidget {
  const _RoutesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncBody(
        value: ref.watch(routesProvider),
        onRefresh: () => ref.refresh(routesProvider.future),
        builder: (routes) => routes.isEmpty
            ? EmptyView(icon: AppIcons.altRoute, message: context.l10n.addRoute)
            : ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 96), children: [
                ListCard(children: [
                  for (final r in routes)
                    EntityRow(
                      icon: AppIcons.altRoute,
                      title: r.name,
                      subtitle: r.stops.join(' → '),
                      trailing: StatusChip(r.status),
                      onTap: () => context.push('/fleet/routes/${r.id}'),
                    ),
                ]),
              ]),
      );
}
