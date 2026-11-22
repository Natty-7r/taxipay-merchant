import 'package:flutter_test/flutter_test.dart';
import 'package:taxipay_merchant/features/fleet/data/fleet_models.dart';
import 'package:taxipay_merchant/features/operations/data/operation_models.dart';

void main() {
  test('Taxi maps the seat layout, default driver and QR url', () {
    final t = Taxi.fromJson({
      'id': 5, 'plateNumber': 'AA 3-12345', 'sideNumber': 'T-17', 'vehicleType': 'MINIBUS',
      'manufacturer': 'Toyota', 'model': 'Hiace', 'manufactureYear': 2018, 'hasImage': false,
      'seatLayout': {'template': 'TOYOTA_HIACE_12', 'capacity': 3, 'rows': [['A1', 'A2'], ['B1']]},
      'defaultDriver': {'id': 2, 'fullName': 'Kebede', 'phoneNumber': '251912000000'},
      'status': 'APPROVED', 'active': true, 'operational': true, 'qrUrl': 'https://pay.taxipay.et/t/abc',
    });
    expect(t.title, 'AA 3-12345 · T-17');
    expect(t.seatRows, [['A1', 'A2'], ['B1']]);
    expect(t.capacity, 3);
    expect(t.defaultDriverName, 'Kebede');
    expect(t.qrUrl, endsWith('/abc'));
  });

  test('LiveTaxi groups seats by row and maps seat statuses', () {
    final live = LiveTaxi.fromJson({
      'taxiId': 5, 'plateNumber': 'AA 3-12345', 'capacity': 3,
      'currentTrip': {'id': 9, 'tripNumber': 2, 'direction': 'REVERSE', 'from': 'Adama', 'to': 'Addis Ababa',
        'status': 'NOT_STARTED', 'passengers': 1, 'revenue': 60.0},
      'seats': [
        {'code': 'B1', 'row': 2, 'position': 1, 'status': 'AVAILABLE'},
        {'code': 'A2', 'row': 1, 'position': 2, 'status': 'OCCUPIED_UNPAID'},
        {'code': 'A1', 'row': 1, 'position': 1, 'status': 'OCCUPIED_PAID', 'destination': 'Addis Ababa'},
      ],
      'available': 1, 'occupiedUnpaid': 1, 'occupiedPaid': 1,
    });
    expect(live.rows.map((r) => r.map((s) => s.code).toList()).toList(), [['A1', 'A2'], ['B1']]);
    expect(live.rows.first.first.status, SeatStatus.occupiedPaid);
    expect(live.currentTrip!.boarding, isTrue);
    expect(live.currentTrip!.revenue, 60);
    expect(live.operation, isNull);
  });

  test('RouteInfo knows when it can still be edited', () {
    RouteInfo route(String status) => RouteInfo.fromJson({
          'id': 1, 'name': 'Addis – Adama', 'status': status, 'points': [{'name': 'Addis'}, {'name': 'Adama'}],
          'subRoutes': [{'id': 3, 'fromName': 'Addis', 'toName': 'Adama', 'direction': 'FORWARD', 'fare': 60}],
          'unpricedSubRoutes': 0, 'taxis': <Object>[],
        });
    expect(route('DRAFT').editable, isTrue);
    expect(route('REJECTED').editable, isTrue);
    expect(route('PENDING').editable, isFalse);
    expect(route('DRAFT').stops, ['Addis', 'Adama']);
  });
}
