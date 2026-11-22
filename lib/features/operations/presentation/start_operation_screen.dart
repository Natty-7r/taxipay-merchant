import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/common.dart';
import '../../fleet/data/fleet_models.dart';
import '../../fleet/presentation/fleet_providers.dart';
import '../data/operations_api.dart';
import 'operations_screen.dart';
import '../../../core/theme/app_icons.dart';

/// Taxi + one of the routes it is assigned to + driver → operation with the first trip boarding.
class StartOperationScreen extends ConsumerStatefulWidget {
  const StartOperationScreen({super.key});

  @override
  ConsumerState<StartOperationScreen> createState() => _StartOperationScreenState();
}

class _StartOperationScreenState extends ConsumerState<StartOperationScreen> {
  Taxi? _taxi;
  RouteInfo? _route;
  int? _driverId;
  String _direction = 'FORWARD';
  bool _standing = false;
  bool _busy = false;

  Future<void> _start() async {
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      final op = await ref.read(operationsApiProvider).start(
          taxiId: _taxi!.id, routeId: _route!.id, driverId: _driverId, direction: _direction, standingAllowed: _standing);
      ref.invalidate(activeOperationsProvider);
      if (mounted) context.pushReplacement('/operate/taxi/${op.taxi.id}');
    });
    if (mounted && !ok) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final taxis = (ref.watch(taxisProvider).value ?? const <Taxi>[]).where((t) => t.operational).toList();
    final routes = (ref.watch(routesProvider).value ?? const <RouteInfo>[])
        .where((r) => r.status == 'APPROVED' && (_taxi == null || r.taxis.any((t) => t.taxiId == _taxi!.id)))
        .toList();
    final drivers = (ref.watch(driversProvider).value ?? const <Driver>[]).where((d) => d.active).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.startOperation)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        DropdownButtonFormField<Taxi>(
          initialValue: _taxi,
          decoration: InputDecoration(labelText: l10n.taxi),
          items: [for (final t in taxis) DropdownMenuItem(value: t, child: Text(t.title))],
          onChanged: (t) => setState(() {
            _taxi = t;
            _route = null;
            _driverId = t?.defaultDriverId;
          }),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<RouteInfo>(
          key: ValueKey(_taxi?.id),
          initialValue: _route,
          decoration: InputDecoration(labelText: l10n.route),
          items: [for (final r in routes) DropdownMenuItem(value: r, child: Text(r.name))],
          onChanged: (r) => setState(() {
            _route = r;
            _direction = 'FORWARD';
          }),
        ),
        if (_route != null && _route!.stops.length >= 2) ...[
          const SizedBox(height: 16),
          Text(l10n.firstTripDirection, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'FORWARD', label: Text('${_route!.stops.first} → ${_route!.stops.last}')),
                ButtonSegment(value: 'REVERSE', label: Text('${_route!.stops.last} → ${_route!.stops.first}')),
              ],
              selected: {_direction},
              onSelectionChanged: (s) => setState(() => _direction = s.first),
            ),
          ),
        ],
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _standing,
          onChanged: (v) => setState(() => _standing = v),
          title: Text(l10n.allowStanding),
          subtitle: Text(l10n.allowStandingHint),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int?>(
          key: ValueKey('driver-${_taxi?.id}'),
          initialValue: _driverId,
          decoration: InputDecoration(labelText: l10n.driverOptional),
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.none)),
            for (final d in drivers) DropdownMenuItem(value: d.id, child: Text(d.fullName)),
          ],
          onChanged: (v) => setState(() => _driverId = v),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _busy || _taxi == null || _route == null ? null : _start,
          icon: const Icon(AppIcons.playArrow),
          label: Text(l10n.start),
        ),
      ]),
    );
  }
}
