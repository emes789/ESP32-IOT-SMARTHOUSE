/*
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 🏠 SMART HOME IoT - ESP32 Sensor Node (OVH Cloud Edition)
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * Wysyła dane z czujników do serwera API na OVH Cloud
 * Obsługuje HTTPS dla bezpiecznej komunikacji
 * 
 * CZUJNIKI:
 * - DHT11 (temperatura + wilgotność) → GPIO 4
 * - PIR (czujnik ruchu) → GPIO 5
 * - LED (status) → GPIO 2
 * 
 * WYMAGANE BIBLIOTEKI:
 * - DHT sensor library (Adafruit)
 * - Adafruit Unified Sensor
 * - ArduinoJson
 * - WiFiClientSecure (wbudowana w ESP32)
 * 
 * WERSJA: 2.0.0 - OVH Cloud
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <DHT.h>

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🔧 KONFIGURACJA - ZMIEŃ TE WARTOŚCI!
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ═══════════════════════════════════════════════════════
// 📶 WiFi credentials
// ═══════════════════════════════════════════════════════
const char* WIFI_SSID = "YOUR_WIFI_SSID";          // ⬅️ Zmień!
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";     // ⬅️ Zmień!

// ═══════════════════════════════════════════════════════
// 🌐 API Endpoint na OVH Cloud
// ═══════════════════════════════════════════════════════
// HTTP (bez SSL) - dla produkcji zalecane HTTPS z domeną
const char* API_HOST = "YOUR_SERVER_IP_OR_DOMAIN";             // Serwer OVH
const int   API_PORT = 80;                          // HTTP
const char* API_PATH = "/api/telemetry";

// Pełny URL (dla HTTPClient)
const char* API_URL = "http://YOUR_SERVER_IP_OR_DOMAIN/api/telemetry";

// ═══════════════════════════════════════════════════════
// 🔐 API Key - BEZPIECZEŃSTWO!
// ═══════════════════════════════════════════════════════
// Ten klucz musi być taki sam jak ESP32_API_KEY na serwerze OVH
// Wygeneruj: openssl rand -hex 32
const char* API_KEY = "YOUR_ESP32_API_KEY_64_HEX_CHARACTERS_GENERATED_WITH_OPENSSL";

// ═══════════════════════════════════════════════════════
// 📱 Device configuration
// ═══════════════════════════════════════════════════════
const char* DEVICE_ID = "ESP32_SALON";              // ⬅️ Zmień: ESP32_KUCHNIA, etc.
const char* LOCATION = "Salon";                      // ⬅️ Zmień lokalizację
const char* FIRMWARE_VERSION = "2.0.0-OVH";

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📌 KONFIGURACJA PINÓW
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#define DHTPIN 4          // DHT11 DATA → GPIO 4
#define DHTTYPE DHT11     // DHT11 (niebieski czujnik)
#define PIR_PIN 5         // PIR OUT → GPIO 5
#define LED_PIN 2         // LED wbudowany ESP32

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⏱️ KONFIGURACJA CZASU
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const unsigned long SEND_INTERVAL = 30000;      // Wysyłaj co 30 sekund
const unsigned long WIFI_TIMEOUT = 20000;       // Timeout WiFi 20s
const unsigned long DHT_READ_DELAY = 2000;      // DHT wymaga 2s między odczytami
const unsigned long API_TIMEOUT = 15000;        // Timeout API 15s

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🔐 Let's Encrypt Root CA (ISRG Root X1)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Ten certyfikat jest używany przez Let's Encrypt
// Ważny do 2035 roku

const char* ROOT_CA = R"EOF(
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----
)EOF";

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🔧 INICJALIZACJA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DHT dht(DHTPIN, DHTTYPE);
WiFiClientSecure secureClient;

// Zmienne globalne
unsigned long lastSendTime = 0;
unsigned long lastDHTRead = 0;
bool lastMotionState = false;
int wifiReconnectAttempts = 0;
int apiFailCount = 0;

// Bufory na ostatnie odczyty
float lastTemperature = 0;
float lastHumidity = 0;
bool lastMotion = false;

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🚀 SETUP
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println();
  Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  Serial.println("🏠 SMART HOME IoT - ESP32 (OVH Cloud Edition)");
  Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  Serial.printf("📱 Device ID: %s\n", DEVICE_ID);
  Serial.printf("📍 Location: %s\n", LOCATION);
  Serial.printf("🔢 Firmware: %s\n", FIRMWARE_VERSION);
  Serial.printf("🌐 API: %s\n", API_HOST);
  Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

  // Konfiguracja pinów
  pinMode(PIR_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  // Start czujnika DHT11
  Serial.println("🌡️  Initializing DHT11...");
  dht.begin();
  delay(2000);
  Serial.println("✅ DHT11 ready");

  // Konfiguracja HTTPS z certyfikatem CA
  secureClient.setCACert(ROOT_CA);
  
  // Połącz z WiFi
  connectWiFi();
  
  // Synchronizacja czasu (wymagana dla HTTPS)
  syncTime();
  
  // Test czujników
  Serial.println("\n🧪 Testing sensors...");
  testSensors();
  
  Serial.println("\n✅ ESP32 Ready! Starting main loop...\n");
  digitalWrite(LED_PIN, HIGH);
  
  lastSendTime = millis();
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🔄 MAIN LOOP
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

void loop() {
  // Sprawdź połączenie WiFi
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("❌ WiFi disconnected!");
    digitalWrite(LED_PIN, LOW);
    connectWiFi();
  }

  // Wysyłaj dane z DHT11 co SEND_INTERVAL
  if (millis() - lastSendTime >= SEND_INTERVAL) {
    sendDHTData();
    lastSendTime = millis();
  }

  // Sprawdź czujnik ruchu natychmiast
  checkMotion();
  
  delay(100);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📡 POŁĄCZENIE WiFi
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

void connectWiFi() {
  Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  Serial.print("📡 Connecting to WiFi: ");
  Serial.println(WIFI_SSID);
  
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  unsigned long startAttempt = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startAttempt < WIFI_TIMEOUT) {
    delay(500);
    Serial.print(".");
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi Connected!");
    Serial.print("📍 IP Address: ");
    Serial.println(WiFi.localIP());
    Serial.print("📶 Signal strength (RSSI): ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
    Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    
    // Migaj LED 3 razy
    for (int i = 0; i < 3; i++) {
      digitalWrite(LED_PIN, LOW);
      delay(200);
      digitalWrite(LED_PIN, HIGH);
      delay(200);
    }
    
    wifiReconnectAttempts = 0;
  } else {
    Serial.println("\n❌ WiFi Connection Failed!");
    wifiReconnectAttempts++;
    if (wifiReconnectAttempts > 5) {
      Serial.println("⚠️  Too many failed attempts. Restarting...");
      delay(3000);
      ESP.restart();
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⏰ SYNCHRONIZACJA CZASU (NTP)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

void syncTime() {
  Serial.println("⏰ Synchronizing time with NTP...");
  
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  
  time_t now = time(nullptr);
  int timeout = 0;
  while (now < 8 * 3600 * 2 && timeout < 30) {
    delay(500);
    Serial.print(".");
    now = time(nullptr);
    timeout++;
  }
  
  Serial.println();
  
  if (now > 8 * 3600 * 2) {
    struct tm timeinfo;
    gmtime_r(&now, &timeinfo);
    Serial.print("✅ Time synchronized: ");
    Serial.println(asctime(&timeinfo));
  } else {
    Serial.println("⚠️  Time sync failed - HTTPS may not work!");
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🌡️ ODCZYT I WYSYŁANIE DHT11
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

void sendDHTData() {
  if (millis() - lastDHTRead < DHT_READ_DELAY) {
    return;
  }
  
  Serial.println("\n📊 Reading DHT11 sensor...");

  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("❌ Failed to read DHT11!");
    return;
  }
  
  lastTemperature = temperature;
  lastHumidity = humidity;
  lastDHTRead = millis();
  
  Serial.printf("🌡️  Temperature: %.1f°C\n", temperature);
  Serial.printf("💧 Humidity: %.1f%%\n", humidity);
  
  // Wyślij temperaturę
  bool tempSuccess = sendToAPI("temperature", temperature, "°C");
  delay(500);
  
  // Wyślij wilgotność
  bool humSuccess = sendToAPI("humidity", humidity, "%");
  
  if (tempSuccess && humSuccess) {
    digitalWrite(LED_PIN, LOW);
    delay(100);
    digitalWrite(LED_PIN, HIGH);
    apiFailCount = 0;
  } else {
    apiFailCount++;
    if (apiFailCount > 10) {
      Serial.println("⚠️  Too many API failures. Restarting...");
      delay(3000);
      ESP.restart();
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🚶 SPRAWDZANIE RUCHU (PIR)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

void checkMotion() {
  bool motionDetected = digitalRead(PIR_PIN);
  
  if (motionDetected != lastMotionState) {
    lastMotionState = motionDetected;
    lastMotion = motionDetected;
    
    if (motionDetected) {
      Serial.println("\n🚶 ━━━ MOTION DETECTED! ━━━");
      digitalWrite(LED_PIN, LOW);
      sendToAPI("motion", 1, "bool");
    } else {
      Serial.println("\n🔇 No motion detected");
      digitalWrite(LED_PIN, HIGH);
      sendToAPI("motion", 0, "bool");
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📤 WYSYŁANIE DANYCH DO API (HTTPS)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool sendToAPI(const char* sensorType, float value, const char* unit) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("❌ No WiFi - cannot send data");
    return false;
  }

  HTTPClient https;
  
  // Przygotuj JSON
  StaticJsonDocument<512> doc;
  doc["deviceId"] = DEVICE_ID;
  doc["sensorType"] = sensorType;
  doc["value"] = value;
  doc["unit"] = unit;
  doc["location"] = LOCATION;
  doc["rssi"] = WiFi.RSSI();
  doc["firmware"] = FIRMWARE_VERSION;
  
  String jsonData;
  serializeJson(doc, jsonData);
  
  Serial.println("📤 Sending to API (HTTPS):");
  Serial.println(jsonData);
  
  // Konfiguracja HTTPS
  https.begin(secureClient, API_URL);
  https.addHeader("Content-Type", "application/json");
  https.addHeader("X-API-Key", API_KEY);  // 🔐 Autoryzacja!
  https.setTimeout(API_TIMEOUT);
  
  int httpResponseCode = https.POST(jsonData);
  
  if (httpResponseCode > 0) {
    Serial.printf("✅ HTTPS Response: %d ", httpResponseCode);
    
    if (httpResponseCode == 200) {
      String response = https.getString();
      Serial.println("(OK)");
      https.end();
      return true;
    } else if (httpResponseCode == 401) {
      Serial.println("(Unauthorized - check API_KEY!)");
    } else if (httpResponseCode == 403) {
      Serial.println("(Forbidden - invalid API_KEY!)");
    } else {
      Serial.println("(Error)");
      String response = https.getString();
      Serial.println(response);
    }
  } else {
    Serial.printf("❌ HTTPS Error: %d\n", httpResponseCode);
    Serial.println("🔍 Possible issues:");
    Serial.println("   - Check internet connection");
    Serial.println("   - Verify API_HOST is correct");
    Serial.println("   - Server may be down");
    Serial.println("   - SSL certificate issue");
  }
  
  https.end();
  return false;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🧪 TEST CZUJNIKÓW
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

void testSensors() {
  // Test DHT11
  Serial.print("🌡️  DHT11: ");
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();
  
  if (!isnan(temp) && !isnan(hum)) {
    Serial.printf("✅ OK (%.1f°C, %.1f%%)\n", temp, hum);
  } else {
    Serial.println("❌ FAILED (check wiring)");
  }
  
  // Test PIR
  Serial.print("🚶 PIR: ");
  bool motion = digitalRead(PIR_PIN);
  Serial.printf("✅ OK (state: %s)\n", motion ? "HIGH" : "LOW");
  Serial.println("   ⏳ Wait 60s for PIR calibration...");
  
  // Test LED
  Serial.print("💡 LED: ");
  digitalWrite(LED_PIN, LOW);
  delay(500);
  digitalWrite(LED_PIN, HIGH);
  Serial.println("✅ OK (blinking)");
  
  // Test API connection
  Serial.print("🌐 API: ");
  if (testAPIConnection()) {
    Serial.println("✅ Connection OK");
  } else {
    Serial.println("⚠️  Connection failed (will retry in loop)");
  }
}

bool testAPIConnection() {
  HTTPClient https;
  String healthUrl = String("https://") + API_HOST + "/api/health";
  
  https.begin(secureClient, healthUrl);
  https.setTimeout(10000);
  
  int httpCode = https.GET();
  https.end();
  
  return httpCode == 200;
}
