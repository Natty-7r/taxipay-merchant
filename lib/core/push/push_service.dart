import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../live/live_events.dart';
import '../logging/app_logger.dart';
import '../providers.dart';

/// Android channel for Taxi Pay notifications (the API sends with this channel id).
const _channel = AndroidNotificationChannel(
  'taxipay_default',
  'Taxi Pay',
  description: 'Payments, approvals and notices',
  importance: Importance.high,
);

final _local = FlutterLocalNotificationsPlugin();

/// Runs in a background isolate when a push arrives while the app is closed. The system already
/// shows the notification; nothing else to do.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {}

/// A tapped notification's screen, held until the app's navigation is ready to open it.
class PendingLink extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? link) => state = link;

  String? take() {
    final link = state;
    state = null;
    return link;
  }
}

final pendingLinkProvider = NotifierProvider<PendingLink, String?>(PendingLink.new);

/// Push notifications (Firebase Cloud Messaging). Configured with --dart-define values
/// (FIREBASE_API_KEY, FIREBASE_APP_ID, FIREBASE_SENDER_ID, FIREBASE_PROJECT_ID); without them
/// the app runs without push and relies on live events while open.
class PushService {
  PushService(this._ref);

  final Ref _ref;
  static bool _ready = false;
  String? _token;

  static bool get configured => Env.firebaseApiKey.isNotEmpty && Env.firebaseAppId.isNotEmpty;

  /// Call once before runApp.
  static Future<void> initialize() async {
    if (!configured || !(Platform.isAndroid || Platform.isIOS)) {
      appLogger.i('Push notifications off (no Firebase configuration)');
      return;
    }
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: Env.firebaseApiKey,
          appId: Env.firebaseAppId,
          messagingSenderId: Env.firebaseSenderId,
          projectId: Env.firebaseProjectId,
        ),
      );
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
      _ready = true;
    } catch (e) {
      appLogger.w('Firebase not available: $e');
    }
  }

  /// After sign-in: ask permission, register this phone, and open screens from tapped notifications.
  Future<void> start() async {
    if (!_ready) return;
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      appLogger.i('Notifications not allowed on this phone');
      return;
    }
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (r) => _open(r.payload),
    );
    await messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // The API sends with FCM HTTP v1 to registration tokens, so we use getToken / onTokenRefresh
    // rather than the newer installation-id registration.
    // ignore: deprecated_member_use
    _token = await messaging.getToken();
    if (_token != null) await _register(_token!);
    // ignore: deprecated_member_use
    messaging.onTokenRefresh.listen((t) {
      _token = t;
      _register(t);
    });

    // Opened from a notification while closed / in the background.
    final initial = await messaging.getInitialMessage();
    if (initial != null) _open(initial.data['link'] as String?);
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _open(m.data['link'] as String?));

    // In the foreground the live stream already shows a banner; only fill in when it's down.
    FirebaseMessaging.onMessage.listen((m) {
      if (_ref.read(liveEventsProvider.notifier).connected) return;
      final n = m.notification;
      if (n == null) return;
      _local.show(
        id: m.hashCode,
        title: n.title,
        body: n.body,
        payload: m.data['link'] as String?,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(_channel.id, _channel.name,
              channelDescription: _channel.description, importance: Importance.high, priority: Priority.high),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });
  }

  /// On sign-out: this phone stops receiving this account's notifications.
  Future<void> stop() async {
    if (!_ready || _token == null) return;
    try {
      await _ref.read(apiClientProvider).post('/api/devices/unregister',
          body: {'token': _token, 'platform': _platform}, map: (_) {});
    } catch (e) {
      appLogger.w('Push unregister failed: $e');
    }
  }

  Future<void> _register(String token) async {
    try {
      await _ref.read(apiClientProvider).post('/api/devices',
          body: {'token': token, 'platform': _platform, 'app': 'merchant'}, map: (_) {});
      appLogger.i('Push notifications registered');
    } catch (e) {
      appLogger.w('Push register failed: $e');
    }
  }

  void _open(String? link) {
    if (link != null && link.startsWith('/')) _ref.read(pendingLinkProvider.notifier).set(link);
  }

  String get _platform => Platform.isIOS ? 'IOS' : 'ANDROID';
}

final pushServiceProvider = Provider<PushService>(PushService.new);
