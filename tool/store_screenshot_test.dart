import 'dart:io';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';
import 'package:pocket_memory_pet/features/diary/presentation/diary_screen.dart';
import 'package:pocket_memory_pet/features/hatch/presentation/hatch_screen.dart';
import 'package:pocket_memory_pet/features/home/presentation/home_screen.dart';
import 'package:pocket_memory_pet/features/minigame/presentation/jump_star_game.dart';
import 'package:pocket_memory_pet/features/minigame/presentation/play_screen.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/features/pet/data/in_memory_pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/diary_entry.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';
import 'package:pocket_memory_pet/features/settings/presentation/settings_screen.dart';
import 'package:pocket_memory_pet/features/status/presentation/status_screen.dart';
import 'package:pocket_memory_pet/shared/layout/retro_screen_scaffold.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await loadAppFonts();
  });

  final sizes = <_ScreenshotSize>[
    const _ScreenshotSize(
      name: 'android_phone',
      logicalSize: Size(360, 800),
    ),
    const _ScreenshotSize(
      name: 'ios_6_7',
      logicalSize: Size(430, 932),
    ),
  ];

  final captures = <_ScreenCapture>[
    _ScreenCapture(
      name: '01_onboarding',
      builder: (_) => const _OnboardingDraftScreen(),
      sessionBuilder: _onboardingSession,
    ),
    _ScreenCapture(
      name: '02_hatch',
      builder: (_) => const HatchScreen(),
      sessionBuilder: _hatchSession,
    ),
    _ScreenCapture(
      name: '03_home',
      builder: (_) => const HomeScreen(),
      sessionBuilder: _sampleSession,
    ),
    _ScreenCapture(
      name: '04_status',
      builder: (_) => const StatusScreen(),
      sessionBuilder: _sampleSession,
    ),
    _ScreenCapture(
      name: '05_jump_star',
      builder: (_) => const PlayScreen(),
      sessionBuilder: _sampleSession,
      settle: const Duration(milliseconds: 500),
      beforeCapture: _pauseJumpStar,
    ),
    _ScreenCapture(
      name: '06_diary',
      builder: (_) => const DiaryScreen(),
      sessionBuilder: _sampleSession,
    ),
    _ScreenCapture(
      name: '07_settings',
      builder: (_) => const SettingsScreen(),
      sessionBuilder: _sampleSession,
    ),
  ];

  for (final size in sizes) {
    for (final capture in captures) {
      testWidgets('generates ${size.name}/${capture.name}', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size.logicalSize;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await _captureScreen(tester, size, capture);
      });
    }
  }
}

class _OnboardingDraftScreen extends StatelessWidget {
  const _OnboardingDraftScreen();

  @override
  Widget build(BuildContext context) {
    return RetroScreenScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.76),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Pet name',
                      filled: true,
                    ),
                    child: Text(
                      'Cloudy',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.retroBrown,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Find the tiny friend'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _captureScreen(
  WidgetTester tester,
  _ScreenshotSize size,
  _ScreenCapture capture,
) async {
  final key = GlobalKey();
  final session = capture.sessionBuilder(DateTime.now().toUtc());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        petRepositoryProvider.overrideWithValue(InMemoryPetRepository(seed: session)),
        initialPetSessionProvider.overrideWithValue(session),
      ],
      child: RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: capture.builder(session),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(capture.settle);
  await capture.beforeCapture?.call(tester);

  final outputDirectory = Directory('build/store_screenshots/${size.name}');
  outputDirectory.createSync(recursive: true);
  await expectLater(
    find.byKey(key),
    matchesGoldenFile('../build/store_screenshots/${size.name}/${capture.name}.png'),
  );
}

Future<void> _pauseJumpStar(WidgetTester tester) async {
  final finder = find.byWidgetPredicate(
    (widget) => widget is GameWidget<JumpStarGame>,
  );
  final widget = tester.widget<GameWidget<JumpStarGame>>(finder);
  widget.game?.pauseEngine();
  await tester.pump();
}

PetSession _onboardingSession(DateTime nowUtc) {
  return PetSession.initial(nowUtc).copyWith(soundEnabled: false);
}

PetSession _hatchSession(DateTime nowUtc) {
  final base = PetSession.initial(nowUtc);
  return base.copyWith(
    pet: base.pet.copyWith(name: 'Cloudy'),
    soundEnabled: false,
  );
}

PetSession _sampleSession(DateTime nowUtc) {
  final base = PetSession.initial(nowUtc);
  final pet = base.pet.copyWith(
    name: 'Cloudy',
    stage: EvolutionStage.child,
    hunger: 72,
    happiness: 86,
    cleanliness: 78,
    energy: 64,
    health: 91,
    discipline: 70,
    ageHours: 36,
    totalMeals: 7,
    totalSnacks: 3,
    totalCleanups: 5,
    totalMiniGameWins: 4,
  );

  return base.copyWith(
    pet: pet,
    soundEnabled: false,
    notificationsEnabled: true,
    diary: [
      DiaryEntry(
        id: 'growth-child',
        createdAtUtc: nowUtc.subtract(const Duration(hours: 2)),
        type: DiaryEntryType.growth,
        title: 'Cloudy learned a new blink',
        body: 'The little LCD room felt warmer after a careful day.',
        iconId: 'growth',
      ),
      DiaryEntry(
        id: 'play-star',
        createdAtUtc: nowUtc.subtract(const Duration(hours: 5)),
        type: DiaryEntryType.care,
        title: 'A star was caught',
        body: 'Cloudy jumped high and caught a blinking star.',
        iconId: 'play',
      ),
      DiaryEntry(
        id: 'clean-room',
        createdAtUtc: nowUtc.subtract(const Duration(hours: 8)),
        type: DiaryEntryType.care,
        title: 'A tidy room',
        body: 'The soft desk room became clean again.',
        iconId: 'clean',
      ),
      ...base.diary,
    ],
  );
}

class _ScreenCapture {
  const _ScreenCapture({
    required this.name,
    required this.builder,
    required this.sessionBuilder,
    this.settle = const Duration(milliseconds: 100),
    this.beforeCapture,
  });

  final String name;
  final Widget Function(PetSession session) builder;
  final PetSession Function(DateTime nowUtc) sessionBuilder;
  final Duration settle;
  final Future<void> Function(WidgetTester tester)? beforeCapture;
}

class _ScreenshotSize {
  const _ScreenshotSize({
    required this.name,
    required this.logicalSize,
  });

  final String name;
  final Size logicalSize;
}
