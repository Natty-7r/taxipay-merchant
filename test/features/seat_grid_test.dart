import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taxipay_merchant/features/fleet/presentation/seat_grid.dart';

Future<void> pumpGrid(WidgetTester tester, {required double width, required List<List<String>> rows, List<String> side = const []}) async {
  tester.view.physicalSize = Size(width * 3, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ListView(padding: const EdgeInsets.all(26), children: [
        SeatGrid(rows: rows, sideSeats: side, seatBuilder: (code) => SeatBox(code)),
      ]),
    ),
  ));
}

void main() {
  const custom = [
    ['A1', 'A2'],
    ['B1', 'B2', 'B3'],
    ['C1', 'C2', 'C3'],
    ['D1', 'D2', 'D3', 'D4'],
  ];

  testWidgets('a back row of four plus side seats fits a narrow phone', (tester) async {
    await pumpGrid(tester, width: 360, rows: custom, side: ['S1', 'S2', 'S3']);
    expect(tester.takeException(), isNull);
    expect(find.text('D4'), findsOneWidget);
    expect(find.text('S3'), findsOneWidget);
  });

  testWidgets('a very wide layout scrolls sideways instead of overflowing', (tester) async {
    await pumpGrid(tester, width: 320, rows: [
      ['A1', 'A2', 'A3', 'A4', 'A5', 'A6'],
    ], side: ['S1', 'S2']);
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });

  testWidgets('a small layout stays full size', (tester) async {
    await pumpGrid(tester, width: 400, rows: [
      ['A1', 'A2'],
      ['B1', 'B2', 'B3'],
    ]);
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SeatBox).first).width, SeatBox.width);
  });
}
