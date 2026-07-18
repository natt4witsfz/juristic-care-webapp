[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  throw 'Node.js 22.12 or later is required. Install Node.js and restart the terminal.'
}

$nodeVersion = [version]((node --version).TrimStart('v'))
if ($nodeVersion -lt [version]'22.12.0') {
  throw "Node.js 22.12 or later is required; found $nodeVersion."
}

if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) {
  corepack enable
  corepack prepare pnpm@11.9.0 --activate
}

if (-not (Test-Path -LiteralPath 'frontend/.env.local')) {
  Copy-Item -LiteralPath 'frontend/.env.example' -Destination 'frontend/.env.local'
  Write-Host 'Created frontend/.env.local. Replace the example Supabase values before starting the app.'
}

pnpm install --frozen-lockfile
pnpm check

Write-Host 'O83 Care workspace setup completed.'
