import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/core/notifications/notification_service.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/features/pet/data/in_memory_pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';
import 'package:pocket_memory_pet/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen shows local reminder explanation before permission', (tester) async {
    final now = DateTime.parse('2026-06-12T00:00:00Z');
    final session = PetSession.initial(now);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          petRepositoryProvider.overrideWithValue(InMemoryPetRepository(seed: session)),
          initialPetSessionProvider.overrideWithValue(session),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Enable gentle reminders?'), findsOneWidget);
    expect(find.textContaining('only uses local reminders'), findsOneWidget);
  });

  testWidgets('SettingsScreen schedules reminders after permission is granted', (tester) async {
    final now = DateTime.parse('2026-06-12T00:00:00Z');
    final session = PetSession.initial(now);
    final notificationService = _FakeNotificationService(granted: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          petRepositoryProvider.overrideWithValue(InMemoryPetRepository(seed: session)),
          initialPetSessionProvider.overrideWithValue(session),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(notificationService.permissionRequested, isTrue);
    expect(notificationService.remindersScheduled, isTrue);
  });
}

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService({required this.granted});

  final bool granted;
  bool permissionRequested = false;
  bool remindersScheduled = false;

  @override
  Future<bool> requestPermission() async {
    permissionRequested = true;
    return granted;
  }

  @override
  Future<List<ReminderScheduleEntry>> scheduleCareReminders({
    DateTime? localNow,
    int days = 2,
  }) async {
    remindersScheduled = true;
    return const [];
  }

  @override
  Future<void> cancelCareReminders() async {}
}
