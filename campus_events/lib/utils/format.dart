import 'package:flutter/material.dart';

// R8: own formatting, no packages.
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// 18 Oct, 10:00
String formatDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]}, ${_two(d.hour)}:${_two(d.minute)}';

/// 18 Oct 2026
String formatDay(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// 09:05
String formatClock(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

/// 2 d 3 h / 4 h 15 min / 12 min
String formatDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays} d ${d.inHours % 24} h';
  if (d.inHours > 0) return '${d.inHours} h ${d.inMinutes % 60} min';
  return '${d.inMinutes} min';
}
