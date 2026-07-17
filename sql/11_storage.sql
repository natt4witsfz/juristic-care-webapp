-- O83 Care Supabase Storage buckets and RLS policies.
-- All buckets are private; database Evidence metadata remains authoritative.

insert into storage.buckets (id, name, public, file_size_limit)
values
  ('o83-evidence-intake', 'o83-evidence-intake', false, 1073741824),
  ('o83-evidence-originals', 'o83-evidence-originals', false, 1073741824),
  ('o83-evidence-renditions', 'o83-evidence-renditions', false, 1073741824),
  ('o83-artifacts', 'o83-artifacts', false, 1073741824),
  ('o83-memory-archive', 'o83-memory-archive', false, 5368709120)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit;

create or replace function core.storage_tenant_id(p_name text)
returns uuid
language plpgsql
immutable
security invoker
set search_path = pg_catalog
as $$
declare v_part text;
begin
  v_part := split_part(p_name, '/', 1);
  if v_part ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    return v_part::uuid;
  end if;
  return null;
end $$;
comment on function core.storage_tenant_id(text) is 'Safely extracts the tenant UUID from an O83 Storage object path.';

create or replace function core.can_read_evidence_object(p_bucket text, p_name text)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, core, evidence, intake, org
as $$
  with tenant as (select core.storage_tenant_id(p_name) as id),
  evidence_object as (
    select ei.id as evidence_id, ei.juristic_person_id
    from evidence.evidence_items ei, tenant t
    where ei.juristic_person_id = t.id
      and ei.original_storage_bucket = p_bucket
      and ei.original_storage_object_key = p_name
    union all
    select er.evidence_item_id, er.juristic_person_id
    from evidence.evidence_renditions er, tenant t
    where er.juristic_person_id = t.id
      and er.storage_bucket = p_bucket
      and er.storage_object_key = p_name
  )
  select exists (
    select 1 from evidence_object eo
    where core.has_any_role(eo.juristic_person_id, array['admin','juristic_manager','juristic_staff','head_technician','technician','auditor'])
       or exists (
         select 1 from evidence.evidence_links el
         where el.evidence_item_id = eo.evidence_id
           and el.target_type = 'case'
           and core.is_case_party(el.target_id)
       )
  )
$$;
comment on function core.can_read_evidence_object(text,text) is 'Authorizes an Evidence object using database Evidence and Case relationships, not path alone.';
revoke all on function core.can_read_evidence_object(text,text) from public, anon;
grant execute on function core.storage_tenant_id(text), core.can_read_evidence_object(text,text) to authenticated;

drop policy if exists o83_storage_intake_insert on storage.objects;
create policy o83_storage_intake_insert on storage.objects
for insert to authenticated
with check (
  bucket_id = 'o83-evidence-intake'
  and core.storage_tenant_id(name) is not null
  and (
    core.current_person_id(core.storage_tenant_id(name)) is not null
    or core.current_service_principal_id(core.storage_tenant_id(name)) is not null
  )
);

drop policy if exists o83_storage_intake_select on storage.objects;
create policy o83_storage_intake_select on storage.objects
for select to authenticated
using (
  bucket_id = 'o83-evidence-intake'
  and core.storage_tenant_id(name) is not null
  and (
    core.has_any_role(core.storage_tenant_id(name), array['admin','juristic_manager','juristic_staff','head_technician','technician'])
    or owner_id = (select auth.uid()::text)
  )
);

drop policy if exists o83_storage_evidence_select on storage.objects;
create policy o83_storage_evidence_select on storage.objects
for select to authenticated
using (
  bucket_id in ('o83-evidence-originals','o83-evidence-renditions')
  and core.can_read_evidence_object(bucket_id, name)
);

drop policy if exists o83_storage_trusted_insert on storage.objects;
create policy o83_storage_trusted_insert on storage.objects
for insert to authenticated
with check (
  bucket_id in ('o83-evidence-originals','o83-evidence-renditions','o83-artifacts')
  and core.storage_tenant_id(name) is not null
  and core.has_any_role(core.storage_tenant_id(name), array['admin','juristic_manager','juristic_staff','head_technician'])
);

drop policy if exists o83_storage_artifact_select on storage.objects;
create policy o83_storage_artifact_select on storage.objects
for select to authenticated
using (
  bucket_id = 'o83-artifacts'
  and core.storage_tenant_id(name) is not null
  and core.has_any_role(core.storage_tenant_id(name), array['admin','committee','juristic_manager','juristic_staff','auditor'])
);

-- No authenticated policy grants direct access to the memory archive bucket.
-- Trusted server-side service-role workflows remain subject to O83 audit and manifest rules.
