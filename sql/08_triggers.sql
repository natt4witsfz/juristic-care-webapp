-- O83 Care generic concurrency and updated-at triggers.

create or replace function core.touch_mutable_row()
returns trigger
language plpgsql
security invoker
set search_path = pg_catalog
as $$
begin
  if new.id <> old.id then
    raise exception 'O83 primary key is immutable';
  end if;
  if new.juristic_person_id is distinct from old.juristic_person_id then
    raise exception 'O83 tenant identity is immutable';
  end if;
  new.updated_at := now();
  new.row_version := old.row_version + 1;
  return new;
end $$;
comment on function core.touch_mutable_row() is 'Maintains optimistic row version and immutable tenant/primary identity.';

do $$
declare r record; v_name text;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
      and not (schemaname = 'org' and tablename = 'juristic_persons')
  loop
    v_name := left('trg_' || r.schemaname || '_' || r.tablename || '_touch', 63);
    if not exists (
      select 1 from pg_trigger t
      join pg_class c on c.oid = t.tgrelid
      join pg_namespace n on n.oid = c.relnamespace
      where not t.tgisinternal and n.nspname = r.schemaname and c.relname = r.tablename and t.tgname = v_name
    ) then
      execute format('create trigger %I before update on %I.%I for each row execute function core.touch_mutable_row()', v_name, r.schemaname, r.tablename);
    end if;
  end loop;
end $$;

comment on function core.touch_mutable_row() is 'Attached to mutable rows; immutable tables receive stricter triggers in 09_history.sql.';
