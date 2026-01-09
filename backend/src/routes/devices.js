/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 📱 ROUTES - ZARZĄDZANIE URZĄDZENIAMI
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

const express = require('express');
const router = express.Router();
const { getCollection } = require('../config/database');
const { authenticateFlutter } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET /api/devices - Lista wszystkich urządzeń
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.get('/devices', authenticateFlutter, asyncHandler(async (req, res) => {
  const { location, status } = req.query;
  
  const collection = getCollection('devices');
  
  const query = {};
  if (location) query.location = location;
  if (status) query.status = status;

  const devices = await collection.find(query).toArray();

  // Dodaj status online/offline na podstawie lastSeen
  const now = new Date();
  const offlineThreshold = 5 * 60 * 1000; // 5 minut

  const devicesWithStatus = devices.map(device => ({
    ...device,
    isOnline: device.lastSeen && (now - new Date(device.lastSeen)) < offlineThreshold,
    lastSeenAgo: device.lastSeen ? formatTimeAgo(new Date(device.lastSeen)) : 'Never'
  }));

  res.json({
    success: true,
    count: devicesWithStatus.length,
    data: devicesWithStatus
  });
}));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET /api/devices/:deviceId - Szczegóły urządzenia
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.get('/devices/:deviceId', authenticateFlutter, asyncHandler(async (req, res) => {
  const { deviceId } = req.params;
  
  const devices = getCollection('devices');
  const telemetry = getCollection('telemetry');

  const device = await devices.findOne({ deviceId });

  if (!device) {
    return res.status(404).json({
      success: false,
      error: 'Device not found'
    });
  }

  // Pobierz ostatnie odczyty
  const latestReadings = await telemetry.aggregate([
    { $match: { deviceId } },
    { $sort: { timestamp: -1 } },
    { $group: {
        _id: '$sensorType',
        latestReading: { $first: '$$ROOT' }
      }
    },
    { $replaceRoot: { newRoot: '$latestReading' } }
  ]).toArray();

  res.json({
    success: true,
    data: {
      ...device,
      isOnline: device.lastSeen && (new Date() - new Date(device.lastSeen)) < 5 * 60 * 1000,
      latestReadings
    }
  });
}));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POST /api/devices - Zarejestruj nowe urządzenie
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.post('/devices', authenticateFlutter, asyncHandler(async (req, res) => {
  const { deviceId, name, location, type, firmware } = req.body;

  if (!deviceId) {
    return res.status(400).json({
      success: false,
      error: 'deviceId is required'
    });
  }

  const collection = getCollection('devices');

  // Sprawdź czy istnieje
  const existing = await collection.findOne({ deviceId });
  if (existing) {
    return res.status(409).json({
      success: false,
      error: 'Device already exists'
    });
  }

  const device = {
    deviceId,
    name: name || deviceId,
    location: location || 'Unknown',
    type: type || 'ESP32',
    firmware: firmware || 'unknown',
    status: 'registered',
    createdAt: new Date(),
    lastSeen: null
  };

  await collection.insertOne(device);

  res.status(201).json({
    success: true,
    message: 'Device registered successfully',
    data: device
  });
}));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PUT /api/devices/:deviceId - Aktualizuj urządzenie
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.put('/devices/:deviceId', authenticateFlutter, asyncHandler(async (req, res) => {
  const { deviceId } = req.params;
  const { name, location, type, firmware, status } = req.body;

  const collection = getCollection('devices');

  const updateFields = {};
  if (name) updateFields.name = name;
  if (location) updateFields.location = location;
  if (type) updateFields.type = type;
  if (firmware) updateFields.firmware = firmware;
  if (status) updateFields.status = status;
  updateFields.updatedAt = new Date();

  const result = await collection.updateOne(
    { deviceId },
    { $set: updateFields }
  );

  if (result.matchedCount === 0) {
    return res.status(404).json({
      success: false,
      error: 'Device not found'
    });
  }

  res.json({
    success: true,
    message: 'Device updated successfully'
  });
}));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DELETE /api/devices/:deviceId - Usuń urządzenie
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.delete('/devices/:deviceId', authenticateFlutter, asyncHandler(async (req, res) => {
  const { deviceId } = req.params;
  const { deleteReadings } = req.query;

  const devices = getCollection('devices');
  
  const result = await devices.deleteOne({ deviceId });

  if (result.deletedCount === 0) {
    return res.status(404).json({
      success: false,
      error: 'Device not found'
    });
  }

  // Opcjonalnie usuń też odczyty
  if (deleteReadings === 'true') {
    const telemetry = getCollection('telemetry');
    await telemetry.deleteMany({ deviceId });
  }

  res.json({
    success: true,
    message: 'Device deleted successfully'
  });
}));

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNKCJE POMOCNICZE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function formatTimeAgo(date) {
  const seconds = Math.floor((new Date() - date) / 1000);
  
  if (seconds < 60) return `${seconds}s ago`;
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
  if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
  return `${Math.floor(seconds / 86400)}d ago`;
}

module.exports = router;
