import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            onChanged: (value) => controller.setNotificationsEnabled(enabled: value),
          ),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Placeholder until original sounds are added.'),
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
}
