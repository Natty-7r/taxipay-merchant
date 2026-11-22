import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../features/auth/presentation/session_controller.dart';

/// App language: the user's saved preference, overridable in Settings for this session.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final session = ref.watch(sessionProvider);
    return switch (session) {
      AsyncData(:final value) when value != null => Locale(value.me.preferredLanguage),
      _ => null,
    };
  }

  void set(Locale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);
