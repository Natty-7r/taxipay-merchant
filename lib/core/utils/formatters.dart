import 'package:intl/intl.dart';

/// "60.00 ETB" → "ETB 60.00"; tolerant of null / strings from JSON.
String money(Object? amount) {
  final value = amount is num ? amount : num.tryParse('$amount') ?? 0;
  return 'ETB ${NumberFormat('#,##0.00').format(value)}';
}

String dateTime(String? iso) {
  if (iso == null) return '—';
  final d = DateTime.tryParse(iso);
  return d == null ? iso : DateFormat('d MMM y, HH:mm').format(d);
}

String shortTime(String? iso) {
  if (iso == null) return '—';
  final d = DateTime.tryParse(iso);
  return d == null ? iso : DateFormat('HH:mm').format(d);
}

/// SNAKE_CASE enum → "Snake case".
String humanize(String? value) {
  if (value == null || value.isEmpty) return '—';
  final s = value.replaceAll('_', ' ').toLowerCase();
  return s[0].toUpperCase() + s.substring(1);
}

/// 1250 → "1,250"; 45.5 → "45.50" (no currency — pair it with an "ETB" label).
String amount(Object? value) {
  final v = value is num ? value : num.tryParse('$value') ?? 0;
  return NumberFormat(v % 1 == 0 ? '#,##0' : '#,##0.00').format(v);
}

/// "Today, 20:42", "Yesterday, 17:30", or "1 Dec, 10:15".
String friendlyTime(String? iso, {String today = 'Today', String yesterday = 'Yesterday'}) {
  if (iso == null) return '—';
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return iso;
  final now = DateTime.now();
  final day = DateTime(d.year, d.month, d.day);
  final diff = DateTime(now.year, now.month, now.day).difference(day).inDays;
  final time = DateFormat('HH:mm').format(d);
  if (diff == 0) return '$today, $time';
  if (diff == 1) return '$yesterday, $time';
  return '${DateFormat('d MMM').format(d)}, $time';
}
