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
      this.startedAt, this.currentTrip, required this.completedTrips, required this.passengers, required this.revenue});

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
    );
  }
}

enum SeatStatus { available, occupiedUnpaid, occupiedPaid }

class SeatState {
  SeatState({required this.code, required this.row, required this.position, required this.status, this.destination});

  final String code;
  final int row;
  final int position;
  final SeatStatus status;
  final String? destination;

  factory SeatState.fromJson(Json j) => SeatState(
        code: j['code'] as String,
        row: numOf(j['row']).toInt(),
        position: numOf(j['position']).toInt(),
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
      required this.seats, required this.available, required this.occupiedUnpaid, required this.occupiedPaid});

  final int taxiId;
  final String plateNumber;
  final int capacity;
  final Operation? operation;
  final Trip? currentTrip;
  final List<SeatState> seats;
  final int available, occupiedUnpaid, occupiedPaid;

  /// Seats grouped by row, front to back.
  List<List<SeatState>> get rows {
    final byRow = <int, List<SeatState>>{};
    for (final s in seats) {
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
    );
  }
}
