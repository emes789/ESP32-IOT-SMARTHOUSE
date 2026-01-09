import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
class AppColors {
  static const Color primary = Color(0xFF6366F1); 
  static const Color primaryLight = Color(0xFF818CF8); 
  static const Color primaryDark = Color(0xFF4F46E5); 
  static const Color secondary = Color(0xFF06B6D4); 
  static const Color secondaryLight = Color(0xFF22D3EE); 
  static const Color secondaryDark = Color(0xFF0891B2); 
  static const Color success = Color(0xFF10B981); 
  static const Color warning = Color(0xFFF59E0B); 
  static const Color error = Color(0xFFEF4444); 
  static const Color info = Color(0xFF3B82F6); 
  static const Color temperature = Color(0xFFFF6B6B); 
  static const Color humidity = Color(0xFF4ECDC4); 
  static const Color motion = Color(0xFF45B7D1); 
  static const Color alert = Color(0xFFFF8A65); 
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient temperatureGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient humidityGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient motionGradient = LinearGradient(
    colors: [Color(0xFF45B7D1), Color(0xFF96C93F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color background = Color(0xFFFAFAFA); 
  static const Color surface = Color(0xFFFFFFFF); 
  static const Color surfaceVariant = Color(0xFFF5F5F5); 
  static const Color textPrimary = Color(0xFF1F2937); 
  static const Color textSecondary = Color(0xFF6B7280); 
  static const Color textTertiary = Color(0xFF9CA3AF); 
  static const Color divider = Color(0xFFE5E7EB); 
  static const Color border = Color(0xFFD1D5DB); 
  static const Color shadow = Color(0xFF000000);
  static const Color darkBackground = Color(0xFF0F0F23); 
  static const Color darkSurface = Color(0xFF1A1A2E); 
  static const Color darkSurfaceVariant = Color(0xFF16213E); 
  static const Color darkTextPrimary = Color(0xFFF9FAFB); 
  static const Color darkTextSecondary = Color(0xFFD1D5DB); 
  static const Color darkTextTertiary = Color(0xFF9CA3AF); 
  static const Color darkDivider = Color(0xFF374151); 
  static const Color darkBorder = Color(0xFF4B5563); 
  static const List<Color> chartColors = [
    Color(0xFF6366F1), 
    Color(0xFF06B6D4), 
    Color(0xFF10B981), 
    Color(0xFFF59E0B), 
    Color(0xFFEF4444), 
    Color(0xFF8B5CF6), 
    Color(0xFFEC4899), 
    Color(0xFF84CC16), 
  ];
  static Color get glassLight => Colors.white.withAlphaFromOpacity(0.2);
  static Color get glassDark => Colors.white.withAlphaFromOpacity(0.1);
  static Color get cardLight => surface.withAlphaFromOpacity(0.8);
  static Color get cardDark => darkSurface.withAlphaFromOpacity(0.8);
  static Color get shimmerBase => Colors.grey[300]!;
  static Color get shimmerHighlight => Colors.grey[100]!;
  static Color get shimmerBaseDark => Colors.grey[700]!;
  static Color get shimmerHighlightDark => Colors.grey[500]!;
  static Color getTemperatureColor(double value) {
    if (value < 10) return const Color(0xFF3B82F6); 
    if (value < 20) return const Color(0xFF10B981); 
    if (value < 30) return const Color(0xFFF59E0B); 
    return const Color(0xFFEF4444); 
  }
  static Color getHumidityColor(double value) {
    if (value < 30) return const Color(0xFFEF4444); 
    if (value < 70) return const Color(0xFF10B981); 
    return const Color(0xFF3B82F6); 
  }
  static Color getAlertColor(String category) {
    switch (category) {
      case 'pilny':
        return error;
      case 'informacyjny':
        return warning;
      default:
        return info;
    }
  }
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimaryContainer = Color(0xFF1E1B16);
  static const Color secondaryContainer = Color(0xFFE6FFFA);
  static const Color onSecondaryContainer = Color(0xFF002020);
}
