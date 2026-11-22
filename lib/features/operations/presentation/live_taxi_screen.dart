import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../fleet/presentation/seat_grid.dart';
import '../data/operation_models.dart';
import '../data/operations_api.dart';
import 'operations_screen.dart';
import '../../../core/theme/app_icons.dart';

final liveTaxiProvider =
    FutureProvider.autoDispose.family<LiveTaxi, int>((ref, taxiId) => ref.watch(operationsApiProvider).live(taxiId));

/// The taxi right now: trip, seat map (tap to mark occupied / free) and trip controls.
/// Refreshes every 10 s so payments made by passengers show up as paid seats.
class LiveTaxiScreen extends ConsumerStatefulWidget {
  const LiveTaxiScreen({super.key, required this.taxiId});

  final int taxiId;

  @override
  ConsumerState<LiveTaxiScreen> createState() => _LiveTaxiScreenState();
}

class _LiveTaxiScreenState extends ConsumerState<LiveTaxiScreen> {
  Timer? _timer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => ref.invalidate(liveTaxiProvider(widget.taxiId)));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _act(Future<void> Function() action) async {
    setState(() => _busy = true);
    await runAction(context, action);
    ref.invalidate(liveTaxiProvider(widget.taxiId));
    ref.invalidate(activeOperationsProvider);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final live = ref.watch(liveTaxiProvider(widget.taxiId));
    final api = ref.read(operationsApiProvider);
    return Scaffold(
      appBar: AppBar(title: Text(live.value?.plateNumber ?? l10n.taxi), actions: [
        IconButton(
          tooltip: l10n.viewTaxi,
          icon: const Icon(AppIcons.infoOutline),
          onPressed: () => context.push('/fleet/taxis/${widget.taxiId}'),
        ),
      ]),
      body: AsyncBody(
        value: live,
        onRefresh: () => ref.refresh(liveTaxiProvider(widget.taxiId).future),
        builder: (t) {
          final op = t.operation;
          final trip = t.currentTrip;
          return ListView(padding: const EdgeInsets.all(16), children: [
            if (op == null)
              Text(l10n.noActiveOperations)
            else ...[
              InkWell(
                onTap: () => context.push('/fleet/routes/${op.route.id}'),
                child: Row(children: [
                  Flexible(
                    child: Text('${op.route.name ?? ''} · ${op.driver.name ?? ''}', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const Icon(AppIcons.chevronRight, size: 20),
                ]),
              ),
              const SizedBox(height: 4),
              Text('${l10n.completedTrips}: ${op.completedTrips} · ${l10n.passengers}: ${op.passengers} · ${money(op.revenue)}'),
              const SizedBox(height: 16),
              if (trip == null)
                Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(l10n.noTripOpen)))
              else
                Card(
                  child: ListTile(
                    leading: Icon(trip.boarding ? AppIcons.groups : AppIcons.directionsBus),
                    title: Text('${l10n.trip} ${trip.tripNumber}: ${trip.from} → ${trip.to}'),
                    subtitle: Text('${trip.boarding ? l10n.boarding : l10n.onTheRoadStatus} · '
                        '${trip.passengers} ${l10n.passengers} · ${money(trip.revenue)}'),
                  ),
                ),
              const SizedBox(height: 16),
              _Legend(available: t.available, unpaid: t.occupiedUnpaid, paid: t.occupiedPaid),
              const SizedBox(height: 12),
              SeatGrid(
                rows: [for (final row in t.rows) [for (final s in row) s.code]],
                sideSeats: [for (final s in t.sideSeats) s.code],
                seatBuilder: (code) {
                  final seat = t.seats.firstWhere((s) => s.code == code);
                  return SeatBox(
                    code,
                    color: switch (seat.status) {
                      SeatStatus.occupiedPaid => AppTheme.seatPaid,
                      SeatStatus.occupiedUnpaid => AppTheme.seatUnpaid,
                      SeatStatus.available => AppTheme.seatAvailable,
                    },
                    caption: seat.destination,
                    onTap: trip == null || _busy
                        ? null
                        : () => _act(() => api.setSeat(trip.id, code, seat.status == SeatStatus.available)),
                  );
                },
              ),
              if (trip != null) Text(l10n.tapSeatHint, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 20),
              if (trip != null && trip.boarding)
                FilledButton.icon(onPressed: _busy ? null : () => _act(() => api.depart(trip.id)),
                    icon: const Icon(AppIcons.playArrow), label: Text(l10n.depart)),
              if (trip != null && trip.onTheRoad) ...[
                FilledButton.icon(onPressed: _busy ? null : () => _act(() => api.complete(trip.id, openNext: true)),
                    icon: const Icon(AppIcons.swapHoriz), label: Text(l10n.completeAndReturn)),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _busy ? null : () => _act(() => api.complete(trip.id, openNext: false)),
                    child: Text(l10n.completeTrip)),
              ],
              if (trip == null)
                FilledButton.icon(onPressed: _busy ? null : () => _act(() => api.openTrip(op.id)),
                    icon: const Icon(AppIcons.add), label: Text(l10n.openNextTrip)),
              const SizedBox(height: 8),
              if (trip == null || trip.boarding)
                TextButton.icon(
                  onPressed: _busy
                      ? null
                      : () async {
                          await _act(() => api.finish(op.id));
                          if (context.mounted) context.pop();
                        },
                  icon: const Icon(AppIcons.stop),
                  label: Text(l10n.finishOperation),
                ),
            ],
          ]);
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.available, required this.unpaid, required this.paid});

  final int available, unpaid, paid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget item(Color c, String label, int n) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 14, height: 14, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 4),
          Text('$label ($n)', style: Theme.of(context).textTheme.bodySmall),
        ]);
    return Wrap(spacing: 12, runSpacing: 4, alignment: WrapAlignment.center, children: [
      item(AppTheme.seatAvailable, l10n.seatsAvailable, available),
      item(AppTheme.seatUnpaid, l10n.seatsUnpaid, unpaid),
      item(AppTheme.seatPaid, l10n.seatsPaid, paid),
    ]);
  }
}
