import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json.dart';
import 'operation_models.dart';

class OperationsApi {
  OperationsApi(this._api);

  final ApiClient _api;

  Future<List<Operation>> active() async => (await _api.getPage('/api/merchant/operations', Operation.fromJson,
          query: {'status': 'ACTIVE', 'size': 100, 'sortBy': 'startedAt'}))
      .content;

  /// [direction] FORWARD = first stop → last, REVERSE = last → first.
  Future<Operation> start({required int taxiId, required int routeId, int? driverId, String direction = 'FORWARD',
          bool standingAllowed = false}) =>
      _api.post('/api/merchant/operations',
          body: {
            'taxiId': taxiId,
            'routeId': routeId,
            'driverId': driverId,
            'firstDirection': direction,
            'standingAllowed': standingAllowed,
          }..removeWhere((_, v) => v == null),
          map: (d) => Operation.fromJson(d as Json));

  /// Allow / stop passengers paying without a seat — any time during the run.
  Future<void> setStanding(int operationId, bool allowed) =>
      _api.put('/api/merchant/operations/$operationId/standing', body: {'allowed': allowed}, map: (_) {});

  Future<void> finish(int operationId) => _api.post('/api/merchant/operations/$operationId/finish', map: (_) {});

  Future<void> openTrip(int operationId, {String? direction}) => _api.post('/api/merchant/operations/$operationId/trips',
      body: direction == null ? null : {'direction': direction}, map: (_) {});

  Future<void> depart(int tripId) => _api.post('/api/merchant/trips/$tripId/depart', map: (_) {});

  Future<void> complete(int tripId, {required bool openNext}) =>
      _api.post('/api/merchant/trips/$tripId/complete', body: {'openNext': openNext}, map: (_) {});

  Future<void> setSeat(int tripId, String code, bool occupied) =>
      _api.put('/api/merchant/trips/$tripId/seats/$code', body: {'occupied': occupied}, map: (_) {});

  /// The owner's taxis, or a driver's assigned ones, with their routes and running operation.
  Future<List<OperableTaxi>> operableTaxis() => _api.get('/api/merchant/operate/taxis',
      map: (d) => [for (final t in d as List) OperableTaxi.fromJson(t as Json)]);

  /// Become the one working this taxi (only one person at a time).
  Future<void> takeOver(int operationId) =>
      _api.post('/api/merchant/operations/$operationId/take-over', map: (_) {});

  Future<LiveTaxi> live(int taxiId) =>
      _api.get('/api/merchant/taxis/$taxiId/live', map: (d) => LiveTaxi.fromJson(d as Json));
}

final operationsApiProvider = Provider<OperationsApi>((ref) => OperationsApi(ref.watch(apiClientProvider)));
