/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 🗄️ MongoDB Initialization Script
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * Ten skrypt jest uruchamiany automatycznie przy pierwszym
 * uruchomieniu kontenera MongoDB. Tworzy użytkownika aplikacji
 * i bazę danych smart-house-iot.
 * 
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

// Przełącz na bazę aplikacji
db = db.getSiblingDB('smart-house-iot');

// Utwórz użytkownika aplikacji z ograniczonymi uprawnieniami
// ⚠️ UWAGA: To hasło jest używane tylko dla przykładu!
// W produkcji MUSISZ ustawić własne hasło w pliku .env
db.createUser({
  user: 'iot_user',
  pwd: 'CHANGE_ME_IN_PRODUCTION',  // ⚠️ Użyj .env w produkcji!
  roles: [
    {
      role: 'readWrite',
      db: 'smart-house-iot'
    }
  ]
});

print('✅ Created user: iot_user');

// Utwórz kolekcje
db.createCollection('telemetry');
db.createCollection('devices');
db.createCollection('alerts');
db.createCollection('users');

print('✅ Created collections: telemetry, devices, alerts, users');

// Utwórz indeksy dla telemetry
db.telemetry.createIndex({ deviceId: 1, timestamp: -1 });
db.telemetry.createIndex({ sensorType: 1, timestamp: -1 });
db.telemetry.createIndex({ timestamp: -1 });
// TTL index - automatyczne usuwanie danych starszych niż 30 dni
db.telemetry.createIndex(
  { timestamp: 1 },
  { expireAfterSeconds: 30 * 24 * 60 * 60 }
);

print('✅ Created indexes for telemetry collection');

// Utwórz indeksy dla devices
db.devices.createIndex({ deviceId: 1 }, { unique: true });
db.devices.createIndex({ location: 1 });
db.devices.createIndex({ lastSeen: -1 });

print('✅ Created indexes for devices collection');

// Utwórz indeksy dla alerts
db.alerts.createIndex({ deviceId: 1, timestamp: -1 });
db.alerts.createIndex({ severity: 1, timestamp: -1 });
db.alerts.createIndex({ acknowledged: 1 });
// TTL index - automatyczne usuwanie alertów starszych niż 90 dni
db.alerts.createIndex(
  { timestamp: 1 },
  { expireAfterSeconds: 90 * 24 * 60 * 60 }
);

print('✅ Created indexes for alerts collection');

// Dodaj przykładowe urządzenie testowe
db.devices.insertOne({
  deviceId: 'ESP32_TEST',
  name: 'Test Device',
  location: 'Test Room',
  type: 'ESP32',
  firmware: 'v1.0.0',
  status: 'registered',
  createdAt: new Date(),
  lastSeen: null
});

print('✅ Added test device: ESP32_TEST');

// Dodaj przykładowe dane telemetryczne
db.telemetry.insertMany([
  {
    deviceId: 'ESP32_TEST',
    sensorType: 'temperature',
    value: 22.5,
    unit: '°C',
    location: 'Test Room',
    timestamp: new Date(),
    rssi: -55
  },
  {
    deviceId: 'ESP32_TEST',
    sensorType: 'humidity',
    value: 45.0,
    unit: '%',
    location: 'Test Room',
    timestamp: new Date(),
    rssi: -55
  }
]);

print('✅ Added sample telemetry data');

print('');
print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
print('🎉 MongoDB initialization completed successfully!');
print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
