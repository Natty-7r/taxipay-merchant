import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
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
          preferredSize: const Size.fromHeight(52),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
            ? EmptyView(icon: Icons.receipt_long, message: l10n.noPaymentsYet)
            : ListView(padding: pagePadding, children: [
                ListCard(children: [for (var i = 0; i < items.length; i++) PaymentRow(items[i], highlight: i == 0)]),
              ]),
      ),
    );
  }
}

/// A payment in the activity style: route, time and taxi, amount and provider.
class PaymentRow extends StatelessWidget {
  const PaymentRow(this.p, {super.key, this.highlight = false});

  final PaymentItem p;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ok = p.status == 'SUCCESSFUL';
    final when = friendlyTime(p.createdAt, today: l10n.today, yesterday: l10n.yesterday);
    return ActivityRow(
      title: '${p.origin} → ${p.destination}',
      subtitle: '$when · ${p.plateNumber}${p.seatCode == null ? '' : ' · ${p.seatCode}'}',
      amount: money(p.amount),
      caption: ok ? l10n.via(p.provider) : humanize(p.status),
      highlight: highlight && ok,
      dotColor: switch (p.status) {
        'FAILED' || 'EXPIRED' || 'CANCELLED' => AppTheme.error,
        'PENDING' || 'INITIATED' => AppTheme.warning,
        'REFUNDED' => AppTheme.inactiveIcon,
        _ => null,
      },
    );
  }
}
