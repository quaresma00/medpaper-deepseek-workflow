# MedPaper 论文工作区启动器（通用，与具体研究无关）
# 用法:
#   pwsh -File F:\deepseek\工作流\medpaper-helpers\new-paper.ps1 -Slug <slug> -IdeaFile <idea.md> [-DataDir <数据目录>]
# 示例:
#   pwsh -File F:\deepseek\工作流\medpaper-helpers\new-paper.ps1 -Slug my-study -IdeaFile F:\deepseek\工作流\idea.md -DataDir G:\mywork\drug\data
param(
  [Parameter(Mandatory=$true)][string]$Slug,
  [Parameter(Mandatory=$true)][string]$IdeaFile,
  [string]$DataDir = ""
)
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent          # F:\deepseek\工作流
$engine = Join-Path $root "medpaper-pipeline-gemini"   # 纯净母版引擎（只读）
$paper  = Join-Path $root ("papers\" + $Slug)

if (-not (Test-Path (Join-Path $engine "pipeline\pipeline.toml"))) { throw "engine not found: $engine" }
if (-not (Test-Path $IdeaFile)) { throw "idea file not found: $IdeaFile" }
if (Test-Path $paper) { throw "paper workspace already exists: $paper" }

Write-Host "==> creating paper workspace: $paper"
New-Item -ItemType Directory -Path $paper -Force | Out-Null
$items = @('pipeline','tools','project','reference','.agent','.agents','AGENTS.md','bootstrap.py','requirements.txt','requirements-guides.txt','.gitignore','INSTALL-ANTIGRAVITY.md')
foreach ($item in $items) { Copy-Item (Join-Path $engine $item) $paper -Recurse -Force }

Push-Location $paper
try {
  Write-Host "==> bootstrap (venv + pinned deps + wf init + doctor)"
  uv run --python 3.13 python bootstrap.py
  if ($LASTEXITCODE -ne 0) { throw "bootstrap failed" }
  $env:PYTHONUTF8 = "1"
  $env:NCBI_API_KEY  = [Environment]::GetEnvironmentVariable('NCBI_API_KEY','User')
  $env:NCBI_API_EMAIL = [Environment]::GetEnvironmentVariable('NCBI_API_EMAIL','User')
  Copy-Item $IdeaFile (Join-Path $paper "project\00_input\idea_source.md") -Force
  Write-Host "==> idea copied to project\00_input\idea_source.md"
  if ($DataDir -and (Test-Path $DataDir)) {
    Write-Host "==> registering data in place (read-only): $DataDir"
    .\.venv\Scripts\python.exe tools\data_sources.py add --path $DataDir --name "local-data" --why "Data registered read-only for the protocol-defined universe"
    if ($LASTEXITCODE -ne 0) { Write-Host "WARN: data registration failed; run it later at S04" }
  }
  Write-Host "==> status"
  .\.venv\Scripts\python.exe tools\wf.py status
} finally {
  Pop-Location
}
Write-Host ""
Write-Host "Paper ready. Next: open a session in $paper and start the pipeline (see MEDPAPER-WORKFLOW.md)."
