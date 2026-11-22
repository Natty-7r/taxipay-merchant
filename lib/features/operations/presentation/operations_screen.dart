import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/operate/start'),
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.startOperation),
      ),
      body: AsyncBody(
        value: ref.watch(activeOperationsProvider),
        onRefresh: () => ref.refresh(activeOperationsProvider.future),
        builder: (ops) => ops.isEmpty
            ? EmptyView(icon: Icons.local_taxi, message: l10n.noActiveOperations)
            : ListView(padding: const EdgeInsets.all(16), children: [for (final op in ops) OperationTile(op)]),
      ),
    );
  }
}

class OperationTile extends StatelessWidget {
  const OperationTile(this.op, {super.key});

  final Operation op;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trip = op.currentTrip;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.local_taxi)),
        title: Text('${op.taxi.name ?? ''} · ${op.route.name ?? ''}'),
        subtitle: Text(trip == null
            ? '${op.driver.name ?? ''} · ${l10n.completedTrips}: ${op.completedTrips}'
            : '${l10n.trip} ${trip.tripNumber}: ${trip.from} → ${trip.to} · ${trip.passengers} ${l10n.passengers}'),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(money(op.revenue), style: const TextStyle(fontWeight: FontWeight.bold)),
          if (trip != null) Text(trip.boarding ? l10n.boarding : l10n.onTheRoadStatus, style: Theme.of(context).textTheme.bodySmall),
        ]),
        onTap: () => context.push('/operate/taxi/${op.taxi.id}'),
      ),
    );
  }
}
