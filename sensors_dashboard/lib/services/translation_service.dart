import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
class TranslationService with ChangeNotifier {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;  TranslationService._internal();
  // Disabled online translation API - using offline translations only
  final String _apiUrl = 'https://translation.googleapis.com/language/translate/v2';
  String? _apiKey;
  String _currentLanguage = 'pl'; 
  String get currentLanguage => _currentLanguage;
  final Map<String, Map<String, String>> _translationsCache = {};
  final Map<String, Map<String, String>> _fallbackTranslations = {};
  bool _isInitialized = false;
  bool _apiErrorOccurred = true; // Set to true to use offline mode by default
  bool _isChangingLanguage = false;
  bool get isInitialized => _isInitialized;
  bool get hasApiError => _apiErrorOccurred;
  bool get isChangingLanguage => _isChangingLanguage;
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('language') ?? 'pl';
      await _loadFallbackTranslations();
      await _initializeGoogleApi();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Translation Service initialization error: $e');
      _apiErrorOccurred = true;
    }
  }
  Future<void> _initializeGoogleApi() async {
    try {
      // Using offline translations only - no API calls
      _apiErrorOccurred = true;
      debugPrint('ℹ️ Translation Service: Using offline translations only');
    } catch (e) {
      debugPrint('❌ Google API initialization error: $e');
      _apiErrorOccurred = true;
    }
  }  
  String translateTextSync(String text, {String? targetLanguage}) {
    if (text.isEmpty) return text;
    final language = targetLanguage ?? _currentLanguage;
    if (language == 'pl') {
      return text;
    }
    if (_translationsCache.containsKey(language) && _translationsCache[language]!.containsKey(text)) {
      return _translationsCache[language]![text]!;
    }
    if (_fallbackTranslations.containsKey(text) && _fallbackTranslations[text]!.containsKey(language)) {
      return _fallbackTranslations[text]![language]!;
    }
    return text;
  }
  Future<String> translateText(String text, {String? targetLanguage}) async {
    if (text.isEmpty) return text;
    final language = targetLanguage ?? _currentLanguage;
    if (language == 'pl') {
      return text;
    }
    if (text.contains('\n')) {
      final lines = text.split('\n');
      final translatedLines = await Future.wait(
        lines.map((line) => translateText(line, targetLanguage: language))
      );
      return translatedLines.join('\n');
    }
    if (_translationsCache.containsKey(language) && 
        _translationsCache[language]!.containsKey(text)) {
      return _translationsCache[language]![text] ?? text;
    }
    final fallback = getFallbackTranslation(text, language);
    if (fallback != null) {
      _translationsCache[language] ??= {};
      _translationsCache[language]![text] = fallback;
      return fallback;
    }
    
    // Offline mode - return original text if no translation found
    return text;
  }
  Future<List<String>> translateTexts(List<String> texts, {String? targetLanguage}) async {
    if (texts.isEmpty) return [];
    final language = targetLanguage ?? _currentLanguage;
    if (language == 'pl') {
      return texts;
    }
    final results = <String>[];
    for (final text in texts) {
      final translation = await translateText(text, targetLanguage: language);
      results.add(translation);
    }
    return results;
  }
  String? getFallbackTranslation(String text, String targetLanguage) {
    if (targetLanguage == 'pl') {
      return text;
    }
    if (_fallbackTranslations.containsKey(text) && 
        _fallbackTranslations[text]!.containsKey(targetLanguage)) {
      return _fallbackTranslations[text]![targetLanguage];
    }
    return null;
  }
  Future<void> _loadFallbackTranslations() async {
    try {
      final jsonString = await rootBundle.loadString('assets/translations/fallback.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      for (var entry in data.entries) {
        final key = entry.key;
        final translations = entry.value as Map<String, dynamic>;
        _fallbackTranslations[key] = {};
        for (var langEntry in translations.entries) {
          _fallbackTranslations[key]![langEntry.key] = langEntry.value as String;
        }
      }
      debugPrint('✅ Fallback translations loaded: ${_fallbackTranslations.length} entries');
    } catch (e) {
      debugPrint('⚠️ Failed to load fallback translations: $e');
      _initializeDefaultFallbacks();
    }
  }
  Future<void> changeLanguage(String languageCode) async {
    if (!AppConstants.supportedLanguages.contains(languageCode)) {
      return;
    }
    _isChangingLanguage = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      _currentLanguage = languageCode;
      debugPrint('✅ Language changed to: $languageCode (offline mode)');
    } catch (e) {
      debugPrint('❌ Error changing language: $e');
    } finally {
      _isChangingLanguage = false;
      notifyListeners();
    }
  }
  
  bool isSupportedLanguage(String languageCode) {
    return AppConstants.supportedLanguages.contains(languageCode);
  }
  Future<void> resetApiErrorState() async {
    _apiErrorOccurred = false;
    await _initializeGoogleApi();
    notifyListeners();
  }
  Future<void> clearTranslationsCache() async {
    _translationsCache.clear();
    debugPrint('✅ Translations cache cleared');
    notifyListeners();
  }
  Future<bool> setApiKey(String apiKey) async {
    if (apiKey.isEmpty) return false;
    try {
      final testResponse = await http.post(
        Uri.parse('$_apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': 'test',
          'target': 'en',
          'source': 'pl',
          'format': 'text',
        }),
      );
      if (testResponse.statusCode == 200) {
        _apiKey = apiKey;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('google_api_key', apiKey);
        _apiErrorOccurred = false;
        debugPrint('✅ API key validated and saved successfully');
        _translationsCache.clear();
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Invalid API key: ${testResponse.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ API key validation error: $e');
      return false;
    }
  }
  Map<String, dynamic> getApiStatus() {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return {
        'status': 'not_configured',
        'message': 'API nie jest skonfigurowane',
        'icon': Icons.error_outline,
        'color': Colors.orange,
        'details': 'Skonfiguruj klucz API, aby włączyć tłumaczenia online'
      };
    }
    if (_apiErrorOccurred) {
      return {
        'status': 'error',
        'message': 'Błąd połączenia z API',
        'icon': Icons.error,
        'color': Colors.red,
        'details': 'Sprawdź klucz API i połączenie internetowe'
      };
    }
    return {
      'status': 'ok',
      'message': 'API działa poprawnie',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'details': 'Tłumaczenia online są aktywne'
    };
  }
  void _addFallbackTranslation(String key, Map<String, String> translations) {
    _fallbackTranslations[key] = translations;
  }
  void _initializeDefaultFallbacks() {
    _addFallbackTranslation('System Online', {
      'pl': 'System Online',
      'en': 'System Online',
      'es': 'Sistema en línea',
      'de': 'System Online',
      'fr': 'Système en ligne',
    });
    _addFallbackTranslation('Łączne Alerty', {
      'pl': 'Łączne Alerty',
      'en': 'Total Alerts',
      'es': 'Alertas Totales',
      'de': 'Gesamte Alarme',
      'fr': 'Total des alertes',
    });
    _addFallbackTranslation('Pilne', {
      'pl': 'Pilne',
      'en': 'Urgent',
      'es': 'Urgentes',
      'de': 'Dringend',
      'fr': 'Urgentes',
    });
    _addFallbackTranslation('Ostatnie 30 min', {
      'pl': 'Ostatnie 30 min',
      'en': 'Last 30 min',
      'es': 'Últimos 30 min',
      'de': 'Letzte 30 Min',
      'fr': 'Dernières 30 min',
    });
    _addFallbackTranslation('Kategoria', {
      'pl': 'Kategoria',
      'en': 'Category',
      'es': 'Categoría',
      'de': 'Kategorie',
      'fr': 'Catégorie',
    });
    _addFallbackTranslation('Wszystkie', {
      'pl': 'Wszystkie',
      'en': 'All',
      'es': 'Todos',
      'de': 'Alle',
      'fr': 'Tous',
    });
    _addFallbackTranslation('Język', {
      'pl': 'Język',
      'en': 'Language',
      'es': 'Idioma',
      'de': 'Sprache',
      'fr': 'Langue',
    });
    _addFallbackTranslation('Polski', {
      'pl': 'Polski',
      'en': 'Polish',
      'es': 'Polaco',
      'de': 'Polnisch',
      'fr': 'Polonais',
    });
    _addFallbackTranslation('Angielski', {
      'pl': 'Angielski',
      'en': 'English',
      'es': 'Inglés',
      'de': 'Englisch',
      'fr': 'Anglais',
    });
    _addFallbackTranslation('Hiszpański', {
      'pl': 'Hiszpański',
      'en': 'Spanish',
      'es': 'Español',
      'de': 'Spanisch',
      'fr': 'Espagnol',
    });
    _addFallbackTranslation('Niemiecki', {
      'pl': 'Niemiecki',
      'en': 'German',
      'es': 'Alemán',
      'de': 'Deutsch',
      'fr': 'Allemand',
    });
    _addFallbackTranslation('Francuski', {
      'pl': 'Francuski',
      'en': 'French',
      'es': 'Francés',
      'de': 'Französisch',
      'fr': 'Français',
    });
    _addFallbackTranslation('Wykresy', {
      'pl': 'Wykresy',
      'en': 'Charts',
      'es': 'Gráficos',
      'de': 'Diagramme',
      'fr': 'Graphiques',
    });
    _addFallbackTranslation('Dane', {
      'pl': 'Dane',
      'en': 'Data',
      'es': 'Datos',
      'de': 'Daten',
      'fr': 'Données',
    });
    _addFallbackTranslation('Ładowanie danych historycznych...', {
      'pl': 'Ładowanie danych historycznych...',
      'en': 'Loading historical data...',
      'es': 'Cargando datos históricos...',
      'de': 'Historische Daten werden geladen...',
      'fr': 'Chargement des données historiques...',
    });
    _addFallbackTranslation('Ostatnie Odczyty', {
      'pl': 'Ostatnie Odczyty',
      'en': 'Recent Readings',
      'es': 'Lecturas Recientes',
      'de': 'Aktuelle Messwerte',
      'fr': 'Lectures Récentes',
    });
    _addFallbackTranslation('Zobacz wszystkie', {
      'pl': 'Zobacz wszystkie',
      'en': 'See all',
      'es': 'Ver todos',
      'de': 'Alle anzeigen',
      'fr': 'Voir tout',
    });
    _addFallbackTranslation('Brak odczytów', {
      'pl': 'Brak odczytów',
      'en': 'No readings',
      'es': 'Sin lecturas',
      'de': 'Keine Messwerte',
      'fr': 'Pas de lectures',
    });
    _addFallbackTranslation('Czekamy na dane z czujników IoT', {
      'pl': 'Czekamy na dane z czujników IoT',
      'en': 'Waiting for data from IoT sensors',
      'es': 'Esperando datos de sensores IoT',
      'de': 'Warten auf Daten von IoT-Sensoren',
      'fr': 'En attente de données des capteurs IoT',
    });
    _addFallbackTranslation('Brak danych', {
      'pl': 'Brak danych',
      'en': 'No data',
      'es': 'Sin datos',
      'de': 'Keine Daten',
      'fr': 'Pas de données',
    });
    _addFallbackTranslation('odczytów', {
      'pl': 'odczytów',
      'en': 'readings',
      'es': 'lecturas',
      'de': 'Messwerte',
      'fr': 'lectures',
    });
    _addFallbackTranslation('Historia Temperatury', {
      'pl': 'Historia Temperatury',
      'en': 'Temperature History',
      'es': 'Historial de Temperatura',
      'de': 'Temperaturverlauf',
      'fr': 'Historique de température',
    });
    _addFallbackTranslation('Historia Wilgotności', {
      'pl': 'Historia Wilgotności',
      'en': 'Humidity History',
      'es': 'Historial de Humedad',
      'de': 'Feuchtigkeitsverlauf',
      'fr': 'Historique d\'humidité',
    });
    _addFallbackTranslation('Historia Ruchu', {
      'pl': 'Historia Ruchu',
      'en': 'Motion History',
      'es': 'Historial de Movimiento',
      'de': 'Bewegungsverlauf',
      'fr': 'Historique de mouvement',
    });
    _addFallbackTranslation('Kokpit', {
      'pl': 'Kokpit',
      'en': 'Dashboard',
      'es': 'Panel',
      'de': 'Dashboard',
      'fr': 'Tableau de bord',
    });
  }
}
