import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SensorReading {
  final String id;
  final String deviceId;
  final String sensorType;
  final double value;
  final DateTime timestamp;
  final String? unit;
  final Map<String, dynamic>? metadata;

  SensorReading({
    required this.id,
    required this.deviceId,
    required this.sensorType,
    required this.value,
    required this.timestamp,
    this.unit,
    this.metadata,
  });

  // Factory method for MongoDB data
  factory SensorReading.fromMongoDB(Map<String, dynamic> data) {
    return SensorReading(
      id: data['_id']?.toString() ?? '',
      deviceId: data['deviceId'] ?? '',
      sensorType: data['sensorType'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      timestamp: data['timestamp'] is String
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
      unit: data['unit'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  // Factory method for Realtime Database data (legacy support)
  factory SensorReading.fromRealtimeDb(String id, Map<dynamic, dynamic> data, String type) {
    return SensorReading(
      id: id,
      deviceId: data['deviceId'] ?? '',
      sensorType: type,
      value: (data['value'] ?? 0).toDouble(),
      timestamp: DateTime.tryParse(data['timestamp'].toString()) ?? DateTime.now(),
      unit: data['unit'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMongoDB() {
    return {
      'deviceId': deviceId,
      'sensorType': sensorType,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'unit': unit,
      'metadata': metadata,
    };
  }

  Map<String, dynamic> toJson() => toMongoDB();
  factory SensorReading.fromJson(Map<String, dynamic> json) =>
      SensorReading.fromMongoDB(json);

  // ========== GETTERS USED IN WIDGETS & PROVIDERS ==========

  // Fix for undefined_getter errors in provider
  double? get temperature => sensorType == 'temperature' ? value : null;
  double? get humidity => sensorType == 'humidity' ? value : null;
  double? get motion => sensorType == 'motion' ? value : null;

  // Alias for compatibility
  String get type => sensorType;

  String get sensorId => '$sensorType-${deviceId.substring(0, min(8, deviceId.length))}';

  // Helper for substring to avoid range errors
  int min(int a, int b) => a < b ? a : b;

  String get formattedValue {
    switch (sensorType) {
      case 'temperature':
        return '${value.toStringAsFixed(1)}°C';
      case 'humidity':
        return '${value.toStringAsFixed(1)}%';
      case 'motion':
        return value > 0 ? 'Wykryto' : 'Brak';
      default:
        return value.toStringAsFixed(2) + (unit ?? '');
    }
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Teraz';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min temu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} godz. temu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dni temu';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
    }
  }

  String get statusText {
    if (isCritical) return 'KRYTYCZNY';
    if (isWarning) return 'OSTRZEŻENIE';
    return 'NORMALNY';
  }

  bool get isCritical {
    switch (sensorType) {
      case 'temperature':
        return value > 35 || value < 10;
      case 'humidity':
        return value > 80 || value < 20;
      case 'motion':
        return value > 0;
      default:
        return false;
    }
  }

  bool get isWarning {
    switch (sensorType) {
      case 'temperature':
        return (value > 30 && value <= 35) || (value >= 10 && value < 15);
      case 'humidity':
        return (value > 70 && value <= 80) || (value >= 20 && value < 30);
      default:
        return false;
    }
  }

  Color get statusColor {
    if (isCritical) return Colors.red;
    if (isWarning) return Colors.orange;
    return Colors.green;
  }

  Color get typeColor {
    switch (sensorType) {
      case 'temperature':
        return AppColors.temperature;
      case 'humidity':
        return AppColors.humidity;
      case 'motion':
        return AppColors.motion;
      default:
        return AppColors.primary;
    }
  }

  IconData get typeIcon {
    switch (sensorType) {
      case 'temperature':
        return Icons.thermostat_rounded;
      case 'humidity':
        return Icons.water_drop_rounded;
      case 'motion':
        return Icons.directions_run_rounded;
      default:
        return Icons.sensors_rounded;
    }
  }

  String get typeDisplayName {
    switch (sensorType) {
      case 'temperature':
        return 'Temperatura';
      case 'humidity':
        return 'Wilgotność';
      case 'motion':
        return 'Czujnik ruchu';
      default:
        return sensorType.toUpperCase();
    }
  }

  bool get isRecent => DateTime.now().difference(timestamp).inMinutes < 5;
  bool get isOld => DateTime.now().difference(timestamp).inHours > 1;

  double get percentageInRange {
    switch (sensorType) {
      case 'temperature':
        return ((value - 0) / (50 - 0)).clamp(0.0, 1.0);
      case 'humidity':
        return (value / 100).clamp(0.0, 1.0);
      case 'motion':
        return value > 0 ? 1.0 : 0.0;
      default:
        return 0.5;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SensorReading &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SensorReading{id: $id, deviceId: $deviceId, sensorType: $sensorType, value: $value, timestamp: $timestamp}';
  }

  SensorReading copyWith({
    String? id,
    String? deviceId,
    String? sensorType,
    double? value,
    DateTime? timestamp,
    String? unit,
    Map<String, dynamic>? metadata,
  }) {
    return SensorReading(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      sensorType: sensorType ?? this.sensorType,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      unit: unit ?? this.unit,
      metadata: metadata ?? this.metadata,
    );
  }
}