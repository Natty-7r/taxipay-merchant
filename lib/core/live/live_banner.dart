import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'live_events.dart';

/// Opens an app path from a notification (only paths this app has; others are ignored).
void openLink(BuildContext context, String link) {
  const known = ['/home', '/operate', '/fleet', '/payments', '/more'];
  if (!known.any(link.startsWith)) return;
  final router = GoRouter.of(context);
  final top = link.split('/').where((p) => p.isNotEmpty).first;
  // Go to the tab first so Back returns to it, then push the detail screen.
  router.go('/$top');
  if (link != '/$top') router.push(link);
}

Timer? _hide;

/// A banner at the top of the screen for a live event, with "Open" when it has a link.
void showLiveBanner(BuildContext context, LiveEvent event) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final l10n = context.l10n;
  _hide?.cancel();
  messenger
    ..hideCurrentMaterialBanner()
    ..showMaterialBanner(MaterialBanner(
      backgroundColor: AppTheme.navy,
      surfaceTintColor: Colors.transparent,
      leading: const CircleAvatar(
        backgroundColor: AppTheme.yellow,
        foregroundColor: AppTheme.navy,
        child: Icon(AppIcons.notificationsNone, size: 20),
      ),
      content: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(event.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        if (event.body.isNotEmpty)
          Text(event.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
      ]),
      actions: [
        if (event.link != null)
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
              openLink(context, event.link!);
            },
            child: Text(l10n.open, style: const TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w800)),
          ),
        IconButton(
          onPressed: messenger.hideCurrentMaterialBanner,
          icon: const Icon(AppIcons.close, color: Colors.white70, size: 18),
        ),
      ],
    ));
  _hide = Timer(const Duration(seconds: 6), messenger.hideCurrentMaterialBanner);
}
