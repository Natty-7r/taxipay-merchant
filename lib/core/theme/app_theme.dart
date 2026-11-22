import 'package:material_ui/material_ui.dart';

/// Taxi Pay brand (taxi-pay/brand/BRAND.md): taxi yellow for actions and key figures,
/// deep navy for text and navigation, white / soft backgrounds everywhere else.
class AppTheme {
  AppTheme._();

  static const yellow = Color(0xFFFEBA07);
  static const navy = Color(0xFF011D33);
  static const white = Color(0xFFFFFFFF);
  static const softBackground = Color(0xFFF8FAFC);

  /// Warm off-white screen background of the app design.
  static const canvas = Color(0xFFFAF9F6);
  static const cardBorder = Color(0xFFECEAE5);
  static const darkCanvas = Color(0xFF07131F);
  static const darkCard = Color(0xFF0F1F2E);
  static const darkBorder = Color(0xFF1C3044);
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
  static const cardRadius = 16.0;

  static ThemeData light() => _theme(Brightness.light);

  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? darkCard : white;
    final background = dark ? darkCanvas : canvas;
    final onSurface = dark ? const Color(0xFFF1F5F9) : navy;
    final outline = dark ? darkBorder : cardBorder;

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
      surfaceContainerLow: surface,
      surfaceContainer: dark ? const Color(0xFF132638) : const Color(0xFFF4F2EE),
      surfaceContainerHigh: dark ? const Color(0xFF162B3F) : const Color(0xFFF0EEE9),
      surfaceContainerHighest: dark ? const Color(0xFF1B3349) : const Color(0xFFEAE8E3),
      outline: outline,
      outlineVariant: outline,
      inverseSurface: dark ? white : navy,
      onInverseSurface: dark ? navy : white,
      inversePrimary: darkYellow,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    final base = ThemeData(brightness: brightness, useMaterial3: true).textTheme;
    final text = base
        .apply(bodyColor: onSurface, displayColor: onSurface)
        .copyWith(
          headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: onSurface),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: onSurface),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: onSurface),
          titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: onSurface),
        );
    final buttonText = text.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 15);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: text,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: onSurface, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3),
        iconTheme: IconThemeData(color: onSurface),
        actionsIconTheme: IconThemeData(color: onSurface),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: navy,
          disabledBackgroundColor: outline,
          minimumSize: const Size.fromHeight(52),
          shape: shape,
          textStyle: buttonText,
          elevation: 0,
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
          backgroundColor: surface,
          side: BorderSide(color: outline),
          shape: shape,
          minimumSize: const Size(0, 46),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: dark ? yellow : navy, textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: yellow,
        foregroundColor: navy,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: outline)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: yellow, width: 1.8),
        ),
        floatingLabelStyle: text.bodyLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: dark ? 0.3 : 0.06),
        elevation: dark ? 0 : 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius), side: BorderSide(color: outline)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: yellow,
        checkmarkColor: navy,
        labelStyle: text.labelLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: navy, fontWeight: FontWeight.w700),
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(selectedBackgroundColor: yellow, selectedForegroundColor: navy, side: BorderSide(color: outline)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: onSurface,
        unselectedLabelColor: dark ? inactiveIcon : textGray,
        indicatorColor: yellow,
        dividerColor: outline,
        labelStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: yellow),
      dividerTheme: DividerThemeData(color: outline, space: 1, thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: onSurface,
        titleTextStyle: text.bodyLarge?.copyWith(color: onSurface, fontSize: 15, fontWeight: FontWeight.w700),
        subtitleTextStyle: text.bodySmall?.copyWith(color: dark ? inactiveIcon : textGray, fontSize: 12.5),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navy,
        contentTextStyle: text.bodyMedium?.copyWith(color: white),
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
