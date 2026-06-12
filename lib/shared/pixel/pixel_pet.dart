import 'package:flutter/material.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';

class PixelPet extends StatelessWidget {
  const PixelPet({
    required this.stage,
    required this.isSleeping,
    required this.isSick,
    super.key,
  });

  final EvolutionStage stage;
  final bool isSleeping;
  final bool isSick;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PixelPetPainter(stage: stage, isSleeping: isSleeping, isSick: isSick),
      child: const SizedBox(width: 148, height: 118),
    );
  }
}

class _PixelPetPainter extends CustomPainter {
  const _PixelPetPainter({
    required this.stage,
    required this.isSleeping,
    required this.isSick,
  });

  final EvolutionStage stage;
  final bool isSleeping;
  final bool isSick;

  @override
  void paint(Canvas canvas, Size size) {
    const pixel = 8.0;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.lcdPixelDark;

    void block(int x, int y, [int w = 1, int h = 1]) {
      canvas.drawRect(
        Rect.fromLTWH(x * pixel, y * pixel, w * pixel, h * pixel),
        paint,
      );
    }

    if (stage == EvolutionStage.egg) {
      for (final rect in const [
        Rect.fromLTWH(6, 2, 7, 1),
        Rect.fromLTWH(4, 3, 11, 1),
        Rect.fromLTWH(3, 4, 13, 6),
        Rect.fromLTWH(4, 10, 11, 2),
        Rect.fromLTWH(6, 12, 7, 1),
      ]) {
        block(rect.left.toInt(), rect.top.toInt(), rect.width.toInt(), rect.height.toInt());
      }
      return;
    }

    block(4, 4, 10, 7);
    block(3, 6, 1, 3);
    block(14, 6, 1, 3);
    block(6, 2, 2, 2);
    block(10, 2, 2, 2);
    block(5, 11, 3, 2);
    block(10, 11, 3, 2);

    if (isSleeping) {
      block(6, 7, 2, 1);
      block(11, 7, 2, 1);
      block(15, 2, 1, 1);
      block(16, 1, 1, 1);
      block(17, 0, 1, 1);
    } else {
      block(6, 7);
      block(12, 7);
      block(8, 9, 3, 1);
    }

    if (isSick) {
      block(2, 2);
      block(15, 11);
    }

    if (stage == EvolutionStage.teen || stage == EvolutionStage.adult) {
      block(1, 7, 2, 1);
      block(15, 7, 2, 1);
    }

    if (stage == EvolutionStage.special) {
      block(8, 0, 2, 1);
      block(7, 1, 4, 1);
    }
  }

  @override
  bool shouldRepaint(covariant _PixelPetPainter oldDelegate) {
    return oldDelegate.stage != stage ||
        oldDelegate.isSleeping != isSleeping ||
        oldDelegate.isSick != isSick;
  }
}
