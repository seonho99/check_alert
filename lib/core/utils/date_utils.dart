/// 날짜 관련 유틸리티
class AppDateUtils {
  AppDateUtils._();

  /// 날짜를 시간 없이 정규화 (yyyy-MM-dd 00:00:00)
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 오늘 날짜 (시간 없음)
  static DateTime get today => normalizeDate(DateTime.now());

  /// 두 날짜가 같은 날인지 비교
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 해당 월의 첫째 날
  static DateTime firstDayOfMonth(int year, int month) {
    return DateTime(year, month, 1);
  }

  /// 해당 월의 마지막 날
  static DateTime lastDayOfMonth(int year, int month) {
    return DateTime(year, month + 1, 0);
  }

  /// 해당 월의 총 일수
  static int daysInMonth(int year, int month) {
    return lastDayOfMonth(year, month).day;
  }

  /// 날짜 포맷: yyyy-MM-dd
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 날짜 포맷: M월 d일 (요일)
  static String formatDateKorean(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일 ($weekday)';
  }

  /// 날짜 포맷: yyyy년 M월 d일 (요일)
  static String formatDateKoreanFull(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}년 ${date.month}월 ${date.day}일 ($weekday)';
  }

  /// 시간 포맷: HH:mm
  static String formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// 시간 포맷: 오전/오후 h:mm
  static String formatTimeKorean(int hour, int minute) {
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }

  /// 주간 날짜 목록 (월~일)
  static List<DateTime> weekDates(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (i) => normalizeDate(monday.add(Duration(days: i))));
  }
}
