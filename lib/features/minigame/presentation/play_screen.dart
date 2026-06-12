import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_memory_pet/core/audio/sound_service.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';
import 'package:pocket_memory_pet/features/minigame/presentation/jump_star_game.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/shared/layout/retro_screen_scaffold.dart';

class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  late JumpStarGame _game;
  JumpStarResult? _result;

  @override
  void initState() {
    super.initState();
    _createGame();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return RetroScreenScaffold(
      title: 'Jump Star',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result == null ? 'Catch 3 stars before the timer ends.' : _resultMessage(result),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.retroBrown,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 360),
                    height: 230,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lcdPixelDark,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4432312B),
                          blurRadius: 0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GameWidget<JumpStarGame>(
                        key: ObjectKey(_game),
                        game: _game,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ResultActions(
                    result: result,
                    onRestart: _restart,
                    onHome: () => context.go('/home'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _createGame() {
    _game = JumpStarGame(onFinished: _handleFinished);
  }

  void _restart() {
    setState(() {
      _result = null;
      _createGame();
    });
  }

  void _handleFinished(JumpStarResult result) {
    if (!mounted || _result != null) {
      return;
    }
    final session = ref.read(petControllerProvider);
    if (session.soundEnabled) {
      final soundService = ref.read(soundServiceProvider);
      unawaited(result.won ? soundService.playWin() : soundService.playMiss());
    }
    ref.read(petControllerProvider.notifier).play(won: result.won);
    setState(() {
      _result = result;
    });
  }

  String _resultMessage(JumpStarResult result) {
    if (result.won) {
      return 'A blinking star landed in your tiny friend\'s hands.';
    }
    return 'A soft little try still made the room brighter.';
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions({
    required this.result,
    required this.onRestart,
    required this.onHome,
  });

  final JumpStarResult? result;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final current = result;
    if (current == null) {
      return Text(
        '3 stars / 8 jumps',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.dustGray,
              fontWeight: FontWeight.w700,
            ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        OutlinedButton(
          onPressed: onRestart,
          child: const Text('Play again'),
        ),
        FilledButton(
          onPressed: onHome,
          child: const Text('Back home'),
        ),
      ],
    );
  }
}
