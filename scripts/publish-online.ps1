param(
  [string]$SourceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [string]$RepoRoot = (Join-Path $HOME "Documents\GitHub\jobdues-finance"),
  [string]$Message = "Aktualizacia Finance AI"
)

$ErrorActionPreference = "Stop"

function Write-Step($Text) {
  Write-Host ""
  Write-Host "== $Text" -ForegroundColor Cyan
}

function Find-Git {
  $git = Get-Command git.exe -ErrorAction SilentlyContinue
  if ($git) { return $git.Source }

  $desktopRoot = Join-Path $env:LOCALAPPDATA "GitHubDesktop"
  if (Test-Path -LiteralPath $desktopRoot) {
    $candidates = Get-ChildItem -LiteralPath $desktopRoot -Recurse -Filter git.exe -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -like "*\resources\app\git\cmd\git.exe" -or $_.FullName -like "*\resources\app\git\mingw64\bin\git.exe" } |
      Sort-Object FullName -Descending
    if ($candidates.Count -gt 0) { return $candidates[0].FullName }
  }

  return $null
}

function Copy-ChangedItem {
  param(
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][string]$DestinationPath
  )

  $sourceItem = Get-Item -LiteralPath $SourcePath
  if ($sourceItem.PSIsContainer) {
    New-Item -ItemType Directory -Force -Path $DestinationPath | Out-Null
    Get-ChildItem -LiteralPath $SourcePath -Force | ForEach-Object {
      Copy-ChangedItem -SourcePath $_.FullName -DestinationPath (Join-Path $DestinationPath $_.Name)
    }
    return
  }

  if (Test-Path -LiteralPath $DestinationPath) {
    try {
      $sourceHash = (Get-FileHash -LiteralPath $SourcePath -Algorithm SHA256).Hash
      $destinationHash = (Get-FileHash -LiteralPath $DestinationPath -Algorithm SHA256).Hash
      if ($sourceHash -eq $destinationHash) { return }
    } catch {}
    try { (Get-Item -LiteralPath $DestinationPath).IsReadOnly = $false } catch {}
  }

  Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force
}

$sourceDocs = Join-Path $SourceRoot "docs"
$repoDocs = Join-Path $RepoRoot "docs"

if (-not (Test-Path -LiteralPath $sourceDocs)) { throw "Nenasiel som zdrojovy priecinok: $sourceDocs" }
if (-not (Test-Path -LiteralPath $RepoRoot)) { throw "Nenasiel som GitHub repo priecinok: $RepoRoot" }
if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot ".git"))) { throw "Tento priecinok nevyzera ako GitHub repo: $RepoRoot" }

Write-Step "Bezpecnostna kontrola pred publikovanim"
$safetyScript = Join-Path $SourceRoot "scripts\Test-FinanceAISafety.ps1"
if (-not (Test-Path -LiteralPath $safetyScript)) { throw "Chyba bezpecnostny skener: $safetyScript" }
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $safetyScript -Root $SourceRoot -Mode Public
if ($LASTEXITCODE -ne 0) { throw "Publikovanie zastavene: bezpecnostna kontrola nasla rizikovy subor alebo tajny udaj." }

Write-Step "Kopirujem verejnu cast aplikacie do GitHub repo"
New-Item -ItemType Directory -Force -Path $repoDocs | Out-Null
Get-ChildItem -LiteralPath $sourceDocs -Force | ForEach-Object {
  Copy-ChangedItem -SourcePath $_.FullName -DestinationPath (Join-Path $repoDocs $_.Name)
}

$rootFiles = @(".gitignore", "package.json", "vercel.json", "README.md", "README-GITHUB.md", "README-VERCEL.md")
foreach ($file in $rootFiles) {
  $sourceFile = Join-Path $SourceRoot $file
  if (Test-Path -LiteralPath $sourceFile) { Copy-Item -LiteralPath $sourceFile -Destination (Join-Path $RepoRoot $file) -Force }
}

Write-Step "Kontrolujem Git"
$git = Find-Git
if (-not $git) {
  Write-Host "Git som nenasiel. Zmeny su skopirovane do GitHub Desktop priecinka." -ForegroundColor Yellow
  Write-Host "Otvor GitHub Desktop, napis popis zmeny, klikni Commit to main a potom Push origin." -ForegroundColor Yellow
  Start-Process "github"
  exit 0
}

Write-Host "Pouzivam Git: $git"

Write-Step "Ukladam zmeny"
Push-Location $RepoRoot
try {
  & $git status --short
  & $git add docs .gitignore package.json vercel.json README.md README-GITHUB.md README-VERCEL.md
  $changes = & $git status --porcelain
  if (-not $changes) {
    Write-Host "Nie su ziadne nove zmeny na publikovanie." -ForegroundColor Green
    exit 0
  }
  & $git commit -m $Message
  Write-Step "Odosielam na GitHub"
  & $git push origin main
  Write-Host ""
  Write-Host "Hotovo. Vercel teraz automaticky pripravi novu online verziu." -ForegroundColor Green
}
finally {
  Pop-Location
}
