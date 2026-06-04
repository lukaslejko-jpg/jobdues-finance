# Finance AI on Vercel

This repository is prepared for:

- GitHub as source control
- Vercel as static frontend hosting
- Separate backend API for SQL/OpenAI

## Vercel setup

1. Push this folder to GitHub.
2. Import the GitHub repository in Vercel.
3. Framework preset: `Other`.
4. Build command:

```bash
npm run build
```

5. Output directory:

```text
docs
```

6. Add Vercel environment variable:

```text
FINANCE_AI_API_BASE_URL=https://your-backend-domain.example
```

For local testing, the default remains:

```text
http://localhost:3000
```

## Important backend note

The current backend is PowerShell + Microsoft SQL Server connection. Vercel is not the right runtime for that backend in its current form.

Recommended production options:

- keep frontend on Vercel and run backend on a Windows VPS,
- or rewrite backend to Node/Express and deploy it as a separate API service,
- SQL credentials and OpenAI key must stay only on the backend.

Never put `.env`, SQL credentials, OpenAI API key, or client passwords into `docs/`.
