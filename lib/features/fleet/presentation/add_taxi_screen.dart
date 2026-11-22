import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/common.dart';
import '../data/fleet_api.dart';
import '../data/fleet_models.dart';
import 'fleet_providers.dart';
import 'seat_grid.dart';

class AddTaxiScreen extends ConsumerStatefulWidget {
  const AddTaxiScreen({super.key});

  @override
  ConsumerState<AddTaxiScreen> createState() => _AddTaxiScreenState();
}

class _AddTaxiScreenState extends ConsumerState<AddTaxiScreen> {
  final _form = GlobalKey<FormState>();
  final _plate = TextEditingController();
  final _side = TextEditingController();
  final _make = TextEditingController(text: 'Toyota');
  final _model = TextEditingController(text: 'Hiace');
  final _year = TextEditingController();
  final _color = TextEditingController();
  SeatTemplate? _template;
  int? _driverId;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_plate, _side, _make, _model, _year, _color]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _template == null) return;
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      final taxi = await ref.read(fleetApiProvider).createTaxi({
        'plateNumber': _plate.text.trim(),
        if (_side.text.trim().isNotEmpty) 'sideNumber': _side.text.trim(),
        'vehicleType': _template!.vehicleType,
        'manufacturer': _make.text.trim(),
        'model': _model.text.trim(),
        if (int.tryParse(_year.text) != null) 'manufactureYear': int.parse(_year.text),
        if (_color.text.trim().isNotEmpty) 'color': _color.text.trim(),
        'seatLayoutTemplate': _template!.code,
        'defaultDriverId': ?_driverId,
      });
      ref.invalidate(taxisProvider);
      if (mounted) context.pushReplacement('/fleet/taxis/${taxi.id}');
    });
    if (mounted && !ok) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final templates = ref.watch(seatTemplatesProvider);
    final drivers = ref.watch(driversProvider).value ?? const <Driver>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addTaxi)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(controller: _plate, textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l10n.plateNumber, hintText: 'AA 3-12345'),
              validator: (v) => requiredValidator(context, v)),
          const SizedBox(height: 12),
          TextFormField(controller: _side, decoration: InputDecoration(labelText: l10n.sideNumber)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(controller: _make, decoration: InputDecoration(labelText: l10n.manufacturer),
                validator: (v) => requiredValidator(context, v))),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _model, decoration: InputDecoration(labelText: l10n.model),
                validator: (v) => requiredValidator(context, v))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(controller: _year, keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.year))),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _color, decoration: InputDecoration(labelText: l10n.color))),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _driverId,
            decoration: InputDecoration(labelText: l10n.defaultDriver),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.none)),
              for (final d in drivers.where((d) => d.active)) DropdownMenuItem(value: d.id, child: Text(d.fullName)),
            ],
            onChanged: (v) => setState(() => _driverId = v),
          ),
          const SizedBox(height: 20),
          Text(l10n.seatLayout, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          switch (templates) {
            AsyncData(:final value) => Wrap(spacing: 8, runSpacing: 8, children: [
                for (final t in value)
                  ChoiceChip(
                    label: Text(t.name),
                    selected: _template?.code == t.code,
                    onSelected: (_) => setState(() => _template = t),
                  ),
              ]),
            AsyncError(:final error) => AppErrorCard(error: error),
            _ => const LinearProgressIndicator(),
          },
          if (_template != null) ...[
            const SizedBox(height: 16),
            SeatGrid(rows: _template!.rows, seatBuilder: (code) => SeatBox(code)),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: _busy || _template == null ? null : _save, child: Text(l10n.save)),
        ]),
      ),
    );
  }
}
