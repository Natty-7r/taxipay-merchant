import 'package:material_ui/material_ui.dart';

import '../theme/app_icons.dart';
import '../theme/app_theme.dart';

/// Building blocks of the Taxi Pay app design: uppercase section labels over white,
/// rounded list cards, a navy hero card and a round icon button.

bool _isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

/// "RECENT ACTIVITY" — small, bold, spaced capitals above a card.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.action, this.onAction, this.padding = const EdgeInsets.fromLTRB(2, 24, 2, 10)});

  final String text;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Row(children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _isDark(context) ? AppTheme.yellow : AppTheme.darkYellow)),
            ),
        ]),
      );
}

/// A white rounded card holding rows separated by hairlines.
class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(const Divider(height: 1));
      rows.add(children[i]);
    }
    return Card(clipBehavior: Clip.antiAlias, child: Column(children: rows));
  }
}

/// A card with padding — the default container for content.
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      );
}

/// The navy hero card: a label with an icon, a big figure and a caption, with a soft taxi
/// silhouette in the corner.
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.label, required this.value, this.unit, this.caption, this.icon = AppIcons.paymentsOutlined, this.footer});

  final String label;
  final String value;
  final String? unit;
  final String? caption;
  final IconData icon;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.heroGradient,
        ),
        boxShadow: [BoxShadow(color: AppTheme.navy.withValues(alpha: 0.10), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Stack(children: [
        Positioned(
          right: -40,
          top: -50,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 6,
          child: Icon(AppIcons.localTaxi, size: 88, color: Colors.white.withValues(alpha: 0.06)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, size: 16, color: AppTheme.inactiveIcon),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppTheme.inactiveIcon, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.1)),
                if (unit != null) ...[
                  const SizedBox(width: 6),
                  Text(unit!, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ]),
            ),
            if (caption != null) ...[
              const SizedBox(height: 6),
              Text(caption!, style: const TextStyle(color: AppTheme.inactiveIcon, fontSize: 13)),
            ],
            if (footer != null) ...[const SizedBox(height: 16), footer!],
          ]),
        ),
      ]),
    );
  }
}

/// A small figure on the hero card ("12 passengers").
class HeroStat extends StatelessWidget {
  const HeroStat({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppTheme.inactiveIcon, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]);
}

/// Initials in a yellow ring.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.name, {super.key, this.size = 48});

  final String name;
  final double size;

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    // Dark: yellow with a navy ring. Light: a soft sky tint with navy initials — no yellow-on-navy.
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark ? AppTheme.yellow : AppTheme.blueSoft,
        border: Border.all(color: dark ? AppTheme.navyLight : AppTheme.blueLine, width: 2),
      ),
      child: Text(initialsOf(name),
          style: TextStyle(color: dark ? AppTheme.navy : AppTheme.blue, fontWeight: FontWeight.w800, fontSize: size * 0.34)),
    );
  }
}

/// A round outlined icon button with an optional badge (the bell).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.onPressed, this.badge = 0, this.tooltip});

  final IconData icon;
  final VoidCallback onPressed;
  final int badge;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: scheme.surface,
        shape: CircleBorder(side: BorderSide(color: scheme.outline)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Center(
              child: Badge(
                isLabelVisible: badge > 0,
                backgroundColor: AppTheme.error,
                label: Text(badge > 99 ? '99+' : '$badge'),
                child: Icon(icon, size: 22, color: scheme.onSurface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Hello, Selam" with initials and a bell.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.name, required this.title, required this.subtitle, required this.trailing});

  final String name;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => Row(children: [
        InitialsAvatar(name),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, letterSpacing: -0.3)),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
          ]),
        ),
        trailing,
      ]);
}

/// A navy rounded square with a yellow icon (like the wallet tile).
class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.size = 46});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _isDark(context) ? AppTheme.navyLight : AppTheme.navy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.yellow, size: size * 0.5),
      );
}

/// A row in an activity list: a status dot, a title and time, an amount and a caption.
class ActivityRow extends StatelessWidget {
  const ActivityRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.amount,
    this.caption,
    this.highlight = false,
    this.dotColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? amount;
  final String? caption;
  final bool highlight;
  final Color? dotColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor ?? (highlight ? AppTheme.yellow : const Color(0xFFCBD5E1)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: muted, fontSize: 12.5)),
            ]),
          ),
          if (amount != null || caption != null)
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (amount != null) Text(amount!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              if (caption != null) ...[
                const SizedBox(height: 2),
                Text(caption!, style: TextStyle(color: muted, fontSize: 12)),
              ],
            ]),
          if (onTap != null && amount == null) Icon(AppIcons.chevronRight, color: muted),
        ]),
      ),
    );
  }
}

/// A compact figure tile: icon, value, label. Height follows its content (no overflow).
class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.icon, required this.value, required this.label, this.onTap});

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _isDark(context) ? const Color(0xFF3A2E00) : AppTheme.lightYellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: _isDark(context) ? AppTheme.yellow : AppTheme.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ),
        ]),
      );
}

/// Two widgets side by side with a gap — for metric tiles.
class TwoUp extends StatelessWidget {
  const TwoUp(this.left, this.right, {super.key});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ]);
}

/// A record in a list card: navy icon tile, title and subtitle, and a trailing widget.
class EntityRow extends StatelessWidget {
  const EntityRow({super.key, required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            IconTile(icon, size: 42),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ]),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ]),
        ),
      );
}

/// Page padding used by every list screen.
const pagePadding = EdgeInsets.fromLTRB(20, 8, 20, 32);

/// An error as a card: red-tinted, with an icon, the message, the support reference and a retry button.
class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.title, required this.message, this.reference, this.icon, this.onRetry, this.retryLabel});

  final String title;
  final String message;
  final String? reference;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF2A1215) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: dark ? const Color(0xFF5B1F24) : const Color(0xFFFECACA)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: dark ? 0.25 : 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon ?? AppIcons.errorOutline, color: AppTheme.error, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: dark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B))),
            const SizedBox(height: 4),
            Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13.5)),
            if (reference != null) ...[
              const SizedBox(height: 6),
              SelectableText(reference!, style: TextStyle(color: muted, fontSize: 12)),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(AppIcons.rotateCw, size: 16),
                label: Text(retryLabel ?? 'Retry'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38), padding: const EdgeInsets.symmetric(horizontal: 14)),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}
