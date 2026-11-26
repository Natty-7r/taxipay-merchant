import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/merchant_api.dart';
import '../data/merchant_models.dart';

/// The business behind the account, submitted for review. An individual works under the owner's own name;
/// a company or association gives its name and TIN. The location is picked on a map.
class BusinessSetupScreen extends ConsumerStatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  ConsumerState<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends ConsumerState<BusinessSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _tin = TextEditingController();
  final _license = TextEditingController();
  final _city = TextEditingController(text: 'Addis Ababa');
  final _subCity = TextEditingController();
  final _address = TextEditingController();
  String _type = 'INDIVIDUAL';
  LatLng? _location;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final m = ref.read(sessionProvider).value?.merchant;
    if (m != null && m.status != MerchantStatus.draft) {
      _type = m.businessType;
      if (m.businessType != 'INDIVIDUAL') _name.text = m.businessName;
      _tin.text = m.tin ?? '';
      _license.text = m.tradeLicenseNumber ?? '';
      _city.text = m.city ?? _city.text;
      _subCity.text = m.subCity ?? '';
      _address.text = m.addressLine ?? '';
      if (m.latitude != null && m.longitude != null) _location = LatLng(m.latitude!, m.longitude!);
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _tin, _license, _city, _subCity, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _individual => _type == 'INDIVIDUAL';

  Future<void> _pickLocation() async {
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => MapPickerScreen(initial: _location)),
    );
    if (picked != null) setState(() => _location = picked);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    String? text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    final ok = await runAction(context, () async {
      await ref.read(merchantApiProvider).setUpBusiness({
        'businessType': _type,
        if (!_individual) 'businessName': text(_name),
        'tin': text(_tin),
        'tradeLicenseNumber': text(_license),
        'city': text(_city),
        'subCity': text(_subCity),
        'addressLine': text(_address),
        if (_location != null) 'latitude': double.parse(_location!.latitude.toStringAsFixed(6)),
        if (_location != null) 'longitude': double.parse(_location!.longitude.toStringAsFixed(6)),
      }..removeWhere((_, v) => v == null));
      await ref.read(sessionProvider.notifier).reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.businessSubmitted)));
        context.pop();
      }
    });
    if (mounted && !ok) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider).value;
    final ownerName = session?.me.fullName ?? '';
    final locked = session?.merchant != null && !const {MerchantStatus.draft, MerchantStatus.pending, MerchantStatus.rejected}
        .contains(session!.merchant!.status);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessDetails)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
          if (locked) ...[
            SoftCard(child: Row(children: [
              const Icon(AppIcons.lock, color: AppTheme.warning),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.businessLocked)),
            ])),
            const SizedBox(height: 16),
          ],
          Text(l10n.businessType, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'INDIVIDUAL', icon: const Icon(AppIcons.user), label: Text(l10n.typeIndividual)),
                ButtonSegment(value: 'COMPANY', icon: const Icon(AppIcons.building), label: Text(l10n.typeCompany)),
                ButtonSegment(value: 'ASSOCIATION', icon: const Icon(AppIcons.handshake), label: Text(l10n.typeAssociation)),
              ],
              selected: {_type},
              onSelectionChanged: locked ? null : (s) => setState(() => _type = s.first),
            ),
          ),
          const SizedBox(height: 16),
          if (_individual)
            SoftCard(
              child: Row(children: [
                const Icon(AppIcons.storefront, color: AppTheme.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10n.businessName, style: TextStyle(color: muted, fontSize: 12.5)),
                    Text(ownerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(l10n.individualUsesYourName, style: TextStyle(color: muted, fontSize: 12.5)),
                  ]),
                ),
              ]),
            )
          else
            TextFormField(
              controller: _name,
              enabled: !locked,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.businessName),
              validator: (v) => requiredValidator(context, v),
            ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tin,
            enabled: !locked,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: InputDecoration(labelText: _individual ? l10n.tinOptional : l10n.tin, counterText: ''),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return _individual ? null : l10n.tinInvalid;
              return RegExp(r'^\d{10}$').hasMatch(value) ? null : l10n.tinInvalid;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _license, decoration: InputDecoration(labelText: l10n.tradeLicense)),
          SectionLabel(l10n.location),
          TextFormField(
            controller: _city,
            decoration: InputDecoration(labelText: l10n.city),
            validator: (v) => requiredValidator(context, v),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _subCity, decoration: InputDecoration(labelText: l10n.subCity)),
          const SizedBox(height: 12),
          TextFormField(controller: _address, decoration: InputDecoration(labelText: l10n.addressLine)),
          const SizedBox(height: 12),
          _LocationTile(location: _location, onPick: _pickLocation),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(session?.merchant?.status == MerchantStatus.pending ? l10n.save : l10n.submitForReview),
          ),
        ]),
      ),
    );
  }
}

/// The picked spot as a small map preview, or a button to pick one.
class _LocationTile extends StatelessWidget {
  const _LocationTile({required this.location, required this.onPick});

  final LatLng? location;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final point = location;
    if (point == null) {
      return OutlinedButton.icon(onPressed: onPick, icon: const Icon(AppIcons.mapPin), label: Text(l10n.pickOnMap));
    }
    return SoftCard(
      padding: EdgeInsets.zero,
      onTap: onPick,
      child: Column(children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: 150,
            child: IgnorePointer(
              child: FlutterMap(
                options: MapOptions(initialCenter: point, initialZoom: 15),
                children: [_tiles(), MarkerLayer(markers: [_pin(point)])],
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(AppIcons.mapPin, color: AppTheme.blue),
          title: Text('${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}'),
          trailing: TextButton(onPressed: onPick, child: Text(l10n.changeLocation)),
        ),
      ]),
    );
  }
}

TileLayer _tiles() => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.taxipay.taxipay_merchant',
    );

Marker _pin(LatLng point) => Marker(
      point: point,
      width: 44,
      height: 44,
      alignment: Alignment.topCenter,
      child: const Icon(AppIcons.mapPin, color: AppTheme.error, size: 40),
    );

/// Full-screen map: tap to place the pin, then confirm. Starts in Addis Ababa.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initial});

  final LatLng? initial;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _addisAbaba = LatLng(9.0108, 38.7613);
  late LatLng? _point = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final point = _point;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mapPickerTitle)),
      body: Stack(children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: widget.initial ?? _addisAbaba,
            initialZoom: widget.initial == null ? 12 : 16,
            onTap: (_, latLng) => setState(() => _point = latLng),
          ),
          children: [
            _tiles(),
            if (point != null) MarkerLayer(markers: [_pin(point)]),
            const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 12,
          child: SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              const Icon(AppIcons.mapPin, color: AppTheme.blue),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.mapPickerHint)),
            ]),
          ),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: point == null ? null : () => Navigator.pop(context, point),
          child: Text(l10n.useThisLocation),
        ),
      ),
    );
  }
}
