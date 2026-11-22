import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import 'fleet_providers.dart';
import 'seat_grid.dart';

/// A seat layout being built: seats per front-to-back row, plus an optional side row.
/// Seat codes are generated: rows A, B, C… numbered left to right; side seats S1, S2…
class SeatLayoutValue {
  const SeatLayoutValue({this.template, required this.perRow, this.side = 0});

  /// The template it started from (kept for reference; the rows are what count).
  final String? template;
  final List<int> perRow;
  final int side;

  static const maxRows = 12;
  static const maxPerRow = 6;
  static const maxSide = 8;

  factory SeatLayoutValue.fromRows(List<List<String>> rows, {String? template, int side = 0}) =>
      SeatLayoutValue(template: template, perRow: [for (final r in rows) r.length], side: side);

  List<List<String>> get rows => [
        for (var r = 0; r < perRow.length; r++) [for (var s = 1; s <= perRow[r]; s++) '${String.fromCharCode(65 + r)}$s'],
      ];

  List<String> get sideSeats => [for (var s = 1; s <= side; s++) 'S$s'];

  int get capacity => perRow.fold(0, (a, b) => a + b) + side;

  bool get isEmpty => perRow.isEmpty;

  SeatLayoutValue copyWith({String? template, bool clearTemplate = false, List<int>? perRow, int? side}) => SeatLayoutValue(
        template: clearTemplate ? null : (template ?? this.template),
        perRow: perRow ?? this.perRow,
        side: side ?? this.side,
      );

  /// Body for the API's SeatLayoutRequest.
  Json toRequest() => {
        'template': ?template,
        'rows': rows,
        'sideSeats': sideSeats,
      };
}

/// Pick a template or build a custom layout row by row, with an optional side row.
class SeatLayoutEditor extends ConsumerWidget {
  const SeatLayoutEditor({super.key, required this.value, required this.onChanged, this.onTemplateVehicle});

  final SeatLayoutValue value;
  final ValueChanged<SeatLayoutValue> onChanged;

  /// Called with the template's vehicle type when one is picked.
  final ValueChanged<String>? onTemplateVehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final templates = ref.watch(seatTemplatesProvider);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final custom = value.template == null;

    void setRow(int i, int n) => onChanged(value.copyWith(clearTemplate: true, perRow: [...value.perRow]..[i] = n));

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Start from a template, or custom.
      switch (templates) {
        AsyncData(:final value) => Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in value)
              ChoiceChip(
                label: Text(t.name),
                selected: this.value.template == t.code,
                onSelected: (_) {
                  onChanged(SeatLayoutValue.fromRows(t.rows, template: t.code, side: this.value.side));
                  onTemplateVehicle?.call(t.vehicleType);
                },
              ),
            ChoiceChip(
              avatar: const Icon(AppIcons.pencil, size: 16),
              label: Text(l10n.customLayout),
              selected: custom,
              onSelected: (_) => onChanged(this.value.copyWith(
                clearTemplate: true,
                perRow: this.value.isEmpty ? [2, 3, 3] : this.value.perRow,
              )),
            ),
          ]),
        AsyncError(:final error) => AppErrorCard(error: error),
        _ => const LinearProgressIndicator(),
      },
      if (!value.isEmpty) ...[
        const SizedBox(height: 14),
        ListCard(children: [
          for (var i = 0; i < value.perRow.length; i++)
            _StepperRow(
              label: l10n.rowLabel(String.fromCharCode(65 + i)),
              value: value.perRow[i],
              min: 1,
              max: SeatLayoutValue.maxPerRow,
              onChanged: (n) => setRow(i, n),
              onRemove: value.perRow.length > 1
                  ? () => onChanged(value.copyWith(clearTemplate: true, perRow: [...value.perRow]..removeAt(i)))
                  : null,
            ),
          if (value.perRow.length < SeatLayoutValue.maxRows)
            InkWell(
              onTap: () => onChanged(value.copyWith(
                clearTemplate: true,
                perRow: [...value.perRow, value.perRow.isEmpty ? 3 : value.perRow.last],
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  const Icon(AppIcons.add, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.addRow, style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        ListCard(children: [
          _StepperRow(
            label: l10n.sideSeatsLabel,
            hint: l10n.sideSeatsHint,
            value: value.side,
            min: 0,
            max: SeatLayoutValue.maxSide,
            onChanged: (n) => onChanged(value.copyWith(side: n)),
          ),
        ]),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(children: [
            SeatGrid(rows: value.rows, sideSeats: value.sideSeats, seatBuilder: (code) => SeatBox(code)),
            const SizedBox(height: 4),
            Text(l10n.seatCount(value.capacity), style: TextStyle(color: muted, fontWeight: FontWeight.w600)),
          ]),
        ),
      ],
    ]);
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({required this.label, this.hint, required this.value, required this.min, required this.max,
      required this.onChanged, this.onRemove});

  final String label;
  final String? hint;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    Widget round(IconData icon, VoidCallback? onTap) => IconButton.outlined(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(side: BorderSide(color: Theme.of(context).colorScheme.outline)),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            if (hint != null) Text(hint!, style: TextStyle(color: muted, fontSize: 12)),
          ]),
        ),
        round(AppIcons.minus, value > min ? () => onChanged(value - 1) : null),
        SizedBox(
          width: 34,
          child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        round(AppIcons.add, value < max ? () => onChanged(value + 1) : null),
        if (onRemove != null)
          IconButton(onPressed: onRemove, icon: const Icon(AppIcons.trash, size: 18, color: AppTheme.error))
        else
          const SizedBox(width: 48),
      ]),
    );
  }
}
