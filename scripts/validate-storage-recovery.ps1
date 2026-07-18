param([string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
$status = supabase status -o env
if ($LASTEXITCODE -ne 0) { throw 'Local Supabase status could not be read.' }

$apiUrl = (($status | Select-String '^API_URL=').Line -replace '^API_URL=', '' -replace '"', '')
$serviceRoleKey = (($status | Select-String '^SERVICE_ROLE_KEY=').Line -replace '^SERVICE_ROLE_KEY=', '' -replace '"', '')
if (-not $apiUrl -or -not $serviceRoleKey) { throw 'Local Supabase recovery environment is incomplete.' }

$env:O83_RECOVERY_SUPABASE_URL = $apiUrl
$env:O83_RECOVERY_SERVICE_ROLE_KEY = $serviceRoleKey
try {
  node (Join-Path $ProjectRoot 'scripts/validate-storage-recovery.mjs')
  if ($LASTEXITCODE -ne 0) { throw 'Private Storage recovery validation failed.' }
}
finally {
  Remove-Item Env:O83_RECOVERY_SUPABASE_URL -ErrorAction SilentlyContinue
  Remove-Item Env:O83_RECOVERY_SERVICE_ROLE_KEY -ErrorAction SilentlyContinue
}
