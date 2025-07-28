import 'package:intl/intl.dart';

class HomeDateUtils {
  static bool isSameDay(DateTime date1, DateTime date2) {
    return DateFormat.yMd().format(date1) == DateFormat.yMd().format(date2);
  }

  static List<DateTime> getLastNDays(int days) {
    final today = DateTime.now();
    return List.generate(days, (i) => today.subtract(Duration(days: i)));
  }

  static String getWeekdayAbbreviation(DateTime date) {
    return DateFormat.E().format(date).toUpperCase();
  }

  static String getDayNumber(DateTime date) {
    return date.day.toString();
  }
}