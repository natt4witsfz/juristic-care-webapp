param([string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
$required = @(
  '00_extensions.sql','01_schemas.sql','02_types.sql','03_tables.sql','04_constraints.sql',
  '05_indexes.sql','06_views.sql','07_functions.sql','08_triggers.sql','09_history.sql',
  '10_audit.sql','11_storage.sql','12_rls.sql','13_permissions.sql','14_seed_reference_data.sql','15_validation.sql'
)

foreach ($file in $required) {
  $path = Join-Path $ProjectRoot (Join-Path 'sql' $file)
  if (-not (Test-Path -LiteralPath $path)) { throw "Missing canonical SQL file: $file" }
  if ((Get-Item -LiteralPath $path).Length -eq 0) { throw "Empty canonical SQL file: $file" }
}

$frontendFiles = Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'frontend') -Recurse -File -Include '*.ts','*.tsx','*.js','*.jsx','.env*'
foreach ($file in $frontendFiles) {
  $content = Get-Content -LiteralPath $file.FullName -Raw
  if ($content -match 'SUPABASE_SERVICE_ROLE|service_role_key') { throw "Browser source may contain a service-role secret reference: $($file.FullName)" }
}

$rls = Get-Content -LiteralPath (Join-Path $ProjectRoot 'sql/12_rls.sql') -Raw
if ($rls -notmatch 'force row level security') { throw 'RLS file does not force row-level security.' }
if ($rls -notmatch 'o83_resident_case_select') { throw 'Resident Case-isolation policy is missing.' }
if ($rls -notmatch 'o83_ai_service_recommendation_insert') { throw 'AI service limitation policy is missing.' }
if ($rls -match 'for all to authenticated using \(core\.is_ai_service') { throw 'AI service has an over-broad FOR ALL policy.' }

$migration = Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'supabase/migrations') -File -Filter '*.sql' | Sort-Object Name
if ($migration.Count -lt 1) { throw 'No timestamped Supabase migration exists.' }

Write-Output "Static SQL validation passed: $($required.Count) canonical files, $($migration.Count) migration(s), browser secret boundary checked."
