# dsh/install.ps1 - install the medpaper skill and global entry into the DeepSeek Harness.
# Run once after cloning (any machine):  pwsh .\dsh\install.ps1
# Installs:
#   1) $DSH_HOME\skills\medpaper\SKILL.md   -> user-level skill (appears in every session's skill catalog)
#   2) $DSH_HOME\AGENTS.md                  -> user-global instruction entry (merged; existing content kept)
# Re-run any time after updating this repository.
$ErrorActionPreference = "Stop"
$dshHome = $env:DSH_HOME
if (-not $dshHome) { $dshHome = Join-Path $HOME ".dsh" }
$skillDir = Join-Path $dshHome "skills\medpaper"
New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
Copy-Item (Join-Path $PSScriptRoot "skills\medpaper\SKILL.md") (Join-Path $skillDir "SKILL.md") -Force
$globalMd = Join-Path $PSScriptRoot "AGENTS.md"
$target = Join-Path $dshHome "AGENTS.md"
if (-not (Test-Path $target)) {
  Copy-Item $globalMd $target -Force
} else {
  $content = Get-Content $target -Raw -Encoding utf8
  if ($content -notmatch "medpaper research-paper workflow") {
    Add-Content -Path $target -Value "" -Encoding utf8
    Add-Content -Path $target -Value (Get-Content $globalMd -Raw -Encoding utf8) -Encoding utf8
  }
}
Write-Host "Installed medpaper skill -> $skillDir"
Write-Host "Installed global entry   -> $target"
Write-Host "Restart sessions (or start a new session) for the skill catalog to refresh."
