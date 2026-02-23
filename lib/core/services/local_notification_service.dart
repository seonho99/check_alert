import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/model/repeat_type.dart';
import '../../domain/model/task_model.dart';

/// 로컬 알림 서비스
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// iOS 최대 예약 알림 수
  static const int _maxIOSNotifications = 64;

  /// 알림 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // timezone 초기화
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('알림 탭: ${response.payload}');
  }

  /// 알림 권한 요청 (iOS/Android)
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return false;

      // 알림 표시 권한 요청
      final notificationGranted =
          await androidPlugin.requestNotificationsPermission() ?? false;

      // Android 14+ 정확한 알람 권한 요청
      await androidPlugin.requestExactAlarmsPermission();

      return notificationGranted;
    }
    return false;
  }

  /// Task의 알림 시간에 반복 알림 스케줄링
  Future<void> scheduleTaskReminder(TaskModel task) async {
    if (!task.isActive) return;

    switch (task.repeatType) {
      case RepeatType.once:
        await _scheduleOnceReminder(task);
      case RepeatType.weekly:
        await _scheduleWeeklyReminder(task);
      case RepeatType.monthly:
        await _scheduleMonthlyReminder(task);
    }
  }

  Future<void> _scheduleWeeklyReminder(TaskModel task) async {
    for (final day in task.repeatDays) {
      final notificationId = _generateNotificationId(task.id, day);

      await _plugin.zonedSchedule(
        notificationId,
        '체크 알리미',
        '${task.name} 을 할 시간이예요!',
        _nextInstanceOfDayAndTime(day, task.reminderHour, task.reminderMinute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'check_reminder',
            '체크 알림',
            channelDescription: '체크 항목 알림',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFFF97316),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: task.id,
      );
    }
  }

  Future<void> _scheduleMonthlyReminder(TaskModel task) async {
    for (final monthDay in task.repeatMonthDays) {
      final notificationId = _generateNotificationId(task.id, 50 + monthDay);
      final scheduledDate = _nextInstanceOfMonthDayAndTime(
          monthDay, task.reminderHour, task.reminderMinute);

      await _plugin.zonedSchedule(
        notificationId,
        '체크 알리미',
        '${task.name} 을 할 시간이예요!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'check_reminder',
            '체크 알림',
            channelDescription: '체크 항목 알림',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFFF97316),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        payload: task.id,
      );
    }
  }

  Future<void> _scheduleOnceReminder(TaskModel task) async {
    if (task.specificDates.isEmpty) return;

    for (int i = 0; i < task.specificDates.length; i++) {
      final date = task.specificDates[i];
      final notificationId = _generateNotificationId(task.id, 100 + i);
      final scheduledDate = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        task.reminderHour,
        task.reminderMinute,
      );

      // 이미 지난 시간이면 스케줄하지 않음
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) continue;

      await _plugin.zonedSchedule(
        notificationId,
        '체크 알리미',
        '${task.name} 을 할 시간이예요!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'check_reminder',
            '체크 알림',
            channelDescription: '체크 항목 알림',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFFF97316),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: task.id,
      );
    }
  }

  /// Task의 모든 알림 취소
  Future<void> cancelTaskReminder(String taskId) async {
    // weekly 타입 알림 (day=1~7)
    for (int day = 1; day <= 7; day++) {
      await _plugin.cancel(_generateNotificationId(taskId, day));
    }
    // monthly 타입 알림 (50+day=51~81)
    for (int day = 1; day <= 31; day++) {
      await _plugin.cancel(_generateNotificationId(taskId, 50 + day));
    }
    // once 타입 알림 (인덱스 100~465, 최대 365일)
    for (int i = 100; i < 466; i++) {
      await _plugin.cancel(_generateNotificationId(taskId, i));
    }
  }

  /// 모든 알림 취소
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  /// 모든 활성 Task의 알림을 재스케줄링
  /// iOS는 최대 64개 제한이 있으므로, 가장 가까운 알림부터 우선 등록
  Future<void> rescheduleAll(List<TaskModel> tasks) async {
    await cancelAllReminders();

    final activeTasks = tasks.where((t) => t.isActive).toList();

    if (Platform.isIOS) {
      await _rescheduleWithLimit(activeTasks);
    } else {
      for (final task in activeTasks) {
        await scheduleTaskReminder(task);
      }
    }
  }

  /// iOS 64개 제한 대응: 가장 가까운 알림 시간 순으로 최대 64개만 등록
  Future<void> _rescheduleWithLimit(List<TaskModel> tasks) async {
    // 각 태스크의 다음 알림 시간을 계산해서 (task, scheduledTime) 쌍 생성
    final List<({TaskModel task, tz.TZDateTime time, int suffix})> entries = [];

    for (final task in tasks) {
      switch (task.repeatType) {
        case RepeatType.weekly:
          for (final day in task.repeatDays) {
            entries.add((
              task: task,
              time: _nextInstanceOfDayAndTime(
                  day, task.reminderHour, task.reminderMinute),
              suffix: day,
            ));
          }
        case RepeatType.monthly:
          for (final monthDay in task.repeatMonthDays) {
            entries.add((
              task: task,
              time: _nextInstanceOfMonthDayAndTime(
                  monthDay, task.reminderHour, task.reminderMinute),
              suffix: 50 + monthDay,
            ));
          }
        case RepeatType.once:
          for (int i = 0; i < task.specificDates.length; i++) {
            final date = task.specificDates[i];
            final scheduled = tz.TZDateTime(
              tz.local,
              date.year, date.month, date.day,
              task.reminderHour, task.reminderMinute,
            );
            if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) continue;
            entries.add((task: task, time: scheduled, suffix: 100 + i));
          }
      }
    }

    // 가장 가까운 시간 순으로 정렬
    entries.sort((a, b) => a.time.compareTo(b.time));

    // 최대 64개까지만 등록
    final limited = entries.take(_maxIOSNotifications);
    for (final entry in limited) {
      await _scheduleOne(entry.task, entry.time, entry.suffix);
    }

    debugPrint('iOS 알림 스케줄: ${limited.length}/${entries.length}개 등록');
  }

  /// 단일 알림 스케줄링 (내부용)
  Future<void> _scheduleOne(
      TaskModel task, tz.TZDateTime scheduledDate, int suffix) async {
    final notificationId = _generateNotificationId(task.id, suffix);

    DateTimeComponents? matchComponents;
    if (task.repeatType == RepeatType.weekly) {
      matchComponents = DateTimeComponents.dayOfWeekAndTime;
    } else if (task.repeatType == RepeatType.monthly) {
      matchComponents = DateTimeComponents.dayOfMonthAndTime;
    }

    await _plugin.zonedSchedule(
      notificationId,
      '체크 알리미',
      '${task.name} 을 할 시간이예요!',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'check_reminder',
          '체크 알림',
          channelDescription: '체크 항목 알림',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFFF97316),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: matchComponents,
      payload: task.id,
    );
  }

  /// 다음 특정 월일+시간의 TZDateTime 계산
  tz.TZDateTime _nextInstanceOfMonthDayAndTime(
      int monthDay, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, monthDay, hour, minute);

    // 이미 지난 시간이면 다음 달로
    if (scheduled.isBefore(now)) {
      final nextMonth = now.month == 12
          ? tz.TZDateTime(tz.local, now.year + 1, 1, monthDay, hour, minute)
          : tz.TZDateTime(
              tz.local, now.year, now.month + 1, monthDay, hour, minute);
      scheduled = nextMonth;
    }

    return scheduled;
  }

  /// 다음 특정 요일+시간의 TZDateTime 계산
  tz.TZDateTime _nextInstanceOfDayAndTime(
      int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);

    // 해당 요일까지 날짜 이동
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // 이미 지난 시간이면 다음 주로
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    return scheduled;
  }

  /// 알림 ID 생성 (taskId 해시 + suffix, 32비트 정수 범위 내)
  int _generateNotificationId(String taskId, int suffix) {
    final hash = taskId.hashCode % 100000000;
    return (hash.abs() * 1000 + suffix) % 2147483647;
  }
}
