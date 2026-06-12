import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/shared/layout/retro_screen_scaffold.dart';
import 'package:pocket_memory_pet/shared/widgets/pixel_gauge.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petControllerProvider).pet;
    return RetroScreenScaffold(
      title: 'Status',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PixelGauge(label: 'Hunger', value: pet.hunger),
          const SizedBox(height: 12),
          PixelGauge(label: 'Happy', value: pet.happiness),
          const SizedBox(height: 12),
          PixelGauge(label: 'Clean', value: pet.cleanliness),
          const SizedBox(height: 12),
          PixelGauge(label: 'Energy', value: pet.energy),
          const SizedBox(height: 12),
          PixelGauge(label: 'Health', value: pet.health),
          const SizedBox(height: 12),
          PixelGauge(label: 'Rhythm', value: pet.discipline),
          const SizedBox(height: 24),
          Text('Age: ${pet.ageHours} hours'),
          Text('Care mistakes: ${pet.careMistakes}'),
          Text('Meals: ${pet.totalMeals}'),
          Text('Snacks: ${pet.totalSnacks}'),
          Text('Cleanups: ${pet.totalCleanups}'),
          Text('Mini-game wins: ${pet.totalMiniGameWins}'),
        ],
      ),
    );
  }
}
