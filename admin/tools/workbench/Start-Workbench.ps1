param()

$ErrorActionPreference = "Stop"
$repo   = Join-Path $env:USERPROFILE "Documents\GitHub\CoCivium"
$logDir = Join-Path $env:USERPROFILE "Documents\CoCiviumLogs"
New-Item -ItemType Directory -Force $logDir | Out-Null
$ts     = Get-Date -Format "yyyyMMdd_HHmmss"
$pre    = Join-Path $repo "tools\readme-preflight.ps1"

# Run preflight quietly if present, log to Documents\CoCiviumLogs
if (Test-Path $pre) {
  $log = Join-Path $logDir ("preflight_{0}.log" -f $ts)
  (& pwsh -NoProfile -ExecutionPolicy Bypass -File $pre *>&1) | Tee-Object -FilePath $log | Out-Null
  Copy-Item $log (Join-Path $logDir "preflight_latest.log") -Force
}

# Open only essentials (ChatGPT, repo home, workflow doc)
try {
  $ownerRepo = (gh repo view --json nameWithOwner | ConvertFrom-Json).nameWithOwner
} catch { $ownerRepo = "rickballard/CoCivium" }

$urls = @(
  "https://chat.openai.com/",
  "https://github.com/$ownerRepo",
  "https://github.com/$ownerRepo/blob/main/docs/ISSUEOPS.md"
)
$urls | ForEach-Object { Start-Process $_ }

exit 0