import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../data/fleet_api.dart';
import 'fleet_providers.dart';
import 'seat_grid.dart';

class TaxiDetailScreen extends ConsumerWidget {
  const TaxiDetailScreen({super.key, required this.taxiId});

  final int taxiId;

  Future<void> _shareQr(BuildContext context, WidgetRef ref, String plate) async {
    await runAction(context, () async {
      final png = await ref.read(fleetApiProvider).qrPng(taxiId);
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(png, mimeType: 'image/png', name: 'taxi-$plate-qr.png')],
        text: 'Taxi Pay · $plate',
      ));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final taxi = ref.watch(taxiProvider(taxiId));
    return Scaffold(
      appBar: AppBar(title: Text(taxi.value?.plateNumber ?? l10n.taxi)),
      body: AsyncBody(
        value: taxi,
        onRefresh: () => ref.refresh(taxiProvider(taxiId).future),
        builder: (t) => ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Expanded(child: Text(t.title, style: Theme.of(context).textTheme.headlineSmall)),
            StatusChip(t.status),
          ]),
          if (t.statusReason != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('${l10n.reason}: ${t.statusReason}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
          const SizedBox(height: 12),
          _info(l10n.vehicleType, humanize(t.vehicleType)),
          _info('${l10n.manufacturer} / ${l10n.model}', '${t.manufacturer} ${t.model}${t.year == null ? '' : ' (${t.year})'}'),
          if (t.color != null) _info(l10n.color, t.color!),
          _info(l10n.defaultDriver, t.defaultDriverName ?? l10n.none),
          const Divider(height: 32),
          Text('${l10n.seatLayout} · ${t.capacity} ${l10n.seats}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SeatGrid(rows: t.seatRows, seatBuilder: (code) => SeatBox(code)),
          const Divider(height: 32),
          Text(l10n.routes, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          _TaxiRoutes(taxiId: taxiId),
          const Divider(height: 32),
          Text(l10n.qrCode, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (t.qrUrl == null)
            Text(l10n.qrNotReady)
          else ...[
            SelectableText(t.qrUrl!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _shareQr(context, ref, t.plateNumber),
              icon: const Icon(Icons.qr_code_2),
              label: Text(l10n.shareQr),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );
}

/// The routes this taxi is assigned to; tap through to a route.
class _TaxiRoutes extends ConsumerWidget {
  const _TaxiRoutes({required this.taxiId});

  final int taxiId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(taxiRoutesProvider(taxiId));
    return routes.when(
      loading: () => const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
      error: (e, _) => Text(e.toString()),
      data: (list) => list.isEmpty
          ? Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(context.l10n.notOnAnyRoute))
          : Column(children: [
              for (final r in list)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.alt_route),
                  title: Text(r.name),
                  subtitle: Text(r.stops.join(' → '), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [StatusChip(r.status), const Icon(Icons.chevron_right)]),
                  onTap: () => context.push('/fleet/routes/${r.id}'),
                ),
            ]),
    );
  }
}
