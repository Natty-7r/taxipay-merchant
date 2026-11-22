import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// One logger for the app. Debug builds log everything; release builds only warnings and errors,
/// and never request bodies (see ApiClient).
final appLogger = Logger(
  level: kReleaseMode ? Level.warning : Level.debug,
  printer: PrettyPrinter(methodCount: 0, errorMethodCount: 6, lineLength: 100, noBoxingByDefault: true),
);
