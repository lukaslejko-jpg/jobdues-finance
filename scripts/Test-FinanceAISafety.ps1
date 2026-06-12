param(
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [ValidateSet("Public", "Full")]
  [string]$Mode = "Public",
  [switch]$Quiet
)

$ErrorActionPreference = "Stop"

$blockedNamePattern = '(?i)(^|[\\/])(\.env($|[\\/])|\.env\.|client-access\.json$|ai-memory\.json$)|(?i)(secret|credential|private-key)'
$blockedTextPattern = '(?i)(OPENAI_API_KEY\s*=\s*(?!\.\.\.|tvoje_heslo|change_me|example|xxx)[^\s#]+|SQL_PASSWORD\s*=\s*(?!\.\.\.|tvoje_heslo|change_me|example|xxx)[^\s#]+|api[_-]?key\s*[:=]\s*["''](?!\.\.\.|tvoje_heslo|change_me|example|xxx)[^"'']{12,}|password\s*[:=]\s*["''](?!\.\.\.|tvoje_heslo|change_me|example|xxx)[^"'']{6,}|Bearer\s+[A-Za-z0-9_\.\-]{20,})'

$publicRoots = @("docs", ".gitignore", "package.json", "vercel.json", "README.md", "README-GITHUB.md", "README-VERCEL.md")
$excludePathPattern = '(?i)(^|[\\/])(backups|work|node_modules|tools|\.git|\.vercel|dist|\.vite)([\\/]|$)|(?i)(^|[\\/])outputs[\\/]restore-|(?i)\.zip$'
$textExtensions = @(".html", ".js", ".cjs", ".mjs", ".json", ".md", ".txt", ".ps1", ".bat", ".css", ".webmanifest", ".yml", ".yaml", ".xml", ".config", ".example")

function Get-RelativePath {
  param([string]$BasePath, [string]$FullPath)
  $baseUri = [Uri]($BasePath.TrimEnd('\') + '\')
  $fileUri = [Uri]$FullPath
  return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($fileUri).ToString()).Replace('/', '\')
}

function Add-Finding {
  param([System.Collections.ArrayList]$Findings, [string]$Type, [string]$Path, [string]$Detail)
  [void]$Findings.Add([pscustomobject]@{ Type = $Type; Path = $Path; Detail = $Detail })
}

$findings = New-Object System.Collections.ArrayList
$files = New-Object System.Collections.Generic.List[object]

if ($Mode -eq "Public") {
  foreach ($item in $publicRoots) {
    $path = Join-Path $Root $item
    if (-not (Test-Path -LiteralPath $path)) { continue }
    $info = Get-Item -LiteralPath $path
    if ($info.PSIsContainer) {
      Get-ChildItem -LiteralPath $path -Recurse -File -Force | ForEach-Object { $files.Add($_) }
    } else {
      $files.Add($info)
    }
  }
} else {
  Get-ChildItem -LiteralPath $Root -Recurse -File -Force | ForEach-Object { $files.Add($_) }
}

foreach ($file in $files) {
  $relative = Get-RelativePath -BasePath $Root -FullPath $file.FullName
  if ($relative -match $excludePathPattern) { continue }

  if ($relative -match $blockedNamePattern) {
    Add-Finding -Findings $findings -Type "BLOCKED_FILE_NAME" -Path $relative -Detail "Nazov alebo cesta vyzera ako tajny/runtime subor."
    continue
  }

  if ($textExtensions -notcontains $file.Extension.ToLowerInvariant()) { continue }
  if ($file.Length -gt 4MB) { continue }

  try {
    $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
  } catch {
    Add-Finding -Findings $findings -Type "READ_ERROR" -Path $relative -Detail "Subor sa nepodarilo precitat pri kontrole."
    continue
  }

  if ($content -match $blockedTextPattern) {
    Add-Finding -Findings $findings -Type "POSSIBLE_SECRET" -Path $relative -Detail "Obsah vyzera ako realne heslo, token alebo API kluc."
  }
}

if ($findings.Count -gt 0) {
  if (-not $Quiet) {
    Write-Host ""
    Write-Host "BEZPECNOSTNA KONTROLA ZLYHALA" -ForegroundColor Red
    $findings | Format-Table Type,Path,Detail -AutoSize
    Write-Host "Publikovanie alebo SAFE zaloha musi byt zastavena." -ForegroundColor Red
  }
  exit 1
}

if (-not $Quiet) {
  Write-Host "Bezpecnostna kontrola presla. Nenasiel som tajne subory ani jasne hesla/API kluce." -ForegroundColor Green
}
exit 0
