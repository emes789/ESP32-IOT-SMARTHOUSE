import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/sensor_reading.dart';
import '../models/alert.dart';
import '../core/constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// MongoDB configuration loaded from .env file for security
String get _mongoDbUri => dotenv.env['MONGODB_URI'] ?? '';
const String _telemetryCollection = 'telemetry'; // Used for sensor readings

class MongoDBService {
  Db? _db;
  DbCollection? _sensorReadingsCollection;
  DbCollection? _alertsCollection;

  final StreamController<SensorReading> _sensorStreamController = StreamController.broadcast();
  final StreamController<Alert> _alertStreamController = StreamController.broadcast();

  bool _isConnecting = false;
  bool _isConnected = false;

  Stream<SensorReading> get sensorStream => _sensorStreamController.stream;
  Stream<Alert> get alertStream => _alertStreamController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;
    _isConnecting = true;

    try {
      // Use MongoDB URI from local constant
      _db = await Db.create(_mongoDbUri);
      await _db!.open();

      // Use telemetry collection for sensor readings
      _sensorReadingsCollection = _db!.collection(_telemetryCollection);
      _alertsCollection = _db!.collection(AppConstants.alertsCollection);

      _isConnected = true;
      _isConnecting = false;
      debugPrint("MongoDB Connected.");
      _startListening();
    } catch (e) {
      debugPrint("MongoDB Connection Error: $e");
      _isConnected = false;
      _isConnecting = false;
    }
  }

  Future<void> close() async {
    await _db?.close();
    _isConnected = false;
  }

  void _startListening() {
    // Polling (symulacja real-time na Free Tier)
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isConnected) { timer.cancel(); return; }
      final recents = await getRecentSensorReadings(5);
      if (recents.isNotEmpty) _sensorStreamController.add(recents.first);
    });

    Timer.periodic(const Duration(seconds: 30), (timer) async {
       if (!_isConnected) { timer.cancel(); return; }
       final alerts = await getRecentAlerts(3);
       if (alerts.isNotEmpty) _alertStreamController.add(alerts.first);
    });
  }

  Future<List<SensorReading>> getAllSensorReadings() async {
    if (!_isConnected) return [];
    final data = await _sensorReadingsCollection!.find(where.sortBy('timestamp', descending: true).limit(100)).toList();
    return data.map((json) => SensorReading.fromJson(json)).toList();
  }
  
  Future<List<SensorReading>> getRecentSensorReadings(int limit) async {
     if (!_isConnected) return [];
    final data = await _sensorReadingsCollection!.find(where.sortBy('timestamp', descending: true).limit(limit)).toList();
    return data.map((json) => SensorReading.fromJson(json)).toList();
  }

  Future<List<Alert>> getAllAlerts() async {
    if (!_isConnected) return [];
    final data = await _alertsCollection!.find(where.sortBy('timestamp', descending: true).limit(50)).toList();
    // Fixed: Alert.fromJson is now defined in the Alert model
    return data.map((json) => Alert.fromJson(json)).toList();
  }

  Future<List<Alert>> getRecentAlerts(int limit) async {
    if (!_isConnected) return [];
    final data = await _alertsCollection!.find(where.sortBy('timestamp', descending: true).limit(limit)).toList();
    // Fixed: Alert.fromJson is now defined in the Alert model
    return data.map((json) => Alert.fromJson(json)).toList();
  }
}
