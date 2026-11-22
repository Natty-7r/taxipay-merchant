import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../fleet/presentation/fleet_providers.dart';
import '../../../core/widgets/ui.dart';

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
          tooltip: l10n.shareTaxiQr,
          icon: const Icon(AppIcons.qrCode2),
          onPressed: () => context.push('/fleet/taxis/${widget.taxiId}/qr'),
        ),
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
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: op.standingAllowed,
                onChanged: _busy ? null : (v) => _act(() => api.setStanding(op.id, v)),
                title: Text(l10n.allowStanding),
                subtitle: Text(l10n.allowStandingHint, style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(height: 8),
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
                        : seat.status == SeatStatus.occupiedPaid
                            // A paid seat is freed only on purpose: that passenger got off.
                            ? () => _confirmFree(context, trip.id, seat)
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
                FilledButton.icon(onPressed: _busy ? null : () => _openTrip(context, op),
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
              if (trip != null) ...[
                SectionLabel(l10n.paidOnTrip(t.payments.length)),
                if (t.payments.isEmpty)
                  SoftCard(child: Text(l10n.noPaymentsOnTrip))
                else
                  ListCard(children: [for (final p in t.payments) _PaymentTile(p)]),
              ],
            ],
          ]);
        },
      ),
    );
  }
}

extension on _LiveTaxiScreenState {
  /// "Did this passenger get off?" before freeing a paid seat.
  Future<void> _confirmFree(BuildContext context, int tripId, SeatState seat) async {
    final l10n = context.l10n;
    final yes = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l10n.freeSeatTitle(seat.code), style: Theme.of(context).textTheme.titleLarge),
            if (seat.destination != null) ...[
              const SizedBox(height: 4),
              Text('${l10n.seatsPaid} · → ${seat.destination}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 12),
            Text(l10n.freeSeatQuestion),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.freeSeat)),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          ]),
        ),
      ),
    );
    if (yes == true) await _act(() => ref.read(operationsApiProvider).setSeat(tripId, seat.code, false));
  }

  /// Open the next trip in the direction the merchant chooses.
  Future<void> _openTrip(BuildContext context, Operation op) async {
    final l10n = context.l10n;
    final stops = (await ref.read(routeProvider(op.route.id).future)).stops;
    if (!context.mounted || stops.length < 2) return;
    final direction = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l10n.nextTripDirection, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(context, 'FORWARD'), child: Text('${stops.first} → ${stops.last}')),
            const SizedBox(height: 8),
            FilledButton(onPressed: () => Navigator.pop(context, 'REVERSE'), child: Text('${stops.last} → ${stops.first}')),
          ]),
        ),
      ),
    );
    if (direction != null) await _act(() => ref.read(operationsApiProvider).openTrip(op.id, direction: direction));
  }
}

/// A payment on the trip: amount, payer, time, and each passenger (seat, from → to, on board / got off).
class _PaymentTile extends StatelessWidget {
  const _PaymentTile(this.p);

  final TripPayment p;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${money(p.amount)} · ${p.passengers}×', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text(
                [p.payerPhone, p.provider == null ? null : humanize(p.provider), shortTime(p.paidAt)].whereType<String>().join(' · '),
                style: TextStyle(color: muted, fontSize: 12.5),
              ),
            ]),
          ),
          Text(p.reference, style: TextStyle(color: muted, fontSize: 11, fontFamily: 'monospace')),
        ]),
        const SizedBox(height: 8),
        for (final tk in p.tickets)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Container(
                width: 36,
                padding: const EdgeInsets.symmetric(vertical: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tk.seatCode == null ? Colors.transparent : AppTheme.lightYellow,
                  border: Border.all(color: AppTheme.cardBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(tk.seatCode ?? '—', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.navy)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('${tk.origin} → ${tk.destination}', maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(money(tk.fare), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text(
                tk.status == 'REFUNDED' ? l10n.refunded : (tk.onBoard || tk.seatCode == null ? l10n.onBoard : l10n.gotOff),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: tk.status == 'REFUNDED' ? AppTheme.error : (tk.onBoard || tk.seatCode == null ? AppTheme.success : muted),
                ),
              ),
            ]),
          ),
      ]),
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
