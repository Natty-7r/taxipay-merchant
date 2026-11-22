import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui.dart';
import 'fleet_providers.dart';
import 'seat_grid.dart';
import '../../../core/theme/app_icons.dart';

class TaxiDetailScreen extends ConsumerWidget {
  const TaxiDetailScreen({super.key, required this.taxiId});

  final int taxiId;

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
          Row(children: [
            Expanded(child: Text('${l10n.seatLayout} · ${t.capacity} ${l10n.seats}', style: Theme.of(context).textTheme.titleMedium)),
            TextButton.icon(
              onPressed: () => context.push('/fleet/taxis/$taxiId/seats'),
              icon: const Icon(AppIcons.pencil, size: 16),
              label: Text(l10n.editSeats),
            ),
          ]),
          const SizedBox(height: 12),
          SeatGrid(rows: t.seatRows, sideSeats: t.sideSeats, seatBuilder: (code) => SeatBox(code)),
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
            _TaxiQrCard(taxiId: taxiId),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.push('/fleet/taxis/$taxiId/qr'),
              icon: const Icon(AppIcons.qrCode2),
              label: Text(l10n.makePoster),
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
      error: (e, _) => AppErrorCard(error: e, onRetry: () => ref.invalidate(taxiRoutesProvider(taxiId))),
      data: (list) => list.isEmpty
          ? Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(context.l10n.notOnAnyRoute))
          : Column(children: [
              for (final r in list)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(AppIcons.altRoute),
                  title: Text(r.name),
                  subtitle: Text(r.stops.join(' → '), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [StatusChip(r.status), const Icon(AppIcons.chevronRight)]),
                  onTap: () => context.push('/fleet/routes/${r.id}'),
                ),
            ]),
    );
  }
}

/// The taxi's QR code, drawn on the phone from the value the API returns.
class _TaxiQrCard extends ConsumerWidget {
  const _TaxiQrCard({required this.taxiId});

  final int taxiId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(taxiQrProvider(taxiId))) {
      AsyncData(:final value) => SoftCard(
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: QrImageView(
                data: value.value,
                size: 180,
                padding: EdgeInsets.zero,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.navy),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppTheme.navy),
                embeddedImage: const AssetImage('assets/brand/mark.png'),
                embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(36, 36)),
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(value.value, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      AsyncError(:final error) => AppErrorCard(error: error, onRetry: () => ref.invalidate(taxiQrProvider(taxiId))),
      _ => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
    };
  }
}
