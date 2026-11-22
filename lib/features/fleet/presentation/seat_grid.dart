import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_icons.dart';

/// Draws a seat layout front to back; [seatBuilder] renders each seat. [sideSeats] are drawn
/// as a column along the right-hand side.
class SeatGrid extends StatelessWidget {
  const SeatGrid({super.key, required this.rows, required this.seatBuilder, this.sideSeats = const []});

  final List<List<String>> rows;
  final List<String> sideSeats;
  final Widget Function(String code) seatBuilder;

  @override
  Widget build(BuildContext context) {
    final grid = _rows(context);
    if (sideSeats.isEmpty) return grid;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Flexible(child: grid),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.fromLTRB(6, 28, 6, 6),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2)),
        ),
        child: Column(children: [
          for (final code in sideSeats) Padding(padding: const EdgeInsets.only(bottom: 8), child: seatBuilder(code)),
        ]),
      ),
    ]);
  }

  Widget _rows(BuildContext context) {
    return Column(children: [
      Row(children: [
        Icon(AppIcons.airlineSeatReclineNormal, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 4),
        Text('Driver', style: Theme.of(context).textTheme.bodySmall),
      ]),
      const SizedBox(height: 8),
      for (final row in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final code in row)
                Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: seatBuilder(code)),
            ],
          ),
        ),
    ]);
  }
}

/// A plain seat box (layout preview).
class SeatBox extends StatelessWidget {
  const SeatBox(this.code, {super.key, this.color, this.onTap, this.caption});

  final String code;
  final Color? color;
  final VoidCallback? onTap;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark ? Colors.white : Colors.black87;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 60,
          height: 56,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(code, style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
            if (caption != null)
              Text(caption!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 10)),
          ]),
        ),
      ),
    );
  }
}
