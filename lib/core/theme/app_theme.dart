import 'package:material_ui/material_ui.dart';

/// Taxi Pay brand: Addis taxi blue with a warm amber accent.
class AppTheme {
  AppTheme._();

  static const brandBlue = Color(0xFF1456B8);
  static const accent = Color(0xFFF2A900);

  // Seat map colours (also used in the legend).
  static const seatAvailable = Color(0xFFE3E8EF);
  static const seatUnpaid = Color(0xFFF2A900);
  static const seatPaid = Color(0xFF1E9E5A);

  static ThemeData light() => _theme(Brightness.light);

  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: brandBlue, secondary: accent, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
      cardTheme: const CardThemeData(margin: EdgeInsets.zero),
    );
  }
}
