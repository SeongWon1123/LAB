import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/shared/layout/retro_screen_scaffold.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diary = ref.watch(petControllerProvider).diary;
    return RetroScreenScaffold(
      title: 'Growth Diary',
      child: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: diary.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = diary[index];
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primaryPink),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.createdAtUtc.toLocal().toString().split('.').first,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.retroBrown,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(entry.body),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
