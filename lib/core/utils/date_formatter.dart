import 'package:intl/intl.dart';

/// Date/time formatting utilities for FlowFi
abstract final class DateFormatter {
  static final DateFormat _full = DateFormat('MMM d, yyyy');
  static final DateFormat _time = DateFormat('hh:mm a');
  static final DateFormat _dayMonth = DateFormat('MMM d');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');

  /// Format: "Oct 24, 2023"
  static String formatFull(DateTime date) => _full.format(date);

  /// Format: "09:42 AM"
  static String formatTime(DateTime date) => _time.format(date);

  /// Format relative: "Today", "Yesterday", "Oct 22, 2023"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return _full.format(date);
  }

  /// Format: "Today, 09:42 AM" or "Oct 24, 06:15 PM"
  static String formatTransactionDate(DateTime date) {
    final relative = formatRelative(date);
    final time = formatTime(date);
    if (relative == 'Today' || relative == 'Yesterday') {
      return '$relative, $time';
    }
    return '$relative, $time';
  }

  /// Format: "January 2024"
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  /// Format: "Oct 24"
  static String formatShort(DateTime date) => _dayMonth.format(date);

  /// Format: "2h ago", "10m ago", "3d ago"
  static String formatAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
