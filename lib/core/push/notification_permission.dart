import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

bool _askedThisLaunch = false;

/// Asks once per launch when notifications are off: explain why, then show the system prompt —
/// or, when Android won't ask again ("don't allow" twice), open the app's settings page.
Future<void> ensureNotificationPermission(BuildContext context) async {
  if (_askedThisLaunch) return;
  _askedThisLaunch = true;
  final status = await Permission.notification.status;
  if (status.isGranted || status.isLimited || !context.mounted) return;
  final blocked = status.isPermanentlyDenied;
  final l10n = context.l10n;
  final allow = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.lightYellow,
        child: Icon(AppIcons.notificationsNone, color: AppTheme.navy, size: 28),
      ),
      title: Text(l10n.notificationsOffTitle, textAlign: TextAlign.center),
      content: Text(l10n.notificationsOffBody, textAlign: TextAlign.center),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.notNow)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.pop(context, true),
          child: Text(blocked ? l10n.notificationsSettings : l10n.notificationsAllow),
        ),
      ],
    ),
  );
  if (allow != true) return;
  if (blocked) {
    await openAppSettings();
    return;
  }
  final result = await Permission.notification.request();
  if (result.isPermanentlyDenied) await openAppSettings();
}
