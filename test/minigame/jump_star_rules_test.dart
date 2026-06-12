import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/features/minigame/presentation/jump_star_game.dart';

void main() {
  group('JumpStarRules', () {
    const rules = JumpStarRules();

    test('wins when the target score is reached', () {
      final outcome = rules.evaluate(
        score: 3,
        jumpsRemaining: 4,
        elapsed: const Duration(seconds: 8),
        isGrounded: false,
      );

      expect(outcome, JumpStarOutcome.won);
    });

    test('loses when the timer ends before the target score', () {
      final outcome = rules.evaluate(
        score: 2,
        jumpsRemaining: 3,
        elapsed: const Duration(seconds: 20),
        isGrounded: true,
      );

      expect(outcome, JumpStarOutcome.lost);
    });

    test('continues while jumps remain and time remains', () {
      final outcome = rules.evaluate(
        score: 1,
        jumpsRemaining: 2,
        elapsed: const Duration(seconds: 12),
        isGrounded: true,
      );

      expect(outcome, isNull);
    });
  });
}
