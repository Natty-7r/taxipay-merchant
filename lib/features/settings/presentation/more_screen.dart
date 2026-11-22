import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/locale.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../auth/data/auth_api.dart';
import '../../auth/presentation/session_controller.dart';
import '../../inbox/data/inbox_api.dart';
import '../../inbox/data/inbox_models.dart';

final telegramStatusProvider =
    FutureProvider.autoDispose<TelegramStatus>((ref) => ref.watch(inboxApiProvider).telegram());

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _connectTelegram(BuildContext context, WidgetRef ref) async {
    await runAction(context, () async {
      final link = await ref.read(inboxApiProvider).telegramLink();
      final opened = await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
      if (!opened) throw Exception('Could not open Telegram');
    });
  }

  Future<void> _setLanguage(BuildContext context, WidgetRef ref, String code) async {
    final me = ref.read(sessionProvider).value?.me;
    if (me == null) return;
    ref.read(localeProvider.notifier).set(Locale(code));
    await runAction(context, () => ref.read(authApiProvider).updateMe(fullName: me.fullName, email: me.email, language: code));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider).value;
    final telegram = ref.watch(telegramStatusProvider);
    final locale = ref.watch(localeProvider)?.languageCode ?? Localizations.localeOf(context).languageCode;
    if (session == null) return const SizedBox.shrink();
    final me = session.me;
    final m = session.merchant;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMore)),
      body: ListView(children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.storefront)),
          title: Text(m.businessName),
          subtitle: Text('${humanize(m.businessType)} · TIN ${m.tin}\n${me.fullName} · ${me.phoneNumber}'),
          isThreeLine: true,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(l10n.notifications),
          onTap: () => context.push('/more/notifications'),
        ),
        ListTile(
          leading: const Icon(Icons.telegram),
          title: Text(l10n.telegram),
          subtitle: Text(switch (telegram) {
            AsyncData(:final value) when value.linked =>
              '${l10n.telegramConnected}${value.telegramUsername == null ? '' : ' (@${value.telegramUsername})'}',
            _ => l10n.telegramNotConnected,
          }),
          isThreeLine: true,
          trailing: switch (telegram) {
            AsyncData(:final value) when value.linked => TextButton(
                onPressed: () async {
                  if (await runAction(context, ref.read(inboxApiProvider).telegramUnlink)) {
                    ref.invalidate(telegramStatusProvider);
                  }
                },
                child: Text(l10n.disconnect)),
            AsyncData(:final value) when value.botAvailable =>
              FilledButton.tonal(onPressed: () => _connectTelegram(context, ref), child: Text(l10n.connectTelegram)),
            _ => null,
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          trailing: SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'en', label: Text('EN')), ButtonSegment(value: 'am', label: Text('አማ'))],
            selected: {locale},
            onSelectionChanged: (s) => _setLanguage(context, ref, s.first),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.local_offer),
          title: Text(l10n.offers),
          value: me.marketingOptIn,
          onChanged: (v) async {
            final ok = await runAction(context,
                () => ref.read(authApiProvider).updateMe(fullName: me.fullName, email: me.email, marketingOptIn: v));
            if (ok) await ref.read(sessionProvider.notifier).reload();
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
          title: Text(l10n.logout),
          onTap: () => ref.read(sessionProvider.notifier).logout(),
        ),
      ]),
    );
  }
}
