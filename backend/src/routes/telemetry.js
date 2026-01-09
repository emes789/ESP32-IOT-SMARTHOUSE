/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 📊 ROUTES - TELEMETRIA (dane z czujników ESP32)
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

const express = require('express');
const router = express.Router();
const { getCollection } = require('../config/database');
const { authenticateESP32, authenticateFlutter } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POST /api/telemetry - Odbierz dane z ESP32
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.post('/telemetry', authenticateESP32, asyncHandler(async (req, res) => {
  const { deviceId, sensorType, value, unit, location, rssi } = req.body;

  // Walidacja wymaganych pól
  if (!deviceId || !sensorType || value === undefined) {
    return res.status(400).json({
      success: false,
      error: 'Missing required fields',
      required: ['deviceId', 'sensorType', 'value']
    });
  }

  // Walidacja typu sensora
  const validSensorTypes = ['temperature', 'humidity', 'motion', 'light', 'pressure', 'gas'];
  if (!validSensorTypes.includes(sensorType)) {
    return res.status(400).json({
      success: false,
      error: 'Invalid sensor type',
      validTypes: validSensorTypes
    });
  }

  // Przygotuj dokument telemetrii
  const telemetryDoc = {
    deviceId,
    sensorType,
    value: parseFloat(value),
    unit: unit || getDefaultUnit(sensorType),
    location: location || 'Unknown',
    rssi: rssi ? parseInt(rssi) : null,
    timestamp: new Date(),
    receivedAt: new Date(),
    ip: req.ip
  };

  // Zapisz do MongoDB
  const collection = getCollection('telemetry');
  const result = await collection.insertOne(telemetryDoc);

  console.log(`📥 Telemetry: ${deviceId} → ${sensorType}: ${value}${telemetryDoc.unit}`);

  // Aktualizuj lastSeen urządzenia
  await updateDeviceLastSeen(deviceId, location);

  // Sprawdź alerty (progi)
  await checkAlerts(telemetryDoc);

  res.status(200).json({
    success: true,
    message: 'Telemetry data saved',
    id: result.insertedId,
    timestamp: telemetryDoc.timestamp
  });
}));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET /api/readings - Pobierz odczyty dla Flutter
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.get('/readings', authenticateFlutter, asyncHandler(async (req, res) => {
  const { 
    deviceId, 
    sensorType, 
    limit = 100, 
    startDate, 
    endDate,
    sortOrder = 'desc'
  } = req.query;

  const collection = getCollection('telemetry');
  
  // Buduj zapytanie
  const query = {};
  if (deviceId) query.deviceId = deviceId;
  if (sensorType) query.sensorType = sensorType;
  
  // Filtrowanie po dacie
  if (startDate || endDate) {
    query.timestamp = {};
    if (startDate) query.timestamp.$gte = new Date(startDate);
    if (endDate) query.timestamp.$lte = new Date(endDate);
  }

  // Wykonaj zapytanie
  const readings = await collection
    .find(query)
    .sort({ timestamp: sortOrder === 'asc' ? 1 : -1 })
    .limit(parseInt(limit))
    .toArray();

  res.json({
    success: true,
    count: readings.length,
    data: readings
  });
}));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET /api/readings/latest - Najnowsze odczyty z każdego sensora
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.get('/readings/latest', authenticateFlutter, asyncHandler(async (req, res) => {
  const collection = getCollection('telemetry');

  // Agregacja - najnowszy odczyt dla każdego (deviceId, sensorType)
  const latestReadings = await collection.aggregate([
    { $sort: { timestamp: -1 } },
    { 
      $group: {
        _id: { deviceId: '$deviceId', sensorType: '$sensorType' },
        latestReading: { $first: '$$ROOT' }
      }
    },
    { $replaceRoot: { newRoot: '$latestReading' } },
    { $sort: { deviceId: 1, sensorType: 1 } }
  ]).toArray();

  res.json({
    success: true,
    count: latestReadings.length,
    data: latestReadings
  });
}));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET /api/readings/stats - Statystyki
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.get('/readings/stats', authenticateFlutter, asyncHandler(async (req, res) => {
  const { deviceId, sensorType, period = '24h' } = req.query;
  
  const collection = getCollection('telemetry');
  
  // Oblicz datę początkową
  const periodMap = {
    '1h': 1 * 60 * 60 * 1000,
    '6h': 6 * 60 * 60 * 1000,
    '24h': 24 * 60 * 60 * 1000,
    '7d': 7 * 24 * 60 * 60 * 1000,
    '30d': 30 * 24 * 60 * 60 * 1000
  };
  
  const startDate = new Date(Date.now() - (periodMap[period] || periodMap['24h']));
  
  const matchStage = {
    timestamp: { $gte: startDate }
  };
  if (deviceId) matchStage.deviceId = deviceId;
  if (sensorType) matchStage.sensorType = sensorType;

  const stats = await collection.aggregate([
    { $match: matchStage },
    {
      $group: {
        _id: { deviceId: '$deviceId', sensorType: '$sensorType' },
        avg: { $avg: '$value' },
        min: { $min: '$value' },
        max: { $max: '$value' },
        count: { $sum: 1 },
        lastValue: { $last: '$value' },
        lastTimestamp: { $last: '$timestamp' }
      }
    },
    { $sort: { '_id.deviceId': 1, '_id.sensorType': 1 } }
  ]).toArray();

  res.json({
    success: true,
    period,
    startDate,
    data: stats.map(s => ({
      deviceId: s._id.deviceId,
      sensorType: s._id.sensorType,
      statistics: {
        average: Math.round(s.avg * 100) / 100,
        minimum: s.min,
        maximum: s.max,
        count: s.count,
        lastValue: s.lastValue,
        lastTimestamp: s.lastTimestamp
      }
    }))
  });
}));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET /api/alerts - Pobierz alerty
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.get('/alerts', authenticateFlutter, asyncHandler(async (req, res) => {
  const { deviceId, severity, acknowledged, limit = 50 } = req.query;
  
  const collection = getCollection('alerts');
  
  const query = {};
  if (deviceId) query.deviceId = deviceId;
  if (severity) query.severity = severity;
  if (acknowledged !== undefined) query.acknowledged = acknowledged === 'true';

  const alerts = await collection
    .find(query)
    .sort({ timestamp: -1 })
    .limit(parseInt(limit))
    .toArray();

  res.json({
    success: true,
    count: alerts.length,
    data: alerts
  });
}));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNKCJE POMOCNICZE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function getDefaultUnit(sensorType) {
  const units = {
    temperature: '°C',
    humidity: '%',
    motion: 'bool',
    light: 'lux',
    pressure: 'hPa',
    gas: 'ppm'
  };
  return units[sensorType] || '';
}

async function updateDeviceLastSeen(deviceId, location) {
  try {
    const devices = getCollection('devices');
    await devices.updateOne(
      { deviceId },
      { 
        $set: { 
          lastSeen: new Date(),
          location: location || 'Unknown'
        },
        $setOnInsert: {
          deviceId,
          createdAt: new Date(),
          status: 'online'
        }
      },
      { upsert: true }
    );
  } catch (error) {
    console.warn('⚠️  Error updating device lastSeen:', error.message);
  }
}

async function checkAlerts(telemetryDoc) {
  const thresholds = {
    temperature: { high: 30, low: 5 },
    humidity: { high: 80, low: 20 }
  };

  const threshold = thresholds[telemetryDoc.sensorType];
  if (!threshold) return;

  let alert = null;

  if (telemetryDoc.value > threshold.high) {
    alert = {
      deviceId: telemetryDoc.deviceId,
      sensorType: telemetryDoc.sensorType,
      type: 'high_value',
      severity: 'warning',
      message: `${telemetryDoc.sensorType} is above threshold: ${telemetryDoc.value}${telemetryDoc.unit} (max: ${threshold.high})`,
      value: telemetryDoc.value,
      threshold: threshold.high,
      timestamp: new Date(),
      acknowledged: false
    };
  } else if (telemetryDoc.value < threshold.low) {
    alert = {
      deviceId: telemetryDoc.deviceId,
      sensorType: telemetryDoc.sensorType,
      type: 'low_value',
      severity: 'warning',
      message: `${telemetryDoc.sensorType} is below threshold: ${telemetryDoc.value}${telemetryDoc.unit} (min: ${threshold.low})`,
      value: telemetryDoc.value,
      threshold: threshold.low,
      timestamp: new Date(),
      acknowledged: false
    };
  }

  if (alert) {
    try {
      const alerts = getCollection('alerts');
      await alerts.insertOne(alert);
      console.log(`🚨 Alert created: ${alert.message}`);
    } catch (error) {
      console.warn('⚠️  Error creating alert:', error.message);
    }
  }
}

module.exports = router;
