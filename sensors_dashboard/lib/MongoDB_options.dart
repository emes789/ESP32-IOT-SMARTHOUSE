import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MongoDBOptions {
  final String uri;
  final String database;
  final String? deviceId;
  final String? deviceLocation;
  final String? deviceFirmware;
  final bool demoMode;

  const MongoDBOptions({
    required this.uri,
    required this.database,
    this.deviceId,
    this.deviceLocation,
    this.deviceFirmware,
    this.demoMode = false,
  });
}

// Serwis do zarządzania połączeniem z MongoDB Atlas
class MongoDBService {
  static MongoDBService? _instance;
  static Db? _db;
  static bool _isConnected = false;

  MongoDBService._();

  static MongoDBService get instance {
    _instance ??= MongoDBService._();
    return _instance!;
  }

  // Inicjalizacja połączenia z MongoDB Atlas
  Future<void> connect(MongoDBOptions options) async {
    if (_isConnected && _db != null) {
      print('Already connected to MongoDB');
      return;
    }

    try {
      // Use URI from environment variables for security
      String uri = options.uri;

      // Diagnostic logs
      print('🔎 MongoDB connect: creating Db for URI: $uri');
      _db = await Db.create(uri);
      print('🔎 MongoDB connect: Db created, opening connection (12s timeout)...');

      // Add a timeout wrapper around open() to fail fast if network/DNS hangs
      await Future.any([
        _db!.open(),
        Future.delayed(const Duration(seconds: 12), () => throw Exception('MongoDB open() timeout after 12s'))
      ]);

      _isConnected = true;
      print('✅ Successfully connected to MongoDB Atlas');
      print('   Database: ${options.database}');
    } catch (e) {
      print('❌ Error connecting to MongoDB: $e');
      try {
        // print stack if available
        throw e;
      } catch (st) {
        print(st);
      }
      _isConnected = false;
      rethrow;
    }
  }

  // Zamknij połączenie
  Future<void> disconnect() async {
    if (_db != null && _isConnected) {
      await _db!.close();
      _isConnected = false;
      print('Disconnected from MongoDB');
    }
  }

  // Pobierz kolekcję
  DbCollection collection(String collectionName) {
    if (!_isConnected || _db == null) {
      throw Exception('Not connected to MongoDB. Call connect() first.');
    }
    return _db!.collection(collectionName);
  }

  // Sprawdź status połączenia
  bool get isConnected => _isConnected;

  // Pobierz bazę danych
  Db? get database => _db;
}

// Repozytorium dla urządzeń IoT
class DeviceRepository {
  final MongoDBService _mongoService = MongoDBService.instance;
  final String _collectionName = 'devices';

  DbCollection get _collection => _mongoService.collection(_collectionName);

  // Dodaj nowe urządzenie
  Future<void> addDevice(Map<String, dynamic> deviceData) async {
    try {
      await _collection.insertOne(deviceData);
      print('Device added successfully');
    } catch (e) {
      print('Error adding device: $e');
      rethrow;
    }
  }

  // Pobierz urządzenie po ID
  Future<Map<String, dynamic>?> getDevice(String deviceId) async {
    try {
      return await _collection.findOne(where.eq('deviceId', deviceId));
    } catch (e) {
      print('Error getting device: $e');
      rethrow;
    }
  }

  // Pobierz wszystkie urządzenia
  Future<List<Map<String, dynamic>>> getAllDevices() async {
    try {
      return await _collection.find().toList();
    } catch (e) {
      print('Error getting all devices: $e');
      rethrow;
    }
  }

  // Aktualizuj dane urządzenia
  Future<void> updateDevice(String deviceId, Map<String, dynamic> updates) async {
    try {
      await _collection.updateOne(
        where.eq('deviceId', deviceId),
        modify.set('lastUpdate', DateTime.now().toIso8601String()).set('data', updates),
      );
      print('Device updated successfully');
    } catch (e) {
      print('Error updating device: $e');
      rethrow;
    }
  }

  // Usuń urządzenie
  Future<void> deleteDevice(String deviceId) async {
    try {
      await _collection.deleteOne(where.eq('deviceId', deviceId));
      print('Device deleted successfully');
    } catch (e) {
      print('Error deleting device: $e');
      rethrow;
    }
  }

  // Zapisz dane z czujników (telemetria)
  Future<void> saveSensorData(String deviceId, Map<String, dynamic> sensorData) async {
    try {
      final telemetryCollection = _mongoService.collection('telemetry');

      final data = {
        'deviceId': deviceId,
        'timestamp': DateTime.now().toIso8601String(),
        'data': sensorData,
      };

      await telemetryCollection.insertOne(data);
      print('Sensor data saved successfully');
    } catch (e) {
      print('Error saving sensor data: $e');
      rethrow;
    }
  }

  // Pobierz historię danych z czujników
  // Fix: Ensure optional parameters are named correctly
  Future<List<Map<String, dynamic>>> getSensorHistory(
      String deviceId, {
        DateTime? startDate,
        DateTime? endDate,
        int limit = 100,
      }) async {
    try {
      final telemetryCollection = _mongoService.collection('telemetry');

      var selector = where.eq('deviceId', deviceId);

      if (startDate != null) {
        selector = selector.gte('timestamp', startDate.toIso8601String());
      }
      if (endDate != null) {
        selector = selector.lte('timestamp', endDate.toIso8601String());
      }

      // Find with sorting - sortFields is added to selector
      selector = selector.sortBy('timestamp', descending: true);

      return await telemetryCollection
          .find(selector)
          .take(limit)
          .toList();
    } catch (e) {
      print('Error getting sensor history: $e');
      rethrow;
    }
  }
}

class DefaultMongoDBOptions {
  static MongoDBOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultMongoDBOptions are not supported for this platform.',
        );
    }
  }

  // Wspólna konfiguracja dla wszystkich platform - loaded from .env
  static String get _mongoUri {
    try {
      return dotenv.env['MONGODB_URI'] ?? '';
    } catch (e) {
      print('⚠️ Warning: Could not load MongoDB URI from .env');
      return '';
    }
  }
  
  static String get _database {
    try {
      return dotenv.env['MONGODB_DATABASE'] ?? 'smart-house-iot';
    } catch (e) {
      return 'smart-house-iot';
    }
  }
  
  static String get _deviceId {
    try {
      return dotenv.env['DEVICE_ID'] ?? 'smart_house_001';
    } catch (e) {
      return 'smart_house_001';
    }
  }
  
  static String get _deviceLocation {
    try {
      return dotenv.env['DEVICE_LOCATION'] ?? 'Living Room';
    } catch (e) {
      return 'Living Room';
    }
  }
  
  static String get _deviceFirmware {
    try {
      return dotenv.env['DEVICE_FIRMWARE'] ?? 'v1.2.3';
    } catch (e) {
      return 'v1.2.3';
    }
  }
  static bool get _demoMode {
    try {
      return dotenv.env['DEMO_MODE']?.toLowerCase() == 'true';
    } catch (e) {
      return false;
    }
  }

  static MongoDBOptions get web => MongoDBOptions(
    uri: _mongoUri,
    database: _database,
    deviceId: _deviceId,
    deviceLocation: _deviceLocation,
    deviceFirmware: _deviceFirmware,
    demoMode: _demoMode,
  );

  static MongoDBOptions get android => MongoDBOptions(
    uri: _mongoUri,
    database: _database,
    deviceId: _deviceId,
    deviceLocation: _deviceLocation,
    deviceFirmware: _deviceFirmware,
    demoMode: _demoMode,
  );

  static MongoDBOptions get ios => MongoDBOptions(
    uri: _mongoUri,
    database: _database,
    deviceId: _deviceId,
    deviceLocation: _deviceLocation,
    deviceFirmware: _deviceFirmware,
    demoMode: _demoMode,
  );

  static MongoDBOptions get macos => MongoDBOptions(
    uri: _mongoUri,
    database: _database,
    deviceId: _deviceId,
    deviceLocation: _deviceLocation,
    deviceFirmware: _deviceFirmware,
    demoMode: _demoMode,
  );

  static MongoDBOptions get windows => MongoDBOptions(
    uri: _mongoUri,
    database: _database,
    deviceId: _deviceId,
    deviceLocation: _deviceLocation,
    deviceFirmware: _deviceFirmware,
    demoMode: _demoMode,
  );

  static MongoDBOptions get linux => MongoDBOptions(
    uri: _mongoUri,
    database: _database,
    deviceId: _deviceId,
    deviceLocation: _deviceLocation,
    deviceFirmware: _deviceFirmware,
    demoMode: _demoMode,
  );
}