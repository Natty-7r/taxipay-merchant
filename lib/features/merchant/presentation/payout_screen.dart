import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/common.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/merchant_api.dart';
import '../data/merchant_models.dart';

/// Where Taxi Pay sends what passengers pay: a bank account or a mobile-money wallet.
/// Needed before the first operation.
class PayoutScreen extends ConsumerStatefulWidget {
  const PayoutScreen({super.key});

  @override
  ConsumerState<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends ConsumerState<PayoutScreen> {
  static const _banks = ['CBE', 'Awash Bank', 'Dashen Bank', 'Bank of Abyssinia', 'Hibret Bank', 'Wegagen Bank'];
  static const _wallets = ['M-Pesa', 'Telebirr', 'CBE Birr'];

  final _form = GlobalKey<FormState>();
  final _provider = TextEditingController();
  final _accountName = TextEditingController();
  final _accountNumber = TextEditingController();
  String _method = 'MOBILE_MONEY';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider).value;
    final payout = session?.merchant?.payout;
    if (payout != null) {
      _method = payout.method;
      _provider.text = payout.provider;
      _accountName.text = payout.accountName;
      _accountNumber.text = payout.accountNumber;
    } else {
      _provider.text = _wallets.first;
      _accountName.text = session?.me.fullName ?? '';
      _accountNumber.text = session?.me.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    _accountName.dispose();
    _accountNumber.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      await ref.read(merchantApiProvider).setPayout(Payout(
            method: _method,
            provider: _provider.text.trim(),
            accountName: _accountName.text.trim(),
            accountNumber: _accountNumber.text.trim(),
          ));
      await ref.read(sessionProvider.notifier).reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.payoutSaved)));
        context.pop();
      }
    });
    if (mounted && !ok) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final choices = _method == 'BANK_ACCOUNT' ? _banks : _wallets;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settlementSection)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
          Text(l10n.payoutIntro, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'MOBILE_MONEY', icon: const Icon(AppIcons.accountBalanceWalletOutlined), label: Text(l10n.mobileMoney)),
                ButtonSegment(value: 'BANK_ACCOUNT', icon: const Icon(AppIcons.bank), label: Text(l10n.bankAccount)),
              ],
              selected: {_method},
              onSelectionChanged: (s) => setState(() {
                _method = s.first;
                _provider.text = (_method == 'BANK_ACCOUNT' ? _banks : _wallets).first;
              }),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in choices)
              ChoiceChip(
                label: Text(p),
                selected: _provider.text == p,
                onSelected: (_) => setState(() => _provider.text = p),
              ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _provider,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.providerName),
            validator: (v) => requiredValidator(context, v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _accountName,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.accountName),
            validator: (v) => requiredValidator(context, v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _accountNumber,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: _method == 'MOBILE_MONEY' ? l10n.walletPhone : l10n.accountNumber),
            validator: (v) => requiredValidator(context, v),
          ),
          const SizedBox(height: 28),
          FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
        ]),
      ),
    );
  }
}
