param(
  [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [string]$TaskName = "FinanceAI-API"
)

$ErrorActionPreference = "Stop"

$runner = Join-Path $ProjectRoot "server\run-finance-ai-api.ps1"
if (-not (Test-Path -LiteralPath $runner)) {
  throw "Runner script was not found: $runner"
}

$powerShell = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"
$argument = "-NoProfile -ExecutionPolicy Bypass -File `"$runner`" -ProjectRoot `"$ProjectRoot`""

$action = New-ScheduledTaskAction -Execute $powerShell -Argument $argument -WorkingDirectory $ProjectRoot
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet `
  -AllowStartIfOnBatteries `
  -DontStopIfGoingOnBatteries `
  -ExecutionTimeLimit (New-TimeSpan -Days 365) `
  -RestartCount 3 `
  -RestartInterval (New-TimeSpan -Minutes 1)

Register-ScheduledTask `
  -TaskName $TaskName `
  -Action $action `
  -Trigger $trigger `
  -Settings $settings `
  -Description "Finance AI secure API for OMEGA SQL readonly data." `
  -RunLevel Highest `
  -Force

Start-ScheduledTask -TaskName $TaskName
Write-Host "Finance AI API scheduled task installed and started: $TaskName"