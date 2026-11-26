import '../../../core/utils/json.dart';

class Ref {
  Ref({required this.id, this.name});

  final int id;
  final String? name;

  factory Ref.fromJson(Json j) => Ref(id: (j['id'] as num).toInt(), name: j['name'] as String?);
}

class Trip {
  Trip({required this.id, required this.tripNumber, required this.direction, this.from, this.to, required this.status,
      required this.passengers, required this.revenue});

  final int id;
  final int tripNumber;
  final String direction;
  final String? from;
  final String? to;

  /// NOT_STARTED (boarding), IN_PROGRESS, COMPLETED, CANCELLED.
  final String status;
  final int passengers;
  final num revenue;

  bool get boarding => status == 'NOT_STARTED';
  bool get onTheRoad => status == 'IN_PROGRESS';

  factory Trip.fromJson(Json j) => Trip(
        id: (j['id'] as num).toInt(),
        tripNumber: numOf(j['tripNumber']).toInt(),
        direction: j['direction'] as String,
        from: j['from'] as String?,
        to: j['to'] as String?,
        status: j['status'] as String,
        passengers: numOf(j['passengers']).toInt(),
        revenue: numOf(j['revenue']),
      );
}

class Operation {
  Operation({required this.id, required this.taxi, required this.route, required this.driver, required this.status,
      this.startedAt, this.currentTrip, required this.completedTrips, required this.passengers, required this.revenue,
      this.standingAllowed = false, this.controller, this.inControl = true});

  /// Who is working the taxi right now (user id and name).
  final Ref? controller;

  /// The signed-in user is working it; anyone else takes over first.
  final bool inControl;

  /// Passengers may pay without a seat on this run.
  final bool standingAllowed;

  final int id;
  final Ref taxi;
  final Ref route;
  final Ref driver;
  final String status;
  final String? startedAt;
  final Trip? currentTrip;
  final int completedTrips;
  final int passengers;
  final num revenue;

  factory Operation.fromJson(Json j) {
    final totals = objOf(j['totals']) ?? const {};
    final trip = objOf(j['currentTrip']);
    return Operation(
      id: (j['id'] as num).toInt(),
      taxi: Ref.fromJson(j['taxi'] as Json),
      route: Ref.fromJson(j['route'] as Json),
      driver: Ref.fromJson(j['driver'] as Json),
      status: j['status'] as String,
      startedAt: j['startedAt'] as String?,
      currentTrip: trip == null ? null : Trip.fromJson(trip),
      completedTrips: numOf(totals['completedTrips']).toInt(),
      passengers: numOf(totals['passengers']).toInt(),
      revenue: numOf(totals['revenue']),
      standingAllowed: (j['standingAllowed'] as bool?) ?? false,
      controller: objOf(j['controller']) == null ? null : Ref.fromJson(objOf(j['controller'])!),
      inControl: (j['inControl'] as bool?) ?? true,
    );
  }
}

/// A route a taxi can start on; FORWARD runs [origin] → [destination].
class RouteChoice {
  RouteChoice({required this.id, required this.name, this.origin, this.destination});

  final int id;
  final String name;
  final String? origin;
  final String? destination;

  factory RouteChoice.fromJson(Json j) => RouteChoice(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String,
        origin: j['origin'] as String?,
        destination: j['destination'] as String?,
      );
}

/// `GET /api/merchant/operate/taxis` — a taxi the signed-in owner or driver can run.
class OperableTaxi {
  OperableTaxi({required this.taxiId, required this.plateNumber, this.sideNumber, required this.operational,
      this.driver, required this.routes, this.activeOperation});

  final int taxiId;
  final String plateNumber;
  final String? sideNumber;
  final bool operational;
  final Ref? driver;
  final List<RouteChoice> routes;
  final Operation? activeOperation;

  String get title => sideNumber == null || sideNumber!.isEmpty ? plateNumber : '$plateNumber · $sideNumber';

  /// Can start now: approved, active, has a route and isn't already running.
  bool get startable => operational && routes.isNotEmpty && activeOperation == null;

  factory OperableTaxi.fromJson(Json j) {
    final op = objOf(j['activeOperation']);
    final driver = objOf(j['driver']);
    return OperableTaxi(
      taxiId: (j['taxiId'] as num).toInt(),
      plateNumber: j['plateNumber'] as String,
      sideNumber: j['sideNumber'] as String?,
      operational: (j['operational'] as bool?) ?? false,
      driver: driver == null ? null : Ref.fromJson(driver),
      routes: listOf(j['routes'], RouteChoice.fromJson),
      activeOperation: op == null ? null : Operation.fromJson(op),
    );
  }
}

/// One payment on a trip: who paid (masked), how, and each passenger it covers.
class TripPayment {
  TripPayment({required this.reference, this.provider, this.payerPhone, required this.amount, required this.status,
      required this.passengers, this.paidAt, required this.tickets});

  final String reference;
  final String? provider;
  final String? payerPhone;
  final num amount;
  final String status;
  final int passengers;
  final String? paidAt;
  final List<TripTicket> tickets;

  factory TripPayment.fromJson(Json j) => TripPayment(
        reference: j['reference'] as String,
        provider: j['provider'] as String?,
        payerPhone: j['payerPhone'] as String?,
        amount: numOf(j['amount']),
        status: j['status'] as String? ?? 'SUCCESSFUL',
        passengers: numOf(j['passengers']).toInt(),
        paidAt: j['paidAt'] as String?,
        tickets: listOf(j['tickets'], TripTicket.fromJson),
      );
}

class TripTicket {
  TripTicket({required this.origin, required this.destination, this.seatCode, required this.fare, required this.status,
      required this.onBoard});

  final String origin;
  final String destination;
  final String? seatCode;
  final num fare;
  final String status;

  /// Still holding the seat; false once freed (got off).
  final bool onBoard;

  factory TripTicket.fromJson(Json j) => TripTicket(
        origin: j['origin'] as String,
        destination: j['destination'] as String,
        seatCode: j['seatCode'] as String?,
        fare: numOf(j['fare']),
        status: j['status'] as String? ?? 'PAID',
        onBoard: (j['onBoard'] as bool?) ?? false,
      );
}

enum SeatStatus { available, occupiedUnpaid, occupiedPaid }

class SeatState {
  SeatState({required this.code, required this.row, required this.position, this.side = false, required this.status, this.destination});

  final String code;
  final int row;
  final int position;

  /// Along the side of the vehicle (row 0).
  final bool side;
  final SeatStatus status;
  final String? destination;

  factory SeatState.fromJson(Json j) => SeatState(
        code: j['code'] as String,
        row: numOf(j['row']).toInt(),
        position: numOf(j['position']).toInt(),
        side: (j['side'] as bool?) ?? false,
        status: switch (j['status']) {
          'OCCUPIED_PAID' => SeatStatus.occupiedPaid,
          'OCCUPIED_UNPAID' => SeatStatus.occupiedUnpaid,
          _ => SeatStatus.available,
        },
        destination: j['destination'] as String?,
      );
}

/// `GET /api/merchant/taxis/{id}/live` — what the taxi is doing now.
class LiveTaxi {
  LiveTaxi({required this.taxiId, required this.plateNumber, required this.capacity, this.operation, this.currentTrip,
      required this.seats, required this.available, required this.occupiedUnpaid, required this.occupiedPaid,
      this.payments = const []});

  /// Payments on the current trip, newest first.
  final List<TripPayment> payments;

  final int taxiId;
  final String plateNumber;
  final int capacity;
  final Operation? operation;
  final Trip? currentTrip;
  final List<SeatState> seats;
  final int available, occupiedUnpaid, occupiedPaid;

  /// Side seats, front to back.
  List<SeatState> get sideSeats => seats.where((s) => s.side).toList()..sort((a, b) => a.position.compareTo(b.position));

  /// Seats grouped by row, front to back (side seats excluded).
  List<List<SeatState>> get rows {
    final byRow = <int, List<SeatState>>{};
    for (final s in seats.where((s) => !s.side)) {
      byRow.putIfAbsent(s.row, () => []).add(s);
    }
    final keys = byRow.keys.toList()..sort();
    return [for (final k in keys) byRow[k]!..sort((a, b) => a.position.compareTo(b.position))];
  }

  factory LiveTaxi.fromJson(Json j) {
    final op = objOf(j['operation']);
    final trip = objOf(j['currentTrip']);
    return LiveTaxi(
      taxiId: (j['taxiId'] as num).toInt(),
      plateNumber: j['plateNumber'] as String,
      capacity: numOf(j['capacity']).toInt(),
      operation: op == null ? null : Operation.fromJson(op),
      currentTrip: trip == null ? null : Trip.fromJson(trip),
      seats: listOf(j['seats'], SeatState.fromJson),
      available: numOf(j['available']).toInt(),
      occupiedUnpaid: numOf(j['occupiedUnpaid']).toInt(),
      occupiedPaid: numOf(j['occupiedPaid']).toInt(),
      payments: listOf(j['payments'], TripPayment.fromJson),
    );
  }
}
