import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/ui.dart';
import '../data/operation_models.dart';
import '../data/operations_api.dart';

final activeOperationsProvider =
    FutureProvider.autoDispose<List<Operation>>((ref) => ref.watch(operationsApiProvider).active());

/// Taxis on the road; tap one for its live seat map.
class OperationsScreen extends ConsumerWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabOperate)),
      body: AsyncBody(
        value: ref.watch(activeOperationsProvider),
        onRefresh: () => ref.refresh(activeOperationsProvider.future),
        builder: (ops) => ListView(padding: pagePadding, children: [
          FilledButton.icon(
            onPressed: () => context.push('/operate/start'),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.startOperation),
          ),
          SectionLabel(l10n.onTheRoad),
          if (ops.isEmpty)
            SoftCard(
              child: Row(children: [
                const IconTile(Icons.local_taxi),
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

/// A taxi on the road, in the activity style.
class OperationTile extends StatelessWidget {
  const OperationTile(this.op, {super.key});

  final Operation op;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trip = op.currentTrip;
    return ActivityRow(
      title: '${op.taxi.name ?? ''} · ${op.route.name ?? ''}',
      subtitle: trip == null
          ? '${op.driver.name ?? ''} · ${l10n.completedTrips}: ${op.completedTrips}'
          : '${trip.from} → ${trip.to} · ${trip.passengers} ${l10n.passengers}',
      amount: money(op.revenue),
      caption: trip == null ? null : (trip.boarding ? l10n.boarding : l10n.onTheRoadStatus),
      dotColor: trip == null ? AppTheme.inactiveIcon : (trip.boarding ? AppTheme.warning : AppTheme.success),
      onTap: () => context.push('/operate/taxi/${op.taxi.id}'),
    );
  }
}
