import 'package:flutter/material.dart';

extension ColorUtils on Color {
  /// Returns a color with the same RGB and an alpha calculated from [opacity]
  /// where [opacity] is in the range 0.0 - 1.0.
  Color withAlphaFromOpacity(double opacity) {
    final clamped = opacity.clamp(0.0, 1.0);
    final a = (clamped * 255).round();
    return withAlpha(a);
  }

  /// Convenience: provide percentage 0-100.
  Color withAlphaPercent(double percent) {
    final p = (percent / 100.0).clamp(0.0, 1.0);
    return withAlphaFromOpacity(p);
  }
}
