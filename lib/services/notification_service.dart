import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyWateringNotificationId = 1;

  bool _initialized = false;

  /// 初期化。main() で await して呼ぶ。
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  /// 通知パーミッションをリクエストする。
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    // Android 13+
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS / macOS
    final darwinImpl = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (darwinImpl != null) {
      final granted = await darwinImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// 毎日 [hour]:[minute] に水やり通知をスケジュールする。
  Future<void> scheduleDailyWateringReminder({
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await initialize();

    await cancelDailyWateringReminder();

    // デバイスのローカルタイムゾーンを使用
    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // 今日の指定時刻が既に過ぎていたら翌日にする
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'watering_reminder',
      '水やりリマインダー',
      channelDescription: '水やりが必要な植物をお知らせします',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const darwinDetails = DarwinNotificationDetails(
      categoryIdentifier: 'watering',
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      id: _dailyWateringNotificationId,
      title: '💧 水やりの時間です',
      body: '水やりが必要な植物を確認しましょう',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 毎日繰り返し
    );

    debugPrint(
        'NotificationService: scheduled daily at $hour:${minute.toString().padLeft(2, '0')}');
  }

  /// 水やり通知をキャンセルする。
  Future<void> cancelDailyWateringReminder() async {
    if (kIsWeb) return;
    await _plugin.cancel(id: _dailyWateringNotificationId);
  }
}
