# 🚀 INSTRUKCJA WDROŻENIA - Smart Home IoT na OVH Cloud

## 📋 Spis Treści

1. [Wymagania](#1-wymagania)
2. [Zamówienie VPS na OVH](#2-zamówienie-vps-na-ovh)
3. [Konfiguracja Serwera](#3-konfiguracja-serwera)
4. [Instalacja Docker](#4-instalacja-docker)
5. [Wdrożenie Aplikacji](#5-wdrożenie-aplikacji)
6. [Konfiguracja SSL (Let's Encrypt)](#6-konfiguracja-ssl-lets-encrypt)
7. [Konfiguracja DNS](#7-konfiguracja-dns)
8. [Backup i Monitoring](#8-backup-i-monitoring)
9. [Rozwiązywanie Problemów](#9-rozwiązywanie-problemów)

---

## 1. Wymagania

### Minimalne wymagania VPS:
- **CPU:** 1 vCore
- **RAM:** 2 GB (zalecane 4 GB)
- **Dysk:** 20 GB SSD
- **System:** Ubuntu 22.04 LTS lub Debian 12
- **Sieć:** Publiczny IPv4

### Rekomendowany plan OVH:
- **OVH VPS Starter** (~5€/mies) - dla testów
- **OVH VPS Essential** (~10€/mies) - dla produkcji

---

## 2. Zamówienie VPS na OVH

### Krok po kroku:

1. **Zaloguj się do OVH Manager:**
   - https://www.ovh.com/manager/

2. **Zamów nowy VPS:**
   - Przejdź do: `Public Cloud` → `Compute` → `Instances`
   - Lub: `VPS` → `Zamów VPS`

3. **Wybierz konfigurację:**
   ```
   ┌─────────────────────────────────────────┐
   │ Model:        VPS Essential (2 vCPU)    │
   │ Lokalizacja:  Gravelines (GRA) / Polska │
   │ System:       Ubuntu 22.04 LTS          │
   │ Dysk:         40 GB SSD                 │
   │ RAM:          4 GB                      │
   └─────────────────────────────────────────┘
   ```

4. **Dodatkowe opcje:**
   - ✅ Automatyczne backupy (zalecane)
   - ✅ Snapshot (opcjonalnie)

5. **Potwierdź zamówienie i poczekaj na email z danymi dostępowymi.**

---

## 3. Konfiguracja Serwera

### 3.1 Pierwszy login SSH

```bash
# Windows (PowerShell / Terminal)
ssh root@YOUR_VPS_IP

# Lub z kluczem SSH
ssh -i ~/.ssh/id_rsa root@YOUR_VPS_IP
```

### 3.2 Aktualizacja systemu

```bash
apt update && apt upgrade -y
apt install -y curl wget git nano htop ufw
```

### 3.3 Konfiguracja firewalla (UFW)

```bash
# Włącz firewall
ufw default deny incoming
ufw default allow outgoing

# Dozwolone porty
ufw allow ssh        # 22 - SSH
ufw allow http       # 80 - HTTP (redirect do HTTPS)
ufw allow https      # 443 - HTTPS

# UWAGA: Port 27017 (MongoDB) NIE powinien być otwarty!
# MongoDB dostępne tylko wewnętrznie przez Docker network

# Włącz firewall
ufw enable
ufw status
```

### 3.4 Utwórz użytkownika (nie używaj root!)

```bash
# Utwórz użytkownika
adduser iotadmin
usermod -aG sudo iotadmin
usermod -aG docker iotadmin

# Skopiuj klucz SSH
mkdir -p /home/iotadmin/.ssh
cp ~/.ssh/authorized_keys /home/iotadmin/.ssh/
chown -R iotadmin:iotadmin /home/iotadmin/.ssh

# Przełącz na nowego użytkownika
su - iotadmin
```

---

## 4. Instalacja Docker

### 4.1 Instalacja Docker Engine

```bash
# Usuń stare wersje
sudo apt remove docker docker-engine docker.io containerd runc 2>/dev/null

# Dodaj repozytorium Docker
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Zainstaluj Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Uruchom Docker
sudo systemctl start docker
sudo systemctl enable docker

# Sprawdź instalację
docker --version
docker compose version
```

### 4.2 Konfiguracja Docker bez sudo

```bash
sudo usermod -aG docker $USER
# Wyloguj i zaloguj ponownie lub:
newgrp docker
```

---

## 5. Wdrożenie Aplikacji

### 5.1 Pobierz projekt

```bash
cd ~
git clone https://github.com/YOUR_REPO/smart-home-iot.git
cd smart-home-iot/backend
```

### 5.2 Konfiguracja zmiennych środowiskowych

```bash
# Skopiuj przykładowy plik
cp .env.example .env

# Edytuj konfigurację
nano .env
```

**Ustaw bezpieczne wartości:**

```env
# ═══════════════════════════════════════════════════════════
# PRODUKCJA - ZMIEŃ WSZYSTKIE PONIŻSZE WARTOŚCI!
# ═══════════════════════════════════════════════════════════

# MongoDB - użytkownik root
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=$(openssl rand -base64 32)

# MongoDB - użytkownik aplikacji
MONGO_APP_USER=iot_user
MONGO_APP_PASSWORD=$(openssl rand -base64 24)

# API Keys - wygeneruj bezpieczne klucze
ESP32_API_KEY=$(openssl rand -hex 32)
FLUTTER_API_KEY=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -hex 64)

# CORS - dodaj swoją domenę
CORS_ORIGINS=https://twoja-domena.ovh,https://api.twoja-domena.ovh
```

**Zapisz wygenerowane klucze w bezpiecznym miejscu!**

### 5.3 Aktualizacja mongo-init.js

```bash
nano mongo-init.js
```

Zmień hasło użytkownika na to samo co `MONGO_APP_PASSWORD` w `.env`:

```javascript
db.createUser({
  user: 'iot_user',
  pwd: 'TWOJE_HASLO_Z_ENV',  // ← Zmień na wartość MONGO_APP_PASSWORD
  roles: [{ role: 'readWrite', db: 'smart-house-iot' }]
});
```

### 5.4 Utwórz certyfikaty SSL (tymczasowe self-signed)

```bash
mkdir -p nginx/ssl
cd nginx/ssl

# Wygeneruj tymczasowy certyfikat self-signed
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout privkey.pem \
  -out fullchain.pem \
  -subj "/CN=smart-home-iot/O=Smart Home/C=PL"

cd ../..
```

### 5.5 Uruchom stack

```bash
# Zbuduj i uruchom kontenery
docker compose up -d --build

# Sprawdź status
docker compose ps

# Sprawdź logi
docker compose logs -f
```

### 5.6 Weryfikacja działania

```bash
# Test health endpoint
curl http://localhost:3000/api/health

# Oczekiwana odpowiedź:
# {"status":"healthy","services":{"api":"up","mongodb":"up"}}

# Test z zewnątrz (użyj IP VPS)
curl http://YOUR_VPS_IP:3000/api/health
```

---

## 6. Konfiguracja SSL (Let's Encrypt)

### 6.1 Zainstaluj Certbot

```bash
sudo apt install -y certbot
```

### 6.2 Uzyskaj certyfikat

```bash
# Zatrzymaj nginx tymczasowo
docker compose stop nginx

# Uzyskaj certyfikat
sudo certbot certonly --standalone -d api.twoja-domena.ovh

# Skopiuj certyfikaty do folderu nginx
sudo cp /etc/letsencrypt/live/api.twoja-domena.ovh/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/api.twoja-domena.ovh/privkey.pem nginx/ssl/
sudo chown -R $USER:$USER nginx/ssl/

# Uruchom nginx
docker compose up -d nginx
```

### 6.3 Auto-odnowienie certyfikatu

```bash
# Dodaj do crontab
sudo crontab -e

# Dodaj linię:
0 3 * * * certbot renew --quiet && cp /etc/letsencrypt/live/api.twoja-domena.ovh/*.pem /home/iotadmin/smart-home-iot/backend/nginx/ssl/ && docker compose -f /home/iotadmin/smart-home-iot/backend/docker-compose.yml restart nginx
```

---

## 7. Konfiguracja DNS

### 7.1 W panelu OVH Manager lub u dostawcy domeny:

```
┌───────────────────────────────────────────────────────┐
│ Typ     │ Nazwa              │ Wartość               │
├─────────┼────────────────────┼───────────────────────┤
│ A       │ api                │ YOUR_VPS_IP           │
│ A       │ @                  │ YOUR_VPS_IP           │
│ CNAME   │ www                │ @                     │
└─────────┴────────────────────┴───────────────────────┘
```

### 7.2 Sprawdź propagację DNS

```bash
# Poczekaj 5-30 minut, potem:
nslookup api.twoja-domena.ovh
dig api.twoja-domena.ovh
```

---

## 8. Backup i Monitoring

### 8.1 Backup MongoDB

```bash
# Utwórz skrypt backupu
mkdir -p ~/backups
nano ~/backup-mongo.sh
```

```bash
#!/bin/bash
DATE=$(date +%Y-%m-%d_%H-%M)
BACKUP_DIR=~/backups
CONTAINER=smart-home-mongo

# Backup
docker exec $CONTAINER mongodump --archive=/tmp/backup-$DATE.gz --gzip
docker cp $CONTAINER:/tmp/backup-$DATE.gz $BACKUP_DIR/

# Usuń stare backupy (starsze niż 7 dni)
find $BACKUP_DIR -name "backup-*.gz" -mtime +7 -delete

echo "Backup completed: backup-$DATE.gz"
```

```bash
chmod +x ~/backup-mongo.sh

# Dodaj do crontab (codziennie o 2:00)
crontab -e
0 2 * * * /home/iotadmin/backup-mongo.sh >> /home/iotadmin/backups/backup.log 2>&1
```

### 8.2 Monitoring z Uptime Robot (bezpłatne)

1. Zarejestruj się na https://uptimerobot.com
2. Dodaj monitor HTTP:
   - URL: `https://api.twoja-domena.ovh/api/health`
   - Interwał: 5 minut
   - Alert: Email

### 8.3 Podstawowy monitoring zasobów

```bash
# Zainstaluj htop
sudo apt install htop

# Monitoruj w czasie rzeczywistym
htop

# Status Docker
docker stats
```

---

## 9. Rozwiązywanie Problemów

### Problem: MongoDB nie startuje

```bash
# Sprawdź logi
docker compose logs mongo

# Częste przyczyny:
# - Za mało RAM (potrzeba min. 1GB wolnego)
# - Błędne hasło w .env vs mongo-init.js
```

### Problem: API nie łączy się z MongoDB

```bash
# Sprawdź czy mongo jest healthy
docker compose ps

# Test połączenia z kontenera API
docker exec smart-home-api wget -qO- http://mongo:27017

# Sprawdź connection string w .env
```

### Problem: SSL nie działa

```bash
# Sprawdź certyfikaty
ls -la nginx/ssl/

# Sprawdź logi nginx
docker compose logs nginx

# Sprawdź konfigurację
docker exec smart-home-nginx nginx -t
```

### Problem: ESP32 nie może się połączyć

```bash
# Sprawdź czy port jest otwarty
sudo ufw status
curl https://api.twoja-domena.ovh/api/health

# Sprawdź logi API
docker compose logs -f api | grep -i error
```

### Restart wszystkich usług

```bash
docker compose down
docker compose up -d
docker compose logs -f
```

---

## 📞 Wsparcie

- **Dokumentacja OVH:** https://docs.ovh.com/
- **Status OVH:** https://status.ovh.com/
- **Docker Docs:** https://docs.docker.com/

---

## ✅ Checklist przed produkcją

- [ ] Zmieniono wszystkie domyślne hasła
- [ ] Wygenerowano bezpieczne API keys
- [ ] Skonfigurowano firewall (UFW)
- [ ] Zainstalowano certyfikat SSL (Let's Encrypt)
- [ ] Skonfigurowano backup MongoDB
- [ ] Skonfigurowano monitoring (Uptime Robot)
- [ ] Przetestowano endpoint /api/health
- [ ] Przetestowano połączenie z ESP32
- [ ] Przetestowano połączenie z Flutter

---

*Ostatnia aktualizacja: Styczeń 2026*
