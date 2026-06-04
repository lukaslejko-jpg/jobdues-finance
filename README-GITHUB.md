# Finance AI - GitHub deployment

## What can go to GitHub

The `docs/` folder is the static frontend prepared for GitHub Pages.

Do not upload secrets:

- `work/soleya-finance-ai-dashboard/.env`
- `work/soleya-finance-ai-dashboard/client-access.json`
- `work/soleya-finance-ai-dashboard/ai-memory.json`
- backups and ZIP archives

These are excluded by `.gitignore`.

## GitHub Pages

1. Create a GitHub repository.
2. Upload the project files.
3. In GitHub, open `Settings -> Pages`.
4. Set source to `Deploy from a branch`.
5. Select branch `main` and folder `/docs`.
6. Save.

GitHub Pages will serve the frontend from `docs/index.html`.

## Backend requirement

GitHub Pages cannot run the SQL/OpenAI backend. The frontend must call a deployed backend URL.

Set it in:

```js
docs/config.js
```

Example:

```js
window.FINANCE_AI_API_BASE_URL = "https://api.tvoja-domena.sk";
```

For local testing, keep:

```js
window.FINANCE_AI_API_BASE_URL = "http://localhost:3000";
```

## Backend security

The backend must stay server-side only:

- SQL credentials only in backend environment variables
- OpenAI API key only in backend environment variables
- readonly SQL user only
- no SQL credentials in `docs/` or frontend code
