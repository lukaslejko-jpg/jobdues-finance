# Finance AI - bezpecnostne pravidla projektu

Tento subor je povinny kontrolny zoznam pre kazdu zmenu, zalohu a publikovanie Finance AI.

## Co nikdy nesmie ist na GitHub, Vercel ani do zdielanej zalohy

- `.env` a `.env.*` okrem `.env.example`
- skutocne SQL hesla, API kluce, tokeny a prihlasovacie udaje
- `client-access.json`
- `ai-memory.json`
- lokalne runtime data zo servera alebo z pracovnej aplikacie
- priecinky `work/`
- priecinky `backups/`
- priecinky `outputs/restore-*`
- hotove ZIP archivy
- dokumenty alebo subory, ktore obsahuju realne hesla, tokeny alebo kluce

## Co moze ist online

- `docs/` ako verejna cast aplikacie
- verejne obrazky a ikony
- `package.json`, `vercel.json`
- README a manualy bez hesiel
- `.env.example` iba so vzorovymi hodnotami

## Povinne pred publikovanim

Pred spustenim `Publikovat-FinanceAI-online.bat` musi prejst kontrola:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\Test-FinanceAISafety.ps1 -Mode Public
```

Publikovaci skript ju spusta automaticky. Ak kontrola zlyha, publikovanie sa musi zastavit.

## Povinne pred zalohou

Pre zdielatelnu zalohu pouzivat iba:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\New-FinanceAISafeBackup.ps1
```

Tento skript vytvara iba `SAFE` zalohu bez tajomstiev. Plna lokalna zaloha sa smie vytvorit iba ako `PRIVATE-NEZDIELAT` a nikdy sa nesmie nahravat na GitHub, Vercel ani posielat klientovi.

## Serverove a SQL udaje

Realne hodnoty ako `SQL_PASSWORD`, OpenAI API kluc, admin hesla a klientsky pristup patria iba do lokalnych/serverovych konfiguracii mimo verejneho repozitara.

## Rezim prace

Pri kazdej rizikovej operacii platia tieto kroky:

1. Najprv skontrolovat, ci sa pracuje s verejnou alebo privatnou castou.
2. Spustit bezpecnostny skener.
3. Az potom publikovat, vytvarat zalohu alebo posielat subory.
4. Pouzivatelovi jasne napisat, ci je vysledok `SAFE` alebo `PRIVATE`.
