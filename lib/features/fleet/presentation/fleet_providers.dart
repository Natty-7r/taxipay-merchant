import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fleet_api.dart';
import '../data/fleet_models.dart';

final taxisProvider = FutureProvider.autoDispose<List<Taxi>>((ref) => ref.watch(fleetApiProvider).taxis());

final taxiProvider = FutureProvider.autoDispose.family<Taxi, int>((ref, id) => ref.watch(fleetApiProvider).taxi(id));

final driversProvider = FutureProvider.autoDispose<List<Driver>>((ref) => ref.watch(fleetApiProvider).drivers());

final routesProvider = FutureProvider.autoDispose<List<RouteInfo>>((ref) => ref.watch(fleetApiProvider).routes());

final routeProvider =
    FutureProvider.autoDispose.family<RouteInfo, int>((ref, id) => ref.watch(fleetApiProvider).route(id));

final seatTemplatesProvider =
    FutureProvider.autoDispose<List<SeatTemplate>>((ref) => ref.watch(fleetApiProvider).seatTemplates());
