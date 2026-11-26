import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/common.dart';
import 'session_controller.dart';

/// Merchant sign-up: just the owner's account. The business and payout account are set up after signing in,
/// from the reminders on the home screen.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _c = <String, TextEditingController>{
    for (final k in ['fullName', 'phone', 'email', 'password']) k: TextEditingController(),
  };
  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _t(String key) => _c[key]!.text.trim();

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final request = {
      'fullName': _t('fullName'),
      'phoneNumber': _t('phone'),
      if (_t('email').isNotEmpty) 'email': _t('email'),
      'password': _c['password']!.text,
      'preferredLanguage': Localizations.localeOf(context).languageCode,
    };
    final ok = await runAction(context, () => ref.read(sessionProvider.notifier).register(request));
    if (mounted && !ok) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
            Text(l10n.registerIntro, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _c['fullName'],
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.fullName, prefixIcon: const Icon(AppIcons.person)),
              validator: (v) => requiredValidator(context, v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c['phone'],
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.phone),
              validator: (v) => requiredValidator(context, v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c['email'],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.emailOptional),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _c['password'],
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _busy ? null : _submit(),
              decoration: InputDecoration(
                labelText: l10n.password,
                helperText: l10n.passwordHint,
                prefixIcon: const Icon(AppIcons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? AppIcons.visibility : AppIcons.visibilityOff),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) => (v ?? '').length < 8 ? l10n.passwordHint : null,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _busy ? null : _submit, child: Text(l10n.createAccount)),
          ]),
        ),
      ),
    );
  }
}
