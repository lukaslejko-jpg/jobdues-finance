param(
  [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$apiScript = Join-Path $ProjectRoot "work\soleya-finance-ai-dashboard\local-sql-api.ps1"
if (-not (Test-Path -LiteralPath $apiScript)) {
  throw "Finance AI API script was not found: $apiScript"
}

Set-Location $ProjectRoot
& $apiScript