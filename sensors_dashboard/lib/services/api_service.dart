/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// 🌐 API SERVICE - Komunikacja z backendem OVH
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// 
/// Ten serwis zastępuje bezpośrednie połączenie z MongoDB.
/// Komunikuje się z REST API hostowanym na OVH Cloud.
/// 
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/sensor_reading.dart';
import '../models/alert.dart';

/// Konfiguracja API pobierana z .env
class ApiConfig {
  static String get baseUrl => 
      dotenv.env['API_BASE_URL'] ?? 'https://api.twoja-domena.ovh';
  
  static String get apiKey => 
      dotenv.env['FLUTTER_API_KEY'] ?? '';
  
  static Duration get timeout => 
      Duration(seconds: int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30);
}

/// Wyjątek API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// Główny serwis API
class ApiService {
  static ApiService? _instance;
  final http.Client _client;
  
  final StreamController<SensorReading> _sensorStreamController = 
      StreamController<SensorReading>.broadcast();
  final StreamController<Alert> _alertStreamController = 
      StreamController<Alert>.broadcast();
  
  Timer? _pollingTimer;
  bool _isPolling = false;

  ApiService._() : _client = http.Client();

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  /// Streamy do nasłuchiwania nowych danych
  Stream<SensorReading> get sensorStream => _sensorStreamController.stream;
  Stream<Alert> get alertStream => _alertStreamController.stream;
  bool get isPolling => _isPolling;

  /// Nagłówki HTTP z autoryzacją
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${ApiConfig.apiKey}',
    'Accept': 'application/json',
  };

  // ═══════════════════════════════════════════════════════════════
  // 📊 TELEMETRIA / ODCZYTY SENSORÓW
  // ═══════════════════════════════════════════════════════════════

  /// Pobierz wszystkie odczyty sensorów
  Future<List<SensorReading>> getAllSensorReadings({
    String? deviceId,
    String? sensorType,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (deviceId != null) queryParams['deviceId'] = deviceId;
      if (sensorType != null) queryParams['sensorType'] = sensorType;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/readings')
          .replace(queryParameters: queryParams);

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'] ?? [];
        return data.map((item) => SensorReading.fromJson(item)).toList();
      } else {
        throw ApiException(
          'Failed to fetch readings',
          statusCode: response.statusCode,
          body: response.body,
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching sensor readings: $e');
      rethrow;
    }
  }

  /// Pobierz najnowsze odczyty
  Future<List<SensorReading>> getRecentSensorReadings(int limit) async {
    return getAllSensorReadings(limit: limit);
  }

  /// Pobierz najnowszy odczyt dla każdego sensora
  Future<List<SensorReading>> getLatestReadings() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/readings/latest');

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'] ?? [];
        return data.map((item) => SensorReading.fromJson(item)).toList();
      } else {
        throw ApiException(
          'Failed to fetch latest readings',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching latest readings: $e');
      rethrow;
    }
  }

  /// Pobierz statystyki
  Future<Map<String, dynamic>> getReadingsStats({
    String? deviceId,
    String? sensorType,
    String period = '24h',
  }) async {
    try {
      final queryParams = <String, String>{
        'period': period,
      };
      if (deviceId != null) queryParams['deviceId'] = deviceId;
      if (sensorType != null) queryParams['sensorType'] = sensorType;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/readings/stats')
          .replace(queryParameters: queryParams);

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          'Failed to fetch stats',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching stats: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📱 URZĄDZENIA
  // ═══════════════════════════════════════════════════════════════

  /// Pobierz listę urządzeń
  Future<List<Map<String, dynamic>>> getDevices() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/devices');

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(json['data'] ?? []);
      } else {
        throw ApiException(
          'Failed to fetch devices',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching devices: $e');
      rethrow;
    }
  }

  /// Pobierz szczegóły urządzenia
  Future<Map<String, dynamic>?> getDevice(String deviceId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/devices/$deviceId');

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'];
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ApiException(
          'Failed to fetch device',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching device: $e');
      rethrow;
    }
  }

  /// Zarejestruj nowe urządzenie
  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    String? name,
    String? location,
    String? type,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/devices');

      final body = jsonEncode({
        'deviceId': deviceId,
        if (name != null) 'name': name,
        if (location != null) 'location': location,
        if (type != null) 'type': type,
      });

      final response = await _client
          .post(uri, headers: _headers, body: body)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['data'];
      } else {
        throw ApiException(
          'Failed to register device',
          statusCode: response.statusCode,
          body: response.body,
        );
      }
    } catch (e) {
      debugPrint('❌ Error registering device: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🚨 ALERTY
  // ═══════════════════════════════════════════════════════════════

  /// Pobierz alerty
  Future<List<Alert>> getAllAlerts({
    String? deviceId,
    String? severity,
    bool? acknowledged,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (deviceId != null) queryParams['deviceId'] = deviceId;
      if (severity != null) queryParams['severity'] = severity;
      if (acknowledged != null) queryParams['acknowledged'] = acknowledged.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/alerts')
          .replace(queryParameters: queryParams);

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'] ?? [];
        return data.map((item) => Alert.fromJson(item)).toList();
      } else {
        throw ApiException(
          'Failed to fetch alerts',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching alerts: $e');
      rethrow;
    }
  }

  /// Pobierz ostatnie alerty
  Future<List<Alert>> getRecentAlerts(int limit) async {
    return getAllAlerts(limit: limit);
  }

  // ═══════════════════════════════════════════════════════════════
  // 💚 HEALTH CHECK
  // ═══════════════════════════════════════════════════════════════

  /// Sprawdź status API
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/health');

      final response = await _client
          .get(uri)  // Health check bez autoryzacji
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          'Health check failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ Health check error: $e');
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Sprawdź czy API jest dostępne
  Future<bool> isApiAvailable() async {
    try {
      final health = await healthCheck();
      return health['status'] == 'healthy' || health['status'] == 'degraded';
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 POLLING (symulacja real-time)
  // ═══════════════════════════════════════════════════════════════

  /// Rozpocznij polling danych
  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    if (_isPolling) return;
    _isPolling = true;
    
    debugPrint('🔄 Starting API polling (interval: ${interval.inSeconds}s)');
    
    _pollingTimer = Timer.periodic(interval, (timer) async {
      try {
        // Pobierz najnowsze odczyty
        final readings = await getRecentSensorReadings(5);
        if (readings.isNotEmpty) {
          _sensorStreamController.add(readings.first);
        }
        
        // Pobierz najnowsze alerty
        final alerts = await getRecentAlerts(3);
        if (alerts.isNotEmpty) {
          _alertStreamController.add(alerts.first);
        }
      } catch (e) {
        debugPrint('⚠️ Polling error: $e');
      }
    });
  }

  /// Zatrzymaj polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    debugPrint('⏹️ API polling stopped');
  }

  /// Zamknij serwis
  void dispose() {
    stopPolling();
    _sensorStreamController.close();
    _alertStreamController.close();
    _client.close();
    _instance = null;
  }
}

/// Alias dla kompatybilności wstecznej
/// Użyj ApiService.instance zamiast MongoDBService.instance
@Deprecated('Use ApiService instead')
typedef MongoDBServiceLegacy = ApiService;
