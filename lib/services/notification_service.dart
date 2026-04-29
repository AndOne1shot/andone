import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final localTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimeZone));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Android 13+ 알림 권한 요청
    await androidPlugin?.requestNotificationsPermission();

    // Android 12+ 정확한 알람 권한 요청 (설정 화면으로 이동)
    final canSchedule = await androidPlugin?.canScheduleExactNotifications() ?? false;
    if (!canSchedule) {
      await androidPlugin?.requestExactAlarmsPermission();
    }

    // 배터리 최적화 해제 요청 (삼성 등 제조사 대응)
    await _requestIgnoreBatteryOptimizations();

    _initialized = true;
  }

  // 배터리 최적화 해제 요청 (네이티브 채널)
  static const _batteryChannel = MethodChannel('com.jjy.andone/battery');

  Future<void> _requestIgnoreBatteryOptimizations() async {
    try {
      await _batteryChannel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (_) {
      // 지원하지 않는 기기 무시
    }
  }

  // 알림 상세 설정
  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'todo_reminder',
      '할 일 리마인더',
      channelDescription: '할 일 시작 30분 전에 알려드려요',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  // docId(String) → 알림 ID(int) 변환 — djb2 해시로 항상 동일한 값 반환
  int _toNotificationId(String docId) {
    int hash = 5381;
    for (final c in docId.codeUnits) {
      hash = ((hash << 5) + hash + c) & 0x7FFFFFFF;
    }
    return hash;
  }

  // 다음 해당 요일 날짜 계산 (1=월 ~ 7=일)
  DateTime _nextWeekday(DateTime startTime, int weekday) {
    final now = DateTime.now();
    var candidate = DateTime(
        now.year, now.month, now.day, startTime.hour, startTime.minute);

    for (int i = 0; i <= 7; i++) {
      final checkDate = candidate.add(Duration(days: i));
      if (checkDate.weekday == weekday) {
        final notifyTime =
            checkDate.subtract(const Duration(minutes: 30));
        if (notifyTime.isAfter(now)) return checkDate;
      }
    }

    // 못 찾으면 다음 주 해당 요일
    for (int i = 1; i <= 7; i++) {
      final checkDate = candidate.add(Duration(days: i));
      if (checkDate.weekday == weekday) return checkDate;
    }

    return candidate;
  }

  // 알림 예약
  // repeat: 0=없음 / 1=매일 / 2=매주
  Future<void> scheduleTodoReminder({
    required String docId,
    required String title,
    required DateTime startTime,
    int repeat = 0,
    List<int> repeatDays = const [],
  }) async {
    final baseId = _toNotificationId(docId);
    final now = DateTime.now();

    if (repeat == 0) {
      // 반복 없음 — 딱 한 번, startTime 30분 전
      final notifyTime = startTime.subtract(const Duration(minutes: 30));
      if (notifyTime.isBefore(now)) return;

      await _plugin.zonedSchedule(
        baseId,
        '📌 할 일 시작 30분 전!',
        title,
        tz.TZDateTime.from(notifyTime, tz.local),
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: docId,
      );
    } else if (repeat == 1) {
      // 매일 반복 — 매일 같은 시간에 자동 반복
      var notifyTime = DateTime(
              now.year, now.month, now.day, startTime.hour, startTime.minute)
          .subtract(const Duration(minutes: 30));

      // 오늘 이미 지났으면 내일부터 시작
      if (notifyTime.isBefore(now)) {
        notifyTime = notifyTime.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        baseId,
        '📌 할 일 시작 30분 전!',
        title,
        tz.TZDateTime.from(notifyTime, tz.local),
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
        payload: docId,
      );
    } else if (repeat == 2) {
      // 매주 반복 — 요일마다 별도 알림 예약
      for (final day in repeatDays) {
        final nextDate = _nextWeekday(startTime, day);
        final notifyTime = nextDate.subtract(const Duration(minutes: 30));

        await _plugin.zonedSchedule(
          baseId + day, // 요일마다 다른 ID
          '📌 할 일 시작 30분 전!',
          title,
          tz.TZDateTime.from(notifyTime, tz.local),
          _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // 매주 반복
          payload: docId,
        );
      }
    }
  }

  // 알림 취소 (반복 요일 알림 포함 전부 취소)
  Future<void> cancelTodoReminder(String docId) async {
    final baseId = _toNotificationId(docId);
    await _plugin.cancel(baseId);
    // 매주 반복 요일별 알림도 모두 취소 (1~7)
    for (int day = 1; day <= 7; day++) {
      await _plugin.cancel(baseId + day);
    }
  }
}

final notificationService = NotificationService();
