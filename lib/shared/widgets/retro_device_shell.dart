import 'package:flutter/material.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';

class RetroDeviceShell extends StatelessWidget {
  const RetroDeviceShell({
    required this.lcd,
    required this.controls,
    required this.menuLabel,
    super.key,
  });

  final Widget lcd;
  final Widget controls;
  final String menuLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 330),
      child: AspectRatio(
        aspectRatio: 0.8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryPink,
            borderRadius: BorderRadius.circular(54),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72), width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x338B6F82),
                blurRadius: 24,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              const _ShellPattern(),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 42, 26, 26),
                child: Column(
                  children: [
                    Text(
                      'Pocket Memory Pet',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.retroBrown,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(child: lcd),
                    const SizedBox(height: 16),
                    Text(
                      menuLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.retroBrown,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    controls,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellPattern extends StatelessWidget {
  const _ShellPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShellPatternPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ShellPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.32);
    final starPaint = Paint()..color = AppColors.starPeach.withValues(alpha: 0.52);
    final rainbowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = AppColors.rainbowBlue.withValues(alpha: 0.48);

    void cloud(Offset offset) {
      canvas.drawCircle(offset, 12, cloudPaint);
      canvas.drawCircle(offset + const Offset(13, 1), 10, cloudPaint);
      canvas.drawCircle(offset + const Offset(25, 4), 8, cloudPaint);
    }

    cloud(const Offset(62, 68));
    cloud(Offset(size.width - 92, 112));
    cloud(Offset(size.width - 118, size.height - 98));

    for (final offset in [
      const Offset(58, 182),
      Offset(size.width - 62, 210),
      Offset(size.width - 70, size.height - 160),
    ]) {
      canvas.drawCircle(offset, 5, starPaint);
      canvas.drawCircle(offset, 2, Paint()..color = Colors.white.withValues(alpha: 0.7));
    }

    canvas.drawArc(
      Rect.fromCenter(center: Offset(size.width / 2, 114), width: 118, height: 78),
      3.7,
      1.7,
      false,
      rainbowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
