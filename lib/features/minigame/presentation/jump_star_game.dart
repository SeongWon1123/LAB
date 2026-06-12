import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

enum JumpStarOutcome { won, lost }

class JumpStarResult {
  const JumpStarResult({
    required this.outcome,
    required this.score,
    required this.jumpsUsed,
    required this.elapsed,
  });

  final JumpStarOutcome outcome;
  final int score;
  final int jumpsUsed;
  final Duration elapsed;

  bool get won => outcome == JumpStarOutcome.won;
}

class JumpStarRules {
  const JumpStarRules({
    this.targetScore = 3,
    this.maxJumps = 8,
    this.duration = const Duration(seconds: 20),
  });

  final int targetScore;
  final int maxJumps;
  final Duration duration;

  JumpStarOutcome? evaluate({
    required int score,
    required int jumpsRemaining,
    required Duration elapsed,
    required bool isGrounded,
  }) {
    if (score >= targetScore) {
      return JumpStarOutcome.won;
    }
    if (elapsed >= duration) {
      return JumpStarOutcome.lost;
    }
    if (jumpsRemaining <= 0 && isGrounded) {
      return JumpStarOutcome.lost;
    }
    return null;
  }
}

class JumpStarGame extends FlameGame with TapCallbacks {
  JumpStarGame({
    required this.onFinished,
    this.rules = const JumpStarRules(),
    int? randomSeed,
  }) : _random = math.Random(randomSeed);

  final JumpStarRules rules;
  final void Function(JumpStarResult result) onFinished;

  final math.Random _random;

  int score = 0;
  late int jumpsRemaining = rules.maxJumps;

  double _elapsedSeconds = 0;
  double _runnerLift = 0;
  double _jumpVelocity = 0;
  double _starX = 0;
  double _starLane = 0.5;
  double _starBob = 0;
  double _sparkTimer = 0;
  bool _finished = false;

  static const ui.Color _lcdYellow = ui.Color(0xFFD9D08A);
  static const ui.Color _pixelDark = ui.Color(0xFF32312B);
  static const ui.Color _softShadow = ui.Color(0x5532312B);
  static const ui.Color _starFill = ui.Color(0xFFFFF4B8);
  static const ui.Color _starEdge = ui.Color(0xFF7A4E2D);
  static const double _gravity = 980;
  static const double _jumpPower = 420;

  bool get isGrounded => _runnerLift <= 0.5;

  @override
  ui.Color backgroundColor() => _lcdYellow;

  @override
  Future<void> onLoad() async {
    _spawnStar(initial: true);
  }

  @override
  void onTapDown(TapDownEvent event) {
    jump();
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.x >= 0 &&
        point.x <= _worldWidth &&
        point.y >= 0 &&
        point.y <= _worldHeight;
  }

  void jump() {
    if (_finished || !isGrounded || jumpsRemaining <= 0) {
      return;
    }
    _jumpVelocity = _jumpPower;
    jumpsRemaining -= 1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished) {
      return;
    }

    _elapsedSeconds += dt;
    _starBob += dt * 5;
    _sparkTimer = math.max(0, _sparkTimer - dt);

    _updateRunner(dt);
    _updateStar(dt);
    _handleCollision();

    final outcome = rules.evaluate(
      score: score,
      jumpsRemaining: jumpsRemaining,
      elapsed: _elapsed,
      isGrounded: isGrounded,
    );
    if (outcome != null) {
      _finish(outcome);
    }
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    final w = _worldWidth;
    final h = _worldHeight;
    final groundY = _groundY;

    final screenPaint = ui.Paint()..color = _lcdYellow;
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, w, h), screenPaint);

    _drawScanLines(canvas, w, h);
    _drawGround(canvas, groundY, w);
    _drawClouds(canvas, w, h);
    _drawStar(canvas, ui.Offset(_starX, _starY), _starRadius);
    _drawRunner(canvas, _runnerRect);

    if (_sparkTimer > 0) {
      _drawSpark(canvas, _runnerRect.center);
    }

    _drawText(
      canvas,
      'Stars $score/${rules.targetScore}',
      const ui.Offset(12, 10),
      bold: true,
    );
    _drawText(
      canvas,
      'Jumps $jumpsRemaining',
      ui.Offset(w - 84, 10),
      bold: true,
    );
    _drawText(
      canvas,
      _remainingLabel,
      ui.Offset(w / 2 - 14, 10),
      bold: true,
    );
  }

  void _updateRunner(double dt) {
    if (isGrounded && _jumpVelocity <= 0) {
      _runnerLift = 0;
      return;
    }

    _runnerLift += _jumpVelocity * dt;
    _jumpVelocity -= _gravity * dt;
    if (_runnerLift <= 0) {
      _runnerLift = 0;
      _jumpVelocity = 0;
    }
  }

  void _updateStar(double dt) {
    _starX -= _starSpeed * dt;
    if (_starX < -32) {
      _spawnStar();
    }
  }

  void _handleCollision() {
    if (_runnerRect.inflate(8).overlaps(_starRect)) {
      score += 1;
      _sparkTimer = 0.34;
      _spawnStar();
    }
  }

  void _finish(JumpStarOutcome outcome) {
    if (_finished) {
      return;
    }
    _finished = true;
    onFinished(
      JumpStarResult(
        outcome: outcome,
        score: score,
        jumpsUsed: rules.maxJumps - jumpsRemaining,
        elapsed: _elapsed,
      ),
    );
    pauseEngine();
  }

  void _spawnStar({bool initial = false}) {
    final w = _worldWidth;
    _starX = initial ? w * 0.78 : w + 28 + _random.nextDouble() * w * 0.35;
    _starLane = _random.nextDouble();
  }

  void _drawScanLines(ui.Canvas canvas, double w, double h) {
    final paint = ui.Paint()
      ..color = const ui.Color(0x2232312B)
      ..strokeWidth = 1;
    for (double y = 28; y < h; y += 12) {
      canvas.drawLine(ui.Offset(0, y), ui.Offset(w, y), paint);
    }
  }

  void _drawClouds(ui.Canvas canvas, double w, double h) {
    final paint = ui.Paint()..color = const ui.Color(0x4432312B);
    for (final x in <double>[w * 0.12, w * 0.58]) {
      final y = h * 0.32;
      canvas.drawRect(ui.Rect.fromLTWH(x, y, 18, 7), paint);
      canvas.drawRect(ui.Rect.fromLTWH(x + 8, y - 8, 18, 7), paint);
      canvas.drawRect(ui.Rect.fromLTWH(x + 24, y, 18, 7), paint);
    }
  }

  void _drawGround(ui.Canvas canvas, double groundY, double w) {
    final shadow = ui.Paint()..color = _softShadow;
    final dark = ui.Paint()..color = _pixelDark;
    canvas.drawRect(ui.Rect.fromLTWH(0, groundY + 6, w, 8), shadow);
    canvas.drawRect(ui.Rect.fromLTWH(0, groundY, w, 5), dark);
    for (double x = 10; x < w; x += 22) {
      canvas.drawRect(ui.Rect.fromLTWH(x, groundY - 6, 8, 3), dark);
    }
  }

  void _drawRunner(ui.Canvas canvas, ui.Rect body) {
    final dark = ui.Paint()..color = _pixelDark;
    final light = ui.Paint()..color = _lcdYellow;
    final shadow = ui.Paint()..color = _softShadow;

    canvas.drawRect(body.translate(4, 5), shadow);
    canvas.drawRect(body, dark);
    canvas.drawRect(ui.Rect.fromLTWH(body.left + 5, body.top - 8, 18, 8), dark);
    canvas.drawRect(ui.Rect.fromLTWH(body.left + 4, body.bottom, 7, 8), dark);
    canvas.drawRect(ui.Rect.fromLTWH(body.right - 11, body.bottom, 7, 8), dark);
    canvas.drawRect(ui.Rect.fromLTWH(body.left + 8, body.top + 10, 4, 4), light);
    canvas.drawRect(ui.Rect.fromLTWH(body.right - 13, body.top + 10, 4, 4), light);
    canvas.drawRect(ui.Rect.fromLTWH(body.left + 12, body.top + 23, 10, 3), light);
  }

  void _drawStar(ui.Canvas canvas, ui.Offset center, double radius) {
    final path = ui.Path();
    for (var i = 0; i < 10; i += 1) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final currentRadius = i.isEven ? radius : radius * 0.48;
      final point = ui.Offset(
        center.dx + math.cos(angle) * currentRadius,
        center.dy + math.sin(angle) * currentRadius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path.shift(const ui.Offset(3, 4)),
      ui.Paint()..color = _softShadow,
    );
    canvas.drawPath(path, ui.Paint()..color = _starFill);
    canvas.drawPath(
      path,
      ui.Paint()
        ..color = _starEdge
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawSpark(ui.Canvas canvas, ui.Offset center) {
    final paint = ui.Paint()
      ..color = _starFill
      ..strokeWidth = 3;
    for (final offset in const <ui.Offset>[
      ui.Offset(-22, -18),
      ui.Offset(24, -14),
      ui.Offset(-18, 18),
      ui.Offset(22, 20),
    ]) {
      final start = center + offset;
      canvas.drawLine(start, start + const ui.Offset(0, 8), paint);
      canvas.drawLine(start + const ui.Offset(-4, 4), start + const ui.Offset(4, 4), paint);
    }
  }

  void _drawText(
    ui.Canvas canvas,
    String text,
    ui.Offset offset, {
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _pixelDark,
          fontFamily: 'VT323',
          fontSize: 12,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  double get _worldWidth => math.max(size.x, 1.0);

  double get _worldHeight => math.max(size.y, 1.0);

  double get _groundY => _worldHeight - 34;

  double get _starSpeed => 88 + score * 12;

  double get _starRadius => math.max(12, _worldHeight * 0.07);

  double get _starY {
    final base = _worldHeight * (0.38 + _starLane * 0.18);
    return base + math.sin(_starBob) * 8;
  }

  ui.Rect get _starRect {
    final radius = _starRadius + 4;
    return ui.Rect.fromCircle(center: ui.Offset(_starX, _starY), radius: radius);
  }

  ui.Rect get _runnerRect {
    final runnerWidth = math.min(34.0, _worldWidth * 0.14);
    final runnerHeight = runnerWidth * 1.1;
    final x = _worldWidth * 0.18;
    final y = _groundY - runnerHeight - _runnerLift;
    return ui.Rect.fromLTWH(x, y, runnerWidth, runnerHeight);
  }

  Duration get _elapsed => Duration(milliseconds: (_elapsedSeconds * 1000).round());

  String get _remainingLabel {
    final total = rules.duration.inSeconds;
    final left = math.max(0, total - _elapsedSeconds.floor());
    return '${left}s';
  }
}
