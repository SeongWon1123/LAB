import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_memory_pet/core/notifications/notification_service.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/shared/layout/retro_screen_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(petControllerProvider);
    final controller = ref.read(petControllerProvider.notifier);
    return RetroScreenScaffold(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('Local reminders'),
            subtitle: const Text('The app keeps working if permission is denied.'),
            value: session.notificationsEnabled,
            onChanged: (value) => _handleNotificationToggle(
              context,
              ref,
              controller,
              enabled: value,
            ),
          ),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Soft beeps and haptics for buttons and care.'),
            value: session.soundEnabled,
            onChanged: (value) => controller.setSoundEnabled(enabled: value),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () {
              controller.reset();
            },
            child: const Text('Reset local pet data'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationToggle(
    BuildContext context,
    WidgetRef ref,
    PetController controller, {
    required bool enabled,
  }) async {
    if (!enabled) {
      await ref.read(notificationServiceProvider).cancelCareReminders();
      controller.setNotificationsEnabled(enabled: false);
      return;
    }

    final shouldAsk = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Enable gentle reminders?'),
              content: const Text(
                'Pocket Memory Pet only uses local reminders. If you decline, the app still works normally.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Not now'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldAsk) {
      return;
    }

    final notificationService = ref.read(notificationServiceProvider);
    final granted = await notificationService.requestPermission();
    if (granted) {
      await notificationService.scheduleCareReminders();
    }

    controller.setNotificationsEnabled(enabled: granted);

    if (!context.mounted || granted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminders are off. You can keep caring for your pet normally.'),
      ),
    );
  }
}
