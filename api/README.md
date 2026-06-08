# Finance AI API

Tento priecinok patri na Windows server, ktory ma pristup k OMEGA SQL.

Na serveri tu maju byt:

```text
local-sql-api.ps1
.env
client-access.json
```

Do GitHubu nepatria:

- `.env`
- `client-access.json`
- `ai-memory.json`

API ma bezat lokalne cez:

```text
http://localhost:3000
```

Verejne ho ma spristupnit az HTTPS reverse proxy, napriklad IIS.