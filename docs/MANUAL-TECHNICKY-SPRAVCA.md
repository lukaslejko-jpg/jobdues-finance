# Finance AI - technicky manual pre spravcu

## Ucel

Finance AI je readonly financny dashboard nad OMEGA SQL databazou. Aplikacia zobrazuje realne data firmy cez bezpecnu API vrstvu. SQL prihlasovacie udaje nikdy nie su vo frontende ani vo Verceli.

## Aktualna architektura

Tok dat:

1. Pouzivatel otvori online aplikaciu vo Verceli.
2. Frontend vola verejne API cez ngrok tunel.
3. Ngrok presmeruje poziadavku na Windows server pri OMEGE.
4. Finance AI API bezi lokalne na serveri.
5. API cita data cez readonly SQL ucet z OMEGA SQL databazy.
6. API vrati JSON spat do aplikacie.

Aktualne adresy:

- Online aplikacia: https://jobdues-finance.vercel.app
- Verejne API: https://trickster-upriver-process.ngrok-free.dev
- Serverove API lokalne: http://localhost:3003
- Health endpoint: /api/health

## Dolezite subory na serveri

Serverovy priecinok:

```text
C:\FinanceAI
```

Konfiguracia API:

```text
C:\FinanceAI\api\.env
```

Hlavny API skript:

```text
C:\FinanceAI\api\local-sql-api.ps1
```

Prihlasenia a priradenia klientov:

```text
C:\FinanceAI\api\client-access.json
```

Automaticke startovacie skripty:

```text
C:\FinanceAI\server\start-api.ps1
C:\FinanceAI\server\start-ngrok.ps1
```

Logy:

```text
C:\FinanceAI\logs
```

## Env nastavenia

Subor `.env` obsahuje napojenie na SQL a API nastavenia. Priklad:

```text
SQL_SERVER=JADSERVER
SQL_PORT=1433
SQL_DATABASE=x_480448100
SQL_USER=omega_readonly
SQL_PASSWORD=...
SQL_ENCRYPT=true
SQL_TRUST_CERT=true
MOCK_MODE=false
ALLOWED_ORIGINS=http://localhost:3000,https://jobdues-finance.vercel.app
SESSION_HOURS=8
API_BIND_HOST=localhost
API_PORT=3003
```

Hesla a SQL udaje nikdy neposielat klientom ani nedavat do GitHubu.

## Automaticke spustanie po restarte

Vo Windows Task Scheduler su nastavene ulohy:

```text
FinanceAI API
FinanceAI ngrok
FinanceAI health check
```

Overenie uloh:

```powershell
schtasks /Query /TN "FinanceAI API"
schtasks /Query /TN "FinanceAI ngrok"
schtasks /Query /TN "FinanceAI health check"
```

Rucne spustenie:

```powershell
schtasks /Run /TN "FinanceAI API"
schtasks /Run /TN "FinanceAI ngrok"
```

Health check bezi kazdych 60 minut a zapisuje vysledok do:

```text
C:\FinanceAI\logs\health.log
```

## Kontrola funkcnosti

Po restarte servera pockat 1-2 minuty a otvorit:

```text
https://trickster-upriver-process.ngrok-free.dev/api/health
```

Ocekavana odpoved:

```json
{
  "ok": true,
  "mode": "secure-api",
  "authRequired": true
}
```

Potom otvorit online aplikaciu:

```text
https://jobdues-finance.vercel.app
```

Prihlas sa ako admin a skontroluj, ci sa KPI zhoduju s lokalnou verziou.

## Pristupy

Admin a klienti su v subore:

```text
C:\FinanceAI\api\client-access.json
```

Format je zoznam:

```json
[
  {
    "email": "admin@example.sk",
    "database": "x_480448100",
    "companyName": "Admin",
    "role": "admin",
    "password": "...",
    "active": true
  }
]
```

Roly:

- `admin` - vidi Nastavenia, vie pridavat klientov a firmy.
- `client` - vidi iba dashboard a data priradenej firmy.

## Bezpecnostne pravidla

- Pouzivat iba readonly SQL ucet.
- SQL heslo nedavat do GitHubu ani frontendu.
- Neotvarat SQL port 1433 do internetu.
- Neotvarat API port 3003 do internetu.
- Produkcne API ide cez tunel, nie cez router port forwarding.
- Po zmene API suborov urobit zalohu.

## Najcastejsie problemy

### Online aplikacia ukazuje demo data

Skontrolovat:

1. Ci bezi API: `http://localhost:3003/api/health`
2. Ci bezi ngrok: `https://trickster-upriver-process.ngrok-free.dev/api/health`
3. Ci je pouzivatel odhlaseny a prihlaseny nanovo.
4. Ci Vercel ma najnovsi deploy.

### API sa nespusti, port je obsadeny

Najprv zistit PowerShell procesy:

```powershell
Get-Process powershell | Select-Object Id,ProcessName,StartTime,Path
```

Zastavit iba proces Finance AI API, nie systemove procesy Windows/IIS.

### Ngrok endpoint je uz online

Zastavit stare ngrok procesy:

```powershell
Stop-Process -Name ngrok -Force
```

Potom spustit ulohu:

```powershell
schtasks /Run /TN "FinanceAI ngrok"
```

## Zaloha

Aktualna zaloha stabilnej online verzie je ulozena v:

```text
backups\finance-ai-ready-online-backup-20260611-104127.zip
```

Pred vacsimi zmenami vytvorit novu zalohu celej aplikacie.

