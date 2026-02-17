import 'package:intl/intl.dart';

/// Date utility functions for the app
class AppDateUtils {
  /// Returns start of day (00:00:00) for given date
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns end of day (23:59:59) for given date
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Returns date without time component
  static DateTime getDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Formats date as relative string (今日, 昨日, 明日, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = getDateOnly(now);
    final targetDay = getDateOnly(date);
    final difference = targetDay.difference(today).inDays;

    if (difference == 0) return '今日';
    if (difference == -1) return '昨日';
    if (difference == 1) return '明日';
    return DateFormat('M月d日').format(date);
  }

  /// Formats date difference with overdue indication
  static String formatDateDifference(DateTime date) {
    final now = DateTime.now();
    final today = getDateOnly(now);
    final targetDay = getDateOnly(date);
    final difference = targetDay.difference(today).inDays;

    if (difference == 0) return '今日';
    if (difference == -1) return '昨日（期限切れ）';
    if (difference == 1) return '明日';
    if (difference < 0) return '${-difference}日前（期限切れ）';
    return '$difference日後';
  }

  /// Checks if two dates are on the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
