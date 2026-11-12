# medpaper.ps1 - one-command driver for the MedPaper workflow.
# Usage (from anywhere; put medpaper-helpers on your PATH):
#   medpaper                     # status + active stage card (inside a paper workspace)
#   medpaper new -Slug <name> -IdeaFile <idea.md> [-DataDir <dir>]   # create a paper
#   medpaper check | advance -n "note" | decide <name> <value> -w "why" | card ...
#   medpaper init-env            # set NCBI_API_KEY / NCBI_API_EMAIL / PYTHONUTF8 (User level)
#   medpaper help
#
# Environment: PYTHONUTF8 + NCBI_API_KEY + NCBI_API_EMAIL are injected automatically
# (from User-level registry when set) so every engine command runs correctly.
param(
  [Parameter(Position = 0)][string]$Command = "",
  [Parameter(ValueFromRemainingArguments = $true)][string[]]$Args
)
$ErrorActionPreference = "Stop"
$Helpers = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path -Parent $Helpers
$Python = Join-Path $Root "tools\wf.py"

function Get-PaperDir {
  # current dir or nearest papers/<slug> under the workflow root
  $cwd = (Get-Location).Path
  if (Test-Path (Join-Path $cwd "pipeline\pipeline.toml")) { return $cwd }
  if (Test-Path (Join-Path $cwd "tools\wf.py")) { return $cwd }
  $papers = Join-Path $Root "papers"
  if (Test-Path $papers) {
    foreach ($d in Get-ChildItem $papers -Directory) {
      if ((Get-Location).Path -like "$($d.FullName)*") { return $d.FullName }
    }
  }
  return $null
}

function Set-Env {
  $env:PYTHONUTF8 = "1"
  $env:NCBI_API_KEY  = [Environment]::GetEnvironmentVariable('NCBI_API_KEY', 'User')
  $env:NCBI_API_EMAIL = [Environment]::GetEnvironmentVariable('NCBI_API_EMAIL', 'User')
}

function Invoke-Wf {
  param([string]$Paper, [string[]]$WfArgs)
  Set-Env
  $py = Join-Path $Paper ".venv\Scripts\python.exe"
  if (-not (Test-Path $py)) { throw "venv missing in $Paper; run bootstrap first" }
  & $py (Join-Path $Paper "tools\wf.py") @WfArgs
  exit $LASTEXITCODE
}

switch ($Command.ToLower()) {
  "" { 
    $paper = Get-PaperDir
    if (-not $paper) { Write-Host "Not inside a paper workspace. Use: medpaper new -Slug <name> -IdeaFile <idea.md>" -ForegroundColor Yellow; exit 1 }
    Invoke-Wf $paper @("status") 
    Write-Host ""
    Invoke-Wf $paper @("card")
  }
  "new" {
    & (Join-Path $Helpers "new-paper.ps1") @Args
    exit $LASTEXITCODE
  }
  "init-env" {
    if ($Args.Count -lt 2) { Write-Host "usage: medpaper init-env -key <NCBI_API_KEY> -email <you@example.org>"; exit 1 }
    for ($i = 0; $i -lt $Args.Count; $i += 2) {
      switch ($Args[$i]) {
        "-key"   { [Environment]::SetEnvironmentVariable("NCBI_API_KEY", $Args[$i+1], "User") }
        "-email" { [Environment]::SetEnvironmentVariable("NCBI_API_EMAIL", $Args[$i+1], "User") }
      }
    }
    [Environment]::SetEnvironmentVariable("PYTHONUTF8", "1", "User")
    Write-Host "Environment variables set (User level). Restart terminals to pick them up."
    exit 0
  }
  "help" { Get-Content (Join-Path $Helpers "medpaper-help.txt") -ErrorAction SilentlyContinue; exit 0 }
  default {
    $paper = Get-PaperDir
    if (-not $paper) { Write-Host "Not inside a paper workspace." -ForegroundColor Yellow; exit 1 }
    Invoke-Wf $paper @($Command, @Args)
  }
}
