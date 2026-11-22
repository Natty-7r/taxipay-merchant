import 'package:material_ui/material_ui.dart';

/// Taxi Pay brand (taxi-pay/brand/BRAND.md): taxi yellow for actions and key figures,
/// deep navy for text and navigation, white / soft backgrounds everywhere else.
class AppTheme {
  AppTheme._();

  static const yellow = Color(0xFFFEBA07);
  static const navy = Color(0xFF011D33);
  static const white = Color(0xFFFFFFFF);
  static const softBackground = Color(0xFFF8FAFC);
  static const lightYellow = Color(0xFFFFF4CC);
  static const darkYellow = Color(0xFFD99A00);
  static const navyLight = Color(0xFF163B55);
  static const border = Color(0xFFE2E8F0);
  static const textGray = Color(0xFF64748B);
  static const inactiveIcon = Color(0xFF94A3B8);

  // Status colours — reserved for payment and operational states.
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFDC2626);

  // Seat map colours (also used in the legend).
  static const seatAvailable = Color(0xFFE2E8F0);
  static const seatUnpaid = warning;
  static const seatPaid = success;

  static const radius = 12.0;

  static ThemeData light() => _theme(Brightness.light);

  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF06192A) : white;
    final background = dark ? const Color(0xFF00101D) : softBackground;
    final onSurface = dark ? const Color(0xFFF1F5F9) : navy;
    final outline = dark ? const Color(0xFF1E3A52) : border;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: yellow,
      onPrimary: navy,
      primaryContainer: dark ? const Color(0xFF3A2E00) : lightYellow,
      onPrimaryContainer: dark ? const Color(0xFFFFE08A) : navy,
      secondary: dark ? const Color(0xFF7CB3DD) : navyLight,
      onSecondary: white,
      secondaryContainer: dark ? navyLight : const Color(0xFFE6EEF5),
      onSecondaryContainer: dark ? white : navy,
      tertiary: success,
      onTertiary: white,
      error: error,
      onError: white,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: dark ? inactiveIcon : textGray,
      surfaceContainerLowest: surface,
      surfaceContainerLow: dark ? const Color(0xFF081D30) : white,
      surfaceContainer: dark ? const Color(0xFF0B2236) : const Color(0xFFF1F5F9),
      surfaceContainerHigh: dark ? const Color(0xFF0D2437) : const Color(0xFFEFF3F7),
      surfaceContainerHighest: dark ? const Color(0xFF12304A) : const Color(0xFFE9EEF3),
      outline: outline,
      outlineVariant: outline,
      inverseSurface: dark ? white : navy,
      onInverseSurface: dark ? navy : white,
      inversePrimary: darkYellow,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    final buttonText = const TextStyle(fontWeight: FontWeight.w700, fontSize: 15);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: navy,
        foregroundColor: white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(color: white, fontSize: 19, fontWeight: FontWeight.w600),
        iconTheme: const IconThemeData(color: white),
        actionsIconTheme: const IconThemeData(color: white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navy,
        surfaceTintColor: Colors.transparent,
        indicatorColor: yellow,
        indicatorShape: shape,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? navy : inactiveIcon),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? yellow : inactiveIcon,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: navy,
          disabledBackgroundColor: dark ? const Color(0xFF1E3A52) : border,
          minimumSize: const Size.fromHeight(50),
          shape: shape,
          textStyle: buttonText,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.pressed) ? darkYellow.withValues(alpha: 0.5) : null,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: yellow, foregroundColor: navy, shape: shape, textStyle: buttonText),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: outline),
          shape: shape,
          minimumSize: const Size(0, 46),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: dark ? yellow : navyLight, textStyle: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: yellow,
        foregroundColor: navy,
        shape: shape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: outline)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: dark ? yellow : navy, width: 1.6),
        ),
        floatingLabelStyle: TextStyle(color: dark ? yellow : navy),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: BorderSide(color: outline)),
      ),
      chipTheme: ChipThemeData(
        selectedColor: yellow,
        checkmarkColor: navy,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(selectedBackgroundColor: yellow, selectedForegroundColor: navy),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: yellow),
      dividerTheme: DividerThemeData(color: outline, space: 1),
      listTileTheme: ListTileThemeData(iconColor: dark ? inactiveIcon : navyLight),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navy,
        contentTextStyle: const TextStyle(color: white),
        actionTextColor: yellow,
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
    );
  }
}

/// The Taxi Pay logo with the "Scan. Pay. Ride." tagline.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 160});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.14),
        child: Image.asset('assets/brand/logo.png', width: size, height: size, fit: BoxFit.contain),
      );
}
