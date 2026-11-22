import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../data/fleet_api.dart';
import '../data/fleet_models.dart';
import 'fleet_providers.dart';

class RouteDetailScreen extends ConsumerWidget {
  const RouteDetailScreen({super.key, required this.routeId});

  final int routeId;

  Future<void> _assign(BuildContext context, WidgetRef ref, RouteInfo route) async {
    final taxis = await ref.read(fleetApiProvider).taxis(status: 'APPROVED');
    final assigned = route.taxis.map((t) => t.taxiId).toSet();
    final candidates = taxis.where((t) => t.operational && !assigned.contains(t.id)).toList();
    if (!context.mounted) return;
    final taxi = await showModalBottomSheet<Taxi>(
      context: context,
      builder: (context) => SafeArea(
        child: candidates.isEmpty
            ? Padding(padding: const EdgeInsets.all(24), child: Text(context.l10n.empty))
            : ListView(shrinkWrap: true, children: [
                for (final t in candidates)
                  ListTile(leading: const Icon(Icons.local_taxi), title: Text(t.title), onTap: () => Navigator.pop(context, t)),
              ]),
      ),
    );
    if (taxi == null || !context.mounted) return;
    final ok = await runAction(context, () => ref.read(fleetApiProvider).assignTaxi(routeId, taxi.id));
    if (ok) ref.invalidate(routeProvider(routeId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final route = ref.watch(routeProvider(routeId));
    return Scaffold(
      appBar: AppBar(title: Text(route.value?.name ?? l10n.route)),
      body: AsyncBody(
        value: route,
        onRefresh: () => ref.refresh(routeProvider(routeId).future),
        builder: (r) => ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Expanded(child: Text(r.stops.join(' → '), style: Theme.of(context).textTheme.titleMedium)),
            StatusChip(r.status),
          ]),
          if (r.statusReason != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('${l10n.reason}: ${r.statusReason}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          Text(l10n.journeysAndFares, style: Theme.of(context).textTheme.titleSmall),
          for (final s in r.subRoutes)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(s.direction == 'FORWARD' ? Icons.arrow_forward : Icons.arrow_back),
              title: Text('${s.fromName} → ${s.toName}'),
              trailing: Text(s.fare == null ? l10n.farePending : money(s.fare)),
            ),
          const Divider(height: 24),
          Text(l10n.taxis, style: Theme.of(context).textTheme.titleSmall),
          if (r.taxis.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.empty)),
          for (final t in r.taxis)
            ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.local_taxi), title: Text(t.plateNumber)),
          const SizedBox(height: 16),
          if (r.editable)
            FilledButton(
              onPressed: () async {
                final ok = await runAction(context, () => ref.read(fleetApiProvider).submitRoute(routeId));
                if (ok) {
                  ref.invalidate(routeProvider(routeId));
                  ref.invalidate(routesProvider);
                }
              },
              child: Text(l10n.submitForApproval),
            ),
          if (r.status == 'APPROVED')
            OutlinedButton.icon(onPressed: () => _assign(context, ref, r), icon: const Icon(Icons.add), label: Text(l10n.assignTaxi)),
        ]),
      ),
    );
  }
}

class AddRouteScreen extends ConsumerStatefulWidget {
  const AddRouteScreen({super.key});

  @override
  ConsumerState<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends ConsumerState<AddRouteScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final List<TextEditingController> _stops = [TextEditingController(), TextEditingController()];
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    for (final s in _stops) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      final route = await ref.read(fleetApiProvider).createRoute({
        'name': _name.text.trim(),
        'points': [for (final s in _stops) {'name': s.text.trim()}],
      });
      ref.invalidate(routesProvider);
      if (mounted) context.pushReplacement('/fleet/routes/${route.id}');
    });
    if (mounted && !ok) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addRoute)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(controller: _name, decoration: InputDecoration(labelText: l10n.routeName, hintText: 'Addis Ababa – Adama'),
              validator: (v) => requiredValidator(context, v)),
          const SizedBox(height: 16),
          Text(l10n.stops, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (var i = 0; i < _stops.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                CircleAvatar(radius: 14, child: Text('${i + 1}', style: const TextStyle(fontSize: 12))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _stops[i], decoration: InputDecoration(labelText: l10n.stopName),
                    validator: (v) => requiredValidator(context, v))),
                if (_stops.length > 2)
                  IconButton(icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setState(() => _stops.removeAt(i).dispose())),
              ]),
            ),
          TextButton.icon(
            onPressed: () => setState(() => _stops.add(TextEditingController())),
            icon: const Icon(Icons.add),
            label: Text(l10n.addStop),
          ),
          const SizedBox(height: 8),
          Text(l10n.routeInfo, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
        ]),
      ),
    );
  }
}
