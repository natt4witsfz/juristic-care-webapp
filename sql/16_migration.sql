-- O83 Care migration assembly guard.
-- The 00-15 scripts are the readable source set. Production migration files must
-- be created by the installed Supabase CLI and must preserve this ordering.

do $$
begin
  if current_setting('server_version_num')::integer < 150000 then
    raise exception 'O83 requires PostgreSQL 15 or newer for reviewed view/RLS behavior';
  end if;
  if not exists (select 1 from pg_extension where extname = 'pgcrypto') then
    raise exception 'O83 pgcrypto extension is missing';
  end if;
  if not exists (select 1 from pg_namespace where nspname = 'api') then
    raise exception 'O83 API boundary schema is missing';
  end if;
  if exists (
    select 1 from pg_tables
    where schemaname = 'public'
      and tablename like 'o83%'
  ) then
    raise exception 'O83 authoritative tables must not be created in public schema';
  end if;
  raise notice 'O83 migration assembly preconditions passed; run 15_validation.sql and Supabase advisors after migration';
end $$;

-- Reload PostgREST schema metadata after the complete migration is committed.
notify pgrst, 'reload schema';
