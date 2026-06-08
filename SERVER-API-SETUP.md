# Finance AI secure API on Windows server

Tento postup je pre Windows server, ktory vidi OMEGA SQL databazu.

Frontend ostava na Verceli:

```text
https://jobdues-finance.vercel.app
```

API bezi server-side pri OMEGE a nesmie zverejnit SQL heslo ani OpenAI kluc.

## 1. Subory na serveri

Na server nahraj projekt do stabilneho priecinka, napriklad:

```text
C:\FinanceAI
```

Citlive subory vytvor iba na serveri:

```text
C:\FinanceAI\work\soleya-finance-ai-dashboard\.env
C:\FinanceAI\work\soleya-finance-ai-dashboard\client-access.json
```

Tieto subory nepatria na GitHub.

## 2. Odporucane `.env`

```text
SQL_SERVER=tvoj_sql_server
SQL_PORT=1433
SQL_DATABASE=x_databaza_klienta
SQL_USER=omega_readonly
SQL_PASSWORD=tvoje_serverove_heslo
SQL_ENCRYPT=true
SQL_TRUST_CERT=true
MOCK_MODE=false
ALLOWED_ORIGINS=https://jobdues-finance.vercel.app
SESSION_HOURS=8
API_BIND_HOST=localhost
API_PORT=3000
```

`API_BIND_HOST=localhost` znamena, ze API nepocuva priamo z internetu. Von ho ma pustit az HTTPS vrstva, napriklad IIS reverse proxy.

## 3. Spustenie API

Na serveri otvor PowerShell ako administrator a spusti:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
C:\FinanceAI\server\install-finance-ai-api-task.ps1 -ProjectRoot C:\FinanceAI
```

Tym sa vytvori automaticka uloha `FinanceAI-API`, ktora sa spusti po starte servera.

## 4. HTTPS pred API

Verejna adresa ma byt HTTPS, napriklad:

```text
https://api.jobdues-finance.sk
```

Odporucany tok:

```text
Vercel frontend
  -> https://api.jobdues-finance.sk
  -> localhost:3000 na Windows serveri
  -> readonly SQL ucet
  -> OMEGA SQL
```

## 5. Vercel nastavenie

Vo Verceli nastav environment variable:

```text
FINANCE_AI_API_BASE_URL=https://api.jobdues-finance.sk
```

Podla Vercel dokumentacie sa zmena environment variables prejavi az po novom deployi, preto po nastaveni spusti redeploy.

## 6. Kontrola

Na serveri ma toto vratit stav API:

```text
http://localhost:3000/api/health
```

Z internetu ma fungovat:

```text
https://api.jobdues-finance.sk/api/health
```

Citlive endpointy maju bez prihlasenia vratit `401`, nie uctovne data.

## 7. Bezpecnostne minimum

- SQL ucet iba readonly.
- Ziadne SQL hesla vo Verceli ani vo frontende.
- Povolit CORS iba pre Vercel domenu.
- API nevystavovat priamo cez `http://`.
- Na firewalli nepustat port 3000 do internetu.
- Verejne pouzit iba HTTPS adresu.