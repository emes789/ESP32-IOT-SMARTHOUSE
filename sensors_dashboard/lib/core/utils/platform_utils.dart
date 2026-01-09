import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
  static bool isMobileScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  static bool isTabletScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }
  static bool isDesktopScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 400;
  }
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  static double getResponsivePadding(BuildContext context) {
    if (isMobileScreen(context)) return 16.0;
    if (isTabletScreen(context)) return 24.0;
    return 32.0;
  }
  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobileScreen(context)) return screenWidth - 32;
    if (isTabletScreen(context)) return screenWidth * 0.8;
    return 400.0;
  }
  static int getGridColumns(BuildContext context) {
    if (isMobileScreen(context)) return 1;
    if (isTabletScreen(context)) return 2;
    return 3;
  }
  static double getChartHeight(BuildContext context) {
    if (isMobileScreen(context)) return 200.0;
    if (isTabletScreen(context)) return 250.0;
    return 300.0;
  }
  static bool shouldUseDrawer(BuildContext context) {
    return isMobileScreen(context);
  }
  static bool shouldUseNavigationRail(BuildContext context) {
    return isDesktopScreen(context);
  }
  static bool shouldUseBottomNavigation(BuildContext context) {
    return isMobileScreen(context) || isTabletScreen(context);
  }
  static EdgeInsets getSystemPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
  static bool shouldUseAdvancedAnimations() {
    return !isWeb; 
  }
  static bool shouldUseCachedImages() {
    return !isWeb;
  }
  static Widget adaptiveButton({
    required VoidCallback onPressed,
    required String text,
    ButtonStyle? style,
  }) {
    if (isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(text),
    );
  }
  static Widget adaptiveLoading() {
    if (isIOS) {
      return const CupertinoActivityIndicator();
    }
    return const CircularProgressIndicator();
  }
  static Widget safeArea({
    required Widget child,
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }
  static void hapticFeedback() {
    if (isMobile) {
      HapticFeedback.lightImpact();
    }
  }
}
extension ResponsiveExtension on BuildContext {
  bool get isMobile => PlatformUtils.isMobileScreen(this);
  bool get isTablet => PlatformUtils.isTabletScreen(this);
  bool get isDesktop => PlatformUtils.isDesktopScreen(this);
  bool get isSmall => PlatformUtils.isSmallScreen(this);
  bool get isLarge => PlatformUtils.isLargeScreen(this);
  double get responsivePadding => PlatformUtils.getResponsivePadding(this);
  int get gridColumns => PlatformUtils.getGridColumns(this);
  double get chartHeight => PlatformUtils.getChartHeight(this);
}
