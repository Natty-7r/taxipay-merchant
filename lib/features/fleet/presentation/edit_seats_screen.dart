import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import '../data/fleet_api.dart';
import 'fleet_providers.dart';
import 'seat_layout_editor.dart';

/// Rebuild a taxi's seat layout: change a template, add or remove rows and seats, add side seats.
class EditSeatsScreen extends ConsumerStatefulWidget {
  const EditSeatsScreen({super.key, required this.taxiId});

  final int taxiId;

  @override
  ConsumerState<EditSeatsScreen> createState() => _EditSeatsScreenState();
}

class _EditSeatsScreenState extends ConsumerState<EditSeatsScreen> {
  SeatLayoutValue? _layout;
  bool _busy = false;

  Future<void> _save(SeatLayoutValue layout) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    final ok = await runAction(context, () => ref.read(fleetApiProvider).setSeatLayout(widget.taxiId, layout.toRequest()));
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ref.invalidate(taxiProvider(widget.taxiId));
      ref.invalidate(taxisProvider);
      showInfo(context, l10n.seatsSaved);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final taxi = ref.watch(taxiProvider(widget.taxiId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editSeats)),
      body: AsyncBody(
        value: taxi,
        onRefresh: () => ref.refresh(taxiProvider(widget.taxiId).future),
        builder: (t) {
          final layout = _layout ?? SeatLayoutValue.fromRows(t.seatRows, template: t.seatTemplate, side: t.sideSeats.length);
          return ListView(padding: pagePadding, children: [
            Text(t.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SeatLayoutEditor(value: layout, onChanged: (v) => setState(() => _layout = v)),
            const SizedBox(height: 24),
            FilledButton(onPressed: _busy || layout.isEmpty ? null : () => _save(layout), child: Text(l10n.save)),
          ]);
        },
      ),
    );
  }
}
