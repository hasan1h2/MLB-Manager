import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat standardDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat isoDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat timeFormat = DateFormat('hh:mm a');
  static final DateFormat dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  /// Current timestamp in milliseconds since epoch
  static int currentTimestamp() {
    return DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  /// Converts timestamp in milliseconds to standard formatted string
  static String formatTimestamp(int? timestampMs, {bool includeTime = false}) {
    if (timestampMs == null || timestampMs == 0) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs).toLocal();
    return includeTime ? dateTimeFormat.format(dt) : standardDateFormat.format(dt);
  }

  /// Start and End timestamps for standard date filters
  static DateTimeRange getFilterRange(String filterType, {DateTime? customStart, DateTime? customEnd}) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (filterType) {
      case 'filter_today':
        return DateTimeRange(start: todayStart, end: todayEnd);
      case 'filter_yesterday':
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));
        final yesterdayEnd = DateTime(yesterdayStart.year, yesterdayStart.month, yesterdayStart.day, 23, 59, 59, 999);
        return DateTimeRange(start: yesterdayStart, end: yesterdayEnd);
      case 'filter_last_7_days':
        final start7 = todayStart.subtract(const Duration(days: 6));
        return DateTimeRange(start: start7, end: todayEnd);
      case 'filter_this_month':
        final startMonth = DateTime(now.year, now.month, 1);
        final endMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        return DateTimeRange(start: startMonth, end: endMonth);
      case 'filter_last_month':
        final startLastMonth = DateTime(now.year, now.month - 1, 1);
        final endLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
        return DateTimeRange(start: startLastMonth, end: endLastMonth);
      case 'filter_this_year':
        final startYear = DateTime(now.year, 1, 1);
        final endYear = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        return DateTimeRange(start: startYear, end: endYear);
      case 'filter_custom_range':
        return DateTimeRange(
          start: customStart ?? todayStart,
          end: customEnd ?? todayEnd,
        );
      default:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: todayEnd);
    }
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});

  int get startMs => start.toUtc().millisecondsSinceEpoch;
  int get endMs => end.toUtc().millisecondsSinceEpoch;
}
