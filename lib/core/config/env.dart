/// Build-time configuration. Override with --dart-define, e.g.
/// `flutter run --dart-define=API_BASE_URL=https://api.taxipay.et`.
class Env {
  Env._();

  /// Default reaches the API on the developer machine from the Android emulator.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080');

  /// Firebase (push notifications). Empty = push off. From the Firebase console → Project settings
  /// → Your apps (Android): API key, App ID, Project number (sender id), Project ID.
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const firebaseSenderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  /// Verbose HTTP logs (never in release builds).
  static const logHttp = bool.fromEnvironment('LOG_HTTP', defaultValue: true);
}
