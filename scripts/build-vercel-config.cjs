const fs = require("fs");
const path = require("path");

const docsDir = path.join(__dirname, "..", "docs");
const configPath = path.join(docsDir, "config.js");
const apiBase = (process.env.FINANCE_AI_API_BASE_URL || "http://localhost:3000").replace(/\/$/, "");

fs.mkdirSync(docsDir, { recursive: true });
fs.writeFileSync(
  configPath,
  `// Generated during build. Configure FINANCE_AI_API_BASE_URL in Vercel.\nwindow.FINANCE_AI_API_BASE_URL = ${JSON.stringify(apiBase)};\n`,
  "utf8"
);

console.log(`Finance AI frontend API base: ${apiBase}`);
