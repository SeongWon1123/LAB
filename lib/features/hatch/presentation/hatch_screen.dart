import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/shared/layout/retro_screen_scaffold.dart';
import 'package:pocket_memory_pet/shared/pixel/pixel_pet.dart';

class HatchScreen extends ConsumerWidget {
  const HatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petControllerProvider).pet;
    return RetroScreenScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 190,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lcdYellow,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.lcdPixelDark, width: 5),
                ),
                child: PixelPet(
                  stage: pet.stage == EvolutionStage.egg ? EvolutionStage.egg : pet.stage,
                  isSleeping: false,
                  isSick: false,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                pet.name.isEmpty ? 'The egg is humming softly.' : '${pet.name} is ready.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.retroBrown,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  ref.read(petControllerProvider.notifier).hatch();
                  context.go('/home');
                },
                child: const Text('Open the LCD screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
