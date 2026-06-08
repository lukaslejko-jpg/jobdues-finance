# IIS reverse proxy for Finance AI API

Toto je krok 1 pre online API.

Pouzijeme IIS ako verejnu HTTPS branu:

```text
https://api.jobdues-finance.sk
  -> IIS reverse proxy
  -> http://localhost:3000
  -> Finance AI API
  -> OMEGA SQL
```

## Co je ciel

- Internet vidi iba HTTPS adresu.
- Finance AI API pocuva iba lokalne na serveri.
- SQL port `1433` nejde do internetu.
- Port `3000` nejde do internetu.
- Frontend na Verceli vola iba `https://api.jobdues-finance.sk`.

## 1. Nainstalovat IIS komponenty

Na Windows serveri musi byt:

- IIS,
- URL Rewrite Module,
- Application Request Routing.

Microsoft dokumentacia uvadza, ze IIS URL Rewrite spolu s Application Request Routing vie fungovat ako reverse proxy. ARR zavisi od URL Rewrite modulu.

Oficialne zdroje:

- https://learn.microsoft.com/en-us/iis/extensions/url-rewrite-module/reverse-proxy-with-url-rewrite-v2-and-application-request-routing
- https://www.iis.net/downloads/microsoft/application-request-routing

## 2. Zapnut proxy v ARR

V IIS Manager:

1. otvor server,
2. otvor `Application Request Routing Cache`,
3. otvor `Server Proxy Settings`,
4. zapni `Enable proxy`,
5. uloz `Apply`.

## 3. Vytvorit IIS web pre API

V IIS vytvor novy site:

```text
Site name: FinanceAI API
Host name: api.jobdues-finance.sk
HTTPS: zapnute
Physical path: C:\FinanceAI\iis-api
```

Do priecinka:

```text
C:\FinanceAI\iis-api
```

vloz subor:

```text
web.config
```

Pouzi obsah zo suboru:

```text
server\iis-api-web.config
```

Tento `web.config` posiela vsetky poziadavky na:

```text
http://localhost:3000
```

## 4. Certifikat

Pre `api.jobdues-finance.sk` musi byt platny HTTPS certifikat.

Moznosti:

- certifikat cez poskytovatela domeny,
- Let's Encrypt cez win-acme,
- existujuci firemny certifikat.

## 5. Firewall

Povolene zvonku:

```text
443 HTTPS
```

Nepovolovat zvonku:

```text
3000 Finance AI API
1433 SQL Server
```

## 6. Finance AI `.env`

Na serveri nastav:

```text
API_BIND_HOST=localhost
API_PORT=3000
ALLOWED_ORIGINS=https://jobdues-finance.vercel.app
```

## 7. Testy

Na serveri:

```text
http://localhost:3000/api/health
```

Z internetu:

```text
https://api.jobdues-finance.sk/api/health
```

Bez prihlasenia musia citlive endpointy vratit `401`, napriklad:

```text
https://api.jobdues-finance.sk/api/dashboard/real
```

## 8. Vercel

Vo Verceli nastav:

```text
FINANCE_AI_API_BASE_URL=https://api.jobdues-finance.sk
```

Potom spusti novy production deploy.