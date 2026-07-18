-- O83 Care row-change audit with actor, time, old/new values, and reason.

alter table audit.audit_entries add column if not exists old_value jsonb;
alter table audit.audit_entries add column if not exists new_value jsonb;
alter table audit.audit_entries add column if not exists database_role text;
comment on column audit.audit_entries.old_value is 'Prior row image for audited modification, classification and retention controlled.';
comment on column audit.audit_entries.new_value is 'New row image for audited modification, classification and retention controlled.';

create or replace function audit.capture_row_change()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, core, iam, audit
as $$
declare
  v_old jsonb := case when tg_op in ('UPDATE','DELETE') then to_jsonb(old) else null end;
  v_new jsonb := case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) else null end;
  v_tenant uuid := coalesce((v_new->>'juristic_person_id')::uuid, (v_old->>'juristic_person_id')::uuid);
  v_target uuid := coalesce((v_new->>'id')::uuid, (v_old->>'id')::uuid);
  v_person uuid;
  v_service uuid;
begin
  if v_tenant is null and tg_table_schema = 'org' and tg_table_name = 'juristic_persons' then
    v_tenant := v_target;
  end if;
  if v_tenant is not null then
    v_person := core.current_person_id(v_tenant);
    v_service := core.current_service_principal_id(v_tenant);
  end if;
  insert into audit.audit_entries (
    juristic_person_id, business_key, lifecycle, principal_kind, principal_id,
    action_code, target_type, target_id, result, old_value, new_value,
    database_role, occurred_at, recorded_at, correlation_id, reason,
    classification
  ) values (
    v_tenant, extensions.gen_random_uuid()::text, 'active',
    case when v_person is not null then 'person'::core.actor_kind
         when v_service is not null then 'service_principal'::core.actor_kind
         else 'system'::core.actor_kind end,
    coalesce(v_person, v_service), lower(tg_op), tg_table_schema || '.' || tg_table_name,
    v_target, 'succeeded', v_old, v_new, current_user, statement_timestamp(),
    clock_timestamp(), extensions.gen_random_uuid(), core.current_change_reason(), 'confidential'
  );
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end $$;
comment on function audit.capture_row_change() is 'Captures row modification with actor, time, old/new value, database role, and reason.';
revoke all on function audit.capture_row_change() from public, anon, authenticated;

do $$
declare r record; v_name text;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','analytics','memory','integration'])
  loop
    v_name := left('trg_' || r.schemaname || '_' || r.tablename || '_audit', 63);
    if not exists (
      select 1 from pg_trigger t
      join pg_class c on c.oid = t.tgrelid
      join pg_namespace n on n.oid = c.relnamespace
      where not t.tgisinternal and n.nspname = r.schemaname and c.relname = r.tablename and t.tgname = v_name
    ) then
      execute format('create trigger %I after insert or update or delete on %I.%I for each row execute function audit.capture_row_change()', v_name, r.schemaname, r.tablename);
    end if;
  end loop;
end $$;
