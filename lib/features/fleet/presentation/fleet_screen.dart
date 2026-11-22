import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import 'fleet_providers.dart';

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
            onPressed: () {
              final tab = DefaultTabController.of(context).index;
              context.push(['/fleet/taxis/new', '/fleet/drivers/new', '/fleet/routes/new'][tab]);
            },
            child: const Icon(Icons.add_rounded, size: 28),
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
            ? EmptyView(icon: Icons.local_taxi, message: context.l10n.addTaxi)
            : ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 96), children: [
                ListCard(children: [
                  for (final t in taxis)
                    EntityRow(
                      icon: Icons.local_taxi,
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
            ? EmptyView(icon: Icons.badge, message: context.l10n.addDriver)
            : ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 96), children: [
                ListCard(children: [
                  for (final d in drivers)
                    EntityRow(
                      icon: Icons.badge_outlined,
                      title: d.fullName,
                      subtitle: '${d.phoneNumber} · ${d.licenseNumber}',
                      trailing: d.licenseExpired
                          ? Tooltip(message: context.l10n.licenseExpired, child: const Icon(Icons.warning_amber_rounded, color: AppTheme.warning))
                          : (d.active ? null : const StatusChip('INACTIVE')),
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
            ? EmptyView(icon: Icons.alt_route, message: context.l10n.addRoute)
            : ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 96), children: [
                ListCard(children: [
                  for (final r in routes)
                    EntityRow(
                      icon: Icons.alt_route,
                      title: r.name,
                      subtitle: r.stops.join(' → '),
                      trailing: StatusChip(r.status),
                      onTap: () => context.push('/fleet/routes/${r.id}'),
                    ),
                ]),
              ]),
      );
}
