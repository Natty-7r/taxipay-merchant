import '../../../core/utils/json.dart';

class InboxItem {
  InboxItem({required this.id, required this.title, required this.body, required this.category, required this.read,
      required this.createdAt, this.linkUrl});

  final int id;
  final String title;
  final String body;
  final String category;
  final bool read;
  final String createdAt;
  final String? linkUrl;

  factory InboxItem.fromJson(Json j) => InboxItem(
        id: (j['id'] as num).toInt(),
        title: j['title'] as String,
        body: j['body'] as String,
        category: j['category'] as String,
        read: (j['read'] as bool?) ?? false,
        createdAt: j['createdAt'] as String,
        linkUrl: j['linkUrl'] as String?,
      );
}

class TelegramStatus {
  TelegramStatus({required this.botAvailable, required this.linked, this.telegramUsername, required this.botStarted});

  final bool botAvailable;
  final bool linked;
  final String? telegramUsername;
  final bool botStarted;

  factory TelegramStatus.fromJson(Json j) => TelegramStatus(
        botAvailable: (j['botAvailable'] as bool?) ?? false,
        linked: (j['linked'] as bool?) ?? false,
        telegramUsername: j['telegramUsername'] as String?,
        botStarted: (j['botStarted'] as bool?) ?? false,
      );
}
