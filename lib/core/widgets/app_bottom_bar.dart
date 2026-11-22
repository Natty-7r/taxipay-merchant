import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class BottomBarItem {
  const BottomBarItem({required this.branch, required this.icon, required this.activeIcon, required this.label});

  final int branch;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// White bottom bar of the app design: yellow active tab, grey inactive ones, and a raised
/// yellow circle in the middle for the main action.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({super.key, required this.currentIndex, required this.onSelect, required this.items, required this.center});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  /// Four items: two either side of [center].
  final List<BottomBarItem> items;
  final BottomBarItem center;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final half = items.length ~/ 2;
    final centerActive = currentIndex == center.branch;

    Widget tab(BottomBarItem item) {
      final active = item.branch == currentIndex;
      final color = active ? (dark ? AppTheme.yellow : AppTheme.darkYellow) : AppTheme.inactiveIcon;
      return Expanded(
        child: InkResponse(
          onTap: () => onSelect(item.branch),
          radius: 36,
          child: Semantics(
            selected: active,
            button: true,
            label: item.label,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(active ? item.activeIcon : item.icon, color: color, size: 25),
              const SizedBox(height: 3),
              Text(item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: color, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
            ]),
          ),
        ),
      );
    }

    return SizedBox(
      height: 72 + MediaQuery.paddingOf(context).bottom + 22,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [
        Container(
          height: 72 + MediaQuery.paddingOf(context).bottom,
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outline)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.3 : 0.04), blurRadius: 12, offset: const Offset(0, -2))],
          ),
          child: Row(children: [
            ...items.take(half).map(tab),
            const SizedBox(width: 76),
            ...items.skip(half).map(tab),
          ]),
        ),
        Positioned(
          top: 0,
          child: Semantics(
            button: true,
            selected: centerActive,
            label: center.label,
            child: GestureDetector(
              onTap: () => onSelect(center.branch),
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.yellow,
                  border: Border.all(color: scheme.surface, width: 4),
                  boxShadow: [BoxShadow(color: AppTheme.yellow.withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(0, 4))],
                ),
                child: Icon(center.icon, color: AppTheme.navy, size: 28),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
