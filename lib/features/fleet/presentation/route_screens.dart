import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../data/fleet_api.dart';
import '../data/fleet_models.dart';
import 'fleet_providers.dart';

class RouteDetailScreen extends ConsumerWidget {
  const RouteDetailScreen({super.key, required this.routeId});

  final int routeId;

  Future<void> _assign(BuildContext context, WidgetRef ref, RouteInfo route) async {
    final taxis = await ref.read(fleetApiProvider).taxis(status: 'APPROVED');
    final assigned = route.taxis.map((t) => t.taxiId).toSet();
    final candidates = taxis.where((t) => t.operational && !assigned.contains(t.id)).toList();
    if (!context.mounted) return;
    final taxi = await showModalBottomSheet<Taxi>(
      context: context,
      builder: (context) => SafeArea(
        child: candidates.isEmpty
            ? Padding(padding: const EdgeInsets.all(24), child: Text(context.l10n.empty))
            : ListView(shrinkWrap: true, children: [
                for (final t in candidates)
                  ListTile(leading: const Icon(Icons.local_taxi), title: Text(t.title), onTap: () => Navigator.pop(context, t)),
              ]),
      ),
    );
    if (taxi == null || !context.mounted) return;
    final ok = await runAction(context, () => ref.read(fleetApiProvider).assignTaxi(routeId, taxi.id));
    if (ok) {
      ref.invalidate(routeProvider(routeId));
      ref.invalidate(taxiRoutesProvider(taxi.id));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final route = ref.watch(routeProvider(routeId));
    return Scaffold(
      appBar: AppBar(title: Text(route.value?.name ?? l10n.route)),
      body: AsyncBody(
        value: route,
        onRefresh: () => ref.refresh(routeProvider(routeId).future),
        builder: (r) => ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Expanded(child: Text(r.stops.join(' → '), style: text.titleMedium)),
            StatusChip(r.status),
          ]),
          if (r.statusReason != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('${l10n.reason}: ${r.statusReason}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Text(l10n.legsAndPrices, style: text.titleMedium)),
            if (r.editable || r.live)
              TextButton.icon(
                onPressed: () => context.push('/fleet/routes/$routeId/prices'),
                icon: const Icon(Icons.sell_outlined, size: 18),
                label: Text(r.editable ? l10n.setPrices : l10n.changePrices),
              ),
          ]),
          if (r.status == 'PENDING') _Notice(icon: Icons.hourglass_top, text: l10n.underReview),
          if (r.live && r.pendingFareChanges > 0)
            _Notice(icon: Icons.hourglass_top, text: l10n.pendingChangesInfo(r.pendingFareChanges)),
          const SizedBox(height: 4),
          LegPriceList(route: r),
          const Divider(height: 32),
          Text(l10n.taxis, style: text.titleMedium),
          if (r.taxis.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.empty)),
          for (final t in r.taxis)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.local_taxi),
              title: Text(t.plateNumber),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/fleet/taxis/${t.taxiId}'),
            ),
          const SizedBox(height: 16),
          if (r.editable) ...[
            if (r.unpricedSubRoutes > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(l10n.priceAllLegs(r.unpricedSubRoutes), style: text.bodySmall),
              ),
            FilledButton(
              onPressed: r.unpricedSubRoutes > 0
                  ? null
                  : () async {
                      final ok = await runAction(context, () => ref.read(fleetApiProvider).submitRoute(routeId));
                      if (ok) {
                        ref.invalidate(routeProvider(routeId));
                        ref.invalidate(routesProvider);
                      }
                    },
              child: Text(l10n.submitForApproval),
            ),
          ],
          if (r.status == 'APPROVED')
            OutlinedButton.icon(onPressed: () => _assign(context, ref, r), icon: const Icon(Icons.add), label: Text(l10n.assignTaxi)),
        ]),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.lightYellow, borderRadius: BorderRadius.circular(AppTheme.radius)),
        child: Row(children: [
          Icon(icon, size: 18, color: AppTheme.navy),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppTheme.navy))),
        ]),
      );
}

String _groupTitle(BuildContext context, LegGroup g) => switch (g) {
      LegGroup.outbound => context.l10n.outboundLegs,
      LegGroup.inbound => context.l10n.returnLegs,
      LegGroup.full => context.l10n.fullRoute,
    };

/// Every leg with the price passengers pay now and, if any, my price waiting for approval.
class LegPriceList extends StatelessWidget {
  const LegPriceList({super.key, required this.route});

  final RouteInfo route;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final entry in route.subRoutes.grouped().entries) ...[
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 2),
          child: Text(_groupTitle(context, entry.key).toUpperCase(),
              style: text.labelSmall?.copyWith(letterSpacing: 0.8, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        for (final s in entry.value)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(s.fullRoute ? Icons.swap_horiz : (s.forward ? Icons.arrow_forward : Icons.arrow_back)),
            title: Text('${s.fromName} → ${s.toName}'),
            subtitle: route.live && s.proposedFare != null
                ? Text('${l10n.newPrice(money(s.proposedFare))} · ${l10n.awaitingApproval}',
                    style: const TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w600))
                : null,
            trailing: Text(
              _shown(s) == null ? l10n.notPriced : money(_shown(s)),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _shown(s) == null ? AppTheme.warning : null,
              ),
            ),
          ),
      ],
    ]);
  }

  /// Before approval my price is the route's price; afterwards show what passengers pay now.
  num? _shown(SubRouteInfo s) => route.live ? s.fare : s.latestPrice;
}

/// Enter or change the price of every leg.
class RoutePricesScreen extends ConsumerStatefulWidget {
  const RoutePricesScreen({super.key, required this.routeId});

  final int routeId;

  @override
  ConsumerState<RoutePricesScreen> createState() => _RoutePricesScreenState();
}

class _RoutePricesScreenState extends ConsumerState<RoutePricesScreen> {
  final _form = GlobalKey<FormState>();
  final Map<int, TextEditingController> _fields = {};
  DateTime? _effectiveFrom;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _field(SubRouteInfo s) => _fields.putIfAbsent(s.id, () {
        final p = s.latestPrice;
        return TextEditingController(text: p == null ? '' : (p % 1 == 0 ? p.toInt().toString() : p.toString()));
      });

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _effectiveFrom ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _effectiveFrom = picked);
  }

  Future<void> _save(RouteInfo r) async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final changes = <int, num>{};
    for (final s in r.subRoutes) {
      final value = num.tryParse(_field(s).text.trim());
      if (value == null) continue;
      if (value != s.latestPrice || !r.live) changes[s.id] = value;
    }
    if (changes.isEmpty) {
      showInfo(context, l10n.nothingChanged);
      return;
    }
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      await ref.read(fleetApiProvider).setFares(widget.routeId, changes, effectiveFrom: r.live ? _effectiveFrom : null);
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ref.invalidate(routeProvider(widget.routeId));
      ref.invalidate(routesProvider);
      showInfo(context, r.live ? l10n.priceChangeSent : l10n.pricesSaved);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final route = ref.watch(routeProvider(widget.routeId));
    return Scaffold(
      appBar: AppBar(title: Text(route.value?.live == true ? l10n.changePrices : l10n.setPrices)),
      body: AsyncBody(
        value: route,
        onRefresh: () => ref.refresh(routeProvider(widget.routeId).future),
        builder: (r) => Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text(r.name, style: text.titleMedium),
            const SizedBox(height: 4),
            Text(r.live ? l10n.priceChangeInfo : l10n.legsInfo, style: text.bodySmall),
            for (final entry in r.subRoutes.grouped().entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Text(_groupTitle(context, entry.key), style: text.titleSmall),
              ),
              for (final s in entry.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Expanded(
                      flex: 3,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${s.fromName} → ${s.toName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (r.live && s.fare != null) Text(money(s.fare), style: text.bodySmall),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        key: Key('price.${s.id}'),
                        controller: _field(s),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(labelText: l10n.priceEtb, isDense: true),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return r.live ? null : l10n.invalidPrice;
                          final n = num.tryParse(t);
                          return n == null || n <= 0 ? l10n.invalidPrice : null;
                        },
                      ),
                    ),
                  ]),
                ),
            ],
            if (r.live) ...[
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(l10n.applyFrom),
                subtitle: Text(_effectiveFrom == null
                    ? l10n.applyWhenApproved
                    : MaterialLocalizations.of(context).formatMediumDate(_effectiveFrom!)),
                trailing: _effectiveFrom == null
                    ? const Icon(Icons.chevron_right)
                    : IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _effectiveFrom = null)),
                onTap: _pickDate,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(onPressed: _busy ? null : () => _save(r), child: Text(l10n.save)),
          ]),
        ),
      ),
    );
  }
}

class AddRouteScreen extends ConsumerStatefulWidget {
  const AddRouteScreen({super.key});

  @override
  ConsumerState<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends ConsumerState<AddRouteScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final List<TextEditingController> _stops = [TextEditingController(), TextEditingController()];
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    for (final s in _stops) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      final route = await ref.read(fleetApiProvider).createRoute({
        'name': _name.text.trim(),
        'points': [for (final s in _stops) {'name': s.text.trim()}],
      });
      ref.invalidate(routesProvider);
      if (mounted) context.pushReplacement('/fleet/routes/${route.id}');
    });
    if (mounted && !ok) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addRoute)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(controller: _name, decoration: InputDecoration(labelText: l10n.routeName, hintText: 'Addis Ababa – Adama'),
              validator: (v) => requiredValidator(context, v)),
          const SizedBox(height: 16),
          Text(l10n.stops, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (var i = 0; i < _stops.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                CircleAvatar(radius: 14, child: Text('${i + 1}', style: const TextStyle(fontSize: 12))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _stops[i], decoration: InputDecoration(labelText: l10n.stopName),
                    validator: (v) => requiredValidator(context, v))),
                if (_stops.length > 2)
                  IconButton(icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setState(() => _stops.removeAt(i).dispose())),
              ]),
            ),
          TextButton.icon(
            onPressed: () => setState(() => _stops.add(TextEditingController())),
            icon: const Icon(Icons.add),
            label: Text(l10n.addStop),
          ),
          const SizedBox(height: 8),
          Text(l10n.routeInfo, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
        ]),
      ),
    );
  }
}
