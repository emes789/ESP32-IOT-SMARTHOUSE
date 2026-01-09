import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/sensor_reading.dart';
import '../models/alert.dart';

// Klasa statystyk
class SensorStatistics {
  final double avgTemperature;
  final double maxTemperature;
  final double minTemperature;
  final double avgHumidity;
  final double maxHumidity;
  final double minHumidity;
  final int motionDetections;
  final int totalReadings;
  final int temperatureCount;
  final int humidityCount;
  final DateTime? lastUpdateTime;

  SensorStatistics({
    this.avgTemperature = 0,
    this.maxTemperature = 0,
    this.minTemperature = 0,
    this.avgHumidity = 0,
    this.maxHumidity = 0,
    this.minHumidity = 0,
    this.motionDetections = 0,
    this.totalReadings = 0,
    this.temperatureCount = 0,
    this.humidityCount = 0,
    this.lastUpdateTime,
  });

  dynamic operator [](String key) {
    switch (key) {
      case 'averageTemperature': return avgTemperature;
      case 'maxTemperature': return maxTemperature;
      case 'minTemperature': return minTemperature;
      case 'averageHumidity': return avgHumidity;
      case 'maxHumidity': return maxHumidity;
      case 'minHumidity': return minHumidity;
      case 'motionDetections': return motionDetections;
      case 'totalReadings': return totalReadings;
      case 'temperatureCount': return temperatureCount;
      case 'humidityCount': return humidityCount;
      case 'lastUpdateTime': return lastUpdateTime;
      default: return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'averageTemperature': avgTemperature,
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'averageHumidity': avgHumidity,
      'maxHumidity': maxHumidity,
      'minHumidity': minHumidity,
      'motionDetections': motionDetections,
      'totalReadings': totalReadings,
      'temperatureCount': temperatureCount,
      'humidityCount': humidityCount,
      'lastUpdateTime': lastUpdateTime?.toIso8601String(),
    };
  }
}

class SensorsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  // Stan
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _errorMessage;
  bool _hasError = false;
  bool _hasInternetConnection = true;
  bool _isDemoMode = false;

  // Dane
  List<SensorReading> _allReadings = [];
  List<Alert> _alerts = [];
  SensorStatistics _statistics = SensorStatistics();

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  bool get hasInternetConnection => _hasInternetConnection;
  bool get isDemoMode => _isDemoMode;
  bool get isRealDeviceConnected => !_isDemoMode && _hasInternetConnection;
  String get dataSourceName => _isDemoMode ? 'Demo' : 'MongoDB';

  List<SensorReading> get allReadings => _allReadings;
  List<Alert> get alerts => _alerts;
  List<Alert> get recentAlerts => _alerts.take(5).toList();
  List<Alert> get urgentAlerts => _alerts.where((a) => a.isUrgent).toList();
  SensorStatistics get statistics => _statistics;

  // Odczyty po typach
  List<SensorReading> get temperatureReadings =>
      _allReadings.where((r) => r.sensorType == 'temperature').toList();
  List<SensorReading> get humidityReadings =>
      _allReadings.where((r) => r.sensorType == 'humidity').toList();
  List<SensorReading> get motionReadings =>
      _allReadings.where((r) => r.sensorType == 'motion').toList();

  // Najnowsze odczyty
  SensorReading? get latestTemperature =>
      temperatureReadings.isNotEmpty ? temperatureReadings.first : null;
  SensorReading? get latestHumidity =>
      humidityReadings.isNotEmpty ? humidityReadings.first : null;
  SensorReading? get latestMotion =>
      motionReadings.isNotEmpty ? motionReadings.first : null;

  SensorsProvider() {
    _initialize();
  }

  Future<void> initialize() async {
    await _loadData();
  }

  Future<void> _initialize() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      // Pobierz dane z OVH API
      _allReadings = await _apiService.getAllSensorReadings(limit: 100);
      _allReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _generateAlerts();
      _calculateStatistics();

      _isLoaded = true;
      _hasError = false;
      _errorMessage = null;
      debugPrint('✅ Loaded ${_allReadings.length} readings from API');
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Błąd ładowania danych: $e';
      debugPrint('❌ Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _generateAlerts() {
    _alerts.clear();

    for (var reading in _allReadings.take(20)) {
      if (reading.sensorType == 'temperature' && reading.value > 30) {
        _alerts.add(Alert(
          id: 'alert_${reading.id}',
          sensorId: reading.sensorId,
          deviceId: reading.deviceId,
          alertType: 'high_temperature',
          sensorType: reading.sensorType,
          message: 'Wysoka temperatura: ${reading.value.toStringAsFixed(1)}°C',
          severity: reading.value > 35 ? 'high' : 'medium',
          category: reading.value > 35 ? 'urgent' : 'informative',
          timestamp: reading.timestamp,
          triggerValue: reading.value,
          translations: {
            'pl': 'Wysoka temperatura: ${reading.value.toStringAsFixed(1)}°C',
            'en': 'High temperature: ${reading.value.toStringAsFixed(1)}°C',
          },
        ));
      }

      if (reading.sensorType == 'humidity' && reading.value > 70) {
        _alerts.add(Alert(
          id: 'alert_${reading.id}',
          sensorId: reading.sensorId,
          deviceId: reading.deviceId,
          alertType: 'high_humidity',
          sensorType: reading.sensorType,
          message: 'Wysoka wilgotność: ${reading.value.toStringAsFixed(1)}%',
          severity: 'medium',
          category: 'informative',
          timestamp: reading.timestamp,
          triggerValue: reading.value,
          translations: {
            'pl': 'Wysoka wilgotność: ${reading.value.toStringAsFixed(1)}%',
            'en': 'High humidity: ${reading.value.toStringAsFixed(1)}%',
          },
        ));
      }
    }

    _alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _calculateStatistics() {
    final tempReadings = temperatureReadings;
    final humReadings = humidityReadings;
    final motReadings = motionReadings;

    if (tempReadings.isEmpty && humReadings.isEmpty) {
      _statistics = SensorStatistics();
      return;
    }

    _statistics = SensorStatistics(
      avgTemperature: tempReadings.isEmpty
          ? 0
          : tempReadings.map((r) => r.value).reduce((a, b) => a + b) /
          tempReadings.length,
      maxTemperature: tempReadings.isEmpty
          ? 0
          : tempReadings.map((r) => r.value).reduce((a, b) => a > b ? a : b),
      minTemperature: tempReadings.isEmpty
          ? 0
          : tempReadings.map((r) => r.value).reduce((a, b) => a < b ? a : b),
      avgHumidity: humReadings.isEmpty
          ? 0
          : humReadings.map((r) => r.value).reduce((a, b) => a + b) /
          humReadings.length,
      maxHumidity: humReadings.isEmpty
          ? 0
          : humReadings.map((r) => r.value).reduce((a, b) => a > b ? a : b),
      minHumidity: humReadings.isEmpty
          ? 0
          : humReadings.map((r) => r.value).reduce((a, b) => a < b ? a : b),
      motionDetections: motReadings.where((r) => r.value > 0).length,
      totalReadings: _allReadings.length,
      temperatureCount: tempReadings.length,
      humidityCount: humReadings.length,
      lastUpdateTime:
      _allReadings.isNotEmpty ? _allReadings.first.timestamp : null,
    );
  }

  Future<void> forceRefresh() async {
    await _loadData();
  }

  Future<void> retry() async {
    await _loadData();
  }

  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<List<SensorReading>> getHistoricalData(
      String sensorType,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      // Pobierz dane z API filtrowane po typie sensora
      final readings = await _apiService.getAllSensorReadings(
        sensorType: sensorType,
        limit: 1000,
      );
      
      // Filtruj po dacie
      return readings.where((r) => 
        r.timestamp.isAfter(startDate) && r.timestamp.isBefore(endDate)
      ).toList();
    } catch (e) {
      debugPrint('Error getting historical data: $e');
      return [];
    }
  }

  Future<List<Alert>> getAlertsByCategory(String category) async {
    if (category == 'all' || category == 'wszystkie') return _alerts;
    return _alerts.where((a) => a.category == category).toList();
  }
}