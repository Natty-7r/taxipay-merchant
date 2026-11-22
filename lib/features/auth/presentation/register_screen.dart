import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/common.dart';
import 'session_controller.dart';

/// Merchant self-registration: owner account + business + payout account, in two steps.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _ownerForm = GlobalKey<FormState>();
  final _businessForm = GlobalKey<FormState>();
  final _c = <String, TextEditingController>{
    for (final k in ['fullName', 'phone', 'email', 'password', 'businessName', 'tin', 'tradeLicense', 'city',
      'subCity', 'provider', 'accountName', 'accountNumber'])
      k: TextEditingController(),
  };
  int _step = 0;
  String _businessType = 'INDIVIDUAL';
  String _settlement = 'MOBILE_MONEY';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _c['city']!.text = 'Addis Ababa';
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _t(String key) => _c[key]!.text.trim();

  Future<void> _submit() async {
    if (!_businessForm.currentState!.validate()) return;
    setState(() => _busy = true);
    final request = {
      'fullName': _t('fullName'),
      'phoneNumber': _t('phone'),
      if (_t('email').isNotEmpty) 'email': _t('email'),
      'password': _c['password']!.text,
      'preferredLanguage': Localizations.localeOf(context).languageCode,
      'businessName': _t('businessName'),
      'businessType': _businessType,
      'tin': _t('tin'),
      if (_t('tradeLicense').isNotEmpty) 'tradeLicenseNumber': _t('tradeLicense'),
      'city': _t('city'),
      if (_t('subCity').isNotEmpty) 'subCity': _t('subCity'),
      if (_t('accountNumber').isNotEmpty)
        'settlement': {
          'method': _settlement,
          'provider': _t('provider'),
          'accountName': _t('accountName'),
          'accountNumber': _t('accountNumber'),
        },
    };
    final ok = await runAction(context, () => ref.read(sessionProvider.notifier).register(request));
    if (mounted && !ok) setState(() => _busy = false);
  }

  Widget _field(String key, String label, {TextInputType? type, bool required = true, bool obscure = false,
      String? Function(String?)? validator, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _c[key],
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(labelText: label, helperText: hint),
        validator: validator ?? (required ? (v) => requiredValidator(context, v) : null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step == 0) {
            if (_ownerForm.currentState!.validate()) setState(() => _step = 1);
          } else {
            _submit();
          }
        },
        onStepCancel: _step == 0 ? null : () => setState(() => _step = 0),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(children: [
            Expanded(
              child: FilledButton(
                onPressed: _busy ? null : details.onStepContinue,
                child: Text(_step == 0 ? MaterialLocalizations.of(context).continueButtonLabel : l10n.createAccount),
              ),
            ),
            if (_step == 1) ...[
              const SizedBox(width: 12),
              TextButton(onPressed: details.onStepCancel, child: Text(MaterialLocalizations.of(context).backButtonTooltip)),
            ],
          ]),
        ),
        steps: [
          Step(
            title: Text(l10n.ownerSection),
            isActive: _step == 0,
            content: Form(
              key: _ownerForm,
              child: Column(children: [
                _field('fullName', l10n.fullName),
                _field('phone', l10n.phone, type: TextInputType.phone),
                _field('email', l10n.emailOptional, type: TextInputType.emailAddress, required: false),
                _field('password', l10n.password, obscure: true, hint: l10n.passwordHint,
                    validator: (v) => (v ?? '').length < 8 ? l10n.passwordHint : null),
              ]),
            ),
          ),
          Step(
            title: Text(l10n.businessSection),
            isActive: _step == 1,
            content: Form(
              key: _businessForm,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _field('businessName', l10n.businessName),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    initialValue: _businessType,
                    decoration: InputDecoration(labelText: l10n.businessType),
                    items: [
                      DropdownMenuItem(value: 'INDIVIDUAL', child: Text(l10n.typeIndividual)),
                      DropdownMenuItem(value: 'COMPANY', child: Text(l10n.typeCompany)),
                      DropdownMenuItem(value: 'ASSOCIATION', child: Text(l10n.typeAssociation)),
                    ],
                    onChanged: (v) => setState(() => _businessType = v!),
                  ),
                ),
                _field('tin', l10n.tin, type: TextInputType.number,
                    validator: (v) => RegExp(r'^\d{10}$').hasMatch(v?.trim() ?? '') ? null : l10n.tin),
                _field('tradeLicense', l10n.tradeLicense, required: false),
                _field('city', l10n.city),
                _field('subCity', l10n.subCity, required: false),
                const SizedBox(height: 8),
                Text(l10n.settlementSection, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'MOBILE_MONEY', label: Text(l10n.mobileMoney)),
                    ButtonSegment(value: 'BANK_ACCOUNT', label: Text(l10n.bankAccount)),
                  ],
                  selected: {_settlement},
                  onSelectionChanged: (s) => setState(() => _settlement = s.first),
                ),
                const SizedBox(height: 12),
                _field('provider', l10n.providerName, required: false),
                _field('accountName', l10n.accountName, required: false),
                _field('accountNumber', l10n.accountNumber, required: false, type: TextInputType.number),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
