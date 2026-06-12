param(
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = Join-Path $Root "backups"
$zipPath = Join-Path $backupDir "finance-ai-SAFE-backup-$timestamp.zip"

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "== Spustam bezpecnostnu kontrolu verejnej casti" -ForegroundColor Cyan
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "Test-FinanceAISafety.ps1") -Root $Root -Mode Public
if ($LASTEXITCODE -ne 0) {
  throw "Bezpecnostna kontrola zlyhala. SAFE zaloha nebola vytvorena."
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$includeItems = @(
  "PROJECT-RULES.md",
  ".gitignore",
  "package.json",
  "vercel.json",
  "README.md",
  "README-GITHUB.md",
  "README-VERCEL.md",
  "IIS-REVERSE-PROXY.md",
  "PRODUCTION-BACKEND.md",
  "SERVER-API-SETUP.md",
  "docs",
  "api\.env.example",
  "api\README.md",
  "api\local-sql-api.ps1",
  "server",
  "scripts\Test-FinanceAISafety.ps1",
  "scripts\New-FinanceAISafeBackup.ps1",
  "scripts\publish-online.ps1"
)

$excludePathPattern = '(?i)(^|[\\/])(\.env($|[\\/])|\.env\.|client-access\.json$|ai-memory\.json$|backups|work|node_modules|tools|\.git|\.vercel|dist|\.vite)([\\/]|$)|(?i)(^|[\\/])outputs[\\/]restore-|(?i)\.zip$'
$blockedTextPattern = '(?i)(OPENAI_API_KEY\s*=\s*(?!\.\.\.|tvoje_heslo|change_me|example|xxx)[^\s#]+|SQL_PASSWORD\s*=\s*(?!\.\.\.|tvoje_heslo|change_me|example|xxx)[^\s#]+|api[_-]?key\s*[:=]\s*["''](?!\.\.\.|tvoje_heslo|change_me|example|xxx)[^"'']{12,}|password\s*[:=]\s*["''](?!\.\.\.|tvoje_heslo|change_me|example|xxx)[^"'']{6,}|Bearer\s+[A-Za-z0-9_\.\-]{20,})'
$textExtensions = @(".html", ".js", ".cjs", ".mjs", ".json", ".md", ".txt", ".ps1", ".bat", ".css", ".webmanifest", ".yml", ".yaml", ".xml", ".config", ".example")

function Get-RelativePath {
  param([string]$BasePath, [string]$FullPath)
  $baseUri = [Uri]($BasePath.TrimEnd('\') + '\')
  $fileUri = [Uri]$FullPath
  return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($fileUri).ToString()).Replace('/', '/')
}

function Should-SkipFile {
  param([System.IO.FileInfo]$File)
  $relativeWindows = Get-RelativePath -BasePath $Root -FullPath $File.FullName
  if ($relativeWindows -match $excludePathPattern) { return $true }
  if ($textExtensions -contains $File.Extension.ToLowerInvariant() -and $File.Length -lt 4MB) {
    try {
      $content = Get-Content -LiteralPath $File.FullName -Raw -ErrorAction Stop
      if ($content -match $blockedTextPattern) { return $true }
    } catch {
      return $true
    }
  }
  return $false
}

Write-Host "== Vytvaram SAFE zalohu bez tajomstiev" -ForegroundColor Cyan

$archive = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
$added = 0
$skipped = New-Object System.Collections.ArrayList

try {
  foreach ($item in $includeItems) {
    $path = Join-Path $Root $item
    if (-not (Test-Path -LiteralPath $path)) { continue }
    $info = Get-Item -LiteralPath $path
    if ($info.PSIsContainer) { $items = Get-ChildItem -LiteralPath $path -Recurse -File -Force } else { $items = @($info) }

    foreach ($file in $items) {
      $relative = Get-RelativePath -BasePath $Root -FullPath $file.FullName
      if (Should-SkipFile -File $file) { [void]$skipped.Add($relative); continue }
      try {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $relative, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
        $added++
      } catch {
        [void]$skipped.Add($relative)
      }
    }
  }
}
finally {
  $archive.Dispose()
}

Write-Host ""
Write-Host "SAFE zaloha vytvorena:" -ForegroundColor Green
Write-Host $zipPath
Write-Host "Pridane subory: $added"
Write-Host "Preskocene subory: $($skipped.Count)"

if ($skipped.Count -gt 0) {
  $logPath = Join-Path $backupDir "finance-ai-SAFE-backup-$timestamp-skipped.txt"
  $skipped | Set-Content -LiteralPath $logPath -Encoding UTF8
  Write-Host "Zoznam preskocenych suborov:" $logPath
}
