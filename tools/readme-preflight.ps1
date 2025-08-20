Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Find repo root in both script and interactive contexts
$repo = $null
try { $repo = (& git rev-parse --show-toplevel 2>$null).Trim() } catch {}
if (-not $repo) {
  if ($PSScriptRoot) { $repo = Split-Path -Parent $PSScriptRoot }
  else { $repo = (Get-Location).Path }
}

$P   = Join-Path $repo 'README.md'
$txt = Get-Content -Raw $P

$errors = @()

# 1) Mojibake marker
if ($txt -match 'Γ') { $errors += "Mojibake token 'Γ' found." }

# 2) Terms must NOT be blockquoted (use (?m) for multiline)
if (Select-String -InputObject $txt -Pattern '(?m)^\s*>\s*Terms:') {
  $errors += "Terms is blockquoted; remove leading '>'"
}

# 3) No "<> LABEL:" placeholders
$lab = 'Why|Who|How|LIFE|FEELS|BROKEN|UNTIL|GOVERNMENTS|COEVOLVE|SOLUTIONS|FOR YOU'
if (Select-String -InputObject $txt -Pattern "(?m)^\s*(?:&lt;\s*&gt;|<\s*>)\s*($lab)\s*:") {
  $errors += "Found '<> LABEL:' placeholder lines."
}

# 4) Fix The World: exactly one H2
$h2 = [regex]::Matches($txt,'(?m)^##\s*Fix The World')
if ($h2.Count -ne 1) { $errors += "Fix The World headers: $($h2.Count) (expect 1)." }

# 5) Icon lines count (expected 11)
$icons = ([regex]::Matches($txt,'<img src="\./assets/icons/')).Count
if ($icons -ne 11) { $errors += "Icon lines: $icons (expect 11)." }

# 6) Hero assets present
if (-not ($txt -match 'assets/hero/quote-960w\.png') -or -not ($txt -match 'assets/hero/hero\.gif')) {
  $errors += "Hero assets reference missing."
}

# 7) Line endings & BOM
if ($txt -match "`r") { $errors += "CR found; README must be LF-only." }
$fs=[IO.File]::OpenRead($P); try { $bom = New-Object byte[] 3; [void]$fs.Read($bom,0,3) } finally { $fs.Dispose() }
if ($bom[0]-eq0xEF -and $bom[1]-eq0xBB -and $bom[2]-eq0xBF) { $errors += "README has UTF-8 BOM; save without BOM." }

if ($errors.Count) { $errors | % { Write-Host "❌ $_" -ForegroundColor Red }; exit 1 }
Write-Host "✅ README preflight passed." -ForegroundColor Green