import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/core/notifications/notification_service.dart';

void main() {
  const policy = NotificationPolicy();

  test('NotificationPolicy blocks quiet hours and daily overflow', () {
    expect(
      policy.canNotifyAt(DateTime(2026, 6, 12, 9), alreadyScheduledToday: 0),
      isTrue,
    );
    expect(
      policy.canNotifyAt(DateTime(2026, 6, 12, 23), alreadyScheduledToday: 0),
      isFalse,
    );
    expect(
      policy.canNotifyAt(DateTime(2026, 6, 12, 11), alreadyScheduledToday: 3),
      isFalse,
    );
  });

  test('NotificationPolicy builds only future reminders inside allowed hours', () {
    final plan = policy.buildReminderPlan(
      localNow: DateTime(2026, 6, 12, 15, 30),
      messages: const ['Meal', 'Clean', 'Sleep'],
    );

    expect(plan, hasLength(4));
    expect(plan.first.scheduledAtLocal, DateTime(2026, 6, 12, 19));
    expect(plan.first.id, NotificationPolicy.reminderNotificationBaseId);
    expect(plan.map((entry) => entry.scheduledAtLocal.hour), [19, 9, 14, 19]);
  });

  test('NotificationPolicy caps reminders at three per day', () {
    final plan = policy.buildReminderPlan(
      localNow: DateTime(2026, 6, 12, 7, 45),
      messages: const ['Meal'],
      days: 1,
    );

    expect(plan, hasLength(NotificationPolicy.maxDailyNotifications));
    expect(plan.every((entry) => entry.scheduledAtLocal.hour >= 8), isTrue);
    expect(plan.every((entry) => entry.scheduledAtLocal.hour < 22), isTrue);
  });
}
