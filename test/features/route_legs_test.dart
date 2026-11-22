import 'package:flutter_test/flutter_test.dart';
import 'package:taxipay_merchant/features/fleet/data/fleet_models.dart';

Map<String, dynamic> leg(int id, String from, String to, String dir, {bool full = false, num? fare, num? proposed}) => {
      'id': id,
      'fromName': from,
      'toName': to,
      'direction': dir,
      'fullRoute': full,
      'fare': fare,
      'proposedFare': proposed,
      'proposedEffectiveFrom': proposed == null ? null : '2099-01-01T00:00:00',
    };

void main() {
  final route = RouteInfo.fromJson({
    'id': 7,
    'name': 'Addis Ababa – Adama',
    'status': 'APPROVED',
    'points': [
      {'name': 'Addis Ababa'},
      {'name': 'Bishoftu'},
      {'name': 'Adama'},
    ],
    'subRoutes': [
      leg(1, 'Addis Ababa', 'Bishoftu', 'FORWARD', fare: 35, proposed: 40),
      leg(2, 'Bishoftu', 'Adama', 'FORWARD', fare: 30),
      leg(3, 'Adama', 'Bishoftu', 'REVERSE', fare: 30),
      leg(4, 'Bishoftu', 'Addis Ababa', 'REVERSE', fare: 35),
      leg(5, 'Addis Ababa', 'Adama', 'FORWARD', full: true, fare: 60),
      leg(6, 'Adama', 'Addis Ababa', 'REVERSE', full: true, fare: 60),
    ],
    'unpricedSubRoutes': 0,
    'pendingFareChanges': 1,
    'taxis': [],
  });

  test('legs are grouped outbound, return, then the full route', () {
    final groups = route.subRoutes.grouped();
    expect(groups.keys, [LegGroup.outbound, LegGroup.inbound, LegGroup.full]);
    expect(groups[LegGroup.outbound]!.map((s) => s.id), [1, 2]);
    expect(groups[LegGroup.inbound]!.map((s) => s.id), [3, 4]);
    expect(groups[LegGroup.full]!.map((s) => s.id), [5, 6]);
  });

  test('a pending change is the latest price but not what passengers pay yet', () {
    final s = route.subRoutes.first;
    expect(route.live, isTrue);
    expect(route.pendingFareChanges, 1);
    expect(s.fare, 35);
    expect(s.proposedFare, 40);
    expect(s.latestPrice, 40);
    expect(s.proposedEffectiveFrom, DateTime(2099));
  });
}
