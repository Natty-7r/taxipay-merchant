import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/fleet_models.dart';
import 'fleet_providers.dart';

enum PosterFormat { image, pdf }

/// A printable poster for a taxi: Taxi Pay logo, the QR code (drawn on the phone from its
/// value), the plate and side number, the taxi's routes and how to pay. Shared or saved as
/// a PNG image or an A5 PDF.
class QrPosterScreen extends ConsumerStatefulWidget {
  const QrPosterScreen({super.key, required this.taxiId});

  final int taxiId;

  @override
  ConsumerState<QrPosterScreen> createState() => _QrPosterScreenState();
}

class _QrPosterScreenState extends ConsumerState<QrPosterScreen> {
  final _poster = GlobalKey();
  PosterFormat _format = PosterFormat.image;
  bool _busy = false;

  /// The poster rendered at print quality (≈1350 × 1950 px).
  Future<Uint8List> _png() async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary = _poster.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.75);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List> _pdf(Uint8List png, String title) async {
    final doc = pw.Document(title: title, author: 'Taxi Pay');
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(18),
      build: (_) => pw.Center(child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain)),
    ));
    return doc.save();
  }

  Future<(Uint8List, String, String)> _file(TaxiQr qr) async {
    final png = await _png();
    final base = 'taxipay-${qr.plateNumber.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')}';
    return switch (_format) {
      PosterFormat.image => (png, '$base.png', 'image/png'),
      PosterFormat.pdf => (await _pdf(png, 'Taxi Pay · ${qr.plateNumber}'), '$base.pdf', 'application/pdf'),
    };
  }

  Future<void> _share(TaxiQr qr) async {
    setState(() => _busy = true);
    await runAction(context, () async {
      final (bytes, name, mime) = await _file(qr);
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(bytes, mimeType: mime, name: name)],
        fileNameOverrides: [name],
        text: 'Taxi Pay · ${qr.plateNumber}',
      ));
    });
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _save(TaxiQr qr) async {
    setState(() => _busy = true);
    final l10n = context.l10n;
    Uri? saved;
    await runAction(context, () async {
      final (bytes, name, mime) = await _file(qr);
      saved = await FilePicker.saveFile(fileName: name, bytes: bytes, mimeType: mime);
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (saved != null) showInfo(context, l10n.savedFile); // null = the user closed the picker
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final qr = ref.watch(taxiQrProvider(widget.taxiId));
    final taxi = ref.watch(taxiProvider(widget.taxiId));
    final routes = ref.watch(taxiRoutesProvider(widget.taxiId));
    final merchant = ref.watch(sessionProvider).value?.businessName;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.qrPoster)),
      body: AsyncBody(
        value: qr,
        onRefresh: () => ref.refresh(taxiQrProvider(widget.taxiId).future),
        builder: (q) => ListView(padding: pagePadding, children: [
          Text(l10n.qrPosterHint, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Center(
            child: FittedBox(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: RepaintBoundary(
                    key: _poster,
                    child: QrPoster(
                      qr: q,
                      routes: routes.value ?? const [],
                      merchantName: merchant,
                      sideNumber: q.sideNumber ?? taxi.value?.sideNumber,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<PosterFormat>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: PosterFormat.image, icon: const Icon(AppIcons.image, size: 18), label: Text(l10n.formatImage)),
                ButtonSegment(value: PosterFormat.pdf, icon: const Icon(AppIcons.pdf, size: 18), label: Text(l10n.formatPdf)),
              ],
              selected: {_format},
              onSelectionChanged: (s) => setState(() => _format = s.first),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _save(q),
                icon: const Icon(AppIcons.download, size: 18),
                label: Text(l10n.saveToPhone),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _share(q),
                icon: const Icon(AppIcons.share, size: 18),
                label: Text(l10n.share),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// The poster itself, laid out at a fixed 360 × 520 logical size so the exported file is
/// identical on every phone.
class QrPoster extends StatelessWidget {
  const QrPoster({super.key, required this.qr, required this.routes, this.merchantName, this.sideNumber});

  final TaxiQr qr;
  final List<RouteInfo> routes;
  final String? merchantName;
  final String? sideNumber;

  static const width = 360.0;
  static const height = 520.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final live = routes.where((r) => r.status == 'APPROVED').toList();

    // Always light, whatever the app theme: this is for paper.
    return Theme(
      data: AppTheme.light(),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppTheme.navy, fontSize: 12),
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
          child: Column(children: [
            // Header: brand.
            Container(
              color: AppTheme.navy,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/brand/mark.png')),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(text: 'Taxi ', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'Pay', style: TextStyle(color: AppTheme.yellow)),
                    ]), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                    Text('SCAN. PAY. RIDE.', style: TextStyle(color: AppTheme.inactiveIcon, fontSize: 9.5, letterSpacing: 1.6, fontWeight: FontWeight.w700)),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(qr.plateNumber, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                  if (sideNumber != null)
                    Text(l10n.sideNumberValue(sideNumber!), style: const TextStyle(color: AppTheme.yellow, fontSize: 10.5, fontWeight: FontWeight.w700)),
                ]),
              ]),
            ),
            Container(height: 5, color: AppTheme.yellow),
            const SizedBox(height: 14),
            Text(l10n.scanToPay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
            const SizedBox(height: 10),
            // The QR, drawn from its value.
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.yellow, width: 3),
              ),
              child: QrImageView(
                data: qr.value,
                version: QrVersions.auto,
                size: 196,
                padding: EdgeInsets.zero,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.navy),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppTheme.navy),
                embeddedImage: const AssetImage('assets/brand/mark.png'),
                embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
              ),
            ),
            const SizedBox(height: 6),
            Text(l10n.qrCodeLabel(qr.value),
                style: const TextStyle(color: AppTheme.navy, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
            const SizedBox(height: 10),
            // Routes.
            if (live.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(children: [
                  for (final r in live.take(2))
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.lightYellow, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        r.stops.join('  →  '),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                      ),
                    ),
                ]),
              ),
            const Spacer(),
            // How to pay.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final (i, step) in [l10n.posterStep1, l10n.posterStep2, l10n.posterStep3].indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Column(children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppTheme.navy, shape: BoxShape.circle),
                        child: Text('${i + 1}', style: const TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                      const SizedBox(height: 4),
                      Text(step, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9.5, height: 1.25)),
                    ]),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              color: const Color(0xFFF4F2EE),
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 18),
              child: Text(
                merchantName == null ? 'taxipay.et' : '${l10n.operatedBy(merchantName!)}  ·  taxipay.et',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textGray, fontSize: 9.5),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
