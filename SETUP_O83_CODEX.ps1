param(
    [string]$Root = "C:\Users\natta\OneDrive\Desktop\Codex"
)

$ErrorActionPreference = "Stop"

$folders = @(
    $Root,
    (Join-Path $Root "source_architecture"),
    (Join-Path $Root "rewritten_architecture"),
    (Join-Path $Root "review"),
    (Join-Path $Root "backup"),
    (Join-Path $Root "engineering")
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
}

$promptSource = Join-Path $PSScriptRoot "CODEX_FULL_REWRITE_PROMPT.md"
$promptTarget = Join-Path $Root "engineering\CODEX_FULL_REWRITE_PROMPT.md"

if (-not (Test-Path $promptSource)) {
    throw "CODEX_FULL_REWRITE_PROMPT.md must be in the same folder as this script."
}

Copy-Item -Force $promptSource $promptTarget

$readme = @"
# O83 Care Codex Rewrite Workspace

## Before running Codex

Copy the existing architecture Markdown files into:

source_architecture/

Expected filenames normally run from:

00_foundation.md

through:

50_integration_catalog.md

Do not place the only copy of your files here. Keep your Git repository or another backup.

## Start Codex

Open this local folder in Codex:

$Root

Then send:

Read engineering/CODEX_FULL_REWRITE_PROMPT.md and execute it exactly.
Do not write application code.
Do not modify source_architecture.
Stop when the rewritten architecture and review reports are complete.
"@

Set-Content -Path (Join-Path $Root "README_START_HERE.md") -Value $readme -Encoding UTF8

Write-Host ""
Write-Host "O83 Care Codex workspace created:" -ForegroundColor Green
Write-Host $Root
Write-Host ""
Write-Host "Next:"
Write-Host "1. Copy all existing architecture .md files into source_architecture"
Write-Host "2. Open the root folder in Codex"
Write-Host "3. Paste the command shown in README_START_HERE.md"
