import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../data/payment_models.dart';
import '../data/payments_api.dart';

final paymentsProvider = FutureProvider.autoDispose.family<List<PaymentItem>, String?>(
    (ref, status) => ref.watch(paymentsApiProvider).list(status: status));

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabPayments),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              for (final s in [null, 'SUCCESSFUL', 'PENDING', 'FAILED', 'REFUNDED'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s == null ? l10n.all : humanize(s)),
                    selected: _status == s,
                    onSelected: (_) => setState(() => _status = s),
                  ),
                ),
            ]),
          ),
        ),
      ),
      body: AsyncBody(
        value: ref.watch(paymentsProvider(_status)),
        onRefresh: () => ref.refresh(paymentsProvider(_status).future),
        builder: (items) => items.isEmpty
            ? const EmptyView(icon: Icons.receipt_long)
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = items[i];
                  return ListTile(
                    title: Text('${p.origin} → ${p.destination}'),
                    subtitle: Text('${p.plateNumber}${p.seatCode == null ? '' : ' · ${p.seatCode}'} · '
                        '${humanize(p.provider)} · ${dateTime(p.createdAt)}\n${p.reference}'),
                    isThreeLine: true,
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(money(p.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          StatusChip(p.status),
                        ]),
                  );
                },
              ),
      ),
    );
  }
}
