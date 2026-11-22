import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../data/inbox_api.dart';
import '../data/inbox_models.dart';
import '../../../core/theme/app_icons.dart';

final inboxProvider = FutureProvider.autoDispose<List<InboxItem>>((ref) => ref.watch(inboxApiProvider).list());

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) => ref.watch(inboxApiProvider).unreadCount());

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(unreadCountProvider);
    ref.invalidate(inboxProvider);
    await ref.read(inboxProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final api = ref.read(inboxApiProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications), actions: [
        IconButton(
          icon: const Icon(AppIcons.doneAll),
          tooltip: l10n.markAllRead,
          onPressed: () async {
            if (await runAction(context, api.markAllRead)) await _refresh(ref);
          },
        ),
      ]),
      body: AsyncBody(
        value: ref.watch(inboxProvider),
        onRefresh: () => _refresh(ref),
        builder: (items) => items.isEmpty
            ? const EmptyView(icon: AppIcons.notificationsNone)
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final n = items[i];
                  return ListTile(
                    leading: Icon(switch (n.category) {
                      'PAYMENT' => AppIcons.payments,
                      'OPERATIONS' => AppIcons.localTaxi,
                      'ADVERTISEMENT' => AppIcons.localOffer,
                      'NOTICE' => AppIcons.campaign,
                      _ => AppIcons.person,
                    }, color: n.read ? null : Theme.of(context).colorScheme.primary),
                    title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text('${n.body}\n${dateTime(n.createdAt)}'),
                    isThreeLine: true,
                    onTap: n.read
                        ? null
                        : () async {
                            if (await runAction(context, () => api.markRead(n.id))) await _refresh(ref);
                          },
                  );
                },
              ),
      ),
    );
  }
}
