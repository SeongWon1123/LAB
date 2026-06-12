import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';
import 'package:pocket_memory_pet/features/diary/presentation/diary_screen.dart';
import 'package:pocket_memory_pet/features/hatch/presentation/hatch_screen.dart';
import 'package:pocket_memory_pet/features/home/presentation/home_screen.dart';
import 'package:pocket_memory_pet/features/minigame/presentation/jump_star_game.dart';
import 'package:pocket_memory_pet/features/minigame/presentation/play_screen.dart';
import 'package:pocket_memory_pet/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/features/pet/data/in_memory_pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/diary_entry.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';
import 'package:pocket_memory_pet/features/settings/presentation/settings_screen.dart';
import 'package:pocket_memory_pet/features/status/presentation/status_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      builder: (_) => const OnboardingScreen(),
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

  testWidgets('generates draft store screenshots', (tester) async {
    try {
      for (final size in sizes) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size.logicalSize;

        for (final capture in captures) {
          await _captureScreen(tester, size, capture);
        }
      }
    } finally {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });
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

  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage();
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  final bytes = byteData!.buffer.asUint8List();

  final output = File('build/store_screenshots/${size.name}/${capture.name}.png');
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(bytes);
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
