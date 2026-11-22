import 'dart:typed_data';

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

  Future<List<SeatTemplate>> seatTemplates() =>
      _api.get('/api/merchant/seat-templates', map: (d) => listOf(d, SeatTemplate.fromJson));

  /// PNG of the taxi's QR code, ready to print.
  Future<Uint8List> qrPng(int taxiId) => _api.bytes('/api/merchant/taxis/$taxiId/qr', query: {'size': 1000});

  // ---- drivers
  Future<List<Driver>> drivers() async =>
      (await _api.getPage('/api/merchant/drivers', Driver.fromJson, query: {'size': 100})).content;

  Future<Driver> createDriver(Json request) =>
      _api.post('/api/merchant/drivers', body: request, map: (d) => Driver.fromJson(d as Json));

  // ---- routes
  Future<List<RouteInfo>> routes({String? status}) async =>
      (await _api.getPage('/api/merchant/routes', RouteInfo.fromJson, query: {'size': 100, 'status': status})).content;

  Future<RouteInfo> route(int id) => _api.get('/api/merchant/routes/$id', map: (d) => RouteInfo.fromJson(d as Json));

  Future<RouteInfo> createRoute(Json request) =>
      _api.post('/api/merchant/routes', body: request, map: (d) => RouteInfo.fromJson(d as Json));

  Future<RouteInfo> submitRoute(int id) =>
      _api.post('/api/merchant/routes/$id/submit', map: (d) => RouteInfo.fromJson(d as Json));

  Future<RouteInfo> assignTaxi(int routeId, int taxiId) => _api.post('/api/merchant/routes/$routeId/taxis',
      body: {'taxiId': taxiId}, map: (d) => RouteInfo.fromJson(d as Json));
}

final fleetApiProvider = Provider<FleetApi>((ref) => FleetApi(ref.watch(apiClientProvider)));
