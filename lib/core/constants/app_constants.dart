/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  // 앱 정보
  static const String appName = '체크 알리미';
  static const String appVersion = '1.0.0';

  // 기본값
  static const int defaultReminderHour = 9;
  static const int defaultReminderMinute = 0;
  static const List<int> defaultRepeatDays = [1, 2, 3, 4, 5, 6, 7];

  // 카테고리
  static const List<String> categories = [
    '건강',
    '납부',
    '운동',
    '공부',
    '게임',
    '루틴',
    '기타',
  ];

  // 요일 이름 (1=월 ~ 7=일)
  static const List<String> weekdayNames = [
    '월', '화', '수', '목', '금', '토', '일',
  ];

  // Firestore 컬렉션
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String checkRecordsCollection = 'checkRecords';

  // 페이지네이션
  static const int defaultPageSize = 20;
}
