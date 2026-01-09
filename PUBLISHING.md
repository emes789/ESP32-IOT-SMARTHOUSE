PODSTAWOWE KROKI PRZED PUBLIKACJĄ (USUŃ DANE WRAŻLIWE)
==================================================

Co zrobiłem:

- Usunąłem śledzony plik `sensors_dashboard/.env`, który zawierał żywy klucz API oraz adres IP.

Co musisz zrobić lokalnie / w repo przed publicznym push:

1) Zatwierdź zmiany (usuń śledzony plik z historii najpierw jeśli chcesz zachować prywatność):

```bash
git add -A
git commit -m "chore(security): remove tracked sensitive .env"
```

2) Jeśli plik był już wcześniej commited w historii, usuń go z całej historii (BFG lub git filter-repo). Przykłady:

# Za pomocą git filter-repo (zalecane):
```bash
# zainstaluj git-filter-repo jeśli brak
# usuń plik z całej historii
git filter-repo --path sensors_dashboard/.env --invert-paths
```

# Lub użyj BFG:
```bash
# zainstaluj BFG i uruchom:
bfg --delete-files .env
# następnie
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```

3) Wymuś push do remote (UWAGA: przepisywanie historii wymaga force push i wpłynie na wszystkich współpracowników):
```bash
git push --force origin main
```

4) ROTACJA/REVOKACJA: natychmiast zmień (rotate) każdy klucz, który mógł być wyeksponowany (np. FLUTTER_API_KEY, ESP32_API_KEY, JWT_SECRET). Zakładaj, że klucz został skompromitowany.

5) Dodaj pliki konfiguracyjne z danymi środowiskowymi lokalnie, używając `.env` (zawartość szablonu w `backend/.env.example` i `sensors_dashboard/.env.example`). Nigdy nie commituj realnych `.env`.

6) Sprawdź repo ponownie pod kątem sekretów przed ponownym publicznym push (np. git-secrets, truffleHog, gitleaks).

Krótka lista do sprawdzenia (manualnie):
- `*.env`, `*.pem`, `*.key`, `*.crt` — powinny być w `.gitignore` i nieśledzone.
- pliki build/wynikowe (folder `build/`, `ios/Runner/`, `android/` etc.) — najlepiej ignorować binaria.

Jeśli chcesz, wykonam te kroki (usuń plik z historii, wygeneruję `.env.example` tam gdzie brakuje, itp.) — daj znać czy chcesz, żebym przepisał historię za Ciebie (potrzebuję uprawnień lub że wykonasz force-push lokalnie).

---
Zespół bezpieczeństwa: po opublikowaniu pamiętaj o monitoringu i natychmiastowej rotacji kluczy, jeśli usługi wykryją nieautoryzowane użycie.
