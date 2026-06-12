import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

class ReminderScheduleEntry {
  const ReminderScheduleEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAtLocal,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAtLocal;
}

class NotificationPolicy {
  const NotificationPolicy();

  static const reminderNotificationBaseId = 2000;
  static const maxDailyNotifications = 3;
  static const reminderCancellationDays = 7;
  static const quietStartHour = 22;
  static const quietEndHour = 8;
  static const reminderHours = [9, 14, 19];

  bool canNotifyAt(DateTime localTime, {required int alreadyScheduledToday}) {
    if (alreadyScheduledToday >= maxDailyNotifications) {
      return false;
    }

    final hour = localTime.hour;
    return hour < quietStartHour && hour >= quietEndHour;
  }

  List<ReminderScheduleEntry> buildReminderPlan({
    required DateTime localNow,
    required List<String> messages,
    int days = 2,
  }) {
    if (days <= 0 || messages.isEmpty) {
      return const [];
    }

    final plan = <ReminderScheduleEntry>[];
    for (var dayOffset = 0; dayOffset < days; dayOffset += 1) {
      var scheduledToday = 0;
      final day = DateTime(localNow.year, localNow.month, localNow.day).add(
        Duration(days: dayOffset),
      );

      for (final hour in reminderHours) {
        final scheduledAt = DateTime(day.year, day.month, day.day, hour);
        if (!scheduledAt.isAfter(localNow)) {
          continue;
        }
        if (!canNotifyAt(scheduledAt, alreadyScheduledToday: scheduledToday)) {
          continue;
        }

        final message = messages[plan.length % messages.length];
        plan.add(
          ReminderScheduleEntry(
            id: reminderNotificationBaseId +
                dayOffset * maxDailyNotifications +
                scheduledToday,
            title: 'Pocket Memory Pet',
            body: message,
            scheduledAtLocal: scheduledAt,
          ),
        );
        scheduledToday += 1;
      }
    }

    return plan;
  }
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationPolicy policy = const NotificationPolicy();
  bool _initialized = false;
  bool _timeZonesInitialized = false;

  Future<void> initialize() async {
    _initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (!_initialized) {
      await initialize();
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();

    final ios =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return androidGranted ?? iosGranted ?? false;
  }

  Future<List<ReminderScheduleEntry>> scheduleCareReminders({
    DateTime? localNow,
    int days = 2,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    await cancelCareReminders();
    final plan = policy.buildReminderPlan(
      localNow: localNow ?? DateTime.now(),
      messages: reminderMessages(),
      days: days,
    );

    for (final reminder in plan) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.scheduledAtLocal, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'care_reminders',
            'Care reminders',
            channelDescription: 'Gentle local pet care reminders.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'care-reminder',
      );
    }

    return plan;
  }

  Future<void> cancelCareReminders() async {
    if (!_initialized) {
      await initialize();
    }

    final count = NotificationPolicy.reminderCancellationDays *
        NotificationPolicy.maxDailyNotifications;
    for (var offset = 0; offset < count; offset += 1) {
      await _plugin.cancel(id: NotificationPolicy.reminderNotificationBaseId + offset);
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) {
      await initialize();
    }
    await _plugin.cancelAll();
  }

  List<String> reminderMessages() {
    return const [
      '작은 친구가 배고픈 것 같아요.',
      '방이 조금 지저분해졌어요.',
      '이제 불을 꺼줄 시간이래요.',
      '작은 친구가 심심해 보여요.',
    ];
  }

  void _initializeTimeZones() {
    if (_timeZonesInitialized) {
      return;
    }
    tz_data.initializeTimeZones();
    _timeZonesInitialized = true;
  }
}
