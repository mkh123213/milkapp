import 'package:intl/intl.dart';

class MilkDateUtils {
  static const List<String> _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static const List<String> _arabicDays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد',
  ];

  static String toDateKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  /// Returns week key in format "YYYY-W{weekNum}" based on Saturday-start weeks.
  static String getWeekKey(DateTime date) {
    final saturday = _getWeekStart(date);
    return '${saturday.year}-W${_isoWeekNumber(saturday).toString().padLeft(2, '0')}';
  }

  /// Get the Saturday that starts the week containing [date].
  static DateTime getWeekStart(DateTime date) => _getWeekStart(date);

  static DateTime _getWeekStart(DateTime date) {
    // weekday: Mon=1..Sun=7. Saturday=6.
    int daysFromSaturday = (date.weekday - 6) % 7;
    if (daysFromSaturday < 0) daysFromSaturday += 7;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromSaturday));
  }

  static DateTime getWeekEnd(DateTime weekStart) =>
      weekStart.add(const Duration(days: 6));

  static int _isoWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  /// Full Arabic date: "السبت، ٢٢ مايو ٢٠٢٦"
  static String formatFullArabic(DateTime date) {
    final dayName = _arabicDays[date.weekday - 1];
    final month = _arabicMonths[date.month - 1];
    return '$dayName، ${_toArabicNumerals(date.day)} $month ${_toArabicNumerals(date.year)}';
  }

  /// Compact: "٢٢/٠٥/٢٠٢٦"
  static String formatCompact(DateTime date) =>
      '${_toArabicNumerals(date.day).padLeft(2, '٠')}/${_toArabicNumerals(date.month).padLeft(2, '٠')}/${_toArabicNumerals(date.year)}';

  /// Short day+number for table header: "السبت ١٦"
  static String formatShortHeader(DateTime date) {
    final dayName = _arabicDays[date.weekday - 1];
    return '$dayName ${_toArabicNumerals(date.day)}';
  }

  /// Month name + year: "مايو ٢٠٢٦"
  static String formatMonthYear(DateTime date) =>
      '${_arabicMonths[date.month - 1]} ${_toArabicNumerals(date.year)}';

  /// Returns list of 7 dates for the week starting Saturday.
  static List<DateTime> getWeekDays(DateTime weekStart) =>
      List.generate(7, (i) => weekStart.add(Duration(days: i)));

  /// Checks if two dates are same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Format time: "٠٧:٣٠ ص"
  static String formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final isAm = hour < 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = isAm ? 'ص' : 'م';
    return '${_toArabicNumerals(displayHour)}:${_toArabicNumerals(int.parse(minute))} $period';
  }

  /// Convert integer to Arabic numerals string.
  static String _toArabicNumerals(int n) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) {
      final idx = western.indexOf(c);
      return idx >= 0 ? arabic[idx] : c;
    }).join();
  }

  static String toArabicNumerals(int n) => _toArabicNumerals(n);
  static String toArabicNumeralsStr(String s) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return s.split('').map((c) {
      final idx = western.indexOf(c);
      return idx >= 0 ? arabic[idx] : c;
    }).join();
  }

  /// Returns last N months as [DateTime] list (first day of each month), newest first.
  static List<DateTime> lastNMonths(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) {
      final m = now.month - i;
      final y = now.year + (m <= 0 ? -1 : 0);
      final adjustedM = m <= 0 ? m + 12 : m;
      return DateTime(y, adjustedM);
    });
  }

  /// Consecutive absence streak: days with no entry before [date] going back.
  /// [entryDates] is the set of dateKeys that have any entry (recorded or no_milk).
  /// Returns count of consecutive missing days before today.
  static int calcAbsenceStreak(DateTime today, Set<String> entryDateKeys, DateTime addedAt) {
    int streak = 0;
    var check = today.subtract(const Duration(days: 1));
    while (!check.isBefore(DateTime(addedAt.year, addedAt.month, addedAt.day))) {
      final key = toDateKey(check);
      if (entryDateKeys.contains(key)) break;
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
