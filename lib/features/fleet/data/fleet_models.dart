import '../../../core/utils/json.dart';

class Taxi {
  Taxi({
    required this.id,
    required this.plateNumber,
    this.sideNumber,
    required this.vehicleType,
    required this.manufacturer,
    required this.model,
    this.year,
    this.color,
    required this.hasImage,
    required this.seatRows,
    this.sideSeats = const [],
    required this.capacity,
    this.seatTemplate,
    this.defaultDriverId,
    this.defaultDriverName,
    required this.status,
    required this.active,
    required this.operational,
    this.statusReason,
    this.qrUrl,
  });

  final int id;
  final String plateNumber;
  final String? sideNumber;
  final String vehicleType;
  final String manufacturer;
  final String model;
  final int? year;
  final String? color;
  final bool hasImage;
  final List<List<String>> seatRows;
  final List<String> sideSeats;
  final int capacity;
  final String? seatTemplate;
  final int? defaultDriverId;
  final String? defaultDriverName;
  final String status;
  final bool active;
  final bool operational;
  final String? statusReason;
  final String? qrUrl;

  String get title => sideNumber == null ? plateNumber : '$plateNumber · $sideNumber';

  factory Taxi.fromJson(Json j) {
    final layout = objOf(j['seatLayout']) ?? const {};
    final driver = objOf(j['defaultDriver']);
    return Taxi(
      id: (j['id'] as num).toInt(),
      plateNumber: j['plateNumber'] as String,
      sideNumber: j['sideNumber'] as String?,
      vehicleType: j['vehicleType'] as String,
      manufacturer: j['manufacturer'] as String,
      model: j['model'] as String,
      year: (j['manufactureYear'] as num?)?.toInt(),
      color: j['color'] as String?,
      hasImage: (j['hasImage'] as bool?) ?? false,
      seatRows: ((layout['rows'] as List?) ?? const [])
          .map((r) => (r as List).map((c) => c as String).toList())
          .toList(),
      capacity: numOf(layout['capacity']).toInt(),
      sideSeats: ((layout['sideSeats'] as List?) ?? const []).map((c) => c as String).toList(),
      seatTemplate: layout['template'] as String?,
      defaultDriverId: (driver?['id'] as num?)?.toInt(),
      defaultDriverName: driver?['fullName'] as String?,
      status: j['status'] as String,
      active: (j['active'] as bool?) ?? true,
      operational: (j['operational'] as bool?) ?? false,
      statusReason: j['statusReason'] as String?,
      qrUrl: j['qrUrl'] as String?,
    );
  }
}

class SeatTemplate {
  SeatTemplate({required this.code, required this.name, required this.vehicleType, required this.capacity, required this.rows});

  final String code;
  final String name;
  final String vehicleType;
  final int capacity;
  final List<List<String>> rows;

  factory SeatTemplate.fromJson(Json j) => SeatTemplate(
        code: j['code'] as String,
        name: j['name'] as String,
        vehicleType: j['vehicleType'] as String,
        capacity: numOf(j['capacity']).toInt(),
        rows: ((j['rows'] as List?) ?? const []).map((r) => (r as List).map((c) => c as String).toList()).toList(),
      );
}

class Driver {
  Driver({required this.id, required this.fullName, required this.phoneNumber, required this.licenseNumber,
      required this.licenseExpired, required this.active, this.canLogin = false, this.taxiIds = const []});

  final int id;
  final String fullName;
  final String phoneNumber;
  final String licenseNumber;
  final bool licenseExpired;
  final bool active;

  /// Has a password and signs in to the app to run their taxis.
  final bool canLogin;

  /// Taxis assigned to this driver.
  final List<int> taxiIds;

  factory Driver.fromJson(Json j) => Driver(
        id: (j['id'] as num).toInt(),
        fullName: j['fullName'] as String,
        phoneNumber: j['phoneNumber'] as String,
        licenseNumber: j['licenseNumber'] as String,
        licenseExpired: (j['licenseExpired'] as bool?) ?? false,
        active: (j['active'] as bool?) ?? true,
        canLogin: (j['canLogin'] as bool?) ?? false,
        taxiIds: [for (final id in (j['taxiIds'] as List?) ?? const []) (id as num).toInt()],
      );
}

/// A leg of a route: two neighbouring stops, or the full route. Priced by the merchant.
class SubRouteInfo {
  SubRouteInfo({
    required this.id,
    required this.fromName,
    required this.toName,
    required this.direction,
    required this.fullRoute,
    this.fare,
    this.proposedFare,
    this.proposedEffectiveFrom,
  });

  final int id;
  final String fromName;
  final String toName;
  final String direction;
  final bool fullRoute;

  /// Approved price passengers pay now.
  final num? fare;

  /// My price waiting for admin approval.
  final num? proposedFare;
  final DateTime? proposedEffectiveFrom;

  bool get forward => direction == 'FORWARD';

  /// The price to show in an edit field: my pending price, else the approved one.
  num? get latestPrice => proposedFare ?? fare;

  factory SubRouteInfo.fromJson(Json j) => SubRouteInfo(
        id: (j['id'] as num).toInt(),
        fromName: j['fromName'] as String,
        toName: j['toName'] as String,
        direction: j['direction'] as String,
        fullRoute: (j['fullRoute'] as bool?) ?? false,
        fare: j['fare'] as num?,
        proposedFare: j['proposedFare'] as num?,
        proposedEffectiveFrom: j['proposedEffectiveFrom'] == null ? null : DateTime.parse(j['proposedEffectiveFrom'] as String),
      );
}

/// Journeys from one stop: all A → … together, then B → …; return journeys after.
class LegGroup {
  LegGroup(this.from, this.forward, this.legs);

  final String from;
  final bool forward;
  final List<SubRouteInfo> legs;
}

extension LegGrouping on List<SubRouteInfo> {
  /// Grouped by starting stop, outbound first, in the order the API lists them (by stop order).
  List<LegGroup> grouped() {
    final groups = <String, LegGroup>{};
    for (final s in [...where((s) => s.forward), ...where((s) => !s.forward)]) {
      groups.putIfAbsent('${s.forward}|${s.fromName}', () => LegGroup(s.fromName, s.forward, [])).legs.add(s);
    }
    return groups.values.toList();
  }
}

class AssignedTaxi {
  AssignedTaxi({required this.taxiId, required this.plateNumber});

  final int taxiId;
  final String plateNumber;

  factory AssignedTaxi.fromJson(Json j) =>
      AssignedTaxi(taxiId: (j['taxiId'] as num).toInt(), plateNumber: j['plateNumber'] as String);
}

/// A merchant route ("RouteInfo" — Flutter already has a Route class).
class RouteInfo {
  RouteInfo({
    required this.id,
    required this.name,
    this.origin,
    this.destination,
    required this.status,
    this.statusReason,
    required this.stops,
    required this.subRoutes,
    required this.unpricedSubRoutes,
    required this.pendingFareChanges,
    required this.taxis,
  });

  final int id;
  final String name;
  final String? origin;
  final String? destination;
  final String status;
  final String? statusReason;
  final List<String> stops;
  final List<SubRouteInfo> subRoutes;
  final int unpricedSubRoutes;
  final int pendingFareChanges;
  final List<AssignedTaxi> taxis;

  bool get editable => status == 'DRAFT' || status == 'REJECTED';

  /// Approved (or paused) — price changes need an admin's approval.
  bool get live => status == 'APPROVED' || status == 'INACTIVE';

  factory RouteInfo.fromJson(Json j) => RouteInfo(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String,
        origin: j['origin'] as String?,
        destination: j['destination'] as String?,
        status: j['status'] as String,
        statusReason: j['statusReason'] as String?,
        stops: listOf(j['points'], (p) => p['name'] as String),
        subRoutes: listOf(j['subRoutes'], SubRouteInfo.fromJson),
        unpricedSubRoutes: numOf(j['unpricedSubRoutes']).toInt(),
        pendingFareChanges: numOf(j['pendingFareChanges']).toInt(),
        taxis: listOf(j['taxis'], AssignedTaxi.fromJson),
      );
}

/// A taxi's QR code value from the API.
class TaxiQr {
  TaxiQr({required this.taxiId, required this.plateNumber, this.sideNumber, required this.value});

  final int taxiId;
  final String plateNumber;
  final String? sideNumber;

  /// Encode exactly this text.
  final String value;

  factory TaxiQr.fromJson(Json j) => TaxiQr(
        taxiId: (j['taxiId'] as num).toInt(),
        plateNumber: j['plateNumber'] as String,
        sideNumber: j['sideNumber'] as String?,
        value: j['value'] as String,
      );
}

/// Vehicle types the API accepts; OTHER for anything that doesn't fit.
const vehicleTypes = ['MINIBUS', 'MIDIBUS', 'BUS', 'SEDAN', 'OTHER'];
