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

  /// App-layer encryption on top of TLS (ECDH P-256 + AES-256-GCM, see secure_channel.dart).
  static const secureChannel = bool.fromEnvironment('SECURE_CHANNEL', defaultValue: true);

  /// The API's long-term secure-channel public key (base64 raw P-256 point), printed by the API at
  /// startup and served at GET /api/secure/key. Pinning it is what stops a man in the middle; when
  /// empty the app fetches it from the API on first use (fine for development only).
  static const secureChannelServerKey = String.fromEnvironment('SECURE_CHANNEL_SERVER_KEY');

  /// Verbose HTTP logs (never in release builds).
  static const logHttp = bool.fromEnvironment('LOG_HTTP', defaultValue: true);
}
