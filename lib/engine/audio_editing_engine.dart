import 'dart:math' as math;
import 'package:flutter/material.dart';

class AudioEditingEngine {
  /// Generates waveform Path for timeline track display
  static Path generateWaveformPath({
    required Size size,
    required double duration,
    int sampleCount = 60,
    double seed = 1.0,
  }) {
    final path = Path();
    final step = size.width / sampleCount;
    final centerY = size.height / 2;
    final random = math.Random((seed * 1000).toInt());

    path.moveTo(0, centerY);

    for (int i = 0; i < sampleCount; i++) {
      final x = i * step;
      final amplitude = (random.nextDouble() * 0.7 + 0.3) * (size.height / 2 - 4);
      final sign = i % 2 == 0 ? 1 : -1;
      final y = centerY + (amplitude * sign);
      
      path.lineTo(x, y);
    }
    path.lineTo(size.width, centerY);

    return path;
  }

  /// Calculates gain multiplier based on volume slider and fade envelopes
  static double calculateEffectiveVolume({
    required double baseVolume,
    required double layerStartTime,
    required double layerDuration,
    required double currentTime,
    double fadeInSeconds = 0.5,
    double fadeOutSeconds = 0.5,
  }) {
    final relativeTime = currentTime - layerStartTime;
    final remainingTime = (layerStartTime + layerDuration) - currentTime;

    double factor = 1.0;
    if (relativeTime < fadeInSeconds && fadeInSeconds > 0) {
      factor *= (relativeTime / fadeInSeconds).clamp(0.0, 1.0);
    }
    if (remainingTime < fadeOutSeconds && fadeOutSeconds > 0) {
      factor *= (remainingTime / fadeOutSeconds).clamp(0.0, 1.0);
    }

    return (baseVolume * factor).clamp(0.0, 2.0);
  }

  /// Generates Equalizer frequency spectrum bands for UI preview
  static List<double> getEqualizerSpectrum(String preset, double time) {
    final List<double> bands = List.filled(8, 0.5);
    final random = math.Random((time * 10).toInt() + preset.hashCode);

    for (int i = 0; i < bands.length; i++) {
      double base = 0.4 + random.nextDouble() * 0.4;
      if (preset == 'Bass Boost' && i < 3) {
        base *= 1.5;
      } else if (preset == 'Vocal Enhancer' && (i >= 2 && i <= 5)) {
        base *= 1.4;
      } else if (preset == 'Treble Boost' && i >= 5) {
        base *= 1.6;
      }
      bands[i] = base.clamp(0.1, 1.0);
    }
    return bands;
  }
}
