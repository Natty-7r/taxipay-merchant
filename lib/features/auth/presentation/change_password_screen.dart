import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/common.dart';
import 'session_controller.dart';
import '../../../core/theme/app_icons.dart';

/// Shown when the account still has an initial password (`mustChangePassword`).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await runAction(context, () => ref.read(sessionProvider.notifier).changePassword(_current.text, _next.text));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordTitle), actions: [
        IconButton(icon: const Icon(AppIcons.logout), onPressed: () => ref.read(sessionProvider.notifier).logout()),
      ]),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(24), children: [
          Text(l10n.changePasswordInfo),
          const SizedBox(height: 16),
          TextFormField(controller: _current, obscureText: true,
              decoration: InputDecoration(labelText: l10n.currentPassword),
              validator: (v) => requiredValidator(context, v)),
          const SizedBox(height: 12),
          TextFormField(controller: _next, obscureText: true,
              decoration: InputDecoration(labelText: l10n.newPassword, helperText: l10n.passwordHint),
              validator: (v) => (v ?? '').length < 8 ? l10n.passwordHint : null),
          const SizedBox(height: 24),
          FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
        ]),
      ),
    );
  }
}
