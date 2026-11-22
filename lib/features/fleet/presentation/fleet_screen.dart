import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/common.dart';
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
            child: const Icon(Icons.add),
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
            : ListView.separated(
                itemCount: taxis.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final t = taxis[i];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.local_taxi)),
                    title: Text(t.title),
                    subtitle: Text('${t.manufacturer} ${t.model} · ${t.capacity} ${context.l10n.seats}'),
                    trailing: StatusChip(t.status == 'APPROVED' && !t.active ? 'INACTIVE' : t.status),
                    onTap: () => context.push('/fleet/taxis/${t.id}'),
                  );
                },
              ),
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
            : ListView.separated(
                itemCount: drivers.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final d = drivers[i];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(d.fullName),
                    subtitle: Text('${d.phoneNumber} · ${d.licenseNumber}'),
                    trailing: d.licenseExpired
                        ? Tooltip(message: context.l10n.licenseExpired, child: const Icon(Icons.warning, color: Colors.orange))
                        : (d.active ? null : const StatusChip('INACTIVE')),
                  );
                },
              ),
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
            : ListView.separated(
                itemCount: routes.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = routes[i];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.alt_route)),
                    title: Text(r.name),
                    subtitle: Text(r.stops.join(' → ')),
                    trailing: StatusChip(r.status),
                    onTap: () => context.push('/fleet/routes/${r.id}'),
                  );
                },
              ),
      );
}
