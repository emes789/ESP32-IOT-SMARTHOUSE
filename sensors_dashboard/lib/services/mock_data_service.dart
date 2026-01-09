import 'dart:math';
import '../models/sensor_reading.dart';
import '../models/alert.dart';
import '../core/constants/app_constants.dart';

class MockDataService {
  final Random _random = Random();

  List<SensorReading> generateMockTemperatureReadings({int count = 30}) {
    final now = DateTime.now();
    final baseTemp = 22.0; 
    final amplitude = 5.0;  
    
    return List.generate(count, (index) {
      final id = 'mock_temp_$index';
      final deviceId = 'temperature_sensor_001';
      final timestamp = now.subtract(Duration(minutes: index * 10));
      final hourOfDay = timestamp.hour + (timestamp.minute / 60.0);
      final dailyCycle = sin((hourOfDay / 24.0) * 2 * 3.14159);
      final noise = _random.nextDouble() * 0.8 - 0.4; 
      final value = baseTemp + (amplitude * dailyCycle) + noise;
      
      return SensorReading(
        id: id,
        deviceId: deviceId,
        value: value,
        timestamp: timestamp,
        sensorType: AppConstants.temperatureSensor,
      );
    });
  }

  List<SensorReading> generateMockHumidityReadings({int count = 30}) {
    final now = DateTime.now();
    final baseHumidity = 50.0; 
    final amplitude = 15.0;    
    
    return List.generate(count, (index) {
      final id = 'mock_hum_$index';
      final deviceId = 'humidity_sensor_001';
      final timestamp = now.subtract(Duration(minutes: index * 10));
      final hourOfDay = timestamp.hour + (timestamp.minute / 60.0);
      final dailyCycle = -sin((hourOfDay / 24.0) * 2 * 3.14159); 
      final noise = _random.nextDouble() * 3.0 - 1.5; 
      final value = baseHumidity + (amplitude * dailyCycle) + noise;
      
      return SensorReading(
        id: id,
        deviceId: deviceId,
        value: value,
        timestamp: timestamp,
        sensorType: AppConstants.humiditySensor,
      );
    });
  }

  List<SensorReading> generateMockMotionReadings({int count = 15}) {
    final now = DateTime.now();
    
    return List.generate(count, (index) {
      final id = 'mock_motion_$index';
      final deviceId = 'motion_sensor_001';
      final timestamp = now.subtract(Duration(minutes: index * 30));
      final hour = timestamp.hour;
      double motionProbability;
      
      if (hour >= 8 && hour < 22) {
        if (hour >= 8 && hour < 18) {
          motionProbability = 0.7;  
        } else {
          motionProbability = 0.4;  
        }
      } else {
        motionProbability = 0.1;  
      }
      
      final value = _random.nextDouble() < motionProbability ? 1.0 : 0.0;
      
      return SensorReading(
        id: id,
        deviceId: deviceId,
        value: value,
        timestamp: timestamp,
        sensorType: AppConstants.motionSensor,
      );
    });
  }

  List<Alert> generateMockAlerts({int count = 10}) {
    final now = DateTime.now();
    final alertTypes = ['temperature_high', 'temperature_low', 'humidity_high', 'motion_detected'];
    List<Alert> alerts = [];
    final recentCriticalCount = _random.nextInt(2); 
    
    for (int i = 0; i < recentCriticalCount; i++) {
      final id = 'mock_alert_critical_$i';
      final alertType = alertTypes[_random.nextInt(2)]; 
      final timestamp = now.subtract(Duration(minutes: _random.nextInt(60)));
      
      alerts.add(Alert(
        id: id,
        sensorId: 'temperature_sensor_001',
        deviceId: 'device_001', // Added missing deviceId
        timestamp: timestamp,
        alertType: alertType,
        severity: 'high',
        message: getAlertMessage(alertType),
        category: 'critical',
        isRead: false, 
        translations: {
          'pl': getAlertMessagePL(alertType),
          'en': getAlertMessage(alertType),
        },
        type: 'temperature', 
        original: getAlertMessage(alertType), 
      ));
    }
    
    final remainingCount = count - recentCriticalCount;
    
    for (int i = 0; i < remainingCount; i++) {
      final id = 'mock_alert_$i';
      String sensorId;
      String alertType;
      final sensorRandom = _random.nextDouble();
      
      if (sensorRandom < 0.4) {
        sensorId = 'temperature_sensor_001';
        alertType = _random.nextBool() ? 'temperature_high' : 'temperature_low';
      } else if (sensorRandom < 0.7) {
        sensorId = 'humidity_sensor_001';
        alertType = 'humidity_high';
      } else {
        sensorId = 'motion_sensor_001';
        alertType = 'motion_detected';
      }
      
      String category;
      if (alertType == 'motion_detected') {
        category = _random.nextDouble() < 0.8 ? 'info' : 'warning';
      } else {
        final catRandom = _random.nextDouble();
        if (catRandom < 0.2) category = 'critical';
        else if (catRandom < 0.6) category = 'warning';
        else category = 'info';
      }
      
      final timeOffset = (-_random.nextDouble() * _random.nextDouble() * 48).floor();
      final timestamp = now.subtract(Duration(hours: timeOffset));
      final hoursSinceAlert = now.difference(timestamp).inHours;
      final readProbability = hoursSinceAlert / 72.0; 
      final isRead = _random.nextDouble() < (readProbability > 0.95 ? 0.95 : readProbability);
      
      String sensorType;
      if (alertType.contains('temperature')) {
        sensorType = 'temperature';
      } else if (alertType.contains('humidity')) {
        sensorType = 'humidity';
      } else {
        sensorType = 'motion';
      }
      
      alerts.add(Alert(
        id: id,
        sensorId: sensorId,
        deviceId: 'device_001', // Added missing deviceId
        timestamp: timestamp,
        alertType: alertType,
        severity: category == 'critical' ? 'high' : (category == 'warning' ? 'medium' : 'low'),
        message: getAlertMessage(alertType),
        category: category,
        isRead: isRead,
        translations: {
          'pl': getAlertMessagePL(alertType),
          'en': getAlertMessage(alertType),
        },
        type: sensorType, 
        original: getAlertMessage(alertType), 
      ));
    }
    
    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return alerts;
  }

  String getAlertMessage(String alertType) {
    switch (alertType) {
      case 'temperature_high':
        return 'High temperature detected';
      case 'temperature_low':
        return 'Low temperature detected';
      case 'humidity_high':
        return 'High humidity detected';
      case 'motion_detected':
        return 'Motion detected in the room';
      default:
        return 'Unknown alert';
    }
  }

  String getAlertMessagePL(String alertType) {
    switch (alertType) {
      case 'temperature_high':
        return 'Wykryto wysoką temperaturę';
      case 'temperature_low':
        return 'Wykryto niską temperaturę';
      case 'humidity_high':
        return 'Wykryto wysoką wilgotność';
      case 'motion_detected':
        return 'Wykryto ruch w pomieszczeniu';
      default:
        return 'Nieznany alert';
    }
  }

  Map<String, dynamic> generateMockStatistics() {
    final temperatureReadings = generateMockTemperatureReadings();
    final humidityReadings = generateMockHumidityReadings();
    final motionReadings = generateMockMotionReadings();
    final alerts = generateMockAlerts();
    final tempValues = temperatureReadings.map((r) => r.value).toList();
    final humValues = humidityReadings.map((r) => r.value).toList();
    
    return {
      'totalReadings': temperatureReadings.length + humidityReadings.length + motionReadings.length,
      'temperatureCount': temperatureReadings.length,
      'humidityCount': humidityReadings.length,
      'motionCount': motionReadings.length,
      'averageTemperature': tempValues.reduce((a, b) => a + b) / tempValues.length,
      'averageHumidity': humValues.reduce((a, b) => a + b) / humValues.length,
      'minTemperature': tempValues.reduce((a, b) => a < b ? a : b),
      'maxTemperature': tempValues.reduce((a, b) => a > b ? a : b),
      'minHumidity': humValues.reduce((a, b) => a < b ? a : b),
      'maxHumidity': humValues.reduce((a, b) => a > b ? a : b),
      'criticalAlertsCount': alerts.where((a) => a.severity == 'high').length,
      'lastUpdateTime': DateTime.now(),
    };
  }
}