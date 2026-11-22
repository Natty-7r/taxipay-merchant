import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/locale.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_mode.dart';
import '../../../core/widgets/ui.dart';
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

    final themeMode = ref.watch(themeModeProvider);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMore)),
      body: ListView(padding: pagePadding, children: [
        SoftCard(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            InitialsAvatar(me.fullName, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(me.fullName, style: Theme.of(context).textTheme.titleMedium),
                Text(me.phoneNumber, style: TextStyle(color: muted)),
                const SizedBox(height: 6),
                Text('${m.businessName} · ${humanize(m.businessType)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('TIN ${m.tin}', style: TextStyle(color: muted, fontSize: 12.5)),
              ]),
            ),
          ]),
        ),
        SectionLabel(l10n.account),
        ListCard(children: [
          ListTile(
            leading: const Icon(Icons.notifications_none_rounded),
            title: Text(l10n.notifications),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/more/notifications'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(children: [
              const Icon(Icons.telegram),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.telegram, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    switch (telegram) {
                      AsyncData(:final value) when value.linked =>
                        '${l10n.telegramConnected}${value.telegramUsername == null ? '' : ' (@${value.telegramUsername})'}',
                      _ => l10n.telegramNotConnected,
                    },
                    style: TextStyle(color: muted, fontSize: 12.5),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              switch (telegram) {
                AsyncData(:final value) when value.linked => TextButton(
                    onPressed: () async {
                      if (await runAction(context, ref.read(inboxApiProvider).telegramUnlink)) {
                        ref.invalidate(telegramStatusProvider);
                      }
                    },
                    child: Text(l10n.disconnect)),
                AsyncData(:final value) when value.botAvailable => FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => _connectTelegram(context, ref),
                    child: Text(l10n.connect)),
                _ => const SizedBox.shrink(),
              },
            ]),
          ),
        ]),
        SectionLabel(l10n.preferences),
        ListCard(children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [ButtonSegment(value: 'en', label: Text('EN')), ButtonSegment(value: 'am', label: Text('አማ'))],
              selected: {locale},
              onSelectionChanged: (s) => _setLanguage(context, ref, s.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.contrast),
                const SizedBox(width: 16),
                Text(l10n.appearance, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode_outlined), label: Text(l10n.themeLight)),
                    ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_outlined), label: Text(l10n.themeDark)),
                    ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.brightness_auto_outlined), label: Text(l10n.themeSystem)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
                ),
              ),
            ]),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.local_offer_outlined),
            title: Text(l10n.offers),
            value: me.marketingOptIn,
            activeTrackColor: AppTheme.yellow,
            onChanged: (v) async {
              final ok = await runAction(context,
                  () => ref.read(authApiProvider).updateMe(fullName: me.fullName, email: me.email, marketingOptIn: v));
              if (ok) await ref.read(sessionProvider.notifier).reload();
            },
          ),
        ]),
        const SizedBox(height: 24),
        ListCard(children: [
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.error),
            title: Text(l10n.logout, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            onTap: () => ref.read(sessionProvider.notifier).logout(),
          ),
        ]),
      ]),
    );
  }
}
