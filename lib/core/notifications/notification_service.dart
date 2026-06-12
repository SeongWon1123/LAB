import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationPolicy {
  const NotificationPolicy();

  static const maxDailyNotifications = 3;
  static const quietStartHour = 22;
  static const quietEndHour = 8;

  bool canNotifyAt(DateTime localTime, {required int alreadyScheduledToday}) {
    if (alreadyScheduledToday >= maxDailyNotifications) {
      return false;
    }

    final hour = localTime.hour;
    return hour < quietStartHour && hour >= quietEndHour;
  }
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationPolicy policy = const NotificationPolicy();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();

    final ios =
        _plugin.resolvePlatformSpecificImplementation<DarwinFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return androidGranted ?? iosGranted ?? false;
  }

  List<String> reminderMessages() {
    return const [
      '작은 친구가 배고픈 것 같아요.',
      '방이 조금 지저분해졌어요.',
      '이제 불을 꺼줄 시간이래요.',
      '작은 친구가 심심해 보여요.',
    ];
  }
}
