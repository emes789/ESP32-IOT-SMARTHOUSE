/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 🗄️ KONFIGURACJA BAZY DANYCH MongoDB
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

const { MongoClient } = require('mongodb');

let client = null;
let db = null;

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/smart-house-iot';
const DATABASE_NAME = process.env.MONGODB_DATABASE || 'smart-house-iot';

/**
 * Nawiąż połączenie z MongoDB
 */
async function connectDB() {
  if (db) {
    console.log('📦 Using existing MongoDB connection');
    return db;
  }

  try {
    console.log('🔄 Connecting to MongoDB...');
    console.log(`   URI: ${MONGODB_URI.replace(/\/\/.*:.*@/, '//***:***@')}`); // Ukryj credentials w logach

    client = new MongoClient(MONGODB_URI, {
      maxPoolSize: 10,
      minPoolSize: 2,
      maxIdleTimeMS: 30000,
      connectTimeoutMS: 10000,
      socketTimeoutMS: 45000,
      serverSelectionTimeoutMS: 10000,
      retryWrites: true,
      w: 'majority'
    });

    await client.connect();
    db = client.db(DATABASE_NAME);

    // Test połączenia
    await db.command({ ping: 1 });
    console.log(`✅ MongoDB connected to database: ${DATABASE_NAME}`);

    // Utwórz indeksy
    await createIndexes();

    return db;

  } catch (error) {
    console.error('❌ MongoDB connection error:', error.message);
    throw error;
  }
}

/**
 * Utwórz indeksy dla wydajności
 */
async function createIndexes() {
  try {
    // Indeksy dla kolekcji telemetry
    const telemetry = db.collection('telemetry');
    await telemetry.createIndex({ deviceId: 1, timestamp: -1 });
    await telemetry.createIndex({ sensorType: 1, timestamp: -1 });
    await telemetry.createIndex({ timestamp: -1 });
    await telemetry.createIndex(
      { timestamp: 1 },
      { expireAfterSeconds: 30 * 24 * 60 * 60 } // TTL: 30 dni
    );

    // Indeksy dla kolekcji devices
    const devices = db.collection('devices');
    await devices.createIndex({ deviceId: 1 }, { unique: true });
    await devices.createIndex({ location: 1 });

    // Indeksy dla kolekcji alerts
    const alerts = db.collection('alerts');
    await alerts.createIndex({ deviceId: 1, timestamp: -1 });
    await alerts.createIndex({ severity: 1 });
    await alerts.createIndex(
      { timestamp: 1 },
      { expireAfterSeconds: 90 * 24 * 60 * 60 } // TTL: 90 dni
    );

    console.log('📊 Database indexes created');

  } catch (error) {
    console.warn('⚠️  Index creation warning:', error.message);
  }
}

/**
 * Pobierz instancję bazy danych
 */
function getDB() {
  if (!db) {
    throw new Error('Database not connected. Call connectDB() first.');
  }
  return db;
}

/**
 * Pobierz kolekcję
 */
function getCollection(collectionName) {
  return getDB().collection(collectionName);
}

/**
 * Zamknij połączenie
 */
async function closeDB() {
  if (client) {
    await client.close();
    db = null;
    client = null;
    console.log('📴 MongoDB connection closed');
  }
}

/**
 * Sprawdź status połączenia
 */
function isConnected() {
  return db !== null && client !== null;
}

module.exports = {
  connectDB,
  getDB,
  getCollection,
  closeDB,
  isConnected
};
