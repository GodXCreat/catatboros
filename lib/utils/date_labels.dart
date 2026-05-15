import 'package:intl/intl.dart';

class DateLabels {
  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
  static DateTime endOfDay(DateTime date) => startOfDay(date).add(const Duration(days: 1));
  static String dayKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  static String monthKey(DateTime date) => DateFormat('yyyy-MM').format(date);

  static String humanDay(DateTime date) {
    final today = startOfDay(DateTime.now());
    final d = startOfDay(date);
    if (d == today) return 'Hari ini';
    if (d == today.subtract(const Duration(days: 1))) return 'Kemarin';
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  static DateTime startOfWeek(DateTime date, bool mondayStart) {
    final d = startOfDay(date);
    final weekday = d.weekday;
    final diff = mondayStart ? weekday - 1 : weekday % 7;
    return d.subtract(Duration(days: diff));
  }

  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);
  static DateTime nextMonth(DateTime date) => DateTime(date.year, date.month + 1);
  static DateTime previousMonth(DateTime date) => DateTime(date.year, date.month - 1);
}
