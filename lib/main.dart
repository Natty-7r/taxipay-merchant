import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/logging/app_logger.dart';
import 'core/push/push_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await PushService.initialize();
    FlutterError.onError = (details) {
      appLogger.e('Flutter error', error: details.exception, stackTrace: details.stack);
      if (kDebugMode) FlutterError.presentError(details);
    };
    appLogger.i('Taxi Pay Merchant starting — API ${Env.apiBaseUrl}');
    // No automatic retries: a failed call shows an error with "Try again" instead.
    runApp(ProviderScope(retry: (_, _) => null, child: const TaxiPayMerchantApp()));
  }, (error, stack) => appLogger.e('Uncaught error', error: error, stackTrace: stack));
}
