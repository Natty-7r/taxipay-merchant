import 'package:flutter_test/flutter_test.dart';
import 'package:taxipay_merchant/core/live/live_events.dart';

void main() {
  test('splits server-sent events across chunks and ignores comments', () {
    final p = SseParser();
    expect(p.add('event:ready\ndata:{}\n\n: ping\n\nevent:notif'), [('ready', '{}')]);
    final events = p.add('ication\nid:7\ndata:{"event":"PAYMENT_RECEIVED","title":"Paid",\ndata:"link":"/operate/taxi/1"}\n\n');
    expect(events, hasLength(1));
    expect(events.single.$1, 'notification');
    expect(events.single.$2, '{"event":"PAYMENT_RECEIVED","title":"Paid",\n"link":"/operate/taxi/1"}');
  });

  test('reads a live event', () {
    final e = LiveEvent.fromJson({'notificationId': 7, 'event': 'PAYMENT_RECEIVED', 'title': 'Paid', 'body': '50 ETB', 'link': '/operate/taxi/1'});
    expect(e.id, 7);
    expect(e.link, '/operate/taxi/1');
  });
}
