/// Build-time configuration. Override with --dart-define, e.g.
/// `flutter run --dart-define=API_BASE_URL=https://api.taxipay.et`.
class Env {
  Env._();

  /// Default reaches the API on the developer machine from the Android emulator.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080');

  /// Verbose HTTP logs (never in release builds).
  static const logHttp = bool.fromEnvironment('LOG_HTTP', defaultValue: true);
}
