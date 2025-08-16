$ErrorActionPreference='Stop'
# Only scan site output paths; allow the scroll layout/page.
$hits = (git grep -n "data-gib=" -- "site/**") 2>$null
$allowed = @("site/_layouts/scroll.html","site/scroll/index.md")
$viol = @()
foreach($h in $hits){
  $path = $h.Split(':')[0]
  if($allowed -notcontains $path){ $viol += $h }
}
if($viol.Count -gt 0){
  Write-Error ("GIB symbols found outside allowed files:`n" + ($viol -join "`n"))
  exit 1
}
Write-Host "GIB usage confined to CC layout/page."
