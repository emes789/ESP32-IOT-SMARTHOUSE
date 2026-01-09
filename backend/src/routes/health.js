/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 💚 ROUTES - HEALTH CHECK
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

const express = require('express');
const router = express.Router();
const { isConnected, getDB } = require('../config/database');

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET /api/health - Status serwera i bazy
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.get('/health', async (req, res) => {
  const status = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    services: {
      api: 'up',
      mongodb: 'unknown'
    }
  };

  try {
    if (isConnected()) {
      const db = getDB();
      await db.command({ ping: 1 });
      status.services.mongodb = 'up';
    } else {
      status.services.mongodb = 'disconnected';
      status.status = 'degraded';
    }
  } catch (error) {
    status.services.mongodb = 'error';
    status.status = 'unhealthy';
    status.error = error.message;
  }

  const httpStatus = status.status === 'healthy' ? 200 : 
                     status.status === 'degraded' ? 200 : 503;

  res.status(httpStatus).json(status);
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET /api/health/live - Kubernetes liveness probe
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.get('/health/live', (req, res) => {
  res.status(200).json({ status: 'alive' });
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET /api/health/ready - Kubernetes readiness probe
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
router.get('/health/ready', async (req, res) => {
  if (!isConnected()) {
    return res.status(503).json({ 
      status: 'not_ready',
      reason: 'MongoDB not connected'
    });
  }

  try {
    const db = getDB();
    await db.command({ ping: 1 });
    res.status(200).json({ status: 'ready' });
  } catch (error) {
    res.status(503).json({ 
      status: 'not_ready',
      reason: error.message
    });
  }
});

module.exports = router;
