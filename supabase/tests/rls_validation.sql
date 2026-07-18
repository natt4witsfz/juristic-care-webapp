-- O83 Care RLS, Storage, role-boundary, and immutable-history validation.
-- These catalog-level integration tests complement identity-fixture behavior tests.
begin;

create extension if not exists pgtap with schema extensions;
select extensions.plan(20);

select extensions.is(
  (
    select count(*)
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where c.relkind in ('r','p')
      and n.nspname = any (array[
        'iam','org','property','taxonomy','intake','investigation','incident','work','evidence',
        'decision','knowledge','workflow','notification','governance','ai','audit','analytics',
        'memory','integration'
      ])
      and (not c.relrowsecurity or not c.relforcerowsecurity)
  ),
  0::bigint,
  'RLS is enabled and forced on every authoritative O83 table'
);

select extensions.is(
  (
    select count(*)
    from information_schema.role_table_grants
    where grantee = 'anon'
      and table_schema = any (array[
        'iam','org','property','taxonomy','intake','investigation','incident','work','evidence',
        'decision','knowledge','workflow','notification','governance','ai','audit','analytics',
        'memory','integration'
      ])
      and privilege_type in ('SELECT','INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER')
  ),
  0::bigint,
  'anon has no direct authoritative-table grants'
);

select extensions.is(
  (
    select count(*)
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'api'
      and p.proname in ('resolve_current_access','create_case','create_investigation')
  ),
  3::bigint,
  'all controlled API functions exist'
);

select extensions.ok(
  (
    select count(*) >= 2
    from pg_trigger
    where tgfoid = 'core.reject_history_change()'::regprocedure
      and not tgisinternal
      and tgrelid in ('audit.domain_events'::regclass, 'audit.audit_entries'::regclass)
  ),
  'domain-event and audit-entry history is immutable'
);

select extensions.is(
  (
    select count(*) from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname like 'o83_storage_%'
  ),
  4::bigint,
  'four narrow O83 Storage read and intake policies exist'
);

select extensions.is(
  (
    select count(*) from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname like 'o83_storage_%'
      and cmd = 'INSERT'
  ),
  1::bigint,
  'browser Storage writes are limited to one intent-bound intake policy'
);

select extensions.ok(
  exists (
    select 1 from storage.buckets
    where id = 'o83-evidence-intake' and public is false
      and file_size_limit = 52428800
      and allowed_mime_types @> array['image/jpeg','image/png','application/pdf','text/plain']::text[]
  ),
  'private Evidence intake enforces the trusted processor size and MIME boundary before upload'
);

select extensions.is(
  (
    select count(*) from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname like 'o83_storage_%'
      and cmd in ('UPDATE','DELETE','ALL')
  ),
  0::bigint,
  'O83 grants no browser update, delete, or all-object Storage policy'
);

select extensions.ok(
  exists (
    select 1 from pg_policies
    where schemaname = 'intake' and tablename = 'cases'
      and policyname = 'o83_resident_case_select'
      and cmd = 'SELECT'
      and qual like '%is_case_party%'
  ),
  'resident Case access is relationship scoped'
);

select extensions.ok(
  exists (
    select 1 from pg_policies
    where schemaname = 'work' and tablename = 'operations'
      and policyname = 'o83_worker_operations_select'
      and qual like '%can_access_operation%'
  ),
  'technician and vendor Operation access is Commitment scoped'
);

select extensions.ok(
  exists (
    select 1 from pg_policies
    where policyname like 'o83_committee_select_%'
      and cmd = 'SELECT'
  ),
  'committee access is represented by explicit read policies'
);

select extensions.is(
  (
    select count(*) from pg_policies
    where policyname like 'o83_admin_all_%'
  ),
  135::bigint,
  'baseline authoritative tables retain one tenant-scoped admin policy each'
);

select extensions.is(
  (
    select count(*) from pg_policies
    where schemaname = 'ai'
      and policyname like 'o83_ai_service_%'
      and cmd in ('UPDATE','DELETE','ALL')
  ),
  0::bigint,
  'AI service cannot update, delete, or obtain all-action access'
);

select extensions.is(
  (
    select count(*) from pg_policies
    where schemaname = 'ai'
      and tablename = 'ai_reviews'
      and policyname like 'o83_ai_service_%'
  ),
  0::bigint,
  'AI service cannot create or impersonate human review'
);

select extensions.ok(
  exists (
    select 1 from pg_policies
    where schemaname = 'ai' and tablename = 'ai_reviews'
      and policyname = 'o83_ai_reviewer_review_insert'
      and cmd = 'INSERT'
      and with_check like '%current_person_id%'
  ),
  'AI review insertion is bound to the current qualified human'
);

select extensions.is(
  (
    select count(*) from pg_policies
    where schemaname = any (array[
      'iam','org','property','taxonomy','intake','investigation','incident','work','evidence',
      'decision','knowledge','workflow','notification','governance','ai','audit','analytics',
      'memory','integration'
    ])
      and 'anon' = any (roles)
  ),
  0::bigint,
  'no authoritative RLS policy targets anon'
);

select extensions.ok(
  exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and policyname = 'o83_storage_intake_insert'
      and with_check like '%can_upload_intake_object%'
  ),
  'intake Storage insertion requires a database-issued upload intent'
);

select extensions.ok(
  not has_function_privilege('authenticated', 'api.promote_evidence_upload(uuid,uuid,text,text,bigint,text,text,uuid,text,core.link_role,text,text,timestamptz,text,uuid)', 'EXECUTE')
  and not has_function_privilege('authenticated', 'api.quarantine_evidence_upload(uuid,uuid,text,text)', 'EXECUTE'),
  'authenticated browsers cannot promote or quarantine Evidence'
);

select extensions.ok(
  has_function_privilege('service_role', 'api.promote_evidence_upload(uuid,uuid,text,text,bigint,text,text,uuid,text,core.link_role,text,text,timestamptz,text,uuid)', 'EXECUTE')
  and has_function_privilege('service_role', 'api.finalize_memory_transfer(uuid,uuid,text,text,jsonb,text,text,timestamptz,timestamptz)', 'EXECUTE'),
  'trusted processors can execute only the reviewed Evidence and Memory finalizers'
);

select extensions.ok(
  exists (
    select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'integration' and c.relname = 'inbound_message_payloads'
      and c.relrowsecurity and c.relforcerowsecurity
  ),
  'immutable offline payloads are protected by forced RLS'
);

select * from extensions.finish();
rollback;
