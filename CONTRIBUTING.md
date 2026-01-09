# 🤝 Contributing Guide

Dziękujemy za zainteresowanie projektem **Smart Home IoT System**!

---

## 📋 Jak Wnieść Wkład

### 1. Fork & Clone

```bash
# Fork repo na GitHubie (kliknij "Fork")

# Sklonuj swój fork
git clone https://github.com/YOUR_USERNAME/PCH.git
cd PCH

# Dodaj upstream
git remote add upstream https://github.com/ORIGINAL_OWNER/PCH.git
```

### 2. Utwórz Branch

```bash
# Zawsze twórz nowy branch dla swojej funkcjonalności
git checkout -b feature/twoja-funkcjonalnosc

# Lub dla bugfixa
git checkout -b fix/nazwa-problemu
```

### 3. Dokonaj Zmian

- Pisz **czytelny kod** z komentarzami
- Przestrzegaj istniejącego **stylu kodu**
- Testuj lokalnie przed commitem
- **Nigdy nie commituj** plików `.env`, kluczy API, haseł!

### 4. Commit & Push

```bash
# Dodaj zmiany
git add .

# Commit z opisową wiadomością
git commit -m "feat: Dodano powiadomienia push dla alertów ruchu"

# Push do swojego forka
git push origin feature/twoja-funkcjonalnosc
```

### 5. Utwórz Pull Request

1. Przejdź na GitHub do swojego forka
2. Kliknij **"Compare & pull request"**
3. Opisz zmiany:
   - Co zostało zrobione?
   - Dlaczego?
   - Jak przetestowałeś?

---

## 🎨 Coding Standards

### JavaScript (Backend)

- **ES6+** syntax
- **2 spacje** indentacja
- **Semicolons** na końcu linii
- **CamelCase** dla zmiennych, **PascalCase** dla klas

```javascript
// ✅ Dobre
const deviceId = req.body.deviceId;
const sensorData = await SensorReading.find({ deviceId });

// ❌ Złe
const device_id = req.body.deviceId;
var sensorData = await SensorReading.find({deviceId})
```

### Dart (Flutter)

- **Flutter style guide:** [dart.dev/guides/language/effective-dart](https://dart.dev/guides/language/effective-dart)
- **2 spacje** indentacja
- **lowerCamelCase** dla zmiennych
- **Trailing commas** dla lepszej formatowania

```dart
// ✅ Dobre
final String deviceId = widget.device.id;
final sensorReadings = await apiService.getReadings(
  deviceId: deviceId,
  limit: 100,
);

// ❌ Złe
final String device_id = widget.device.id;
final sensorReadings = await apiService.getReadings(deviceId: deviceId, limit: 100);
```

### C++ (ESP32)

- **Arduino style guide**
- **2 spacje** indentacja
- **UPPER_CASE** dla stałych
- **Komentarze** dla złożonych funkcji

```cpp
// ✅ Dobre
const int DHT_PIN = 4;
float readTemperature() {
  return dht.readTemperature();
}

// ❌ Złe
int dhtPin = 4;
float read_temp(){return dht.readTemperature();}
```

---

## 🧪 Testowanie

### Backend

```bash
cd backend

# Uruchom testy (jeśli są)
npm test

# Sprawdź linting
npm run lint

# Uruchom lokalnie
docker-compose up -d
```

### Flutter

```bash
cd sensors_dashboard

# Sprawdź format
flutter format .

# Analiza kodu
flutter analyze

# Testy jednostkowe
flutter test

# Testy integracyjne
flutter test integration_test/
```

### ESP32

- Przetestuj na **prawdziwym sprzęcie**
- Sprawdź **Serial Monitor** (115200 baud)
- Upewnij się że:
  - WiFi łączy się poprawnie
  - API zwraca `200 OK`
  - Dane pojawiają się w MongoDB

---

## 📝 Commit Messages

Używamy **Conventional Commits:**

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat:` - Nowa funkcjonalność
- `fix:` - Naprawa buga
- `docs:` - Zmiana w dokumentacji
- `style:` - Formatowanie (nie zmienia logiki)
- `refactor:` - Refactoring kodu
- `test:` - Dodanie testów
- `chore:` - Aktualizacja zależności, build tools

### Przykłady

```bash
# Nowa funkcjonalność
git commit -m "feat(api): Dodano endpoint /api/devices/:id/stats"

# Bugfix
git commit -m "fix(esp32): Naprawiono problem z reconnect WiFi"

# Dokumentacja
git commit -m "docs(readme): Zaktualizowano sekcję instalacji"

# Refactoring
git commit -m "refactor(flutter): Przeniesiono logikę API do service class"
```

---

## 🚫 Co NIE Commitować

**Absolutnie zakazane:**

```bash
# ❌ Pliki środowiskowe
.env
.env.local
.env.production

# ❌ Klucze i certyfikaty
*.pem
*.key
*.crt

# ❌ Credentials
credentials.json
secrets.yml

# ❌ Build artifacts (niektóre)
node_modules/
.dart_tool/
build/ (niektóre platformy)

# ❌ IDE specific
.vscode/settings.json (jeśli zawiera ścieżki użytkownika)
.idea/workspace.xml
```

**Sprawdź przed commitem:**

```bash
# Zobacz co będzie commitowane
git diff --staged

# Jeśli przypadkowo dodałeś .env
git reset HEAD .env
echo ".env" >> .gitignore
```

---

## 🐛 Zgłaszanie Bugów

### Szablon Issue (Bug Report)

```markdown
**Opis problemu:**
Krótki opis co się dzieje.

**Kroki do odtworzenia:**
1. Uruchom backend
2. Wyślij request POST do /api/telemetry
3. Zobacz błąd...

**Oczekiwane zachowanie:**
Co powinno się stać?

**Rzeczywiste zachowanie:**
Co się dzieje zamiast tego?

**Środowisko:**
- OS: Windows 10 / Ubuntu 22.04 / macOS
- Node.js: v18.17.0
- Docker: v24.0.5
- Flutter: 3.13.0

**Logi:**
```
Wklej istotne logi tutaj
```

**Screenshots:**
Jeśli dotyczy UI, dodaj screenshot.
```

---

## 💡 Propozycje Funkcjonalności

### Szablon Issue (Feature Request)

```markdown
**Opis funkcjonalności:**
Co chcesz dodać?

**Problem który rozwiązuje:**
Dlaczego to jest potrzebne?

**Propozycja implementacji:**
Jak widzisz realizację?

**Alternatywy:**
Czy rozważałeś inne podejścia?

**Dodatkowy kontekst:**
Linki, dokumentacja, przykłady z innych projektów.
```

---

## 🔍 Code Review

### Jako Author (PR)

- Opisz **co** i **dlaczego** zmieniałeś
- Dodaj **screenshots** dla zmian UI
- Oznacz `[WIP]` jeśli PR nie jest gotowy
- Odpowiadaj na komentarze konstruktywnie

### Jako Reviewer

- Bądź **konstruktywny**, nie krytyczny
- Wskaż **dlaczego** coś należy zmienić
- Doceniaj dobre rozwiązania 👍
- Sprawdź:
  - Czy kod działa lokalnie?
  - Czy nie ma wrażliwych danych?
  - Czy dokumentacja jest aktualna?

---

## 📚 Przydatne Zasoby

### Dokumentacja

- [Node.js Docs](https://nodejs.org/docs)
- [Flutter Docs](https://docs.flutter.dev)
- [ESP32 Arduino Core](https://docs.espressif.com/projects/arduino-esp32/)
- [MongoDB Manual](https://www.mongodb.com/docs/manual/)

### Style Guides

- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)

### Narzędzia

- [ESLint](https://eslint.org/) - JavaScript linting
- [Prettier](https://prettier.io/) - Code formatting
- [Flutter Format](https://docs.flutter.dev/tools/formatting) - Dart formatting

---

## 🎓 Dla Początkujących

### Pierwsze Kroki

Jeśli to Twój pierwszy wkład w open source:

1. **Zacznij małą zmianą** - popraw literówkę, zaktualizuj docs
2. **Czytaj kod** - zrozum jak działa system
3. **Zadawaj pytania** - nie ma głupich pytań!
4. **Zobacz Issues** - oznaczone `good first issue`

### Pomoc

- **Discord/Slack:** (link jeśli jest)
- **GitHub Issues:** Zadaj pytanie w nowym issue
- **Email:** your-email@example.com

---

## 📜 Licencja

Poprzez contribution do tego projektu, zgadzasz się na licencję **MIT License**.

Twój kod będzie:
- ✅ Wolny do użytku
- ✅ Modyfikowalny
- ✅ Komercyjnie dostępny (z zachowaniem licencji)

---

## 🙏 Podziękowania

Dziękujemy wszystkim kontrybutrom:

<!-- ALL-CONTRIBUTORS-LIST:START -->
<!-- Tutaj automatycznie pojawi się lista kontrybutorów -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

---

<div align="center">

**Razem budujemy lepszy IoT! 🏠💡**

**Pytania?** Otwórz [Issue](https://github.com/YOUR_USERNAME/PCH/issues/new)

</div>
