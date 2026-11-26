import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/common.dart';
import '../../auth/presentation/session_controller.dart';
import '../../fleet/data/fleet_models.dart';
import '../../fleet/presentation/fleet_providers.dart';
import '../data/operation_models.dart';
import '../data/operations_api.dart';
import 'operations_screen.dart';
import '../../../core/theme/app_icons.dart';

/// Taxi + one of its approved routes (+ driver, for the owner) → operation with the first trip boarding.
/// A driver only sees their own taxis and always drives themselves.
class StartOperationScreen extends ConsumerStatefulWidget {
  const StartOperationScreen({super.key, this.taxiId});

  /// Preselected taxi (from the driver's taxi list).
  final int? taxiId;

  @override
  ConsumerState<StartOperationScreen> createState() => _StartOperationScreenState();
}

class _StartOperationScreenState extends ConsumerState<StartOperationScreen> {
  int? _taxiId;
  int? _routeId;
  int? _driverId;
  bool _driverTouched = false;
  String _direction = 'FORWARD';
  bool _standing = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _taxiId = widget.taxiId;
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      final op = await ref.read(operationsApiProvider).start(
          taxiId: _taxiId!, routeId: _routeId!, driverId: _driverId, direction: _direction, standingAllowed: _standing);
      ref.invalidate(activeOperationsProvider);
      ref.invalidate(operableTaxisProvider);
      if (mounted) context.pushReplacement('/operate/taxi/${op.taxi.id}');
    });
    if (mounted && !ok) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDriver = ref.watch(sessionProvider).value?.isDriver ?? false;
    final taxis = (ref.watch(operableTaxisProvider).value ?? const <OperableTaxi>[]).where((t) => t.startable).toList();
    final taxi = taxis.where((t) => t.taxiId == _taxiId).firstOrNull;
    final route = taxi?.routes.where((r) => r.id == _routeId).firstOrNull;
    final drivers = isDriver
        ? const <Driver>[]
        : (ref.watch(driversProvider).value ?? const <Driver>[]).where((d) => d.active).toList();
    final driverId = _driverTouched ? _driverId : taxi?.driver?.id;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.startOperation)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (ref.watch(operableTaxisProvider).hasValue && taxis.isEmpty) ...[
          Text(isDriver ? l10n.noAssignedTaxis : l10n.noTaxiReady),
          const SizedBox(height: 16),
        ],
        DropdownButtonFormField<int>(
          initialValue: taxi?.taxiId,
          decoration: InputDecoration(labelText: l10n.taxi),
          items: [for (final t in taxis) DropdownMenuItem(value: t.taxiId, child: Text(t.title))],
          onChanged: (id) => setState(() {
            _taxiId = id;
            _routeId = null;
            _driverTouched = false;
          }),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          key: ValueKey(_taxiId),
          initialValue: route?.id,
          decoration: InputDecoration(labelText: l10n.route),
          items: [for (final r in taxi?.routes ?? const <RouteChoice>[]) DropdownMenuItem(value: r.id, child: Text(r.name))],
          onChanged: (id) => setState(() {
            _routeId = id;
            _direction = 'FORWARD';
          }),
        ),
        if (route != null && route.origin != null && route.destination != null) ...[
          const SizedBox(height: 16),
          Text(l10n.firstTripDirection, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'FORWARD', label: Text('${route.origin} → ${route.destination}')),
                ButtonSegment(value: 'REVERSE', label: Text('${route.destination} → ${route.origin}')),
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
        if (!isDriver) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<int?>(
            key: ValueKey('driver-$_taxiId'),
            initialValue: driverId,
            decoration: InputDecoration(labelText: l10n.driverOptional),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.none)),
              for (final d in drivers) DropdownMenuItem(value: d.id, child: Text(d.fullName)),
            ],
            onChanged: (v) => setState(() {
              _driverTouched = true;
              _driverId = v;
            }),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _busy || taxi == null || route == null ? null : _start,
          icon: const Icon(AppIcons.playArrow),
          label: Text(l10n.start),
        ),
      ]),
    );
  }
}
