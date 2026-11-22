import 'package:flutter_test/flutter_test.dart';
import 'package:taxipay_merchant/features/fleet/presentation/seat_layout_editor.dart';

void main() {
  test('generates row and side seat codes and the API request', () {
    const layout = SeatLayoutValue(template: 'TOYOTA_HIACE_12', perRow: [2, 3], side: 2);
    expect(layout.rows, [
      ['A1', 'A2'],
      ['B1', 'B2', 'B3'],
    ]);
    expect(layout.sideSeats, ['S1', 'S2']);
    expect(layout.capacity, 7);
    expect(layout.toRequest(), {
      'template': 'TOYOTA_HIACE_12',
      'rows': layout.rows,
      'sideSeats': ['S1', 'S2'],
    });
  });

  test('editing a row turns a template into a custom layout', () {
    final layout = SeatLayoutValue.fromRows([
      ['A1', 'A2'],
    ], template: 'SEDAN_4');
    final edited = layout.copyWith(clearTemplate: true, perRow: [2, 4]);
    expect(edited.template, isNull);
    expect(edited.toRequest().containsKey('template'), isFalse);
    expect(edited.rows.last, ['B1', 'B2', 'B3', 'B4']);
  });
}
