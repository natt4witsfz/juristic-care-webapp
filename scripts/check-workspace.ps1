[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$requiredFolders = @('frontend', 'backend', 'database', 'architecture', 'planning', 'docs', 'scripts', '.github', 'bootstrap', 'supabase')
$requiredFiles = @(
  'package.json',
  'pnpm-lock.yaml',
  'frontend/.env.example',
  'frontend/playwright.config.ts',
  'frontend/vitest.config.ts',
  '.github/workflows/ci.yml',
  'frontend/vercel.json',
  'docs/DEVELOPMENT_SETUP.md',
  'review/SPRINT_00_PREFLIGHT.md'
)

$missing = @()
foreach ($folder in $requiredFolders) {
  if (-not (Test-Path -LiteralPath (Join-Path $root $folder) -PathType Container)) { $missing += $folder }
}
foreach ($file in $requiredFiles) {
  if (-not (Test-Path -LiteralPath (Join-Path $root $file) -PathType Leaf)) { $missing += $file }
}

if ($missing.Count -gt 0) {
  throw "Workspace is incomplete: $($missing -join ', ')"
}

Write-Host "Workspace structure passed: $($requiredFolders.Count) required folders and $($requiredFiles.Count) required files."
