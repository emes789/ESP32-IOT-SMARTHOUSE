import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';

class Alert {
  final String id;
  final String sensorId;
  final String deviceId;
  final String? alertType;
  final String? severity;
  final String? message;
  final bool isRead;
  final Map<String, String> translations;
  final String category;
  final DateTime timestamp;
  final String type;
  final String? sensorType;
  final double? triggerValue;
  final double? threshold;
  final Map<String, dynamic>? metadata;
  final String? original;

  Alert({
    required this.id,
    required this.sensorId,
    required this.deviceId,
    this.alertType,
    this.severity,
    this.message,
    this.isRead = false,
    required this.translations,
    required this.category,
    required this.timestamp,
    this.type = '',
    this.sensorType,
    this.triggerValue,
    this.threshold,
    this.metadata,
    this.original,
  });

  // Factory method for MongoDB
  factory Alert.fromMongoDB(Map<String, dynamic> data) {
    Map<String, String> translations = {};
    if (data['translations'] != null && data['translations'] is Map) {
      final translationsData = data['translations'] as Map<String, dynamic>;
      translationsData.forEach((key, value) {
        translations[key] = value?.toString() ?? '';
      });
    }

    return Alert(
      id: data['_id']?.toString() ?? '',
      sensorId: data['sensorId'] ?? '',
      deviceId: data['deviceId'] ?? '',
      original: data['original'] ?? data['message'] ?? '',
      translations: translations,
      category: data['category'] ?? AppConstants.informativeAlert,
      timestamp: _parseTimestamp(data['timestamp']),
      type: data['type'] ?? '',
      sensorType: data['sensorType'],
      triggerValue: data['triggerValue']?.toDouble(),
      threshold: data['threshold']?.toDouble(),
      metadata: data['metadata'] as Map<String, dynamic>?,
      isRead: data['isRead'] ?? false,
      message: data['message'] ?? '',
    );
  }

  // Alias for fromMongoDB - required by mongodb_service.dart
  factory Alert.fromJson(Map<String, dynamic> json) => Alert.fromMongoDB(json);

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMongoDB() {
    final map = <String, dynamic>{
      'sensorId': sensorId,
      'deviceId': deviceId,
      'translations': translations,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
    };

    if (original != null) map['original'] = original;
    if (sensorType != null) map['sensorType'] = sensorType;
    if (triggerValue != null) map['triggerValue'] = triggerValue;
    if (threshold != null) map['threshold'] = threshold;
    if (metadata != null) map['metadata'] = metadata;
    if (message != null) map['message'] = message;

    return map;
  }

  Map<String, dynamic> toMap() => toMongoDB();

  // Critical getters used by Providers and Widgets
  bool get isUrgent => category == AppConstants.urgentAlert || category == 'urgent' || category == 'critical';
  bool get isInformative => category == AppConstants.informativeAlert;

  String get categoryDisplayName {
    if (isUrgent) return 'PILNY';
    if (isInformative) return 'Informacyjny';
    return category.toUpperCase();
  }

  String get typeDisplayName {
    switch (type) {
      case AppConstants.temperatureSensor:
        return 'Temperatura';
      case AppConstants.humiditySensor:
        return 'Wilgotność';
      case AppConstants.motionSensor:
        return 'Ruch';
      default:
        return type.toUpperCase();
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

  String get detailedTimestamp {
    return '${timestamp.day.toString().padLeft(2, '0')}.'
        '${timestamp.month.toString().padLeft(2, '0')}.'
        '${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  Color get categoryColor => AppColors.getAlertColor(category);

  Color get typeColor {
    switch (type) {
      case AppConstants.temperatureSensor:
        return AppColors.temperature;
      case AppConstants.humiditySensor:
        return AppColors.humidity;
      case AppConstants.motionSensor:
        return AppColors.motion;
      default:
        return AppColors.primary;
    }
  }

  IconData get categoryIcon {
    return isUrgent ? Icons.error_rounded : Icons.warning_rounded;
  }

  IconData get typeIcon {
    switch (type) {
      case AppConstants.temperatureSensor:
        return Icons.thermostat_rounded;
      case AppConstants.humiditySensor:
        return Icons.water_drop_rounded;
      case AppConstants.motionSensor:
        return Icons.directions_run_rounded;
      default:
        return Icons.sensors_rounded;
    }
  }

  String getTranslation(String languageCode) {
    return translations[languageCode] ?? original ?? message ?? '';
  }

  bool hasTranslation(String languageCode) {
    return translations.containsKey(languageCode) &&
        translations[languageCode]!.isNotEmpty;
  }

  List<String> get availableLanguages {
    return translations.keys.where((key) => translations[key]!.isNotEmpty).toList();
  }

  int get priority {
    if (isUrgent) return 3;
    if (category == AppConstants.informativeAlert) return 1;
    return 2;
  }

  String get severityText {
    switch (priority) {
      case 3:
        return 'Wysoki';
      case 2:
        return 'Średni';
      case 1:
        return 'Niski';
      default:
        return 'Nieznany';
    }
  }

  Duration get timeSinceAlert => DateTime.now().difference(timestamp);
  bool get isRecent => timeSinceAlert.inMinutes < 30;
  bool get isOld => timeSinceAlert.inDays > 7;

  String get formattedTriggerValue {
    if (triggerValue == null) return '';
    switch (type) {
      case AppConstants.temperatureSensor:
        return '${triggerValue!.toStringAsFixed(1)}°C';
      case AppConstants.humiditySensor:
        return '${triggerValue!.toStringAsFixed(1)}%';
      case AppConstants.motionSensor:
        return triggerValue == 1.0 ? 'Wykryto' : 'Nie wykryto';
      default:
        return triggerValue!.toStringAsFixed(2);
    }
  }

  String get formattedThreshold {
    if (threshold == null) return '';
    switch (type) {
      case AppConstants.temperatureSensor:
        return '${threshold!.toStringAsFixed(1)}°C';
      case AppConstants.humiditySensor:
        return '${threshold!.toStringAsFixed(1)}%';
      default:
        return threshold!.toStringAsFixed(2);
    }
  }

  String get shortSummary {
    String summary = '$typeDisplayName: $sensorId';
    if (triggerValue != null) {
      summary += ' - $formattedTriggerValue';
    }
    return summary;
  }

  String get fullSummary {
    return '$categoryDisplayName: $typeDisplayName $sensorId'
        '${triggerValue != null ? " ($formattedTriggerValue)" : ""}'
        ' - $formattedTimestamp';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Alert &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Alert{id: $id, sensorId: $sensorId, deviceId: $deviceId, category: $category, type: $type, timestamp: $timestamp}';
  }

  Alert copyWith({
    String? id,
    String? sensorId,
    String? deviceId,
    String? original,
    Map<String, String>? translations,
    String? category,
    DateTime? timestamp,
    String? type,
    String? sensorType,
    double? triggerValue,
    double? threshold,
    Map<String, dynamic>? metadata,
    bool? isRead,
  }) {
    return Alert(
      id: id ?? this.id,
      sensorId: sensorId ?? this.sensorId,
      deviceId: deviceId ?? this.deviceId,
      original: original ?? this.original,
      translations: translations ?? this.translations,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      sensorType: sensorType ?? this.sensorType,
      triggerValue: triggerValue ?? this.triggerValue,
      threshold: threshold ?? this.threshold,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
    );
  }
}