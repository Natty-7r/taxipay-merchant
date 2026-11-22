import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../logging/app_logger.dart';
import '../providers.dart';
import 'live_refresh.dart';

/// Something that just happened for this merchant (a payment, a review…), from `GET /api/events`.
class LiveEvent {
  LiveEvent({required this.id, required this.event, required this.title, required this.body, this.link});

  final int? id;
  final String event;
  final String title;
  final String body;

  /// The screen to open, e.g. /operate/taxi/12.
  final String? link;

  factory LiveEvent.fromJson(Map<String, dynamic> j) => LiveEvent(
        id: (j['notificationId'] as num?)?.toInt(),
        event: j['event'] as String? ?? '',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        link: j['link'] as String?,
      );
}

/// Splits a server-sent event stream into (event name, data) pairs.
class SseParser {
  final _buffer = StringBuffer();
  String _event = 'message';
  final _data = <String>[];

  /// Feeds a chunk; returns the events completed by it.
  List<(String, String)> add(String chunk) {
    final out = <(String, String)>[];
    _buffer.write(chunk);
    var text = _buffer.toString();
    var newline = text.indexOf('\n');
    while (newline >= 0) {
      final line = text.substring(0, newline).replaceAll('\r', '');
      text = text.substring(newline + 1);
      if (line.isEmpty) {
        if (_data.isNotEmpty) out.add((_event, _data.join('\n')));
        _event = 'message';
        _data.clear();
      } else if (line.startsWith('event:')) {
        _event = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        _data.add(line.substring(5).trimLeft());
      }
      newline = text.indexOf('\n');
    }
    _buffer
      ..clear()
      ..write(text);
    return out;
  }
}

/// Keeps `GET /api/events` open while the app is in the foreground and signed in, reconnecting
/// with a back-off. Each event is published as the state, for the banner and screen refresh.
class LiveEventsController extends Notifier<LiveEvent?> {
  CancelToken? _cancel;
  Timer? _retry;
  int _failures = 0;
  bool _wanted = false;

  /// True while the stream is open — push messages in the foreground are then redundant.
  bool connected = false;

  @override
  LiveEvent? build() {
    ref.onDispose(stop);
    return null;
  }

  void start() {
    if (_wanted) return;
    _wanted = true;
    _connect();
  }

  void stop() {
    _wanted = false;
    _retry?.cancel();
    _cancel?.cancel();
    _cancel = null;
    connected = false;
  }

  Future<void> _connect() async {
    if (!_wanted) return;
    final api = ref.read(apiClientProvider);
    final cancel = CancelToken();
    _cancel = cancel;
    try {
      final stream = await api.openEventStream('/api/events', cancel);
      connected = true;
      _failures = 0;
      appLogger.i('Live events connected');
      final parser = SseParser();
      await for (final chunk in stream) {
        for (final (name, data) in parser.add(chunk)) {
          if (name != 'notification') continue;
          try {
            state = LiveEvent.fromJson(jsonDecode(data) as Map<String, dynamic>);
          } catch (e) {
            appLogger.w('Bad live event: $e');
          }
        }
      }
    } catch (e) {
      if (!(e is DioException && CancelToken.isCancel(e))) appLogger.w('Live events dropped: $e');
    } finally {
      connected = false;
    }
    if (!_wanted || cancel.isCancelled) return;
    // Back off: 2, 4, 8 … up to 60 s.
    final delay = Duration(seconds: (2 << _failures.clamp(0, 5)).clamp(2, 60));
    _failures++;
    _retry = Timer(delay, _connect);
  }
}

final liveEventsProvider = NotifierProvider<LiveEventsController, LiveEvent?>(LiveEventsController.new);

/// Starts / stops the live stream with the app's lifecycle.
class LiveEventsLifecycle extends ConsumerStatefulWidget {
  const LiveEventsLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LiveEventsLifecycle> createState() => _LiveEventsLifecycleState();
}

class _LiveEventsLifecycleState extends ConsumerState<LiveEventsLifecycle> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(liveEventsProvider.notifier).start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final live = ref.read(liveEventsProvider.notifier);
    if (state == AppLifecycleState.resumed) {
      live.start();
      refreshAll(ref); // anything may have changed while we were away
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      live.stop(); // closed or in the background: push notifications take over
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
