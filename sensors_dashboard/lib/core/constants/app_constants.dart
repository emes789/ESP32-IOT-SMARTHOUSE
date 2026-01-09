class AppConstants {
  static const String appName = 'Smart House IoT';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Centrum sterowania inteligentnym domem';
  static const String temperatureCollection = 'temperature_readings';
  static const String humidityCollection = 'humidity_readings';
  static const String motionCollection = 'motion_readings';
  static const String alertsCollection = 'alerts';
  static const String temperatureSensor = 'temperature';
  static const String humiditySensor = 'humidity';
  static const String motionSensor = 'motion';
  static const String urgentAlert = 'pilny';
  static const String informativeAlert = 'informacyjny';
  static const List<String> supportedLanguages = ['pl', 'en', 'es', 'de', 'fr'];
  static const Map<String, String> languageNames = {
    'pl': 'Polski',
    'en': 'English',
    'es': 'Español',
    'de': 'Deutsch',
    'fr': 'Français',
  };
  static const double temperatureThreshold = 30.0;
  static const double humidityThreshold = 70.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration refreshInterval = Duration(seconds: 30);
  static const Duration chartUpdateInterval = Duration(seconds: 5);
  static const int maxChartPoints = 50;
  static const int maxHistoryItems = 100;
  static const int maxAlerts = 100;  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const String baseApiUrl = 'https://smart-house-iot-api.example.com/api/v1';
  static const String noInternetError = 'Brak połączenia z internetem';
  static const String mongoError = 'Błąd połączenia z bazą danych';
  static const String unknownError = 'Wystąpił nieznany błąd';
  static const String noDataError = 'Brak danych do wyświetlenia';
  static const String dataLoadedSuccess = 'Dane zostały załadowane pomyślnie';
  static const String settingsSaved = 'Ustawienia zostały zapisane';
  static const String temperatureIcon = '🌡️';
  static const String humidityIcon = '💧';
  static const String motionIcon = '🚶';
  static const String alertIcon = '🚨';
}
