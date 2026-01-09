# 🏠 Smart Home IoT System

> **Projekt studencki** - System monitoringu inteligentnego domu z wykorzystaniem ESP32, Node.js i Flutter

[![Live Server](https://img.shields.io/badge/Server-Configure_Your_Own-blue?style=for-the-badge)](http://your-server.com/api/health)
[![OVH Cloud](https://img.shields.io/badge/OVH-Cloud-123F6D?style=for-the-badge&logo=ovh)](https://www.ovh.com)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=for-the-badge&logo=node.js)](https://nodejs.org)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Security](https://img.shields.io/badge/Security-Guide-red?style=for-the-badge&logo=security)](SECURITY.md)

---

## 🎓 Informacje o Projekcie

| | |
|---|---|
| **Typ projektu** | Projekt zaliczeniowy |
| **Temat** | System IoT do monitoringu środowiska domowego |
| **Technologie** | ESP32, Node.js, MongoDB, Flutter, Docker |
| **Infrastruktura** | OVH Cloud VPS (Warszawa) |
| **Status** | ✅ **Produkcja** - działa 24/7 |

---

## 🎯 Cel Projektu

Zaprojektowanie i implementacja **kompletnego systemu IoT** umożliwiającego:

1. **Zbieranie danych** z czujników (temperatura, wilgotność, ruch)
2. **Przesyłanie danych** przez WiFi do serwera w chmurze
3. **Przechowywanie** w bazie danych NoSQL (MongoDB)
4. **Wizualizacja** w aplikacji mobilnej/webowej (Flutter)
5. **Hosting 24/7** na infrastrukturze chmurowej

---

## 🏗️ Architektura Systemu

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ARCHITEKTURA SMART HOME IoT                          │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐                                        ┌─────────────┐
    │   ESP32     │                                        │   Flutter   │
    │  Mikrokont. │                                        │     App     │
    │             │                                        │             │
    │ • Temp/Wilg │                                        │ • Android   │
    │ • Czuj.ruchu│                                        │ • iOS / Web │
    └──────┬──────┘                                        └──────┬──────┘
           │                                                      │
           │  HTTP POST                              HTTP GET     │
           │  + API Key                              + Bearer     │
           │                                                      │
           └──────────────────────┬───────────────────────────────┘
                                  │
                                  ▼
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                    🌐 OVH VPS (YOUR_SERVER_IP)                            │
    │  ┌───────────────────────────────────────────────────────────────────┐  │
    │  │                        Docker Compose                              │  │
    │  │                                                                    │  │
    │  │   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐           │  │
    │  │   │   Nginx     │    │  Node.js    │    │  MongoDB    │           │  │
    │  │   │   Proxy     │───►│    API      │───►│  Database   │           │  │
    │  │   │   :80       │    │   :3000     │    │   :27017    │           │  │
    │  │   └─────────────┘    └─────────────┘    └─────────────┘           │  │
    │  │                                                                    │  │
    │  └───────────────────────────────────────────────────────────────────┘  │
    └─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Wykorzystane Technologie

### Hardware
| Komponent | Opis |
|-----------|------|
| **ESP32 DevKit** | Mikrokontroler z WiFi/Bluetooth |
| **DHT11** | Czujnik temperatury i wilgotności |
| **PIR HC-SR501** | Czujnik ruchu (podczerwień) |

### Software
| Warstwa | Technologia | Opis |
|---------|-------------|------|
| **Firmware** | C++ / Arduino | Kod ESP32 |
| **Backend** | Node.js + Express | REST API |
| **Baza danych** | MongoDB 7.0 | NoSQL, dokumentowa |
| **Frontend** | Flutter 3.x | Cross-platform app |
| **Konteneryzacja** | Docker | Izolacja usług |
| **Reverse Proxy** | Nginx | Load balancing |

### Infrastruktura
| Element | Specyfikacja |
|---------|--------------|
| **Serwer** | OVH VPS b3-8 |
| **CPU** | 2 vCPU |
| **RAM** | 8 GB |
| **Dysk** | 80 GB NVMe |
| **Lokalizacja** | Warszawa, PL |
| **IP** | `YOUR_SERVER_IP` |

---

## 📊 Funkcjonalności

### ✅ Zaimplementowane

- [x] Odczyt temperatury i wilgotności (ESP32 → API)
- [x] Wykrywanie ruchu (PIR → API)
- [x] REST API z autoryzacją (API Keys)
- [x] Persystencja danych w MongoDB
- [x] Dashboard Flutter (Web/Android/iOS)
- [x] Hosting 24/7 na OVH Cloud
- [x] Dockeryzacja całego stacku
- [x] Rate limiting i ochrona przed DDoS

### 🔮 Planowane rozszerzenia

- [ ] Powiadomienia push przy alertach
- [ ] Certyfikat SSL (HTTPS)
- [ ] Panel administracyjny
- [ ] Eksport danych do CSV/PDF

---

## � Aplikacja Flutter - Zrzuty Ekranu

### Dashboard - Przegląd Systemu

<div align="center">
<table>
<tr>
<td align="center">
<img src="docs/screenshots/dashboard_main.png" width="250" alt="Dashboard - System Online"/>
<br/><b>System Online</b><br/>
<sub>Status połączeń i szybkie statystyki</sub>
</td>
<td align="center">
<img src="docs/screenshots/dashboard_sensors.png" width="250" alt="Dashboard - Czujniki"/>
<br/><b>Status Czujników</b><br/>
<sub>Temperatura, wilgotność, detekcja ruchu</sub>
</td>
</tr>
</table>
</div>

### Historia Odczytów

<div align="center">
<table>
<tr>
<td align="center">
<img src="docs/screenshots/history_charts.png" width="250" alt="Historia - Wykresy"/>
<br/><b>Wykresy Historyczne</b><br/>
<sub>Wizualizacja danych z ostatnich 24h</sub>
</td>
<td align="center">
<img src="docs/screenshots/history_data.png" width="250" alt="Historia - Dane"/>
<br/><b>Lista Odczytów</b><br/>
<sub>Szczegółowe dane tabelaryczne</sub>
</td>
</tr>
</table>
</div>

### Ustawienia

<div align="center">
<img src="docs/screenshots/settings.png" width="250" alt="Ustawienia"/>
<br/><b>Panel Ustawień</b><br/>
<sub>Konfiguracja urządzeń, motyw, język, powiadomienia</sub>
</div>

---

## �🚀 Quick Start - Sprawdź działanie

### 1. Status serwera (otwórz w przeglądarce)
```
http://YOUR_SERVER_IP/api/health
```

### 2. Terminal - pobierz dane
```bash
curl http://YOUR_SERVER_IP/api/health
```

**Odpowiedź:**
```json
{
  "status": "healthy",
  "services": { "api": "up", "mongodb": "up" }
}
```

---

## 📁 Struktura Projektu

```
PCH/
├── 📂 backend/                    # Serwer API (Node.js)
│   ├── src/
│   │   ├── server.js             # Express server
│   │   ├── config/database.js    # MongoDB connection
│   │   ├── routes/               # API endpoints
│   │   └── middleware/           # Auth, error handling
│   ├── docker-compose.yml        # Stack kontenerów
│   ├── Dockerfile
│   └── nginx/nginx.conf
│
├── 📂 esp32_firmware/             # Firmware mikrokontrolera
│   └── smart_home_sensor/
│       └── smart_home_sensor_HTTP.ino
│
├── 📂 sensors_dashboard/          # Aplikacja Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── services/api_service.dart
│   │   ├── providers/
│   │   └── screens/
│   └── pubspec.yaml
│
└── README.md
```

---

## � Wymagania Wstępne

Przed rozpoczęciem upewnij się, że masz zainstalowane:

### 🖥️ Dla rozwoju lokalnego

| Narzędzie | Wersja | Link |
|-----------|--------|------|
| **Node.js** | 18+ | [nodejs.org](https://nodejs.org) |
| **Docker** | 20.10+ | [docker.com](https://docker.com) |
| **Flutter** | 3.0+ | [flutter.dev](https://flutter.dev) |
| **Arduino IDE** | 2.0+ | [arduino.cc](https://www.arduino.cc/en/software) |
| **Git** | Latest | [git-scm.com](https://git-scm.com) |

### 🏗️ Dla produkcji

- **VPS/Cloud Server** (np. OVH, DigitalOcean, AWS)
- **System operacyjny:** Ubuntu 22.04 LTS lub nowszy
- **RAM:** Min. 2GB (zalecane 4GB+)
- **Przestrzeń dyskowa:** Min. 20GB

### 🔌 Hardware (ESP32)

- **ESP32 DevKit v1** (lub kompatybilny)
- **DHT11** - czujnik temperatury/wilgotności
- **PIR HC-SR501** - czujnik ruchu
- **Kabel USB** (micro-USB lub USB-C zależnie od modelu)
- **Przewody połączeniowe**

---

## 🚀 Instalacja Krok po Kroku

### 1️⃣ Sklonuj Repozytorium

```bash
git clone https://github.com/YOUR_USERNAME/PCH.git
cd PCH
```

### 2️⃣ Konfiguracja Backend (Node.js + MongoDB)

#### A. Utwórz plik .env

```bash
cd backend
cp .env.example .env
```

#### B. Wygeneruj bezpieczne klucze API

**Linux/macOS:**
```bash
# ESP32 API Key
openssl rand -hex 32

# Flutter API Key  
openssl rand -hex 32

# JWT Secret
openssl rand -hex 32
```

**Windows (PowerShell):**
```powershell
# Każda komenda wygeneruje inny klucz
-join ((48..57) + (97..102) | Get-Random -Count 64 | % {[char]$_})
```

#### C. Edytuj backend/.env

Wklej wygenerowane klucze:

```env
# Backend configuration
NODE_ENV=production
PORT=3000

# MongoDB
MONGODB_URI=mongodb://mongo:27017/smart-house-iot
MONGODB_DATABASE=smart-house-iot

# Bezpieczeństwo - WKLEJ WYGENEROWANE KLUCZE!
ESP32_API_KEY=TWOJ_KLUCZ_ESP32_64_ZNAKI
FLUTTER_API_KEY=TWOJ_KLUCZ_FLUTTER_64_ZNAKI
JWT_SECRET=TWOJ_SEKRET_JWT_64_ZNAKI

# Rate limiting
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=100

# CORS
CORS_ORIGINS=http://localhost:3000,http://YOUR_SERVER_IP
```

#### D. Uruchom serwer lokalnie

```bash
# Pozostań w katalogu backend/
docker compose up -d

# Sprawdź czy działa
curl http://localhost/api/health
```

**Oczekiwana odpowiedź:**
```json
{"status":"healthy","services":{"api":"up","mongodb":"up"}}
```

---

### 3️⃣ Konfiguracja Aplikacji Flutter

#### A. Zainstaluj zależności Flutter

```bash
cd ../sensors_dashboard
flutter pub get
```

#### B. Utwórz plik .env

```bash
cp .env.example .env
```

#### C. Edytuj sensors_dashboard/.env

```env
# API Configuration
API_BASE_URL=http://localhost  # Zmień na IP serwera w produkcji
FLUTTER_API_KEY=TWOJ_KLUCZ_FLUTTER_64_ZNAKI  # Ten sam co w backend/.env!

API_TIMEOUT=30

# Device info
DEVICE_ID=ESP32_SALON
DEVICE_LOCATION=Salon
DEVICE_FIRMWARE=v2.0.0

DEMO_MODE=false
```

#### D. Uruchom aplikację

**Web (Chrome):**
```bash
flutter run -d chrome
```

**Android (emulator lub urządzenie):**
```bash
flutter run -d android
```

**iOS (tylko macOS):**
```bash
flutter run -d ios
```

---

### 4️⃣ Konfiguracja ESP32

#### A. Zainstaluj sterowniki CP210x

- **Windows:** [Silicon Labs CP210x Driver](https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers)
- **macOS/Linux:** Zwykle nie wymagane (wbudowane w system)

#### B. Konfiguracja Arduino IDE

1. Otwórz **Arduino IDE 2.0**
2. Przejdź do: **File → Preferences**
3. W polu "Additional Board Manager URLs" dodaj:
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. Kliknij **OK**
5. **Tools → Board → Boards Manager**
6. Wyszukaj: `esp32`
7. Zainstaluj: **ESP32 by Espressif Systems** (wersja 2.0.0+)

#### C. Zainstaluj biblioteki

**Tools → Manage Libraries** - wyszukaj i zainstaluj:

- `DHT sensor library` by Adafruit
- `Adafruit Unified Sensor`
- `ArduinoJson` (v6.21+)

#### D. Edytuj kod firmware

Otwórz: `esp32_firmware/smart_home_sensor/smart_home_sensor_OVH.ino`

**Zmień te wartości:**

```cpp
// WiFi
const char* WIFI_SSID = "TWOJA_SIEC_WIFI";
const char* WIFI_PASSWORD = "HASLO_DO_WIFI";

// API
const char* API_HOST = "192.168.1.100";  // IP twojego serwera (localhost: 127.0.0.1)
const char* API_URL = "http://192.168.1.100/api/telemetry";

// API Key (ten sam co ESP32_API_KEY w backend/.env!)
const char* API_KEY = "TWOJ_KLUCZ_ESP32_64_ZNAKI";

// Device ID
const char* DEVICE_ID = "ESP32_SALON";  // Unikalny ID urządzenia
const char* LOCATION = "Salon";
```

#### E. Upload na ESP32

1. Podłącz ESP32 przez USB
2. **Tools → Board** → `ESP32 Dev Module`
3. **Tools → Port** → wybierz port COM (Windows) lub `/dev/cu.usbserial-*` (Mac)
4. **Tools → Upload Speed** → `115200`
5. Kliknij **Upload** (→)
6. Po zakończeniu: **Tools → Serial Monitor**
7. Ustaw **115200 baud**
8. Powinny pojawić się logi:
   ```
   🔌 WiFi connected: 192.168.1.123
   ✅ API Response: 200
   ```

---

### 5️⃣ Deployment na OVH (Produkcja)

#### A. Zamów VPS

1. Przejdź na: [ovhcloud.com](https://www.ovhcloud.com/pl/vps/)
2. Wybierz: **VPS Starter** lub **Essential**
3. System: **Ubuntu 22.04 LTS**
4. Sfinalizuj zamówienie i zapisz:
   - **IP publiczne**
   - **Login SSH** (domyślnie: `ubuntu`)
   - **Hasło root** (otrzymane mailem)

#### B. Konfiguracja serwera

**Połącz się przez SSH:**

```bash
ssh ubuntu@YOUR_SERVER_IP
```

**Zaktualizuj system:**

```bash
sudo apt update && sudo apt upgrade -y
```

**Zainstaluj Docker:**

```bash
# Docker Engine
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Dodaj użytkownika do grupy docker
sudo usermod -aG docker $USER

# Zaloguj się ponownie aby zastosować zmiany
exit
ssh ubuntu@YOUR_SERVER_IP
```

**Zainstaluj Docker Compose:**

```bash
sudo apt install docker-compose-plugin -y
```

**Skonfiguruj firewall:**

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS (przyszłość)
sudo ufw enable
```

#### C. Deploy aplikacji

**Sklonuj repo na serwerze:**

```bash
cd ~
git clone https://github.com/YOUR_USERNAME/PCH.git
cd PCH/backend
```

**Utwórz .env z produkcyjnymi danymi:**

```bash
nano .env
```

Wklej konfigurację z sekcji 2️⃣C, ale zmień:
- `CORS_ORIGINS` na `http://YOUR_SERVER_IP`
- Upewnij się że wszystkie klucze są wypełnione

**Uruchom stack:**

```bash
docker compose up -d

# Sprawdź logi
docker compose logs -f

# Sprawdź status
docker compose ps
```

**Testuj z zewnątrz:**

```bash
# Z twojego komputera (nie serwera):
curl http://YOUR_SERVER_IP/api/health
```

#### D. Zaktualizuj konfigurację urządzeń

**ESP32:** Zmień `API_HOST` na `YOUR_SERVER_IP`

**Flutter:** Zmień `API_BASE_URL` w `.env` na `http://YOUR_SERVER_IP`

---

## 🔧 Troubleshooting

### ❌ ESP32 nie łączy się z WiFi

**Problem:** `WiFi connection failed`

**Rozwiązania:**
- Sprawdź SSID i hasło (case-sensitive!)
- Upewnij się że używasz sieci 2.4 GHz (ESP32 nie obsługuje 5 GHz)
- Sprawdź czy router ma włączone DHCP
- Resetuj ESP32: odłącz USB, poczekaj 5s, podłącz ponownie

---

### ❌ API zwraca 401 Unauthorized

**Problem:** `{"error":"Invalid API key"}`

**Rozwiązania:**
- Sprawdź czy `ESP32_API_KEY` w `backend/.env` jest identyczny z `API_KEY` w kodzie ESP32
- Upewnij się że klucz nie ma spacji na początku/końcu
- Zrestartuj backend: `docker compose restart api`

---

### ❌ Flutter nie pobiera danych

**Problem:** Dashboard pusty lub błąd połączenia

**Rozwiązania:**
- Sprawdź czy backend działa: `curl http://YOUR_SERVER_IP/api/health`
- Zweryfikuj `API_BASE_URL` w `sensors_dashboard/.env`
- Upewnij się że `FLUTTER_API_KEY` w Flutter `.env` = `FLUTTER_API_KEY` w backend `.env`
- Sprawdź logi Flutter w konsoli

---

### ❌ MongoDB connection refused

**Problem:** `MongoNetworkError: connect ECONNREFUSED`

**Rozwiązania:**
- Sprawdź czy kontener mongo działa: `docker ps`
- Uruchom ponownie: `docker compose down && docker compose up -d`
- Sprawdź logi: `docker compose logs mongo`

---

### ❌ Port 80 zajęty

**Problem:** `bind: address already in use`

**Rozwiązania:**

**Linux/macOS:**
```bash
# Zobacz co używa portu 80
sudo lsof -i :80

# Zatrzymaj Apache/Nginx jeśli działa
sudo systemctl stop apache2
sudo systemctl stop nginx
```

**Windows:**
```powershell
# Zobacz co używa portu 80
netstat -ano | findstr :80

# Wyłącz IIS jeśli włączony
iisreset /stop
```

---

## �📡 API Reference

| Metoda | Endpoint | Opis | Auth |
|--------|----------|------|------|
| `GET` | `/api/health` | Status serwera | ❌ |
| `POST` | `/api/telemetry` | Dane z ESP32 | `X-API-Key` |
| `GET` | `/api/readings` | Lista odczytów | `Bearer` |
| `GET` | `/api/readings/latest` | Najnowsze | `Bearer` |
| `GET` | `/api/devices` | Lista urządzeń | `Bearer` |

---

## 🔐 Bezpieczeństwo

| Mechanizm | Opis |
|-----------|------|
| **API Keys** | Osobne klucze dla ESP32 i Flutter |
| **Rate Limiting** | Max 100 req/min per IP |
| **Helmet.js** | Bezpieczne nagłówki HTTP |
| **Docker Network** | MongoDB niedostępne z zewnątrz |
| **UFW Firewall** | Tylko porty 22, 80, 443 |

---

## 📈 Metryki Projektu

| Metryka | Wartość |
|---------|---------|
| Linii kodu (backend) | ~1500 |
| Linii kodu (Flutter) | ~5000 |
| Linii kodu (ESP32) | ~300 |
| Czas odpowiedzi API | <50ms |
| Uptime serwera | 99.9% |
| Interwał wysyłania danych | 30s |

---

## 🎬 Scenariusz Prezentacji

### 1️⃣ Demonstracja działającego serwera
```bash
# W przeglądarce lub terminalu
curl http://YOUR_SERVER_IP/api/health
```

### 2️⃣ ESP32 wysyła dane
- Otwórz **Arduino IDE** → Serial Monitor (115200 baud)
- Pokaż logi: `✅ Response: 200`

### 3️⃣ Aplikacja Flutter
- Uruchom: `flutter run -d chrome`
- Pokaż dashboard z danymi w czasie rzeczywistym

### 4️⃣ Test API (opcjonalnie)
```bash
# Wyślij testowe dane
curl -X POST http://YOUR_SERVER_IP/api/telemetry \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_ESP32_API_KEY" \
  -d '{"deviceId":"PREZENTACJA","sensorType":"temperature","value":25.5,"location":"Sala"}'
```

---

## 🛠️ Uruchomienie lokalne

### Backend
```bash
cd backend
docker compose up -d
```

### Flutter
```bash
cd sensors_dashboard
flutter run -d chrome
```

### ESP32
1. Otwórz `esp32_firmware/smart_home_sensor/smart_home_sensor_HTTP.ino`
2. Zmień WiFi credentials
3. Upload na ESP32

---

## 👨‍💻 Autor

**Damian** - Projekt studencki 2024/2025

---

## 📚 Dokumentacja

- 📖 **[Installation Guide](#-wymagania-wstępne)** - Kompletna instrukcja instalacji
- 🔐 **[Security Guide](SECURITY.md)** - Wytyczne bezpieczeństwa i best practices
- 🚀 **[Deployment Guide](backend/DEPLOYMENT_GUIDE.md)** - Deployment na OVH Cloud
- 📡 **[API Reference](#-api-reference)** - Dokumentacja endpointów REST API
- 🤝 **[Contributing Guide](CONTRIBUTING.md)** - Jak wnieść wkład do projektu

---

## 🤝 Jak Użyć Tego Projektu

### Dla studentów

Ten projekt może służyć jako:

- 📚 **Materiał do nauki** - kompletny przykład architektury IoT
- 💡 **Inspiracja** - wykorzystaj fragmenty kodu w swoich projektach
- 🎓 **Baza do rozszerzenia** - dodaj własne funkcjonalności

### Dla nauczycieli

- ✅ Demonstracja best practices w IoT
- ✅ Przykład kompletnej dokumentacji technicznej
- ✅ Reference implementation dla projektów zaliczeniowych

### ⚠️ Ważne

- Ten projekt jest **open source** pod licencją MIT
- **Przeczytaj:** [SECURITY.md](SECURITY.md) przed wdrożeniem
- **Wygeneruj własne klucze API** - nie używaj przykładowych!

---

## 🌟 Features

### ✅ Zaimplementowane

- [x] Odczyt temperatury i wilgotności (DHT11)
- [x] Wykrywanie ruchu (PIR)
- [x] REST API z autoryzacją (API Keys)
- [x] Persystencja w MongoDB z TTL
- [x] Dashboard Flutter (Web/Android/iOS)
- [x] Dockerized backend stack
- [x] Rate limiting & DDoS protection
- [x] CORS & Helmet.js security

### 🔮 Możliwe Rozszerzenia

- [ ] **SSL/TLS** - Certyfikat Let's Encrypt dla HTTPS
- [ ] **Powiadomienia Push** - Alerty przy wykryciu ruchu
- [ ] **Panel Admin** - Zarządzanie urządzeniami przez web
- [ ] **Grafana Dashboard** - Zaawansowane wykresy
- [ ] **Multi-room Support** - Wiele pokoi w jednym systemie
- [ ] **ML Predictions** - Predykcja temperatury przez TensorFlow
- [ ] **Voice Control** - Integracja z Google Assistant/Alexa
- [ ] **MQTT Protocol** - Alternatywa do HTTP dla ESP32

---

## 📄 Licencja

```
MIT License

Copyright (c) 2024 Damian

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- **ESP32 Community** - Świetne biblioteki i przykłady
- **MongoDB** - Niezawodna baza danych NoSQL
- **Flutter Team** - Cross-platform framework
- **OVH Cloud** - Stabilny hosting w Polsce

---

<div align="center">

**🏠 Smart Home IoT System**

*Kompletny system IoT od hardware'u po chmurę*

`ESP32` → `Node.js API` → `MongoDB` → `Flutter App`

---

**📖 Dokumentacja:** [Instalacja](#-wymagania-wstępne) • [Bezpieczeństwo](SECURITY.md) • [Deployment](backend/DEPLOYMENT_GUIDE.md)

**⭐ Jeśli projekt Ci pomógł, zostaw gwiazdkę!**

---

Made with ❤️ for educational purposes

</div>
