import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/shared/layout/retro_screen_scaffold.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petControllerProvider).pet;
    if (_nameController.text.isEmpty && pet.name.isNotEmpty) {
      _nameController.text = pet.name;
    }

    return RetroScreenScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.76),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pocket Memory Pet',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.retroBrown,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'A tiny LCD friend is waiting inside a soft pastel desk toy.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.dustGray,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        maxLength: 18,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Pet name',
                          hintText: 'Cloudy',
                          filled: true,
                          errorText: _nameError,
                        ),
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                        onSubmitted: (_) => _continue(),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _continue,
                        child: const Text('Find the tiny friend'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _continue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Choose a pet name first.');
      return;
    }

    ref.read(petControllerProvider.notifier).namePet(name);
    context.go('/hatch');
  }
}
