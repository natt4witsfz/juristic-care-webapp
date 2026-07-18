param([string]$ContainerName = 'supabase_db_o83-care')

$ErrorActionPreference = 'Stop'
$validationDatabase = 'o83_restore_validation'
$dumpPath = '/tmp/o83_restore_validation.dump'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw 'Docker is required for isolated local PostgreSQL restore validation.'
}

$container = docker ps --filter "name=^/$ContainerName$" --format '{{.Names}}'
if ($container -ne $ContainerName) {
  throw "Local Supabase database container '$ContainerName' is not running."
}

try {
  docker exec $ContainerName pg_dump -U postgres -d postgres --format=custom --no-owner --no-acl --file=$dumpPath
  if ($LASTEXITCODE -ne 0) { throw 'Local PostgreSQL backup creation failed.' }

  docker exec $ContainerName psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "drop database if exists $validationDatabase with (force);"
  if ($LASTEXITCODE -ne 0) { throw 'Isolated restore database cleanup failed.' }
  docker exec $ContainerName psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "create database $validationDatabase;"
  if ($LASTEXITCODE -ne 0) { throw 'Isolated restore database creation failed.' }
  # Supabase-managed schemas include privileged Realtime/Auth function settings.
  # The local bootstrap administrator is required to recreate those platform
  # objects; the application postgres role is intentionally not privileged.
  docker exec $ContainerName pg_restore -U supabase_admin -d $validationDatabase --no-owner --no-acl --exit-on-error $dumpPath
  if ($LASTEXITCODE -ne 0) { throw 'Isolated PostgreSQL restore failed.' }

  $tableCount = docker exec $ContainerName psql -U postgres -d $validationDatabase -At -c "select count(*) from pg_tables where schemaname = any(array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration']);"
  if ($LASTEXITCODE -ne 0 -or [int]$tableCount -ne 136) {
    throw "Restored authoritative table count was '$tableCount', expected 136."
  }
  $privateBuckets = docker exec $ContainerName psql -U postgres -d $validationDatabase -At -c "select count(*) from storage.buckets where id like 'o83-%' and public is false;"
  if ($LASTEXITCODE -ne 0 -or [int]$privateBuckets -ne 5) {
    throw "Restored private bucket metadata count was '$privateBuckets', expected 5."
  }
  Write-Output 'Isolated PostgreSQL backup and restore validation passed: 136 authoritative tables and 5 private bucket records restored.'
}
finally {
  docker exec $ContainerName psql -U postgres -d postgres -c "drop database if exists $validationDatabase with (force);" | Out-Null
  docker exec $ContainerName rm -f $dumpPath | Out-Null
}
