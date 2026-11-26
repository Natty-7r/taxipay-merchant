import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import '../../auth/presentation/session_controller.dart';
import '../../merchant/presentation/setup_guard.dart';
import '../data/operation_models.dart';
import '../data/operations_api.dart';
import '../../../core/theme/app_icons.dart';

final activeOperationsProvider =
    FutureProvider.autoDispose<List<Operation>>((ref) => ref.watch(operationsApiProvider).active());

/// The taxis the signed-in owner or driver can run, with their routes and running operation.
final operableTaxisProvider =
    FutureProvider.autoDispose<List<OperableTaxi>>((ref) => ref.watch(operationsApiProvider).operableTaxis());

/// Taxis on the road; tap one for its live seat map. A driver sees their own taxis.
class OperationsScreen extends ConsumerWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider).value;
    if (session?.isDriver ?? false) return const _DriverOperate();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabOperate)),
      body: AsyncBody(
        value: ref.watch(activeOperationsProvider),
        onRefresh: () => ref.refresh(activeOperationsProvider.future),
        builder: (ops) => ListView(padding: pagePadding, children: [
          FilledButton.icon(
            onPressed: () async {
              if (await ensureSetup(context, ref, forOperating: true) && context.mounted) context.push('/operate/start');
            },
            icon: const Icon(AppIcons.playArrowRounded),
            label: Text(l10n.startOperation),
          ),
          SectionLabel(l10n.onTheRoad),
          if (ops.isEmpty)
            SoftCard(
              child: Row(children: [
                const IconTile(AppIcons.localTaxi),
                const SizedBox(width: 14),
                Expanded(child: Text(l10n.noActiveOperations)),
              ]),
            )
          else
            ListCard(children: [for (final op in ops) OperationTile(op)]),
        ]),
      ),
    );
  }
}

/// A driver's home: hello, and each assigned taxi — running (open it), ready (start it) or not ready.
class _DriverOperate extends ConsumerWidget {
  const _DriverOperate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider).value;
    final fullName = session?.me.fullName ?? '';
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncBody(
          value: ref.watch(operableTaxisProvider),
          onRefresh: () => ref.refresh(operableTaxisProvider.future),
          builder: (taxis) => ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
            GreetingHeader(
              name: fullName,
              title: l10n.hello(fullName.trim().split(RegExp(r'\s+')).first),
              subtitle: '${l10n.driverRole} · ${session?.businessName ?? ''}',
              trailing: const SizedBox.shrink(),
            ),
            SectionLabel(l10n.yourTaxis),
            if (taxis.isEmpty)
              SoftCard(
                child: Row(children: [
                  const IconTile(AppIcons.localTaxi),
                  const SizedBox(width: 14),
                  Expanded(child: Text(l10n.noAssignedTaxis)),
                ]),
              )
            else
              ListCard(children: [for (final t in taxis) _DriverTaxiRow(t)]),
          ]),
        ),
      ),
    );
  }
}

class _DriverTaxiRow extends StatelessWidget {
  const _DriverTaxiRow(this.taxi);

  final OperableTaxi taxi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final op = taxi.activeOperation;
    final trip = op?.currentTrip;
    if (op != null) {
      return ActivityRow(
        title: '${taxi.title} · ${op.route.name ?? ''}',
        subtitle: op.inControl
            ? (trip == null ? l10n.onTheRoadStatus : '${trip.from} → ${trip.to} · ${trip.passengers} ${l10n.passengers}')
            : l10n.operatingBy(op.controller?.name ?? ''),
        amount: money(op.revenue),
        caption: trip == null ? null : (trip.boarding ? l10n.boarding : l10n.onTheRoadStatus),
        dotColor: !op.inControl ? AppTheme.warning : (trip?.boarding ?? false) ? AppTheme.warning : AppTheme.success,
        onTap: () => context.push('/operate/taxi/${taxi.taxiId}'),
      );
    }
    return EntityRow(
      icon: AppIcons.localTaxi,
      title: taxi.title,
      subtitle: !taxi.operational
          ? l10n.taxiNotActive
          : taxi.routes.isEmpty
              ? l10n.noRoutesForTaxi
              : taxi.routes.map((r) => r.name).join(', '),
      trailing: taxi.startable
          ? FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 38), padding: const EdgeInsets.symmetric(horizontal: 16)),
              onPressed: () => context.push('/operate/start?taxi=${taxi.taxiId}'),
              child: Text(l10n.start),
            )
          : null,
    );
  }
}

/// A taxi on the road, in the activity style.
class OperationTile extends StatelessWidget {
  const OperationTile(this.op, {super.key});

  final Operation op;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trip = op.currentTrip;
    final someoneElse = !op.inControl && op.controller != null;
    return ActivityRow(
      title: '${op.taxi.name ?? ''} · ${op.route.name ?? ''}',
      subtitle: someoneElse
          ? l10n.operatingBy(op.controller!.name ?? '')
          : trip == null
              ? '${op.driver.name ?? ''} · ${l10n.completedTrips}: ${op.completedTrips}'
              : '${trip.from} → ${trip.to} · ${trip.passengers} ${l10n.passengers}',
      amount: money(op.revenue),
      caption: trip == null ? null : (trip.boarding ? l10n.boarding : l10n.onTheRoadStatus),
      dotColor: trip == null ? AppTheme.inactiveIcon : (trip.boarding ? AppTheme.warning : AppTheme.success),
      onTap: () => context.push('/operate/taxi/${op.taxi.id}'),
    );
  }
}
