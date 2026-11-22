import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json.dart';
import 'inbox_models.dart';

class InboxApi {
  InboxApi(this._api);

  final ApiClient _api;

  Future<List<InboxItem>> list() async =>
      (await _api.getPage('/api/notifications', InboxItem.fromJson, query: {'size': 50})).content;

  Future<int> unreadCount() =>
      _api.get('/api/notifications/unread-count', map: (d) => numOf((d as Json)['unread']).toInt());

  Future<void> markRead(int id) => _api.post('/api/notifications/$id/read', map: (_) {});

  Future<void> markAllRead() => _api.post('/api/notifications/read-all', map: (_) {});

  Future<TelegramStatus> telegram() =>
      _api.get('/api/telegram/me', map: (d) => TelegramStatus.fromJson(d as Json));

  /// One-time t.me deep link; pressing Start in the bot connects the account.
  Future<String> telegramLink() =>
      _api.post('/api/telegram/me/link', map: (d) => (d as Json)['deepLink'] as String);

  Future<void> telegramUnlink() => _api.delete('/api/telegram/me');
}

final inboxApiProvider = Provider<InboxApi>((ref) => InboxApi(ref.watch(apiClientProvider)));
