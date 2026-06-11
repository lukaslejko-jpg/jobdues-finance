const fs = require("fs");
const path = require("path");

const docsDir = path.join(__dirname, "..", "docs");
const configPath = path.join(docsDir, "config.js");
const defaultApiBase = "https://trickster-upriver-process.ngrok-free.dev";
const apiBase = (process.env.FINANCE_AI_API_BASE_URL || defaultApiBase).replace(/\/$/, "");

fs.mkdirSync(docsDir, { recursive: true });
fs.writeFileSync(
  configPath,
  `// Generated during build. Configure FINANCE_AI_API_BASE_URL in Vercel.
(function () {
  const apiBase = ${JSON.stringify(apiBase)};
  const authTokenKey = "financeAiAuthToken";

  window.FINANCE_AI_API_BASE_URL = apiBase;

  const nativeFetch = window.fetch.bind(window);
  window.fetch = async function financeAiSecureFetch(input, init = {}) {
    const rawUrl = typeof input === "string" ? input : input && input.url ? input.url : "";
    const isApiCall =
      rawUrl.startsWith(apiBase) ||
      rawUrl.startsWith("http://localhost:3000") ||
      rawUrl.startsWith("/api/");
    const token = window.localStorage.getItem(authTokenKey);

    if (token && isApiCall) {
      init = {
        ...init,
        headers: {
          ...(init.headers || {}),
          Authorization: \`Bearer \${token}\`,
        },
      };
    }

    const response = await nativeFetch(input, init);

    if (rawUrl.includes("/api/auth/login")) {
      response
        .clone()
        .json()
        .then((payload) => {
          if (payload && payload.token) {
            window.localStorage.setItem(authTokenKey, payload.token);
          }
        })
        .catch(() => {});
    }

    return response;
  };

  document.addEventListener(
    "click",
    (event) => {
      if (event.target && event.target.id === "logoutBtn") {
        window.localStorage.removeItem(authTokenKey);
      }
    },
    true
  );
})();
`,
  "utf8"
);

console.log(`Finance AI frontend API base: ${apiBase}`);