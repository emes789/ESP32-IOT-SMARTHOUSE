import 'package:flutter/material.dart';
extension MaterialAppDebugOverrideExtension on MaterialApp {
  MaterialApp disableDebugOverflowIndicators() {
    return MaterialApp(
      key: key,
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      home: home,
      routes: routes ?? const <String, WidgetBuilder>{},
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onUnknownRoute: onUnknownRoute,
      navigatorObservers: navigatorObservers ?? const <NavigatorObserver>[],
      builder: (BuildContext context, Widget? child) {
        final Widget materialAppChild = builder != null ? builder!(context, child) : child!;
        return _DebugBannerDisabler(child: materialAppChild);
      },
      title: title,
      onGenerateTitle: onGenerateTitle,
      color: color,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      localeResolutionCallback: localeResolutionCallback,
      localeListResolutionCallback: localeListResolutionCallback,
      supportedLocales: supportedLocales,
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
      checkerboardRasterCacheImages: false,
      checkerboardOffscreenLayers: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      highContrastTheme: highContrastTheme,
      highContrastDarkTheme: highContrastDarkTheme,
    );
  }
}
class _DebugBannerDisabler extends StatelessWidget {
  final Widget child;
  const _DebugBannerDisabler({required this.child});
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero, 
      ),
      child: Banner(
        location: BannerLocation.topStart,
        message: '',
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
