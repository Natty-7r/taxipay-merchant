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
