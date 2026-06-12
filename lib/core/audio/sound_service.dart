import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundServiceProvider = Provider<SoundService>((ref) => const SoundService());

class SoundService {
  const SoundService();

  static var _prefixConfigured = false;

  Future<void> playButton() async {
    await _playEffect(
      file: 'button.wav',
      fallbackSound: SystemSoundType.click,
      haptic: HapticFeedback.selectionClick,
      volume: 0.28,
    );
  }

  Future<void> playCare() async {
    await _playEffect(
      file: 'care.wav',
      fallbackSound: SystemSoundType.alert,
      haptic: HapticFeedback.lightImpact,
      volume: 0.32,
    );
  }

  Future<void> playWin() async {
    await _playEffect(
      file: 'win.wav',
      fallbackSound: SystemSoundType.alert,
      haptic: HapticFeedback.mediumImpact,
      volume: 0.34,
    );
  }

  Future<void> playMiss() async {
    await _playEffect(
      file: 'miss.wav',
      fallbackSound: SystemSoundType.click,
      haptic: HapticFeedback.lightImpact,
      volume: 0.26,
    );
  }

  Future<void> _playEffect({
    required String file,
    required SystemSoundType fallbackSound,
    required Future<void> Function() haptic,
    required double volume,
  }) async {
    try {
      _configurePrefix();
      await FlameAudio.play(file, volume: volume);
      await haptic();
    } on Object catch (error) {
      await _fallback(fallbackSound, haptic);
      if (kDebugMode) {
        debugPrint('Sound effect skipped: $error');
      }
    }
  }

  void _configurePrefix() {
    if (_prefixConfigured) {
      return;
    }
    FlameAudio.updatePrefix('assets/sounds/');
    _prefixConfigured = true;
  }

  Future<void> _fallback(
    SystemSoundType fallbackSound,
    Future<void> Function() haptic,
  ) async {
    try {
      await SystemSound.play(fallbackSound);
      await haptic();
    } on Object {
      // Audio and haptic feedback are non-critical for care state changes.
    }
  }
}
