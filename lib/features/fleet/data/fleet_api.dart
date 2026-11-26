import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json.dart';
import 'fleet_models.dart';

class FleetApi {
  FleetApi(this._api);

  final ApiClient _api;

  // ---- taxis
  Future<List<Taxi>> taxis({String? status}) async =>
      (await _api.getPage('/api/merchant/taxis', Taxi.fromJson, query: {'size': 100, 'status': status})).content;

  Future<Taxi> taxi(int id) => _api.get('/api/merchant/taxis/$id', map: (d) => Taxi.fromJson(d as Json));

  Future<Taxi> createTaxi(Json request) =>
      _api.post('/api/merchant/taxis', body: request, map: (d) => Taxi.fromJson(d as Json));

  /// Edit a taxi (pending or rejected; an approved taxi goes back to review when its identity changes).
  Future<Taxi> updateTaxi(int id, Json request) =>
      _api.put('/api/merchant/taxis/$id', body: request, map: (d) => Taxi.fromJson(d as Json));

  Future<List<SeatTemplate>> seatTemplates() =>
      _api.get('/api/merchant/seat-templates', map: (d) => listOf(d, SeatTemplate.fromJson));

  /// PNG of the taxi's QR code, ready to print.
  /// Replace a taxi's seats (template and/or explicit rows, plus side seats).
  Future<Taxi> setSeatLayout(int taxiId, Json layout) =>
      _api.put('/api/merchant/taxis/$taxiId/seat-layout', body: layout, map: (d) => Taxi.fromJson(d as Json));

  /// The text to encode in the taxi's QR code (approved taxis only); the app draws the image.
  Future<TaxiQr> qr(int taxiId) => _api.get('/api/merchant/taxis/$taxiId/qr', map: (d) => TaxiQr.fromJson(d as Json));

  // ---- drivers
  Future<List<Driver>> drivers() async =>
      (await _api.getPage('/api/merchant/drivers', Driver.fromJson, query: {'size': 100})).content;

  Future<Driver> createDriver(Json request) =>
      _api.post('/api/merchant/drivers', body: request, map: (d) => Driver.fromJson(d as Json));

  Future<Driver> updateDriver(int id, Json request) =>
      _api.put('/api/merchant/drivers/$id', body: request, map: (d) => Driver.fromJson(d as Json));

  /// The driver runs exactly these taxis (a taxi has one driver).
  Future<Driver> assignTaxis(int driverId, List<int> taxiIds) =>
      _api.put('/api/merchant/drivers/$driverId/taxis', body: {'taxiIds': taxiIds}, map: (d) => Driver.fromJson(d as Json));

  Future<void> setDriverActive(int id, bool active) =>
      _api.post('/api/merchant/drivers/$id/${active ? 'activate' : 'deactivate'}', map: (_) {});

  // ---- routes
  Future<List<RouteInfo>> routes({String? status, int? taxiId}) async => (await _api.getPage(
          '/api/merchant/routes', RouteInfo.fromJson, query: {'size': 100, 'status': status, 'taxiId': taxiId}))
      .content;

  /// My prices per leg. On an approved route they wait for an admin; the current prices stay meanwhile.
  Future<RouteInfo> setFares(int routeId, Map<int, num> fares, {DateTime? effectiveFrom}) => _api.put(
        '/api/merchant/routes/$routeId/fares',
        body: {
          'fares': [for (final e in fares.entries) {'subRouteId': e.key, 'amount': e.value}],
          if (effectiveFrom != null) 'effectiveFrom': effectiveFrom.toIso8601String().substring(0, 19),
        },
        map: (d) => RouteInfo.fromJson(d as Json),
      );

  Future<RouteInfo> route(int id) => _api.get('/api/merchant/routes/$id', map: (d) => RouteInfo.fromJson(d as Json));

  Future<RouteInfo> createRoute(Json request) =>
      _api.post('/api/merchant/routes', body: request, map: (d) => RouteInfo.fromJson(d as Json));

  /// Edit a draft or rejected route's name and stops (prices of legs that stay are kept).
  Future<RouteInfo> updateRoute(int id, Json request) =>
      _api.put('/api/merchant/routes/$id', body: request, map: (d) => RouteInfo.fromJson(d as Json));

  Future<RouteInfo> submitRoute(int id) =>
      _api.post('/api/merchant/routes/$id/submit', map: (d) => RouteInfo.fromJson(d as Json));

  /// The taxi's driver; null removes it.
  Future<Taxi> setTaxiDriver(int taxiId, int? driverId) =>
      _api.put('/api/merchant/taxis/$taxiId/driver', body: {'driverId': driverId}, map: (d) => Taxi.fromJson(d as Json));

  Future<RouteInfo> assignTaxi(int routeId, int taxiId) => _api.post('/api/merchant/routes/$routeId/taxis',
      body: {'taxiId': taxiId}, map: (d) => RouteInfo.fromJson(d as Json));
}

final fleetApiProvider = Provider<FleetApi>((ref) => FleetApi(ref.watch(apiClientProvider)));
