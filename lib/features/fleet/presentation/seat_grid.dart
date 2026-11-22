import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_icons.dart';

/// Draws a seat layout front to back; [seatBuilder] renders each seat.
class SeatGrid extends StatelessWidget {
  const SeatGrid({super.key, required this.rows, required this.seatBuilder});

  final List<List<String>> rows;
  final Widget Function(String code) seatBuilder;

  @override
  Widget build(BuildContext context) {
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
