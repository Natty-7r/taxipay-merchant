import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import '../data/fleet_api.dart';
import '../data/fleet_models.dart';
import 'fleet_providers.dart';

/// Add or edit a driver. With a password the driver signs in to this app (same login page) and runs only
/// the taxis assigned here.
class AddDriverScreen extends ConsumerStatefulWidget {
  const AddDriverScreen({super.key, this.initial});

  final Driver? initial;

  @override
  ConsumerState<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends ConsumerState<AddDriverScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.fullName);
  late final _phone = TextEditingController(text: widget.initial?.phoneNumber);
  late final _license = TextEditingController(text: widget.initial?.licenseNumber);
  final _password = TextEditingController();
  late bool _canLogin = widget.initial?.canLogin ?? true;
  late final Set<int> _taxiIds = {...?widget.initial?.taxiIds};
  bool _obscure = true;
  bool _busy = false;

  bool get _editing => widget.initial != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _license.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      final api = ref.read(fleetApiProvider);
      final body = {
        'fullName': _name.text.trim(),
        'phoneNumber': _phone.text.trim(),
        'licenseNumber': _license.text.trim(),
        if (_canLogin && _password.text.isNotEmpty) 'password': _password.text,
      };
      final driver = _editing ? await api.updateDriver(widget.initial!.id, body) : await api.createDriver(body);
      if (!_sameTaxis(driver.taxiIds)) await api.assignTaxis(driver.id, _taxiIds.toList());
      ref.invalidate(driversProvider);
      ref.invalidate(taxisProvider);
      if (mounted) context.pop();
    });
    if (mounted && !ok) setState(() => _busy = false);
  }

  bool _sameTaxis(List<int> current) => current.length == _taxiIds.length && current.every(_taxiIds.contains);

  Future<void> _toggleActive() async {
    final d = widget.initial!;
    final ok = await runAction(context, () => ref.read(fleetApiProvider).setDriverActive(d.id, !d.active));
    if (ok && mounted) {
      ref.invalidate(driversProvider);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final taxis = ref.watch(taxisProvider).value ?? const <Taxi>[];
    final drivers = ref.watch(driversProvider).value ?? const <Driver>[];
    String? driverOf(Taxi t) {
      if (t.defaultDriverId == null || t.defaultDriverId == widget.initial?.id) return null;
      return drivers.where((d) => d.id == t.defaultDriverId).firstOrNull?.fullName;
    }

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? l10n.editDriver : l10n.addDriver)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
          TextFormField(controller: _name, textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.fullName), validator: (v) => requiredValidator(context, v)),
          const SizedBox(height: 12),
          TextFormField(controller: _phone, keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.phone), validator: (v) => requiredValidator(context, v)),
          const SizedBox(height: 12),
          TextFormField(controller: _license, textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l10n.licenseNumber),
              validator: (v) => requiredValidator(context, v)),
          SectionLabel(l10n.driverLogin),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _canLogin,
                // A sign-in can't be removed here; deactivate the driver instead.
                onChanged: widget.initial?.canLogin == true ? null : (v) => setState(() => _canLogin = v),
                title: Text(l10n.canSignIn, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(l10n.driverLoginHint, style: TextStyle(color: muted, fontSize: 12.5)),
              ),
              if (_canLogin)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: widget.initial?.canLogin == true ? l10n.driverPasswordKeep : l10n.password,
                      helperText: l10n.passwordHint,
                      prefixIcon: const Icon(AppIcons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? AppIcons.visibility : AppIcons.visibilityOff),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      final value = v ?? '';
                      if (value.isEmpty) return widget.initial?.canLogin == true ? null : l10n.passwordHint;
                      return value.length < 8 ? l10n.passwordHint : null;
                    },
                  ),
                ),
            ]),
          ),
          SectionLabel(l10n.assignedTaxis),
          Text(l10n.assignedTaxisHint, style: TextStyle(color: muted, fontSize: 12.5)),
          const SizedBox(height: 10),
          if (taxis.isEmpty)
            Text(l10n.empty, style: TextStyle(color: muted))
          else
            ListCard(children: [
              for (final t in taxis)
                CheckboxListTile(
                  value: _taxiIds.contains(t.id),
                  onChanged: (v) => setState(() => v == true ? _taxiIds.add(t.id) : _taxiIds.remove(t.id)),
                  secondary: const Icon(AppIcons.localTaxi),
                  title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: driverOf(t) == null ? null : Text(l10n.currentDriver(driverOf(t)!)),
                ),
            ]),
          const SizedBox(height: 28),
          FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
          if (_editing) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : _toggleActive,
              style: TextButton.styleFrom(foregroundColor: widget.initial!.active ? AppTheme.error : AppTheme.success),
              child: Text(widget.initial!.active ? l10n.deactivateDriver : l10n.activateDriver),
            ),
          ],
        ]),
      ),
    );
  }
}
