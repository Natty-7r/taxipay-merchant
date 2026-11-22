import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../data/inbox_api.dart';
import '../data/inbox_models.dart';

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
          icon: const Icon(Icons.done_all),
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
            ? const EmptyView(icon: Icons.notifications_none)
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final n = items[i];
                  return ListTile(
                    leading: Icon(switch (n.category) {
                      'PAYMENT' => Icons.payments,
                      'OPERATIONS' => Icons.local_taxi,
                      'ADVERTISEMENT' => Icons.local_offer,
                      'NOTICE' => Icons.campaign,
                      _ => Icons.person,
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
