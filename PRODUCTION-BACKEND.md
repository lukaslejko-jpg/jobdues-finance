# Finance AI production backend

Frontend je nasadeny na Verceli:

```text
https://jobdues-finance.vercel.app
```

Backend musi bezat server-side, pretoze obsahuje:

- SQL pristup do OMEGA databaz,
- OpenAI API kluc,
- prihlasovacie udaje klientov/adminov.

Tieto udaje nesmu byt vo frontende ani vo Verceli ako staticky subor.

## Odporucana produkcna architektura

```text
Vercel frontend
  -> HTTPS API backend
  -> readonly SQL ucet
  -> OMEGA SQL databaza
```

## Bezpecna cesta pre MVP

1. Vybrat server, ktory ma pristup k SQL serveru `JADSERVER`.
   - idealne Windows server vo firme alebo Windows VPS cez VPN,
   - musi vidiet port SQL Servera `1433`,
   - SQL ucet musi ostat readonly.

2. Na serveri spustit backend:

```text
work/soleya-finance-ai-dashboard/local-sql-api.ps1
```

3. Pred backend dat HTTPS adresu, napriklad:

```text
https://api.jobdues.sk
```

Moznosti:

- IIS reverse proxy,
- Cloudflare Tunnel s vlastnou domenou a access pravidlami,
- Nginx/Traefik na serveri,
- prepis backendu do Node/Express a nasadenie ako samostatna API sluzba.

4. Vo Verceli nastavit environment variable:

```text
FINANCE_AI_API_BASE_URL=https://api.jobdues.sk
```

5. Vo Verceli spustit novy deployment.

## Bezpecnostne pravidla

- Nepouzivat docasny verejny tunel pre realne firemne uctovne data bez access pravidiel.
- Povolit CORS iba pre:

```text
https://jobdues-finance.vercel.app
```

- SQL ucet musi byt readonly.
- Backend nesmie mat ziadne INSERT, UPDATE, DELETE endpointy.
- `.env`, `client-access.json` a `ai-memory.json` nepatria na GitHub.

## Co potrebujeme od servera

Pre dalsi krok treba rozhodnut, kde bude bezat backend:

- firemny Windows server,
- pocitac v kancelarii, ktory bude stale zapnuty,
- Windows VPS s VPN do siete,
- prepis na Node backend a hosting na API platforme, ak SQL bude dostupne cez VPN alebo verejny zabezpeceny endpoint.
