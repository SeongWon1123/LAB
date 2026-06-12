import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/core/notifications/notification_service.dart';

void main() {
  test('NotificationPolicy blocks quiet hours and daily overflow', () {
    const policy = NotificationPolicy();

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
}
