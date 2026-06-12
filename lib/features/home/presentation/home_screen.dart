import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_memory_pet/core/audio/sound_service.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_state.dart';
import 'package:pocket_memory_pet/shared/buttons/three_button_pad.dart';
import 'package:pocket_memory_pet/shared/layout/retro_screen_scaffold.dart';
import 'package:pocket_memory_pet/shared/pixel/pixel_pet.dart';
import 'package:pocket_memory_pet/shared/widgets/pixel_gauge.dart';
import 'package:pocket_memory_pet/shared/widgets/retro_device_shell.dart';

enum HomeMenu { meal, snack, play, clean, sleep, status, diary, settings }

extension HomeMenuLabel on HomeMenu {
  String get label {
    return switch (this) {
      HomeMenu.meal => 'Meal',
      HomeMenu.snack => 'Snack',
      HomeMenu.play => 'Play',
      HomeMenu.clean => 'Clean',
      HomeMenu.sleep => 'Sleep',
      HomeMenu.status => 'Status',
      HomeMenu.diary => 'Diary',
      HomeMenu.settings => 'Settings',
    };
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({this.initialMenu = HomeMenu.meal, super.key});

  final HomeMenu initialMenu;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomeMenu _selected = widget.initialMenu;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(petControllerProvider.notifier).refreshElapsed());
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(petControllerProvider);
    final pet = session.pet;

    return RetroScreenScaffold(
      title: 'Pocket Memory Pet',
      actions: [
        IconButton(
          tooltip: 'Diary',
          onPressed: () => context.go('/diary'),
          icon: const Icon(Icons.book_outlined),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 34),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dailyMessage(pet),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.retroBrown,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  RetroDeviceShell(
                    menuLabel: _selected.label,
                    lcd: _LcdPanel(pet: pet),
                    controls: ThreeButtonPad(
                      onLeft: _previousMenu,
                      onCenter: _selectMenu,
                      onRight: _nextMenu,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _dailyMessage(PetState pet) {
    if (pet.isSleeping) {
      return '${pet.nameOrFallback} is resting under pixel stars.';
    }
    if (pet.hunger < 28) {
      return '${pet.nameOrFallback} is looking for a warm meal.';
    }
    if (pet.cleanliness < 30) {
      return 'The little room needs a soft cleanup.';
    }
    return 'A tiny beep says hello from the desk.';
  }

  void _previousMenu() {
    _playButtonSound();
    final menus = HomeMenu.values;
    setState(() {
      _selected = menus[(_selected.index - 1 + menus.length) % menus.length];
    });
  }

  void _nextMenu() {
    _playButtonSound();
    final menus = HomeMenu.values;
    setState(() {
      _selected = menus[(_selected.index + 1) % menus.length];
    });
  }

  void _selectMenu() {
    final controller = ref.read(petControllerProvider.notifier);
    switch (_selected) {
      case HomeMenu.meal:
        _playCareSound();
        controller.feedMeal();
        break;
      case HomeMenu.snack:
        _playCareSound();
        controller.feedSnack();
        break;
      case HomeMenu.play:
        _playButtonSound();
        context.go('/play');
        break;
      case HomeMenu.clean:
        _playCareSound();
        controller.cleanRoom();
        break;
      case HomeMenu.sleep:
        _playCareSound();
        controller.toggleSleep();
        break;
      case HomeMenu.status:
        _playButtonSound();
        context.go('/status');
        break;
      case HomeMenu.diary:
        _playButtonSound();
        context.go('/diary');
        break;
      case HomeMenu.settings:
        _playButtonSound();
        context.go('/settings');
        break;
    }
  }

  void _playButtonSound() {
    if (!ref.read(petControllerProvider).soundEnabled) {
      return;
    }
    unawaited(ref.read(soundServiceProvider).playButton());
  }

  void _playCareSound() {
    if (!ref.read(petControllerProvider).soundEnabled) {
      return;
    }
    unawaited(ref.read(soundServiceProvider).playCare());
  }
}

class _LcdPanel extends StatelessWidget {
  const _LcdPanel({required this.pet});

  final PetState pet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lcdYellow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lcdPixelDark, width: 5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4432312B),
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 230,
                height: 210,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusIcon(label: 'H', active: pet.hunger > 35),
                        _StatusIcon(label: 'C', active: pet.cleanliness > 35),
                        _StatusIcon(label: 'E', active: pet.energy > 35),
                        _StatusIcon(label: 'HP', active: pet.health > 45),
                      ],
                    ),
                    const Spacer(),
                    PixelPet(stage: pet.stage, isSleeping: pet.isSleeping, isSick: pet.isSick),
                    const Spacer(),
                    Text(
                      '${pet.nameOrFallback} / ${pet.stage.label} / ${pet.ageHours}h',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.lcdPixelDark,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    PixelGauge(label: 'Happy', value: pet.happiness),
                    const SizedBox(height: 6),
                    PixelGauge(label: 'Energy', value: pet.energy),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lcdPixelDark, width: 2),
        color: active ? AppColors.lcdPixelDark : Colors.transparent,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.lcdYellow : AppColors.lcdPixelDark,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

extension PetFallbackName on PetState {
  String get nameOrFallback => name.trim().isEmpty ? 'Tiny Friend' : name;
}
