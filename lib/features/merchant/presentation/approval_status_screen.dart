import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/merchant_api.dart';
import '../data/merchant_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';

/// Gate for businesses that aren't approved: status, reason, documents and resubmission.
class ApprovalStatusScreen extends ConsumerWidget {
  const ApprovalStatusScreen({super.key});

  Future<void> _upload(BuildContext context, WidgetRef ref) async {
    final type = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          for (final t in documentTypes)
            ListTile(leading: const Icon(AppIcons.description), title: Text(humanize(t)), onTap: () => Navigator.pop(context, t)),
        ]),
      ),
    );
    if (type == null) return;
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
    if (file == null || !context.mounted) return;
    final ok = await runAction(context,
        () async => ref.read(merchantApiProvider).uploadDocument(type, await file.readAsBytes(), file.name));
    if (ok) await ref.read(sessionProvider.notifier).reload();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider).value;
    if (session == null) return const SizedBox.shrink();
    final m = session.merchant;
    final (title, info, icon, color) = switch (m.status) {
      MerchantStatus.rejected => (l10n.statusRejected, l10n.statusRejectedInfo, AppIcons.cancel, AppTheme.error),
      MerchantStatus.suspended => (l10n.statusSuspended, l10n.statusSuspendedInfo, AppIcons.block, AppTheme.error),
      _ => (l10n.statusPending, l10n.statusPendingInfo, AppIcons.hourglassTop, AppTheme.warning),
    };
    final canEdit = m.status == MerchantStatus.pending || m.status == MerchantStatus.rejected;

    return Scaffold(
      appBar: AppBar(title: Text(m.businessName), actions: [
        IconButton(icon: const Icon(AppIcons.logout), tooltip: l10n.logout,
            onPressed: () => ref.read(sessionProvider.notifier).logout()),
      ]),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _upload(context, ref), icon: const Icon(AppIcons.uploadFile), label: Text(l10n.uploadDocument))
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.read(sessionProvider.notifier).reload(),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                ]),
                const SizedBox(height: 12),
                Text(info),
                if (m.statusReason != null) ...[
                  const SizedBox(height: 12),
                  Text('${l10n.reason}: ${m.statusReason}', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.documents, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (m.documents.isEmpty) Text(l10n.empty),
          for (final d in m.documents)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(AppIcons.insertDriveFile),
              title: Text(humanize(d.type)),
              subtitle: Text('${d.fileName} · ${dateTime(d.createdAt)}'),
            ),
          if (m.status == MerchantStatus.rejected) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final ok = await runAction(context, () => ref.read(merchantApiProvider).resubmit());
                if (ok) await ref.read(sessionProvider.notifier).reload();
              },
              child: Text(l10n.resubmit),
            ),
          ],
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}
