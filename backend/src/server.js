/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 🏠 SMART HOME IoT API SERVER
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * REST API dla systemu Smart Home:
 * - Odbiera dane z ESP32 (temperatura, wilgotność, ruch)
 * - Zapisuje do MongoDB
 * - Udostępnia dane dla aplikacji Flutter
 * 
 * Autor: Smart Home IoT Team
 * Wersja: 1.0.0
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const { connectDB, getDB } = require('./config/database');
const telemetryRoutes = require('./routes/telemetry');
const devicesRoutes = require('./routes/devices');
const healthRoutes = require('./routes/health');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🔒 MIDDLEWARE BEZPIECZEŃSTWA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Helmet - podstawowe nagłówki bezpieczeństwa
app.use(helmet());

// CORS - dozwolone originy
const corsOptions = {
  origin: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3000'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-API-Key'],
  credentials: true
};
app.use(cors(corsOptions));

// Rate Limiting - ochrona przed DDoS
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 60000, // 1 minuta
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,     // max 100 req/min
  message: {
    success: false,
    error: 'Too many requests, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false
});
app.use('/api/', limiter);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📝 PARSOWANIE I LOGOWANIE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// Morgan - logowanie requestów
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined'));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🛣️ ROUTES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Health check (publiczny)
app.use('/api', healthRoutes);

// Telemetria z ESP32
app.use('/api', telemetryRoutes);

// Zarządzanie urządzeniami
app.use('/api', devicesRoutes);

// Główna strona - informacja o API
app.get('/', (req, res) => {
  res.json({
    name: 'Smart Home IoT API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      health: 'GET /api/health',
      telemetry: 'POST /api/telemetry',
      readings: 'GET /api/readings',
      devices: 'GET /api/devices'
    },
    documentation: 'https://github.com/your-repo/docs'
  });
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ❌ ERROR HANDLING
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 404 - Not Found
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    path: req.originalUrl
  });
});

// Global error handler
app.use(errorHandler);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🚀 START SERWERA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async function startServer() {
  try {
    // Połącz z MongoDB
    await connectDB();
    console.log('✅ Connected to MongoDB');

    // Uruchom serwer
    app.listen(PORT, HOST, () => {
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log('🏠 SMART HOME IoT API');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log(`📡 Server running on http://${HOST}:${PORT}`);
      console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    });

  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('⏹️  SIGTERM received. Shutting down gracefully...');
  const { closeDB } = require('./config/database');
  await closeDB();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('⏹️  SIGINT received. Shutting down gracefully...');
  const { closeDB } = require('./config/database');
  await closeDB();
  process.exit(0);
});

startServer();

module.exports = app;
