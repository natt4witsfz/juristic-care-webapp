-- O83 Care internal and RLS helper functions.

create or replace function core.current_person_id(p_juristic_person_id uuid)
returns uuid
language sql
stable
security definer
set search_path = pg_catalog, iam
as $$
  select ua.person_id
  from iam.user_accounts ua
  where ua.auth_user_id = (select auth.uid())
    and ua.juristic_person_id = p_juristic_person_id
    and ua.account_state = 'active'
    and ua.disabled_at is null
  order by ua.linked_at desc
  limit 1
$$;
comment on function core.current_person_id(uuid) is 'Resolves current Supabase Auth account to tenant-specific O83 Person identity.';

create or replace function core.current_service_principal_id(p_juristic_person_id uuid)
returns uuid
language sql
stable
security definer
set search_path = pg_catalog, iam
as $$
  select sp.id
  from iam.service_principals sp
  where sp.auth_user_id = (select auth.uid())
    and sp.juristic_person_id = p_juristic_person_id
    and sp.lifecycle = 'active'
    and (sp.expires_at is null or sp.expires_at > now())
  limit 1
$$;
comment on function core.current_service_principal_id(uuid) is 'Resolves a current Auth identity to an active scoped service principal.';

create or replace function core.has_role(p_juristic_person_id uuid, p_role_code text)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, iam, org
as $$
  select exists (
    select 1
    from iam.user_accounts ua
    join org.organization_relationships rel
      on rel.person_id = ua.person_id
     and rel.juristic_person_id = ua.juristic_person_id
     and rel.recorded_to is null
     and rel.relationship_state = 'effective'
    join org.role_assignments ra
      on ra.organization_relationship_id = rel.id
     and ra.recorded_to is null
     and ra.relationship_state = 'effective'
    join org.role_definitions rd on rd.id = ra.role_definition_id
    where ua.auth_user_id = (select auth.uid())
      and ua.juristic_person_id = p_juristic_person_id
      and ua.account_state = 'active'
      and ua.disabled_at is null
      and rd.role_code = p_role_code
  )
$$;
comment on function core.has_role(uuid,text) is 'Checks an effective database-owned role; JWT user metadata is not trusted.';

create or replace function core.has_any_role(p_juristic_person_id uuid, p_role_codes text[])
returns boolean
language sql
stable
security invoker
set search_path = pg_catalog, core
as $$
  select coalesce(bool_or(core.has_role(p_juristic_person_id, role_code)), false)
  from unnest(p_role_codes) role_code
$$;
comment on function core.has_any_role(uuid,text[]) is 'Checks whether the current Person has any listed effective tenant role.';

create or replace function core.is_case_party(p_case_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, core, intake, org
as $$
  select exists (
    select 1
    from intake.cases c
    join intake.case_party_relationships cp on cp.case_id = c.id and cp.recorded_to is null
    join org.organization_relationships rel on rel.id = cp.organization_relationship_id and rel.recorded_to is null
    where c.id = p_case_id
      and rel.person_id = core.current_person_id(c.juristic_person_id)
  )
$$;
comment on function core.is_case_party(uuid) is 'Checks whether current Person has an effective party relationship to a Case.';

create or replace function core.has_active_mandate(p_juristic_person_id uuid, p_action text, p_scope_type text, p_scope_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, core, iam, org
as $$
  select exists (
    select 1
    from org.mandates m
    join org.organization_relationships rel on rel.id = m.grantee_relationship_id
    where m.juristic_person_id = p_juristic_person_id
      and rel.person_id = core.current_person_id(p_juristic_person_id)
      and m.lifecycle = 'active'
      and m.revoked_at is null
      and (m.valid_from is null or m.valid_from <= now())
      and (m.valid_to is null or m.valid_to > now())
      and p_action = any(m.authority_actions)
      and (m.scope_type = 'juristic_person' or (m.scope_type = p_scope_type and m.scope_id = p_scope_id))
  )
$$;
comment on function core.has_active_mandate(uuid,text,text,uuid) is 'Checks effective database-owned Authority for action and scope.';

create or replace function core.current_change_reason()
returns text
language sql
stable
security invoker
set search_path = pg_catalog
as $$
  select nullif(current_setting('app.change_reason', true), '')
$$;
comment on function core.current_change_reason() is 'Returns transaction-local reason supplied by trusted workflow code, if any.';

revoke all on function core.current_person_id(uuid) from public, anon;
revoke all on function core.current_service_principal_id(uuid) from public, anon;
revoke all on function core.has_role(uuid,text) from public, anon;
revoke all on function core.has_any_role(uuid,text[]) from public, anon;
revoke all on function core.is_case_party(uuid) from public, anon;
revoke all on function core.has_active_mandate(uuid,text,text,uuid) from public, anon;
grant execute on function core.current_person_id(uuid), core.current_service_principal_id(uuid),
  core.has_role(uuid,text), core.has_any_role(uuid,text[]), core.is_case_party(uuid),
  core.has_active_mandate(uuid,text,text,uuid), core.current_change_reason() to authenticated;

create or replace function api.resolve_current_access()
returns table (
  juristic_person_id uuid,
  person_id uuid,
  display_name text,
  roles text[],
  permissions text[]
)
language sql
stable
security definer
set search_path = ''
as $$
  select ua.juristic_person_id,
         ua.person_id,
         p.display_name,
         coalesce((
           select array_agg(distinct rd.role_code order by rd.role_code)
           from org.organization_relationships rel
           join org.role_assignments ra on ra.organization_relationship_id = rel.id
             and ra.recorded_to is null and ra.relationship_state = 'effective'
           join org.role_definitions rd on rd.id = ra.role_definition_id
           where rel.juristic_person_id = ua.juristic_person_id
             and rel.person_id = ua.person_id
             and rel.recorded_to is null
             and rel.relationship_state = 'effective'
         ), array[]::text[]) as roles,
         coalesce((
           select array_agg(distinct pd.permission_code order by pd.permission_code)
           from org.organization_relationships rel
           join org.role_assignments ra on ra.organization_relationship_id = rel.id
             and ra.recorded_to is null and ra.relationship_state = 'effective'
           join org.role_permissions rp on rp.role_definition_id = ra.role_definition_id
             and rp.recorded_to is null and rp.relationship_state = 'effective' and rp.effect = 'allow'
           join org.permission_definitions pd on pd.id = rp.permission_definition_id
           where rel.juristic_person_id = ua.juristic_person_id
             and rel.person_id = ua.person_id
             and rel.recorded_to is null
             and rel.relationship_state = 'effective'
             and not exists (
               select 1
               from org.role_permissions denied
               where denied.role_definition_id = ra.role_definition_id
                 and denied.permission_definition_id = pd.id
                 and denied.recorded_to is null
                 and denied.relationship_state = 'effective'
                 and denied.effect = 'deny'
             )
         ), array[]::text[]) as permissions
  from iam.user_accounts ua
  join org.people p on p.id = ua.person_id
  where ua.auth_user_id = (select auth.uid())
    and ua.account_state = 'active'
    and ua.disabled_at is null
    and ua.lifecycle = 'active'
$$;
comment on function api.resolve_current_access() is 'Returns database-owned tenant identity, effective roles, and data-driven permissions for the current Auth user.';

create or replace function core.has_permission(p_juristic_person_id uuid, p_permission_code text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from iam.user_accounts ua
    join org.organization_relationships rel
      on rel.person_id = ua.person_id and rel.juristic_person_id = ua.juristic_person_id
    join org.role_assignments ra on ra.organization_relationship_id = rel.id
    join org.role_permissions rp on rp.role_definition_id = ra.role_definition_id
    join org.permission_definitions pd on pd.id = rp.permission_definition_id
    where ua.auth_user_id = (select auth.uid())
      and ua.juristic_person_id = p_juristic_person_id
      and ua.account_state = 'active' and ua.disabled_at is null and ua.lifecycle = 'active'
      and rel.recorded_to is null and rel.relationship_state = 'effective'
      and ra.recorded_to is null and ra.relationship_state = 'effective'
      and rp.recorded_to is null and rp.relationship_state = 'effective' and rp.effect = 'allow'
      and pd.permission_code = p_permission_code
      and not exists (
        select 1 from org.role_permissions denied
        where denied.role_definition_id = ra.role_definition_id
          and denied.permission_definition_id = pd.id
          and denied.recorded_to is null and denied.relationship_state = 'effective'
          and denied.effect = 'deny'
      )
  )
$$;
comment on function core.has_permission(uuid,text) is 'Checks an effective database-owned role-permission mapping for the current Auth identity.';
revoke all on function core.has_permission(uuid,text) from public, anon;
grant execute on function core.has_permission(uuid,text) to authenticated;

create or replace function api.create_case(
  p_juristic_person_id uuid,
  p_channel text,
  p_submitted_text text,
  p_submitted_location_text text default null,
  p_occurred_at timestamptz default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid;
  v_relationship_id uuid;
  v_reporter_term_id uuid;
  v_report_id uuid := extensions.gen_random_uuid();
  v_case_id uuid := extensions.gen_random_uuid();
  v_correlation_id uuid := extensions.gen_random_uuid();
  v_year text := to_char(timezone('Asia/Bangkok', now()), 'YYYY');
  v_sequence integer;
  v_case_number text;
  v_report_number text;
begin
  if (select auth.uid()) is null then
    raise exception using errcode = '42501', message = 'Authentication is required.';
  end if;
  if p_channel not in ('resident_form','juristic_staff_intake','technician_finding','security_report','external_authority','system_recommendation') then
    raise exception using errcode = '22023', message = 'Unsupported Case source.';
  end if;
  if nullif(btrim(p_submitted_text), '') is null then
    raise exception using errcode = '22023', message = 'Report description is required.';
  end if;

  v_person_id := core.current_person_id(p_juristic_person_id);
  if v_person_id is null or not core.has_any_role(
    p_juristic_person_id,
    array['admin','juristic_manager','juristic_staff','head_technician','technician','resident','security']
  ) then
    raise exception using errcode = '42501', message = 'No active membership may create a Case for this organization.';
  end if;
  if (p_channel = 'resident_form' and not core.has_role(p_juristic_person_id, 'resident'))
     or (p_channel in ('juristic_staff_intake','external_authority','system_recommendation')
         and not core.has_any_role(p_juristic_person_id, array['admin','juristic_manager','juristic_staff']))
     or (p_channel = 'technician_finding'
         and not core.has_any_role(p_juristic_person_id, array['head_technician','technician']))
     or (p_channel = 'security_report' and not core.has_role(p_juristic_person_id, 'security')) then
    raise exception using errcode = '42501', message = 'The selected Case source does not match the current effective role.';
  end if;

  select rel.id into v_relationship_id
  from org.organization_relationships rel
  where rel.juristic_person_id = p_juristic_person_id
    and rel.person_id = v_person_id
    and rel.recorded_to is null
    and rel.relationship_state = 'effective'
  order by rel.recorded_from desc
  limit 1;

  select tt.id into v_reporter_term_id
  from taxonomy.taxonomy_terms tt
  join taxonomy.taxonomies t on t.id = tt.taxonomy_id
  where tt.juristic_person_id = p_juristic_person_id
    and t.taxonomy_code = 'case_party_role'
    and tt.term_code = 'reporter'
    and tt.lifecycle = 'active'
  limit 1;

  if v_relationship_id is null or v_reporter_term_id is null then
    raise exception using errcode = '55000', message = 'Membership or Case party reference data is not provisioned.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_juristic_person_id::text || ':case:' || v_year, 0));
  select coalesce(max(right(c.case_number, 6)::integer), 0) + 1 into v_sequence
  from intake.cases c
  where c.juristic_person_id = p_juristic_person_id
    and c.case_number ~ ('^CASE-' || v_year || '-[0-9]{6}$');
  v_case_number := 'CASE-' || v_year || '-' || lpad(v_sequence::text, 6, '0');
  v_report_number := 'REPORT-' || v_year || '-' || lpad(v_sequence::text, 6, '0');

  insert into intake.reports (
    id, juristic_person_id, business_key, created_by_person_id, report_number,
    channel, source_relationship_id, submitted_text, submitted_location_text,
    occurred_at, recorded_at
  ) values (
    v_report_id, p_juristic_person_id, 'report:' || v_report_id::text, v_person_id,
    v_report_number, p_channel, v_relationship_id, btrim(p_submitted_text),
    nullif(btrim(p_submitted_location_text), ''), p_occurred_at, now()
  );

  insert into intake.cases (
    id, juristic_person_id, business_key, created_by_person_id, case_number,
    report_id, current_state, opened_at, current_summary
  ) values (
    v_case_id, p_juristic_person_id, 'case:' || v_case_id::text, v_person_id,
    v_case_number, v_report_id, 'open', now(), left(btrim(p_submitted_text), 500)
  );

  insert into intake.case_party_relationships (
    juristic_person_id, business_key, created_by_person_id, case_id,
    organization_relationship_id, party_role_term_id, contact_permission,
    relationship_state, recorded_from
  ) values (
    p_juristic_person_id, 'case-party:' || v_case_id::text || ':' || v_relationship_id::text,
    v_person_id, v_case_id, v_relationship_id, v_reporter_term_id, 'case_updates',
    'effective', now()
  );

  insert into audit.domain_events (
    juristic_person_id, business_key, created_by_person_id, event_type, schema_version,
    aggregate_type, aggregate_id, aggregate_version, payload, producer, occurred_at,
    actor_kind, actor_id, correlation_id
  ) values (
    p_juristic_person_id, 'event:' || v_correlation_id::text, v_person_id,
    'CaseCreated', 1, 'Case', v_case_id, 1,
    jsonb_build_object('case_number', v_case_number, 'report_id', v_report_id, 'channel', p_channel),
    'api.create_case', coalesce(p_occurred_at, now()), 'person', v_person_id, v_correlation_id
  );

  return jsonb_build_object('case_id', v_case_id, 'case_number', v_case_number, 'report_id', v_report_id);
end
$$;
comment on function api.create_case(uuid,text,text,text,timestamptz) is 'Atomically creates one immutable Report, exactly one separate Case, reporter relationship, and CaseCreated event.';

create or replace function api.create_investigation(
  p_juristic_person_id uuid,
  p_case_id uuid,
  p_question text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid;
  v_investigation_id uuid := extensions.gen_random_uuid();
  v_year text := to_char(timezone('Asia/Bangkok', now()), 'YYYY');
  v_sequence integer;
  v_number text;
begin
  v_person_id := core.current_person_id(p_juristic_person_id);
  if v_person_id is null or not core.has_any_role(p_juristic_person_id, array['admin','juristic_manager','juristic_staff','head_technician']) then
    raise exception using errcode = '42501', message = 'Investigation permission is required.';
  end if;
  if not exists (select 1 from intake.cases c where c.id = p_case_id and c.juristic_person_id = p_juristic_person_id) then
    raise exception using errcode = 'P0002', message = 'Case was not found in this organization.';
  end if;
  if nullif(btrim(p_question), '') is null then
    raise exception using errcode = '22023', message = 'Investigation question is required.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_juristic_person_id::text || ':investigation:' || v_year, 0));
  select count(*) + 1 into v_sequence from investigation.investigations i
  where i.juristic_person_id = p_juristic_person_id and i.investigation_number like 'INV-' || v_year || '-%';
  v_number := 'INV-' || v_year || '-' || lpad(v_sequence::text, 6, '0');

  insert into investigation.investigations (
    id, juristic_person_id, business_key, created_by_person_id, investigation_number,
    question, initiating_case_id, current_state, opened_at
  ) values (
    v_investigation_id, p_juristic_person_id, 'investigation:' || v_investigation_id::text,
    v_person_id, v_number, btrim(p_question), p_case_id, 'opened', now()
  );
  insert into investigation.investigation_cases (
    juristic_person_id, business_key, created_by_person_id, investigation_id,
    case_id, scope_role, inclusion_reason, relationship_state, recorded_from
  ) values (
    p_juristic_person_id, 'investigation-case:' || v_investigation_id::text || ':' || p_case_id::text,
    v_person_id, v_investigation_id, p_case_id, 'initiating', 'Created from Case investigation action',
    'effective', now()
  );
  return jsonb_build_object('investigation_id', v_investigation_id, 'investigation_number', v_number);
end
$$;
comment on function api.create_investigation(uuid,uuid,text) is 'Creates an Investigation without creating an Incident; Incident verification remains a separate human Decision.';

revoke all on function api.resolve_current_access() from public, anon;
revoke all on function api.create_case(uuid,text,text,text,timestamptz) from public, anon;
revoke all on function api.create_investigation(uuid,uuid,text) from public, anon;
grant execute on function api.resolve_current_access(),
  api.create_case(uuid,text,text,text,timestamptz),
  api.create_investigation(uuid,uuid,text) to authenticated;
