import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/shared/layout/retro_screen_scaffold.dart';

class PlayScreen extends ConsumerWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RetroScreenScaffold(
      title: 'Jump Star',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240,
                height: 180,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lcdYellow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.lcdPixelDark, width: 5),
                ),
                child: const Text('★  ★  ★', style: TextStyle(fontSize: 42)),
              ),
              const SizedBox(height: 22),
              const Text('Flame mini-game placeholder'),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => ref.read(petControllerProvider.notifier).play(won: true),
                child: const Text('Catch a star'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
