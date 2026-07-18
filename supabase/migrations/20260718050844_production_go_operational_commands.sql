-- O83 Care Production-GO operational commands and projections.
-- Forward-only migration. The verified baseline migration remains immutable.

-- RLS policies call this helper while the caller has no direct USAGE on the
-- private core schema. Keep the result-only boundary SECURITY DEFINER and use
-- fully qualified names so policy evaluation cannot fail or search-path drift.
create or replace function core.has_any_role(p_juristic_person_id uuid, p_role_codes text[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(pg_catalog.bool_or(core.has_role(p_juristic_person_id, role_code)), false)
  from pg_catalog.unnest(p_role_codes) role_code
$$;
comment on function core.has_any_role(uuid,text[]) is 'Checks effective database-owned tenant roles through a result-only RLS helper; no private schema access is granted to callers.';

update storage.buckets
set file_size_limit = 52428800
where id in ('o83-evidence-intake', 'o83-evidence-originals', 'o83-evidence-renditions');

update storage.buckets
set allowed_mime_types = array[
  'image/jpeg', 'image/png', 'image/webp', 'application/pdf',
  'video/mp4', 'audio/mpeg', 'audio/mp4', 'text/plain'
]
where id = 'o83-evidence-intake';

create or replace function core.current_relationship_id(p_juristic_person_id uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select rel.id
  from org.organization_relationships rel
  where rel.juristic_person_id = p_juristic_person_id
    and rel.person_id = core.current_person_id(p_juristic_person_id)
    and rel.recorded_to is null
    and rel.relationship_state = 'effective'
  order by rel.recorded_from desc
  limit 1
$$;
comment on function core.current_relationship_id(uuid) is 'Returns the current effective organization relationship for the authenticated Person and tenant.';

create or replace function core.assert_command_authority(
  p_juristic_person_id uuid,
  p_permission_code text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_authority_action text,
  p_scope_type text,
  p_scope_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_relationship_id uuid := core.current_relationship_id(p_juristic_person_id);
begin
  if (select auth.uid()) is null or v_person_id is null or v_relationship_id is null then
    raise exception using errcode = '42501', message = 'An active authenticated organization membership is required.';
  end if;
  if not core.has_permission(p_juristic_person_id, p_permission_code) then
    raise exception using errcode = '42501', message = 'The required effective permission is not present.';
  end if;
  if not exists (
    select 1
    from org.role_assignments ra
    where ra.id = p_acting_role_assignment_id
      and ra.juristic_person_id = p_juristic_person_id
      and ra.organization_relationship_id = v_relationship_id
      and ra.recorded_to is null
      and ra.relationship_state = 'effective'
  ) then
    raise exception using errcode = '42501', message = 'The acting role assignment is not currently effective for this Person.';
  end if;
  if p_mandate_id is null or not exists (
    select 1
    from org.mandates m
    where m.id = p_mandate_id
      and m.juristic_person_id = p_juristic_person_id
      and m.grantee_relationship_id = v_relationship_id
      and (m.grantee_role_assignment_id is null or m.grantee_role_assignment_id = p_acting_role_assignment_id)
      and m.lifecycle = 'active'
      and m.revoked_at is null
      and (m.valid_from is null or m.valid_from <= now())
      and (m.valid_to is null or m.valid_to > now())
      and p_authority_action = any(m.authority_actions)
      and (
        m.scope_type = 'juristic_person'
        or (m.scope_type = p_scope_type and m.scope_id = p_scope_id)
      )
  ) then
    raise exception using errcode = '42501', message = 'An effective Mandate for the exact action and scope is required.';
  end if;
end
$$;
comment on function core.assert_command_authority(uuid,text,uuid,uuid,text,text,uuid) is 'Internal command guard that keeps permission, acting role, Authority, scope, and identity independent and explicit.';

create or replace function core.record_human_decision(
  p_juristic_person_id uuid,
  p_decision_class text,
  p_question text,
  p_context_summary text,
  p_outcome text,
  p_rationale text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_expected_consequences text default null,
  p_assessment_id uuid default null,
  p_evidence_item_ids uuid[] default array[]::uuid[],
  p_decided_at timestamptz default now()
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_decision_id uuid := extensions.gen_random_uuid();
  v_year text := to_char(timezone('Asia/Bangkok', now()), 'YYYY');
  v_sequence integer;
  v_number text;
  v_evidence_id uuid;
begin
  if v_person_id is null then
    raise exception using errcode = '42501', message = 'A human organization identity is required to record a Decision.';
  end if;
  if nullif(btrim(p_question), '') is null or nullif(btrim(p_outcome), '') is null or nullif(btrim(p_rationale), '') is null then
    raise exception using errcode = '22023', message = 'Decision question, outcome, and rationale are required.';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_juristic_person_id::text || ':decision:' || v_year, 0));
  select coalesce(max(right(d.decision_number, 6)::integer), 0) + 1
    into v_sequence
  from decision.decision_records d
  where d.juristic_person_id = p_juristic_person_id
    and d.decision_number ~ ('^DEC-' || v_year || '-[0-9]{6}$');
  v_number := 'DEC-' || v_year || '-' || lpad(v_sequence::text, 6, '0');

  insert into decision.decision_records (
    id, juristic_person_id, business_key, created_by_person_id, decision_number,
    decision_class, question, context_summary, alternatives, outcome, rationale,
    responsible_person_id, acting_role_assignment_id, mandate_id,
    authority_source_type, authority_source_id, decided_at, effective_from,
    expected_consequences, decision_status
  ) values (
    v_decision_id, p_juristic_person_id, 'decision:' || v_decision_id::text, v_person_id,
    v_number, btrim(p_decision_class), btrim(p_question), btrim(p_context_summary), '[]'::jsonb,
    btrim(p_outcome), btrim(p_rationale), v_person_id, p_acting_role_assignment_id,
    p_mandate_id, 'mandate', p_mandate_id, coalesce(p_decided_at, now()),
    coalesce(p_decided_at, now()), nullif(btrim(p_expected_consequences), ''), 'issued'
  );

  if p_assessment_id is not null then
    if not exists (
      select 1 from investigation.understanding_assessments a
      where a.id = p_assessment_id and a.juristic_person_id = p_juristic_person_id
    ) then
      raise exception using errcode = 'P0002', message = 'The referenced Understanding Assessment was not found in this organization.';
    end if;
    insert into decision.decision_assessment_links (
      juristic_person_id, business_key, created_by_person_id,
      decision_id, assessment_id, relationship_role
    ) values (
      p_juristic_person_id, 'decision-assessment:' || v_decision_id::text || ':' || p_assessment_id::text,
      v_person_id, v_decision_id, p_assessment_id, 'basis'
    );
  end if;

  foreach v_evidence_id in array coalesce(p_evidence_item_ids, array[]::uuid[])
  loop
    if not exists (
      select 1 from evidence.evidence_items e
      where e.id = v_evidence_id and e.juristic_person_id = p_juristic_person_id
    ) then
      raise exception using errcode = 'P0002', message = 'A referenced Evidence Item was not found in this organization.';
    end if;
    insert into decision.decision_evidence_links (
      juristic_person_id, business_key, created_by_person_id, decision_id,
      evidence_item_id, consideration_role, relevance
    ) values (
      p_juristic_person_id, 'decision-evidence:' || v_decision_id::text || ':' || v_evidence_id::text,
      v_person_id, v_decision_id, v_evidence_id, 'considered', 'Considered by the recorded human Decision'
    );
  end loop;
  return v_decision_id;
end
$$;
comment on function core.record_human_decision(uuid,text,text,text,text,text,uuid,uuid,text,uuid,uuid[],timestamptz) is 'Internal append-only Decision recorder; AI and browser clients receive no execute grant.';

create or replace function core.record_transition_and_event(
  p_juristic_person_id uuid,
  p_aggregate_type text,
  p_aggregate_id uuid,
  p_version_before bigint,
  p_version_after bigint,
  p_previous_state text,
  p_current_state text,
  p_reason text,
  p_event_type text,
  p_payload jsonb,
  p_actor_id uuid,
  p_acting_role_assignment_id uuid default null,
  p_decision_id uuid default null,
  p_mandate_id uuid default null,
  p_evidence_package_id uuid default null,
  p_occurred_at timestamptz default now()
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_correlation_id uuid := extensions.gen_random_uuid();
begin
  insert into workflow.state_transitions (
    juristic_person_id, business_key, created_by_person_id, aggregate_type,
    aggregate_id, aggregate_version_before, aggregate_version_after,
    previous_state, current_state, decision_id, mandate_id, evidence_package_id,
    occurred_at, recorded_at, correlation_id, reason
  ) values (
    p_juristic_person_id, 'transition:' || v_correlation_id::text, p_actor_id,
    p_aggregate_type, p_aggregate_id, p_version_before, p_version_after,
    p_previous_state, p_current_state, p_decision_id, p_mandate_id,
    p_evidence_package_id, coalesce(p_occurred_at, now()), now(), v_correlation_id,
    btrim(p_reason)
  );
  insert into audit.domain_events (
    juristic_person_id, business_key, created_by_person_id, event_type, schema_version,
    aggregate_type, aggregate_id, aggregate_version, payload, producer,
    occurred_at, actor_kind, actor_id, acting_role_assignment_id, correlation_id
  ) values (
    p_juristic_person_id, 'event:' || v_correlation_id::text, p_actor_id,
    p_event_type, 1, p_aggregate_type, p_aggregate_id, p_version_after,
    coalesce(p_payload, '{}'::jsonb), 'core.record_transition_and_event',
    coalesce(p_occurred_at, now()), 'person', p_actor_id,
    p_acting_role_assignment_id, v_correlation_id
  );
  insert into audit.outbox_messages (
    juristic_person_id, business_key, created_by_person_id,
    domain_event_id, destination, publication_state
  )
  select p_juristic_person_id, 'outbox:' || e.id::text || ':notification', p_actor_id,
         e.id, 'notification', 'pending'
  from audit.domain_events e
  where e.correlation_id = v_correlation_id;
  return v_correlation_id;
end
$$;
comment on function core.record_transition_and_event(uuid,text,uuid,bigint,bigint,text,text,text,text,jsonb,uuid,uuid,uuid,uuid,uuid,timestamptz) is 'Internal atomic transition, domain-event, and outbox recorder.';

revoke all on function core.current_relationship_id(uuid) from public, anon;
grant execute on function core.current_relationship_id(uuid) to authenticated;
revoke all on function core.assert_command_authority(uuid,text,uuid,uuid,text,text,uuid) from public, anon, authenticated;
revoke all on function core.record_human_decision(uuid,text,text,text,text,text,uuid,uuid,text,uuid,uuid[],timestamptz) from public, anon, authenticated;
revoke all on function core.record_transition_and_event(uuid,text,uuid,bigint,bigint,text,text,text,text,jsonb,uuid,uuid,uuid,uuid,uuid,timestamptz) from public, anon, authenticated;

create or replace function api.add_case_to_investigation(
  p_juristic_person_id uuid,
  p_investigation_id uuid,
  p_case_id uuid,
  p_scope_role text,
  p_inclusion_reason text,
  p_expected_investigation_version bigint
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_investigation investigation.investigations%rowtype;
  v_link_id uuid := extensions.gen_random_uuid();
  v_correlation_id uuid;
begin
  if v_person_id is null or not core.has_permission(p_juristic_person_id, 'investigation.manage') then
    raise exception using errcode = '42501', message = 'Investigation management permission is required.';
  end if;
  if nullif(btrim(p_inclusion_reason), '') is null then
    raise exception using errcode = '22023', message = 'A Case inclusion reason is required.';
  end if;
  select * into v_investigation from investigation.investigations i
  where i.id = p_investigation_id and i.juristic_person_id = p_juristic_person_id
  for update;
  if not found then raise exception using errcode = 'P0002', message = 'Investigation was not found.'; end if;
  if v_investigation.row_version <> p_expected_investigation_version then
    raise exception using errcode = '40001', message = 'Investigation changed; reload before associating a Case.';
  end if;
  if not exists (select 1 from intake.cases c where c.id = p_case_id and c.juristic_person_id = p_juristic_person_id) then
    raise exception using errcode = 'P0002', message = 'Case was not found in this organization.';
  end if;
  if exists (
    select 1 from investigation.investigation_cases ic
    where ic.investigation_id = p_investigation_id and ic.case_id = p_case_id
      and ic.recorded_to is null and ic.relationship_state = 'effective'
  ) then
    raise exception using errcode = '23505', message = 'Case is already in the effective Investigation scope.';
  end if;
  perform pg_catalog.set_config('app.change_reason', btrim(p_inclusion_reason), true);
  insert into investigation.investigation_cases (
    id, juristic_person_id, business_key, created_by_person_id,
    investigation_id, case_id, scope_role, inclusion_reason,
    relationship_state, recorded_from
  ) values (
    v_link_id, p_juristic_person_id, 'investigation-case:' || p_investigation_id::text || ':' || p_case_id::text || ':' || v_link_id::text,
    v_person_id, p_investigation_id, p_case_id, coalesce(nullif(btrim(p_scope_role), ''), 'related'),
    btrim(p_inclusion_reason), 'effective', now()
  );
  update investigation.investigations
  set row_version = row_version + 1, updated_at = now(), current_state = 'gathering'
  where id = p_investigation_id;
  v_correlation_id := core.record_transition_and_event(
    p_juristic_person_id, 'Investigation', p_investigation_id,
    v_investigation.row_version, v_investigation.row_version + 1,
    v_investigation.current_state, 'gathering', p_inclusion_reason,
    'CaseAddedToInvestigation', jsonb_build_object('case_id', p_case_id, 'scope_role', p_scope_role),
    v_person_id
  );
  return jsonb_build_object('investigation_case_id', v_link_id, 'correlation_id', v_correlation_id, 'row_version', v_investigation.row_version + 1);
end
$$;
comment on function api.add_case_to_investigation(uuid,uuid,uuid,text,text,bigint) is 'Adds a separate Case to an Investigation scope with a reason; no Incident is inferred or created.';

create or replace function api.verify_incident_from_investigation(
  p_juristic_person_id uuid,
  p_investigation_id uuid,
  p_expected_investigation_version bigint,
  p_known_summary text,
  p_inferred_summary text,
  p_disputed_summary text,
  p_unknown_summary text,
  p_confidence numeric,
  p_decision_outcome text,
  p_decision_rationale text,
  p_expected_consequences text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_evidence_item_ids uuid[] default array[]::uuid[],
  p_occurred_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_investigation investigation.investigations%rowtype;
  v_assessment_id uuid := extensions.gen_random_uuid();
  v_incident_id uuid := extensions.gen_random_uuid();
  v_decision_id uuid;
  v_year text := to_char(timezone('Asia/Bangkok', now()), 'YYYY');
  v_sequence integer;
  v_number text;
  v_assessment_number text;
  v_case record;
  v_association_id uuid;
begin
  select * into v_investigation from investigation.investigations i
  where i.id = p_investigation_id and i.juristic_person_id = p_juristic_person_id
  for update;
  if not found then raise exception using errcode = 'P0002', message = 'Investigation was not found.'; end if;
  if v_investigation.row_version <> p_expected_investigation_version then
    raise exception using errcode = '40001', message = 'Investigation changed; reload before verifying an Incident.';
  end if;
  if nullif(btrim(p_known_summary), '') is null or nullif(btrim(p_decision_outcome), '') is null then
    raise exception using errcode = '22023', message = 'Known understanding and a human Decision outcome are required.';
  end if;
  if p_confidence is not null and (p_confidence < 0 or p_confidence > 1) then
    raise exception using errcode = '22023', message = 'Confidence must be between zero and one.';
  end if;
  perform core.assert_command_authority(
    p_juristic_person_id, 'incident.manage', p_acting_role_assignment_id,
    p_mandate_id, 'incident.verify', 'investigation', p_investigation_id
  );
  perform pg_catalog.set_config('app.change_reason', btrim(p_decision_rationale), true);
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_juristic_person_id::text || ':incident:' || v_year, 0));
  select coalesce(max(right(i.incident_number, 6)::integer), 0) + 1 into v_sequence
  from incident.incidents i
  where i.juristic_person_id = p_juristic_person_id
    and i.incident_number ~ ('^INC-' || v_year || '-[0-9]{6}$');
  v_number := 'INC-' || v_year || '-' || lpad(v_sequence::text, 6, '0');
  v_assessment_number := 'ASM-' || v_year || '-' || lpad(v_sequence::text, 6, '0');

  insert into investigation.understanding_assessments (
    id, juristic_person_id, business_key, created_by_person_id, assessment_number,
    investigation_id, known_summary, inferred_summary, disputed_summary,
    unknown_summary, confidence, recommendation_summary, assessment_status, issued_at
  ) values (
    v_assessment_id, p_juristic_person_id, 'assessment:' || v_assessment_id::text,
    v_person_id, v_assessment_number, p_investigation_id, btrim(p_known_summary),
    nullif(btrim(p_inferred_summary), ''), nullif(btrim(p_disputed_summary), ''),
    nullif(btrim(p_unknown_summary), ''), p_confidence, null,
    'issued', coalesce(p_occurred_at, now())
  );

  insert into investigation.assessment_evidence_links (
    juristic_person_id, business_key, created_by_person_id, assessment_id,
    evidence_item_id, consideration_role, relevance, reliability_assessment
  )
  select p_juristic_person_id,
         'assessment-evidence:' || v_assessment_id::text || ':' || e.id::text,
         v_person_id, v_assessment_id, e.id, 'considered',
         'Considered for Incident verification', 'Not automatically treated as conclusive'
  from evidence.evidence_items e
  where e.juristic_person_id = p_juristic_person_id
    and e.id = any(coalesce(p_evidence_item_ids, array[]::uuid[]));
  if (select count(*) from investigation.assessment_evidence_links where assessment_id = v_assessment_id)
     <> cardinality(coalesce(p_evidence_item_ids, array[]::uuid[])) then
    raise exception using errcode = 'P0002', message = 'One or more Evidence Items were not found in this organization.';
  end if;

  v_decision_id := core.record_human_decision(
    p_juristic_person_id, 'incident_verification',
    'Does the Investigation verify one operational Incident?',
    concat('Investigation ', v_investigation.investigation_number, ': ', p_known_summary),
    p_decision_outcome, p_decision_rationale, p_acting_role_assignment_id,
    p_mandate_id, p_expected_consequences, v_assessment_id,
    p_evidence_item_ids, p_occurred_at
  );

  insert into incident.incidents (
    id, juristic_person_id, business_key, created_by_person_id, incident_number,
    verification_decision_id, verification_assessment_id, verified_at,
    current_state, current_summary, activated_at
  ) values (
    v_incident_id, p_juristic_person_id, 'incident:' || v_incident_id::text,
    v_person_id, v_number, v_decision_id, v_assessment_id,
    coalesce(p_occurred_at, now()), 'active', left(btrim(p_known_summary), 1000),
    coalesce(p_occurred_at, now())
  );

  for v_case in
    select ic.case_id
    from investigation.investigation_cases ic
    where ic.investigation_id = p_investigation_id
      and ic.juristic_person_id = p_juristic_person_id
      and ic.recorded_to is null and ic.relationship_state = 'effective'
  loop
    v_association_id := extensions.gen_random_uuid();
    insert into incident.case_incident_associations (
      id, juristic_person_id, business_key, created_by_person_id, association_code,
      case_id, incident_id, relationship_type, relevance, decision_id, mandate_id,
      assessment_id, relationship_state, recorded_from
    ) values (
      v_association_id, p_juristic_person_id, 'case-incident:' || v_association_id::text,
      v_person_id, 'ASSOC-' || upper(left(replace(v_association_id::text, '-', ''), 12)),
      v_case.case_id, v_incident_id, 'describes_same_verified_event',
      'Included in the verified Investigation scope', v_decision_id, p_mandate_id,
      v_assessment_id, 'effective', coalesce(p_occurred_at, now())
    );
    update intake.cases
    set current_state = 'resolved', resolved_at = coalesce(resolved_at, p_occurred_at, now()),
        row_version = row_version + 1, updated_at = now()
    where id = v_case.case_id and juristic_person_id = p_juristic_person_id;
  end loop;

  update investigation.investigations
  set current_state = 'concluded', concluded_at = coalesce(p_occurred_at, now()),
      row_version = row_version + 1, updated_at = now()
  where id = p_investigation_id;
  perform core.record_transition_and_event(
    p_juristic_person_id, 'Investigation', p_investigation_id,
    v_investigation.row_version, v_investigation.row_version + 1,
    v_investigation.current_state, 'concluded', p_decision_rationale,
    'IncidentVerified', jsonb_build_object('incident_id', v_incident_id, 'incident_number', v_number, 'assessment_id', v_assessment_id, 'decision_id', v_decision_id),
    v_person_id, p_acting_role_assignment_id, v_decision_id, p_mandate_id,
    null, p_occurred_at
  );
  return jsonb_build_object(
    'incident_id', v_incident_id, 'incident_number', v_number,
    'assessment_id', v_assessment_id, 'decision_id', v_decision_id
  );
end
$$;
comment on function api.verify_incident_from_investigation(uuid,uuid,bigint,text,text,text,text,numeric,text,text,text,uuid,uuid,uuid[],timestamptz) is 'Records Operational Truth, an authorized human Decision, one verified Incident, and reasoned Case associations without merging Cases.';

create or replace function api.associate_case_to_incident(
  p_juristic_person_id uuid,
  p_case_id uuid,
  p_incident_id uuid,
  p_assessment_id uuid,
  p_relationship_type text,
  p_relevance text,
  p_decision_rationale text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_evidence_item_ids uuid[] default array[]::uuid[]
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_association_id uuid := extensions.gen_random_uuid();
  v_decision_id uuid;
begin
  if not exists (select 1 from intake.cases where id = p_case_id and juristic_person_id = p_juristic_person_id) then
    raise exception using errcode = 'P0002', message = 'Case was not found in this organization.';
  end if;
  if not exists (select 1 from incident.incidents where id = p_incident_id and juristic_person_id = p_juristic_person_id) then
    raise exception using errcode = 'P0002', message = 'Incident was not found in this organization.';
  end if;
  if not exists (
    select 1 from investigation.understanding_assessments a
    join investigation.investigation_cases ic on ic.investigation_id = a.investigation_id
    where a.id = p_assessment_id and a.juristic_person_id = p_juristic_person_id
      and ic.case_id = p_case_id and ic.recorded_to is null and ic.relationship_state = 'effective'
  ) then
    raise exception using errcode = '22023', message = 'Association requires an Understanding Assessment from an Investigation that includes the Case.';
  end if;
  if exists (
    select 1 from incident.case_incident_associations a
    where a.case_id = p_case_id and a.incident_id = p_incident_id
      and a.recorded_to is null and a.relationship_state = 'effective'
  ) then
    raise exception using errcode = '23505', message = 'Case is already effectively associated with this Incident.';
  end if;
  perform core.assert_command_authority(
    p_juristic_person_id, 'incident.manage', p_acting_role_assignment_id,
    p_mandate_id, 'incident.associate', 'incident', p_incident_id
  );
  perform pg_catalog.set_config('app.change_reason', btrim(p_decision_rationale), true);
  v_decision_id := core.record_human_decision(
    p_juristic_person_id, 'case_incident_association',
    'Does this separate Case describe the verified Incident?',
    'Case ' || p_case_id::text || ' and Incident ' || p_incident_id::text,
    coalesce(nullif(btrim(p_relationship_type), ''), 'describes_same_verified_event'),
    p_decision_rationale, p_acting_role_assignment_id, p_mandate_id,
    'The Case remains separate and gains a traceable Incident association.',
    p_assessment_id, p_evidence_item_ids, now()
  );
  insert into incident.case_incident_associations (
    id, juristic_person_id, business_key, created_by_person_id, association_code,
    case_id, incident_id, relationship_type, relevance, decision_id, mandate_id,
    assessment_id, relationship_state, recorded_from
  ) values (
    v_association_id, p_juristic_person_id, 'case-incident:' || v_association_id::text,
    v_person_id, 'ASSOC-' || upper(left(replace(v_association_id::text, '-', ''), 12)),
    p_case_id, p_incident_id, coalesce(nullif(btrim(p_relationship_type), ''), 'describes_same_verified_event'),
    nullif(btrim(p_relevance), ''), v_decision_id, p_mandate_id, p_assessment_id,
    'effective', now()
  );
  perform core.record_transition_and_event(
    p_juristic_person_id, 'Incident', p_incident_id,
    (select row_version from incident.incidents where id = p_incident_id),
    (select row_version from incident.incidents where id = p_incident_id),
    (select current_state from incident.incidents where id = p_incident_id),
    (select current_state from incident.incidents where id = p_incident_id),
    p_decision_rationale, 'CaseAssociatedWithIncident',
    jsonb_build_object('case_id', p_case_id, 'association_id', v_association_id, 'assessment_id', p_assessment_id, 'decision_id', v_decision_id),
    v_person_id, p_acting_role_assignment_id, v_decision_id, p_mandate_id
  );
  return jsonb_build_object('association_id', v_association_id, 'decision_id', v_decision_id);
end
$$;
comment on function api.associate_case_to_incident(uuid,uuid,uuid,uuid,text,text,text,uuid,uuid,uuid[]) is 'Creates one reasoned human association while preserving separate Case and Incident identities.';

create or replace function api.create_operation(
  p_juristic_person_id uuid,
  p_incident_id uuid,
  p_operation_type_term_id uuid,
  p_responsibility_assignment_id uuid,
  p_title text,
  p_scope text,
  p_desired_outcome text,
  p_hazards jsonb,
  p_relationship_type text,
  p_initial_tasks text[],
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_occurred_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_operation_id uuid := extensions.gen_random_uuid();
  v_year text := to_char(timezone('Asia/Bangkok', now()), 'YYYY');
  v_sequence integer;
  v_number text;
  v_task text;
  v_task_index integer := 0;
begin
  if nullif(btrim(p_title), '') is null or nullif(btrim(p_scope), '') is null or nullif(btrim(p_desired_outcome), '') is null then
    raise exception using errcode = '22023', message = 'Operation title, scope, and desired outcome are required.';
  end if;
  if not exists (select 1 from incident.incidents i where i.id = p_incident_id and i.juristic_person_id = p_juristic_person_id and i.current_state <> 'verification_withdrawn') then
    raise exception using errcode = 'P0002', message = 'An active verified Incident is required.';
  end if;
  if not exists (select 1 from taxonomy.taxonomy_terms t where t.id = p_operation_type_term_id and t.juristic_person_id = p_juristic_person_id and t.lifecycle = 'active') then
    raise exception using errcode = 'P0002', message = 'Operation type reference data was not found.';
  end if;
  if not exists (
    select 1 from org.responsibility_assignments r
    where r.id = p_responsibility_assignment_id and r.juristic_person_id = p_juristic_person_id
      and r.recorded_to is null and r.relationship_state = 'effective'
  ) then
    raise exception using errcode = 'P0002', message = 'An effective Responsibility Assignment is required.';
  end if;
  perform core.assert_command_authority(
    p_juristic_person_id, 'operation.manage', p_acting_role_assignment_id,
    p_mandate_id, 'operation.authorize', 'incident', p_incident_id
  );
  perform pg_catalog.set_config('app.change_reason', 'Authorize Operation: ' || btrim(p_title), true);
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_juristic_person_id::text || ':operation:' || v_year, 0));
  select coalesce(max(right(o.operation_number, 6)::integer), 0) + 1 into v_sequence
  from work.operations o
  where o.juristic_person_id = p_juristic_person_id
    and o.operation_number ~ ('^OP-' || v_year || '-[0-9]{6}$');
  v_number := 'OP-' || v_year || '-' || lpad(v_sequence::text, 6, '0');

  insert into work.operations (
    id, juristic_person_id, business_key, created_by_person_id, operation_number,
    operation_type_term_id, title, scope, desired_outcome, hazards,
    responsibility_assignment_id, current_state, proposed_at, authorized_at
  ) values (
    v_operation_id, p_juristic_person_id, 'operation:' || v_operation_id::text,
    v_person_id, v_number, p_operation_type_term_id, btrim(p_title), btrim(p_scope),
    btrim(p_desired_outcome), coalesce(p_hazards, '{}'::jsonb),
    p_responsibility_assignment_id, 'authorized', coalesce(p_occurred_at, now()),
    coalesce(p_occurred_at, now())
  );
  insert into work.incident_operations (
    juristic_person_id, business_key, created_by_person_id, incident_id,
    operation_id, relationship_type, scope_note, relationship_state, recorded_from
  ) values (
    p_juristic_person_id, 'incident-operation:' || p_incident_id::text || ':' || v_operation_id::text,
    v_person_id, p_incident_id, v_operation_id,
    coalesce(nullif(btrim(p_relationship_type), ''), 'responds_to'),
    btrim(p_scope), 'effective', coalesce(p_occurred_at, now())
  );
  foreach v_task in array coalesce(p_initial_tasks, array[]::text[])
  loop
    if nullif(btrim(v_task), '') is not null then
      v_task_index := v_task_index + 1;
      insert into work.work_steps (
        juristic_person_id, business_key, created_by_person_id, operation_id,
        step_code, sequence_hint, title, current_state
      ) values (
        p_juristic_person_id, 'work-step:' || v_operation_id::text || ':' || v_task_index::text,
        v_person_id, v_operation_id, 'STEP-' || lpad(v_task_index::text, 3, '0'),
        v_task_index, btrim(v_task), 'planned'
      );
    end if;
  end loop;
  insert into org.responsibility_ledger_entries (
    juristic_person_id, business_key, created_by_person_id,
    responsibility_assignment_id, entry_type, subject_type, subject_id,
    mandate_id, state_after, occurred_at, reason
  ) values (
    p_juristic_person_id, 'responsibility-ledger:' || extensions.gen_random_uuid()::text,
    v_person_id, p_responsibility_assignment_id, 'operation_authorized',
    'Operation', v_operation_id, p_mandate_id, 'authorized',
    coalesce(p_occurred_at, now()), 'Responsibility attached to authorized Operation'
  );
  perform core.record_transition_and_event(
    p_juristic_person_id, 'Operation', v_operation_id, 0, 1, null, 'authorized',
    'Operation authorized from verified Incident', 'OperationAuthorized',
    jsonb_build_object('operation_number', v_number, 'incident_id', p_incident_id, 'responsibility_assignment_id', p_responsibility_assignment_id),
    v_person_id, p_acting_role_assignment_id, null, p_mandate_id, null, p_occurred_at
  );
  return jsonb_build_object('operation_id', v_operation_id, 'operation_number', v_number, 'task_count', v_task_index);
end
$$;
comment on function api.create_operation(uuid,uuid,uuid,uuid,text,text,text,jsonb,text,text[],uuid,uuid,timestamptz) is 'Authorizes one bounded Operation for a verified Incident with explicit Responsibility and optional initial Tasks.';

create or replace function api.add_operation_task(
  p_juristic_person_id uuid,
  p_operation_id uuid,
  p_expected_operation_version bigint,
  p_title text,
  p_instructions text,
  p_sequence_hint integer
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_operation work.operations%rowtype;
  v_step_id uuid := extensions.gen_random_uuid();
  v_step_code text;
begin
  if v_person_id is null or not core.has_permission(p_juristic_person_id, 'operation.manage') then
    raise exception using errcode = '42501', message = 'Operation management permission is required.';
  end if;
  if nullif(btrim(p_title), '') is null then raise exception using errcode = '22023', message = 'Task title is required.'; end if;
  select * into v_operation from work.operations o
  where o.id = p_operation_id and o.juristic_person_id = p_juristic_person_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'Operation was not found.'; end if;
  if v_operation.row_version <> p_expected_operation_version then raise exception using errcode = '40001', message = 'Operation changed; reload before adding a Task.'; end if;
  if v_operation.current_state in ('awaiting_verification','completed','cancelled') then
    raise exception using errcode = '55000', message = 'Tasks cannot be added in the current Operation state.';
  end if;
  select 'STEP-' || lpad((coalesce(max(sequence_hint), 0) + 1)::text, 3, '0') into v_step_code
  from work.work_steps where operation_id = p_operation_id;
  perform pg_catalog.set_config('app.change_reason', 'Add operational Task: ' || btrim(p_title), true);
  insert into work.work_steps (
    id, juristic_person_id, business_key, created_by_person_id, operation_id,
    step_code, sequence_hint, title, instructions, current_state
  ) values (
    v_step_id, p_juristic_person_id, 'work-step:' || v_step_id::text, v_person_id,
    p_operation_id, v_step_code, coalesce(p_sequence_hint, (select coalesce(max(sequence_hint), 0) + 1 from work.work_steps where operation_id = p_operation_id)),
    btrim(p_title), nullif(btrim(p_instructions), ''), 'planned'
  );
  update work.operations set row_version = row_version + 1, updated_at = now() where id = p_operation_id;
  perform core.record_transition_and_event(
    p_juristic_person_id, 'Operation', p_operation_id, v_operation.row_version,
    v_operation.row_version + 1, v_operation.current_state, v_operation.current_state,
    'Operational Task added', 'OperationalTaskAdded', jsonb_build_object('work_step_id', v_step_id, 'title', btrim(p_title)), v_person_id
  );
  return jsonb_build_object('work_step_id', v_step_id, 'step_code', v_step_code, 'row_version', v_operation.row_version + 1);
end
$$;
comment on function api.add_operation_task(uuid,uuid,bigint,text,text,integer) is 'Adds an Operation-owned executable Task under optimistic concurrency.';

create or replace function api.offer_commitment(
  p_juristic_person_id uuid,
  p_operation_id uuid,
  p_work_step_id uuid,
  p_accepted_by_relationship_id uuid,
  p_scope text,
  p_due_at timestamptz,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_commitment_id uuid := extensions.gen_random_uuid();
  v_year text := to_char(timezone('Asia/Bangkok', now()), 'YYYY');
  v_sequence integer;
  v_number text;
  v_responsibility_id uuid;
begin
  if nullif(btrim(p_scope), '') is null then raise exception using errcode = '22023', message = 'Commitment scope is required.'; end if;
  if not exists (select 1 from work.operations where id = p_operation_id and juristic_person_id = p_juristic_person_id and current_state not in ('completed','cancelled')) then
    raise exception using errcode = 'P0002', message = 'Active Operation was not found.';
  end if;
  if p_work_step_id is not null and not exists (select 1 from work.work_steps where id = p_work_step_id and operation_id = p_operation_id) then
    raise exception using errcode = 'P0002', message = 'Task does not belong to the Operation.';
  end if;
  if not exists (select 1 from org.organization_relationships where id = p_accepted_by_relationship_id and juristic_person_id = p_juristic_person_id and recorded_to is null and relationship_state = 'effective') then
    raise exception using errcode = 'P0002', message = 'Commitment recipient is not an effective organization relationship.';
  end if;
  perform core.assert_command_authority(p_juristic_person_id, 'operation.manage', p_acting_role_assignment_id, p_mandate_id, 'commitment.offer', 'operation', p_operation_id);
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_juristic_person_id::text || ':commitment:' || v_year, 0));
  select count(*) + 1 into v_sequence from work.commitments where juristic_person_id = p_juristic_person_id and commitment_number like 'COM-' || v_year || '-%';
  v_number := 'COM-' || v_year || '-' || lpad(v_sequence::text, 6, '0');
  perform pg_catalog.set_config('app.change_reason', 'Offer Commitment: ' || btrim(p_scope), true);
  insert into work.commitments (
    id, juristic_person_id, business_key, created_by_person_id, commitment_number,
    operation_id, work_step_id, offered_by_person_id, accepted_by_relationship_id,
    scope, due_at, current_state
  ) values (
    v_commitment_id, p_juristic_person_id, 'commitment:' || v_commitment_id::text,
    v_person_id, v_number, p_operation_id, p_work_step_id, v_person_id,
    p_accepted_by_relationship_id, btrim(p_scope), p_due_at, 'offered'
  );
  select responsibility_assignment_id into v_responsibility_id from work.operations where id = p_operation_id;
  insert into org.responsibility_ledger_entries (
    juristic_person_id, business_key, created_by_person_id, responsibility_assignment_id,
    entry_type, subject_type, subject_id, commitment_id, mandate_id, state_after,
    occurred_at, reason
  ) values (
    p_juristic_person_id, 'responsibility-ledger:' || extensions.gen_random_uuid()::text,
    v_person_id, v_responsibility_id, 'commitment_offered', 'Operation', p_operation_id,
    v_commitment_id, p_mandate_id, 'offered', now(), btrim(p_scope)
  );
  return jsonb_build_object('commitment_id', v_commitment_id, 'commitment_number', v_number);
end
$$;
comment on function api.offer_commitment(uuid,uuid,uuid,uuid,text,timestamptz,uuid,uuid) is 'Offers work without claiming it has been accepted; Commitment remains independent from Responsibility and Authority.';

create or replace function api.accept_commitment(
  p_juristic_person_id uuid,
  p_commitment_id uuid,
  p_expected_commitment_version bigint
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_relationship_id uuid := core.current_relationship_id(p_juristic_person_id);
  v_commitment work.commitments%rowtype;
  v_responsibility_id uuid;
begin
  select * into v_commitment from work.commitments c
  where c.id = p_commitment_id and c.juristic_person_id = p_juristic_person_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'Commitment was not found.'; end if;
  if v_commitment.row_version <> p_expected_commitment_version then raise exception using errcode = '40001', message = 'Commitment changed; reload before accepting.'; end if;
  if v_commitment.accepted_by_relationship_id <> v_relationship_id then raise exception using errcode = '42501', message = 'Only the named recipient may accept this Commitment.'; end if;
  if v_commitment.current_state <> 'offered' then raise exception using errcode = '55000', message = 'Only an offered Commitment may be accepted.'; end if;
  if not core.has_permission(p_juristic_person_id, 'operation.accept') then raise exception using errcode = '42501', message = 'Operation acceptance permission is required.'; end if;
  perform pg_catalog.set_config('app.change_reason', 'Accept Commitment ' || v_commitment.commitment_number, true);
  update work.commitments set current_state = 'accepted', accepted_at = now(), row_version = row_version + 1, updated_at = now() where id = p_commitment_id;
  select responsibility_assignment_id into v_responsibility_id from work.operations where id = v_commitment.operation_id;
  insert into org.responsibility_ledger_entries (
    juristic_person_id, business_key, created_by_person_id, responsibility_assignment_id,
    entry_type, subject_type, subject_id, commitment_id, state_after, occurred_at, reason
  ) values (
    p_juristic_person_id, 'responsibility-ledger:' || extensions.gen_random_uuid()::text,
    v_person_id, v_responsibility_id, 'commitment_accepted', 'Operation', v_commitment.operation_id,
    p_commitment_id, 'accepted', now(), 'Named recipient accepted the Commitment'
  );
  return jsonb_build_object('commitment_id', p_commitment_id, 'current_state', 'accepted', 'row_version', v_commitment.row_version + 1);
end
$$;
comment on function api.accept_commitment(uuid,uuid,bigint) is 'Allows only the named effective relationship to accept its offered Commitment.';

create or replace function api.transition_work_step(
  p_juristic_person_id uuid,
  p_work_step_id uuid,
  p_expected_step_version bigint,
  p_to_state text,
  p_reason text,
  p_occurred_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_step work.work_steps%rowtype;
  v_allowed boolean := false;
begin
  select * into v_step from work.work_steps s
  where s.id = p_work_step_id and s.juristic_person_id = p_juristic_person_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'Operational Task was not found.'; end if;
  if v_step.row_version <> p_expected_step_version then raise exception using errcode = '40001', message = 'Task changed; reload before updating.'; end if;
  if not core.can_access_operation(v_step.operation_id) then raise exception using errcode = '42501', message = 'An accepted Commitment or management role is required.'; end if;
  v_allowed := (v_step.current_state = 'planned' and p_to_state in ('in_progress','skipped'))
    or (v_step.current_state = 'in_progress' and p_to_state in ('paused','completed'))
    or (v_step.current_state = 'paused' and p_to_state = 'in_progress');
  if not v_allowed then raise exception using errcode = '22023', message = 'Invalid Operational Task transition.'; end if;
  if nullif(btrim(p_reason), '') is null then raise exception using errcode = '22023', message = 'Transition reason is required.'; end if;
  if p_to_state in ('completed','skipped')
     and not exists (
       select 1 from evidence.evidence_links el
       where el.juristic_person_id = p_juristic_person_id
         and el.target_type = 'work_step' and el.target_id = p_work_step_id
         and el.relationship_state = 'effective'
     )
     and lower(btrim(p_reason)) not like 'evidence_exception:%' then
    raise exception using errcode = '55000', message = 'Completion requires linked Evidence or an explicit evidence_exception reason.';
  end if;
  perform pg_catalog.set_config('app.change_reason', btrim(p_reason), true);
  update work.work_steps
  set current_state = p_to_state, row_version = row_version + 1, updated_at = now(),
      started_at = case when p_to_state = 'in_progress' then coalesce(started_at, p_occurred_at, now()) else started_at end,
      completed_at = case when p_to_state = 'completed' then coalesce(p_occurred_at, now()) else completed_at end,
      skip_reason = case when p_to_state = 'skipped' then btrim(p_reason) else skip_reason end
  where id = p_work_step_id;
  perform core.record_transition_and_event(
    p_juristic_person_id, 'WorkStep', p_work_step_id, v_step.row_version,
    v_step.row_version + 1, v_step.current_state, p_to_state, p_reason,
    'OperationalTask' || replace(initcap(p_to_state), '_', ''),
    jsonb_build_object('operation_id', v_step.operation_id), v_person_id, null, null, null, null, p_occurred_at
  );
  return jsonb_build_object('work_step_id', p_work_step_id, 'current_state', p_to_state, 'row_version', v_step.row_version + 1);
end
$$;
comment on function api.transition_work_step(uuid,uuid,bigint,text,text,timestamptz) is 'Applies the governed Task state machine with Commitment-scoped access and Evidence/exception completion semantics.';

create or replace function api.transition_operation(
  p_juristic_person_id uuid,
  p_operation_id uuid,
  p_expected_operation_version bigint,
  p_to_state text,
  p_reason text,
  p_acting_role_assignment_id uuid default null,
  p_mandate_id uuid default null,
  p_occurred_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_operation work.operations%rowtype;
  v_allowed boolean := false;
  v_management_transition boolean;
begin
  select * into v_operation from work.operations o
  where o.id = p_operation_id and o.juristic_person_id = p_juristic_person_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'Operation was not found.'; end if;
  if v_operation.row_version <> p_expected_operation_version then raise exception using errcode = '40001', message = 'Operation changed; reload before transitioning.'; end if;
  if nullif(btrim(p_reason), '') is null then raise exception using errcode = '22023', message = 'Transition reason is required.'; end if;
  v_allowed := (v_operation.current_state = 'authorized' and p_to_state in ('scheduled','cancelled'))
    or (v_operation.current_state = 'scheduled' and p_to_state = 'in_progress')
    or (v_operation.current_state = 'in_progress' and p_to_state in ('paused','awaiting_verification'))
    or (v_operation.current_state = 'paused' and p_to_state = 'in_progress');
  if not v_allowed then raise exception using errcode = '22023', message = 'Invalid Operation transition; verification is the only path to Completed.'; end if;
  v_management_transition := p_to_state in ('scheduled','cancelled');
  if v_management_transition then
    perform core.assert_command_authority(p_juristic_person_id, 'operation.manage', p_acting_role_assignment_id, p_mandate_id, 'operation.transition', 'operation', p_operation_id);
  elsif not core.can_access_operation(p_operation_id) then
    raise exception using errcode = '42501', message = 'An accepted Commitment or management role is required.';
  end if;
  if p_to_state = 'awaiting_verification' and exists (
    select 1 from work.work_steps s where s.operation_id = p_operation_id and s.current_state not in ('completed','skipped')
  ) then
    raise exception using errcode = '55000', message = 'All Operational Tasks must be completed or explicitly skipped before verification.';
  end if;
  if p_to_state = 'awaiting_verification'
     and not exists (
       select 1 from evidence.evidence_links el
       where el.juristic_person_id = p_juristic_person_id and el.relationship_state = 'effective'
         and ((el.target_type = 'operation' and el.target_id = p_operation_id)
           or (el.target_type = 'work_step' and exists (select 1 from work.work_steps s where s.id = el.target_id and s.operation_id = p_operation_id)))
     )
     and lower(btrim(p_reason)) not like 'evidence_exception:%' then
    raise exception using errcode = '55000', message = 'Verification submission requires Evidence or an explicit evidence_exception reason.';
  end if;
  perform pg_catalog.set_config('app.change_reason', btrim(p_reason), true);
  update work.operations
  set current_state = p_to_state, row_version = row_version + 1, updated_at = now(),
      started_at = case when p_to_state = 'in_progress' then coalesce(started_at, p_occurred_at, now()) else started_at end,
      cancelled_at = case when p_to_state = 'cancelled' then coalesce(p_occurred_at, now()) else cancelled_at end
  where id = p_operation_id;
  perform core.record_transition_and_event(
    p_juristic_person_id, 'Operation', p_operation_id, v_operation.row_version,
    v_operation.row_version + 1, v_operation.current_state, p_to_state,
    p_reason, 'Operation' || replace(initcap(p_to_state), '_', ''),
    '{}'::jsonb, v_person_id, p_acting_role_assignment_id, null, p_mandate_id, null, p_occurred_at
  );
  return jsonb_build_object('operation_id', p_operation_id, 'current_state', p_to_state, 'row_version', v_operation.row_version + 1);
end
$$;
comment on function api.transition_operation(uuid,uuid,bigint,text,text,uuid,uuid,timestamptz) is 'Applies valid Operation transitions; worker execution remains Commitment-scoped and completion remains verification-only.';

create or replace function api.record_operation_verification(
  p_juristic_person_id uuid,
  p_operation_id uuid,
  p_expected_operation_version bigint,
  p_method text,
  p_result text,
  p_limitations text,
  p_remote boolean,
  p_evidence_package_version_id uuid,
  p_decision_rationale text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_occurred_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_relationship_id uuid := core.current_relationship_id(p_juristic_person_id);
  v_operation work.operations%rowtype;
  v_verification_id uuid := extensions.gen_random_uuid();
  v_decision_id uuid;
  v_attempt integer;
  v_number text;
  v_to_state text;
  v_high_risk boolean;
begin
  select * into v_operation from work.operations o
  where o.id = p_operation_id and o.juristic_person_id = p_juristic_person_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'Operation was not found.'; end if;
  if v_operation.row_version <> p_expected_operation_version then raise exception using errcode = '40001', message = 'Operation changed; reload before verification.'; end if;
  if v_operation.current_state <> 'awaiting_verification' then raise exception using errcode = '55000', message = 'Operation is not awaiting verification.'; end if;
  if p_result not in ('passed','failed') then raise exception using errcode = '22023', message = 'Verification result must be passed or failed.'; end if;
  if nullif(btrim(p_method), '') is null or nullif(btrim(p_decision_rationale), '') is null then raise exception using errcode = '22023', message = 'Verification method and rationale are required.'; end if;
  perform core.assert_command_authority(p_juristic_person_id, 'verification.perform', p_acting_role_assignment_id, p_mandate_id, 'operation.verify', 'operation', p_operation_id);
  v_high_risk := lower(coalesce(v_operation.hazards->>'risk_tier', 'routine')) in ('significant','critical');
  if v_high_risk and exists (
    select 1 from work.commitments c
    where c.operation_id = p_operation_id and c.accepted_by_relationship_id = v_relationship_id
      and c.current_state in ('accepted','in_progress','fulfilled')
  ) then
    raise exception using errcode = '42501', message = 'A performer cannot solely verify their own significant or critical work.';
  end if;
  if v_high_risk and p_result = 'passed' and p_evidence_package_version_id is null then
    raise exception using errcode = '55000', message = 'Passed significant or critical verification requires an issued Evidence Package Version.';
  end if;
  if p_evidence_package_version_id is not null and not exists (
    select 1 from evidence.evidence_package_versions pv
    where pv.id = p_evidence_package_version_id and pv.juristic_person_id = p_juristic_person_id and pv.status = 'issued'
  ) then
    raise exception using errcode = 'P0002', message = 'Issued Evidence Package Version was not found.';
  end if;
  select coalesce(max(attempt_number), 0) + 1 into v_attempt from work.verification_records where operation_id = p_operation_id;
  v_number := 'VER-' || replace(v_operation.operation_number, 'OP-', '') || '-' || lpad(v_attempt::text, 2, '0');
  v_to_state := case when p_result = 'passed' then 'completed' else 'in_progress' end;
  perform pg_catalog.set_config('app.change_reason', btrim(p_decision_rationale), true);
  v_decision_id := core.record_human_decision(
    p_juristic_person_id, 'operation_verification',
    'Did the Operation satisfy its desired outcome and verification criteria?',
    v_operation.title || ': ' || v_operation.desired_outcome,
    p_result, p_decision_rationale, p_acting_role_assignment_id, p_mandate_id,
    case when p_result = 'passed' then 'Operation may complete; Incident closure remains separate.' else 'Operation returns to execution with the failed finding preserved.' end,
    null, array[]::uuid[], p_occurred_at
  );
  insert into work.verification_records (
    id, juristic_person_id, business_key, created_by_person_id, verification_number,
    operation_id, attempt_number, verifier_relationship_id, verifier_role_assignment_id,
    method, remote, result, limitations, evidence_package_version_id, decision_id,
    occurred_at, recorded_at
  ) values (
    v_verification_id, p_juristic_person_id, 'verification:' || v_verification_id::text,
    v_person_id, v_number, p_operation_id, v_attempt, v_relationship_id,
    p_acting_role_assignment_id, btrim(p_method), coalesce(p_remote, false), p_result,
    nullif(btrim(p_limitations), ''), p_evidence_package_version_id, v_decision_id,
    coalesce(p_occurred_at, now()), now()
  );
  update work.operations
  set current_state = v_to_state, row_version = row_version + 1, updated_at = now(),
      completed_at = case when p_result = 'passed' then coalesce(p_occurred_at, now()) else null end
  where id = p_operation_id;
  if p_result = 'passed' then
    update work.commitments set current_state = 'fulfilled', row_version = row_version + 1, updated_at = now()
    where operation_id = p_operation_id and current_state in ('accepted','in_progress');
  end if;
  perform core.record_transition_and_event(
    p_juristic_person_id, 'Operation', p_operation_id, v_operation.row_version,
    v_operation.row_version + 1, v_operation.current_state, v_to_state,
    p_decision_rationale, case when p_result = 'passed' then 'OperationVerified' else 'OperationVerificationFailed' end,
    jsonb_build_object('verification_id', v_verification_id, 'decision_id', v_decision_id, 'result', p_result),
    v_person_id, p_acting_role_assignment_id, v_decision_id, p_mandate_id,
    p_evidence_package_version_id, p_occurred_at
  );
  return jsonb_build_object('verification_id', v_verification_id, 'decision_id', v_decision_id, 'operation_state', v_to_state, 'row_version', v_operation.row_version + 1);
end
$$;
comment on function api.record_operation_verification(uuid,uuid,bigint,text,text,text,boolean,uuid,text,uuid,uuid,timestamptz) is 'Records immutable human verification, enforces risk-based separation, and completes or returns the Operation.';

create or replace function api.close_incident(
  p_juristic_person_id uuid,
  p_incident_id uuid,
  p_expected_incident_version bigint,
  p_decision_rationale text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_evidence_item_ids uuid[] default array[]::uuid[],
  p_occurred_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_incident incident.incidents%rowtype;
  v_decision_id uuid;
begin
  select * into v_incident from incident.incidents i
  where i.id = p_incident_id and i.juristic_person_id = p_juristic_person_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'Incident was not found.'; end if;
  if v_incident.row_version <> p_expected_incident_version then raise exception using errcode = '40001', message = 'Incident changed; reload before closure.'; end if;
  if v_incident.current_state not in ('active','monitoring') then raise exception using errcode = '55000', message = 'Only an active or monitoring Incident may close.'; end if;
  if exists (
    select 1 from work.incident_operations io join work.operations o on o.id = io.operation_id
    where io.incident_id = p_incident_id and io.recorded_to is null and io.relationship_state = 'effective'
      and o.current_state not in ('completed','cancelled')
  ) then raise exception using errcode = '55000', message = 'Every linked Operation must be completed or cancelled before Incident closure.'; end if;
  perform core.assert_command_authority(p_juristic_person_id, 'incident.manage', p_acting_role_assignment_id, p_mandate_id, 'incident.close', 'incident', p_incident_id);
  perform pg_catalog.set_config('app.change_reason', btrim(p_decision_rationale), true);
  v_decision_id := core.record_human_decision(
    p_juristic_person_id, 'incident_closure', 'Can the verified Incident be closed?',
    coalesce(v_incident.current_summary, v_incident.incident_number), 'closed',
    p_decision_rationale, p_acting_role_assignment_id, p_mandate_id,
    'Closure preserves all Cases, Operations, Evidence, verification, and prior understanding.',
    v_incident.verification_assessment_id, p_evidence_item_ids, p_occurred_at
  );
  update incident.incidents set current_state = 'closed', closed_at = coalesce(p_occurred_at, now()), row_version = row_version + 1, updated_at = now() where id = p_incident_id;
  perform core.record_transition_and_event(
    p_juristic_person_id, 'Incident', p_incident_id, v_incident.row_version,
    v_incident.row_version + 1, v_incident.current_state, 'closed', p_decision_rationale,
    'IncidentClosed', jsonb_build_object('decision_id', v_decision_id), v_person_id,
    p_acting_role_assignment_id, v_decision_id, p_mandate_id, null, p_occurred_at
  );
  return jsonb_build_object('incident_id', p_incident_id, 'decision_id', v_decision_id, 'current_state', 'closed', 'row_version', v_incident.row_version + 1);
end
$$;
comment on function api.close_incident(uuid,uuid,bigint,text,uuid,uuid,uuid[],timestamptz) is 'Closes an Incident only through an authorized human Decision after linked work is terminal.';

create or replace function api.reopen_incident(
  p_juristic_person_id uuid,
  p_incident_id uuid,
  p_expected_incident_version bigint,
  p_reason_type text,
  p_relationship_to_prior_repair text,
  p_related_case_id uuid,
  p_decision_rationale text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_evidence_item_ids uuid[] default array[]::uuid[],
  p_occurred_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_incident incident.incidents%rowtype;
  v_decision_id uuid;
  v_reopen_id uuid := extensions.gen_random_uuid();
  v_reopen_sequence integer;
  v_close_transition_id uuid;
begin
  select * into v_incident from incident.incidents i where i.id = p_incident_id and i.juristic_person_id = p_juristic_person_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'Incident was not found.'; end if;
  if v_incident.row_version <> p_expected_incident_version then raise exception using errcode = '40001', message = 'Incident changed; reload before reopening.'; end if;
  if v_incident.current_state <> 'closed' then raise exception using errcode = '55000', message = 'Only a closed Incident may be reopened.'; end if;
  if p_reason_type not in ('repair_recurrence','new_evidence','safety','disputed_completion','other') then raise exception using errcode = '22023', message = 'Unsupported Incident reopen reason type.'; end if;
  if p_related_case_id is not null and not exists (select 1 from intake.cases where id = p_related_case_id and juristic_person_id = p_juristic_person_id) then raise exception using errcode = 'P0002', message = 'Related Case was not found.'; end if;
  select id into v_close_transition_id from workflow.state_transitions
  where juristic_person_id = p_juristic_person_id and aggregate_type = 'Incident'
    and aggregate_id = p_incident_id and current_state = 'closed'
  order by occurred_at desc, recorded_at desc limit 1;
  if v_close_transition_id is null then raise exception using errcode = '55000', message = 'Prior Incident closure transition is missing.'; end if;
  perform core.assert_command_authority(p_juristic_person_id, 'incident.manage', p_acting_role_assignment_id, p_mandate_id, 'incident.reopen', 'incident', p_incident_id);
  perform pg_catalog.set_config('app.change_reason', btrim(p_decision_rationale), true);
  v_decision_id := core.record_human_decision(
    p_juristic_person_id, 'incident_reopen', 'Should the closed Incident be reopened?',
    concat('Reason type: ', p_reason_type, '. Relationship to prior repair: ', coalesce(p_relationship_to_prior_repair, 'not stated')),
    'reopen', p_decision_rationale, p_acting_role_assignment_id, p_mandate_id,
    'The prior closure remains immutable and the Incident returns to active work.',
    v_incident.verification_assessment_id, p_evidence_item_ids, p_occurred_at
  );
  select coalesce(max(reopen_sequence), 0) + 1 into v_reopen_sequence from incident.incident_reopens where incident_id = p_incident_id;
  insert into incident.incident_reopens (
    id, juristic_person_id, business_key, created_by_person_id, incident_id,
    reopen_sequence, decision_id, prior_close_transition_id, relationship_to_prior_repair,
    reason_type, occurred_at, recorded_at
  ) values (
    v_reopen_id, p_juristic_person_id, 'incident-reopen:' || v_reopen_id::text,
    v_person_id, p_incident_id, v_reopen_sequence, v_decision_id,
    v_close_transition_id, nullif(btrim(p_relationship_to_prior_repair), ''),
    p_reason_type, coalesce(p_occurred_at, now()), now()
  );
  update incident.incidents set current_state = 'active', closed_at = null, row_version = row_version + 1, updated_at = now() where id = p_incident_id;
  perform core.record_transition_and_event(
    p_juristic_person_id, 'Incident', p_incident_id, v_incident.row_version,
    v_incident.row_version + 1, 'closed', 'active', p_decision_rationale,
    'IncidentReopened', jsonb_build_object('reopen_id', v_reopen_id, 'reason_type', p_reason_type, 'related_case_id', p_related_case_id, 'decision_id', v_decision_id),
    v_person_id, p_acting_role_assignment_id, v_decision_id, p_mandate_id, null, p_occurred_at
  );
  return jsonb_build_object('incident_id', p_incident_id, 'reopen_id', v_reopen_id, 'decision_id', v_decision_id, 'row_version', v_incident.row_version + 1);
end
$$;
comment on function api.reopen_incident(uuid,uuid,bigint,text,text,uuid,text,uuid,uuid,uuid[],timestamptz) is 'Records a human-authorized Reopen or recurrence classification without automatic merging or history overwrite.';

create or replace function api.transfer_responsibility(
  p_juristic_person_id uuid,
  p_responsibility_assignment_id uuid,
  p_to_relationship_id uuid,
  p_summary text,
  p_risk_summary text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_occurred_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_old org.responsibility_assignments%rowtype;
  v_new_id uuid := extensions.gen_random_uuid();
  v_handover_id uuid := extensions.gen_random_uuid();
  v_effective_at timestamptz := coalesce(p_occurred_at, now());
begin
  if nullif(btrim(p_summary), '') is null then raise exception using errcode = '22023', message = 'Responsibility transfer summary is required.'; end if;
  select * into v_old from org.responsibility_assignments r
  where r.id = p_responsibility_assignment_id and r.juristic_person_id = p_juristic_person_id for update;
  if not found or v_old.recorded_to is not null or v_old.relationship_state <> 'effective' then raise exception using errcode = 'P0002', message = 'Effective Responsibility Assignment was not found.'; end if;
  if not exists (select 1 from org.organization_relationships r where r.id = p_to_relationship_id and r.juristic_person_id = p_juristic_person_id and r.recorded_to is null and r.relationship_state = 'effective') then raise exception using errcode = 'P0002', message = 'Successor relationship is not effective.'; end if;
  if v_old.responsible_relationship_id = p_to_relationship_id then raise exception using errcode = '22023', message = 'Successor must differ from the current responsible relationship.'; end if;
  perform core.assert_command_authority(p_juristic_person_id, 'operation.manage', p_acting_role_assignment_id, p_mandate_id, 'responsibility.transfer', v_old.scope_type, v_old.scope_id);
  perform pg_catalog.set_config('app.change_reason', btrim(p_summary), true);
  insert into org.handovers (
    id, juristic_person_id, business_key, created_by_person_id, handover_code,
    from_relationship_id, to_relationship_id, scope_type, scope_id,
    offered_at, accepted_at, summary
  ) values (
    v_handover_id, p_juristic_person_id, 'handover:' || v_handover_id::text,
    v_person_id, 'HND-' || upper(left(replace(v_handover_id::text, '-', ''), 12)),
    v_old.responsible_relationship_id, p_to_relationship_id, v_old.scope_type,
    v_old.scope_id, v_effective_at, v_effective_at, btrim(p_summary)
  );
  insert into org.handover_items (
    juristic_person_id, business_key, created_by_person_id, handover_id,
    item_sequence, subject_type, subject_id, context_summary, risk_summary,
    acknowledgement_state, acknowledged_at
  ) values (
    p_juristic_person_id, 'handover-item:' || v_handover_id::text || ':1', v_person_id,
    v_handover_id, 1, v_old.scope_type, v_old.scope_id, btrim(p_summary),
    nullif(btrim(p_risk_summary), ''), 'accepted', v_effective_at
  );
  update org.responsibility_assignments
  set recorded_to = v_effective_at, relationship_state = 'superseded',
      lifecycle = 'superseded', row_version = row_version + 1, updated_at = now()
  where id = v_old.id;
  insert into org.responsibility_assignments (
    id, juristic_person_id, business_key, created_by_person_id, assignment_code,
    responsibility_definition_id, responsible_relationship_id,
    responsible_role_assignment_id, scope_type, scope_id, supervising_assignment_id,
    relationship_state, recorded_from, supersedes_id
  ) values (
    v_new_id, p_juristic_person_id, 'responsibility-assignment:' || v_new_id::text,
    v_person_id, v_old.assignment_code || '-T' || to_char(v_effective_at, 'YYYYMMDDHH24MISS'),
    v_old.responsibility_definition_id, p_to_relationship_id, null,
    v_old.scope_type, v_old.scope_id, v_old.supervising_assignment_id,
    'effective', v_effective_at, v_old.id
  );
  insert into org.responsibility_ledger_entries (
    juristic_person_id, business_key, created_by_person_id, responsibility_assignment_id,
    entry_type, subject_type, subject_id, mandate_id, state_after, handover_id,
    occurred_at, reason
  ) values
    (p_juristic_person_id, 'responsibility-ledger:' || extensions.gen_random_uuid()::text, v_person_id,
     v_old.id, 'transferred_out', v_old.scope_type, v_old.scope_id, p_mandate_id,
     'superseded', v_handover_id, v_effective_at, btrim(p_summary)),
    (p_juristic_person_id, 'responsibility-ledger:' || extensions.gen_random_uuid()::text, v_person_id,
     v_new_id, 'transferred_in', v_old.scope_type, v_old.scope_id, p_mandate_id,
     'effective', v_handover_id, v_effective_at, btrim(p_summary));
  if v_old.scope_type = 'operation' then
    update work.operations set responsibility_assignment_id = v_new_id, row_version = row_version + 1, updated_at = now() where id = v_old.scope_id and juristic_person_id = p_juristic_person_id;
  elsif v_old.scope_type = 'investigation' then
    update investigation.investigations set responsibility_assignment_id = v_new_id, row_version = row_version + 1, updated_at = now() where id = v_old.scope_id and juristic_person_id = p_juristic_person_id;
  end if;
  perform core.record_transition_and_event(
    p_juristic_person_id, 'ResponsibilityAssignment', v_new_id, v_old.row_version,
    1, 'effective', 'effective', p_summary, 'ResponsibilityTransferred',
    jsonb_build_object('from_assignment_id', v_old.id, 'to_assignment_id', v_new_id, 'handover_id', v_handover_id, 'effective_at', v_effective_at),
    v_person_id, p_acting_role_assignment_id, null, p_mandate_id, null, v_effective_at
  );
  return jsonb_build_object('old_assignment_id', v_old.id, 'new_assignment_id', v_new_id, 'handover_id', v_handover_id, 'effective_at', v_effective_at);
end
$$;
comment on function api.transfer_responsibility(uuid,uuid,uuid,text,text,uuid,uuid,timestamptz) is 'Atomically supersedes and replaces Responsibility at one effective instant with handover and immutable ledger evidence.';

-- Controlled browser commands are executable only by authenticated principals.
-- Each command still resolves the active account, relationship, role assignment,
-- permission, Mandate, tenant, scope, and optimistic version inside the function.
revoke all on function api.add_case_to_investigation(uuid,uuid,uuid,text,text,bigint) from public, anon;
grant execute on function api.add_case_to_investigation(uuid,uuid,uuid,text,text,bigint) to authenticated;

revoke all on function api.verify_incident_from_investigation(uuid,uuid,bigint,text,text,text,text,numeric,text,text,text,uuid,uuid,uuid[],timestamptz) from public, anon;
grant execute on function api.verify_incident_from_investigation(uuid,uuid,bigint,text,text,text,text,numeric,text,text,text,uuid,uuid,uuid[],timestamptz) to authenticated;

revoke all on function api.associate_case_to_incident(uuid,uuid,uuid,uuid,text,text,text,uuid,uuid,uuid[]) from public, anon;
grant execute on function api.associate_case_to_incident(uuid,uuid,uuid,uuid,text,text,text,uuid,uuid,uuid[]) to authenticated;

revoke all on function api.create_operation(uuid,uuid,uuid,uuid,text,text,text,jsonb,text,text[],uuid,uuid,timestamptz) from public, anon;
grant execute on function api.create_operation(uuid,uuid,uuid,uuid,text,text,text,jsonb,text,text[],uuid,uuid,timestamptz) to authenticated;

revoke all on function api.add_operation_task(uuid,uuid,bigint,text,text,integer) from public, anon;
grant execute on function api.add_operation_task(uuid,uuid,bigint,text,text,integer) to authenticated;

revoke all on function api.offer_commitment(uuid,uuid,uuid,uuid,text,timestamptz,uuid,uuid) from public, anon;
grant execute on function api.offer_commitment(uuid,uuid,uuid,uuid,text,timestamptz,uuid,uuid) to authenticated;

revoke all on function api.accept_commitment(uuid,uuid,bigint) from public, anon;
grant execute on function api.accept_commitment(uuid,uuid,bigint) to authenticated;

revoke all on function api.transition_work_step(uuid,uuid,bigint,text,text,timestamptz) from public, anon;
grant execute on function api.transition_work_step(uuid,uuid,bigint,text,text,timestamptz) to authenticated;

revoke all on function api.transition_operation(uuid,uuid,bigint,text,text,uuid,uuid,timestamptz) from public, anon;
grant execute on function api.transition_operation(uuid,uuid,bigint,text,text,uuid,uuid,timestamptz) to authenticated;

revoke all on function api.record_operation_verification(uuid,uuid,bigint,text,text,text,boolean,uuid,text,uuid,uuid,timestamptz) from public, anon;
grant execute on function api.record_operation_verification(uuid,uuid,bigint,text,text,text,boolean,uuid,text,uuid,uuid,timestamptz) to authenticated;

revoke all on function api.close_incident(uuid,uuid,bigint,text,uuid,uuid,uuid[],timestamptz) from public, anon;
grant execute on function api.close_incident(uuid,uuid,bigint,text,uuid,uuid,uuid[],timestamptz) to authenticated;

revoke all on function api.reopen_incident(uuid,uuid,bigint,text,text,uuid,text,uuid,uuid,uuid[],timestamptz) from public, anon;
grant execute on function api.reopen_incident(uuid,uuid,bigint,text,text,uuid,text,uuid,uuid,uuid[],timestamptz) to authenticated;

revoke all on function api.transfer_responsibility(uuid,uuid,uuid,text,text,uuid,uuid,timestamptz) from public, anon;
grant execute on function api.transfer_responsibility(uuid,uuid,uuid,text,text,uuid,uuid,timestamptz) to authenticated;

-- Evidence intake is browser-writeable only through an issued upload intent.
-- Promotion, quarantine, original-object writes, and digest attestation remain
-- service-role operations performed by the evidence processor.
create unique index if not exists ux_evidence_upload_id
  on evidence.upload_attachments (juristic_person_id, upload_id);

create or replace function core.can_access_evidence_target(
  p_juristic_person_id uuid,
  p_target_type text,
  p_target_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case lower(p_target_type)
    when 'case' then exists (
      select 1 from intake.cases c
      where c.id = p_target_id and c.juristic_person_id = p_juristic_person_id
        and (core.is_case_party(c.id) or core.has_any_role(p_juristic_person_id, array['admin','juristic_manager','juristic_staff','head_technician','technician','auditor']))
    )
    when 'investigation' then exists (
      select 1 from investigation.investigations i
      where i.id = p_target_id and i.juristic_person_id = p_juristic_person_id
        and core.has_any_role(p_juristic_person_id, array['admin','juristic_manager','juristic_staff','head_technician','auditor'])
    )
    when 'incident' then exists (
      select 1 from incident.incidents i
      where i.id = p_target_id and i.juristic_person_id = p_juristic_person_id
        and core.has_any_role(p_juristic_person_id, array['admin','committee','juristic_manager','juristic_staff','head_technician','technician','auditor'])
    )
    when 'operation' then core.can_access_operation(p_target_id)
    when 'workstep' then exists (
      select 1 from work.work_steps s
      where s.id = p_target_id and s.juristic_person_id = p_juristic_person_id
        and core.can_access_operation(s.operation_id)
    )
    else false
  end
$$;
comment on function core.can_access_evidence_target(uuid,text,uuid) is 'Checks Evidence target visibility without granting access from an object path alone.';

create or replace function core.can_upload_intake_object(p_bucket text, p_name text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from evidence.upload_attachments u
    where u.storage_bucket = p_bucket
      and u.storage_object_key = p_name
      and u.juristic_person_id = core.storage_tenant_id(p_name)
      and u.uploader_person_id = core.current_person_id(u.juristic_person_id)
      and u.upload_state = 'initiated'
      and u.scan_state = 'pending'
      and u.promoted_evidence_item_id is null
  )
$$;
comment on function core.can_upload_intake_object(text,text) is 'Allows exactly one pending intake path issued to the current authenticated person.';

create or replace function core.can_read_intake_object(p_bucket text, p_name text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from evidence.upload_attachments u
    where u.storage_bucket = p_bucket
      and u.storage_object_key = p_name
      and u.juristic_person_id = core.storage_tenant_id(p_name)
      and u.uploader_person_id = core.current_person_id(u.juristic_person_id)
      and u.upload_state = 'initiated'
      and u.scan_state = 'pending'
  )
$$;
comment on function core.can_read_intake_object(text,text) is 'Limits intake reads to the issuing uploader before server processing; quarantined bytes are never browser-readable.';

create or replace function api.begin_evidence_upload(
  p_juristic_person_id uuid,
  p_target_type text,
  p_target_id uuid,
  p_original_filename text,
  p_media_type text,
  p_byte_size bigint,
  p_expected_digest text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_upload_id uuid := extensions.gen_random_uuid();
  v_filename text;
  v_object_key text;
begin
  if v_person_id is null or not core.has_permission(p_juristic_person_id, 'evidence.create') then
    raise exception using errcode = '42501', message = 'Evidence creation permission is required.';
  end if;
  if not core.can_access_evidence_target(p_juristic_person_id, p_target_type, p_target_id) then
    raise exception using errcode = '42501', message = 'The Evidence target is not accessible.';
  end if;
  if p_byte_size is null or p_byte_size < 1 or p_byte_size > 52428800 then
    raise exception using errcode = '22023', message = 'Evidence byte size must be between 1 byte and 50 MiB for the trusted processor.';
  end if;
  if lower(coalesce(p_expected_digest, '')) !~ '^[0-9a-f]{64}$' then
    raise exception using errcode = '22023', message = 'A lowercase SHA-256 digest is required.';
  end if;
  if lower(coalesce(p_media_type, '')) not in ('image/jpeg','image/png','image/webp','application/pdf','video/mp4','audio/mpeg','audio/mp4','text/plain') then
    raise exception using errcode = '22023', message = 'The Evidence media type is not allowed.';
  end if;
  v_filename := regexp_replace(coalesce(nullif(btrim(p_original_filename), ''), 'evidence.bin'), '[^A-Za-z0-9._-]+', '_', 'g');
  v_filename := left(v_filename, 160);
  v_object_key := p_juristic_person_id::text || '/' || v_upload_id::text || '/' || v_filename;
  perform pg_catalog.set_config('app.change_reason', 'Governed Evidence upload intent issued', true);
  insert into evidence.upload_attachments (
    juristic_person_id, business_key, created_by_person_id, upload_id,
    storage_bucket, storage_object_key, original_filename, media_type,
    byte_size, expected_digest, uploader_person_id, upload_state, scan_state
  ) values (
    p_juristic_person_id, 'upload:' || v_upload_id::text, v_person_id, v_upload_id::text,
    'o83-evidence-intake', v_object_key, v_filename, lower(p_media_type),
    p_byte_size, lower(p_expected_digest), v_person_id, 'initiated', 'pending'
  );
  return jsonb_build_object(
    'upload_id', v_upload_id,
    'bucket', 'o83-evidence-intake',
    'object_key', v_object_key,
    'expected_digest', lower(p_expected_digest),
    'target_type', lower(p_target_type),
    'target_id', p_target_id
  );
end
$$;
comment on function api.begin_evidence_upload(uuid,text,uuid,text,text,bigint,text) is 'Issues a single private intake path after permission, tenant, target, MIME, size, and digest validation.';

create or replace function api.quarantine_evidence_upload(
  p_juristic_person_id uuid,
  p_upload_id uuid,
  p_observed_digest text,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare v_upload evidence.upload_attachments%rowtype;
begin
  if coalesce(auth.role(), '') <> 'service_role' and session_user not in ('postgres','supabase_admin') then
    raise exception using errcode = '42501', message = 'Evidence quarantine is a trusted server operation.';
  end if;
  if nullif(btrim(p_reason), '') is null then
    raise exception using errcode = '22023', message = 'A quarantine reason is required.';
  end if;
  select * into v_upload from evidence.upload_attachments u
  where u.juristic_person_id = p_juristic_person_id and u.upload_id = p_upload_id::text for update;
  if not found then raise exception using errcode = 'P0002', message = 'Evidence upload was not found.'; end if;
  if v_upload.promoted_evidence_item_id is not null then
    raise exception using errcode = '23514', message = 'Promoted Evidence cannot be quarantined through the intake command.';
  end if;
  perform pg_catalog.set_config('app.change_reason', 'Evidence upload quarantined: ' || btrim(p_reason), true);
  update evidence.upload_attachments
  set observed_digest = lower(nullif(p_observed_digest, '')), upload_state = 'quarantined',
      scan_state = 'quarantined', quarantine_reason = btrim(p_reason),
      row_version = row_version + 1, updated_at = now()
  where id = v_upload.id;
  insert into audit.domain_events (
    juristic_person_id, business_key, created_by_person_id, event_type, schema_version,
    aggregate_type, aggregate_id, aggregate_version, payload, producer,
    occurred_at, actor_kind, correlation_id
  ) values (
    p_juristic_person_id, 'event:evidence-quarantine:' || p_upload_id::text,
    v_upload.uploader_person_id, 'EvidenceUploadQuarantined', 1,
    'EvidenceUpload', v_upload.id, v_upload.row_version + 1,
    jsonb_build_object('reason', btrim(p_reason), 'expected_digest', v_upload.expected_digest, 'observed_digest', lower(nullif(p_observed_digest, ''))),
    'api.quarantine_evidence_upload', now(), 'system', extensions.gen_random_uuid()
  );
  return jsonb_build_object('upload_id', p_upload_id, 'state', 'quarantined');
end
$$;
comment on function api.quarantine_evidence_upload(uuid,uuid,text,text) is 'Service-only quarantine that blocks browser reads and preserves the digest mismatch or scan reason.';

create or replace function api.promote_evidence_upload(
  p_juristic_person_id uuid,
  p_upload_id uuid,
  p_original_object_key text,
  p_observed_digest text,
  p_observed_byte_size bigint,
  p_observed_media_type text,
  p_target_type text,
  p_target_id uuid,
  p_evidence_type text,
  p_link_role core.link_role,
  p_relevance text,
  p_capture_method text,
  p_captured_at timestamptz,
  p_source_device text,
  p_custodian_relationship_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_upload evidence.upload_attachments%rowtype;
  v_evidence_id uuid := extensions.gen_random_uuid();
  v_link_id uuid := extensions.gen_random_uuid();
begin
  if coalesce(auth.role(), '') <> 'service_role' and session_user not in ('postgres','supabase_admin') then
    raise exception using errcode = '42501', message = 'Evidence promotion is a trusted server operation.';
  end if;
  select * into v_upload from evidence.upload_attachments u
  where u.juristic_person_id = p_juristic_person_id and u.upload_id = p_upload_id::text for update;
  if not found then raise exception using errcode = 'P0002', message = 'Evidence upload was not found.'; end if;
  if v_upload.upload_state <> 'initiated' or v_upload.scan_state <> 'pending' or v_upload.promoted_evidence_item_id is not null then
    raise exception using errcode = '23514', message = 'Evidence upload is not eligible for promotion.';
  end if;
  if lower(coalesce(p_observed_digest, '')) <> v_upload.expected_digest
     or p_observed_byte_size <> v_upload.byte_size
     or lower(coalesce(p_observed_media_type, '')) <> v_upload.media_type then
    raise exception using errcode = '23514', message = 'Observed Evidence bytes do not match the issued upload intent.';
  end if;
  if p_original_object_key !~ ('^' || p_juristic_person_id::text || '/[0-9a-f-]+/') then
    raise exception using errcode = '22023', message = 'Promoted Evidence key must remain inside the tenant prefix.';
  end if;
  if not exists (
    select 1 from storage.objects o
    where o.bucket_id = 'o83-evidence-originals' and o.name = p_original_object_key
  ) then
    raise exception using errcode = 'P0002', message = 'Promoted private original object was not found.';
  end if;
  if lower(p_target_type) not in ('case','investigation','incident','operation','workstep') then
    raise exception using errcode = '22023', message = 'Unsupported Evidence target type.';
  end if;
  if p_custodian_relationship_id is not null and not exists (
    select 1 from org.organization_relationships r
    where r.id = p_custodian_relationship_id and r.juristic_person_id = p_juristic_person_id
      and r.recorded_to is null and r.relationship_state = 'effective'
  ) then
    raise exception using errcode = 'P0002', message = 'Evidence custodian relationship is not effective.';
  end if;
  perform pg_catalog.set_config('app.change_reason', 'Digest-verified Evidence promoted from quarantine intake', true);
  insert into evidence.evidence_items (
    id, juristic_person_id, business_key, created_by_person_id, evidence_number,
    evidence_type, original_attachment_id, original_storage_bucket,
    original_storage_object_key, content_digest, byte_size, capture_method,
    captured_at, source_person_id, source_device, custodian_relationship_id,
    access_state, classification
  ) values (
    v_evidence_id, p_juristic_person_id, 'evidence:' || v_evidence_id::text,
    v_upload.uploader_person_id, 'EVD-' || upper(left(replace(v_evidence_id::text, '-', ''), 12)),
    coalesce(nullif(btrim(p_evidence_type), ''), 'attachment'), v_upload.id,
    'o83-evidence-originals', p_original_object_key, lower(p_observed_digest),
    p_observed_byte_size, coalesce(nullif(btrim(p_capture_method), ''), 'governed_upload'),
    coalesce(p_captured_at, v_upload.created_at), v_upload.uploader_person_id,
    nullif(btrim(p_source_device), ''), p_custodian_relationship_id, 'captured', 'confidential'
  );
  insert into evidence.evidence_links (
    id, juristic_person_id, business_key, created_by_person_id, evidence_item_id,
    target_type, target_id, link_role, relevance
  ) values (
    v_link_id, p_juristic_person_id, 'evidence-link:' || v_link_id::text,
    v_upload.uploader_person_id, v_evidence_id, lower(p_target_type), p_target_id,
    coalesce(p_link_role, 'related'::core.link_role), nullif(btrim(p_relevance), '')
  );
  insert into evidence.evidence_integrity_checks (
    juristic_person_id, business_key, created_by_person_id, evidence_item_id,
    check_type, expected_digest, observed_digest, availability_result,
    occurred_at, recorded_at
  ) values (
    p_juristic_person_id, 'integrity:' || extensions.gen_random_uuid()::text,
    v_upload.uploader_person_id, v_evidence_id, 'sha256_and_object_presence',
    v_upload.expected_digest, lower(p_observed_digest), 'available', now(), now()
  );
  insert into evidence.evidence_custody_events (
    juristic_person_id, business_key, created_by_person_id, evidence_item_id,
    to_custodian_id, custody_action, occurred_at, recorded_at
  ) values (
    p_juristic_person_id, 'custody:' || extensions.gen_random_uuid()::text,
    v_upload.uploader_person_id, v_evidence_id, p_custodian_relationship_id,
    'captured_and_promoted', now(), now()
  );
  update evidence.upload_attachments
  set observed_digest = lower(p_observed_digest), upload_state = 'promoted',
      scan_state = 'passed', promoted_evidence_item_id = v_evidence_id,
      disposed_at = now(), row_version = row_version + 1, updated_at = now()
  where id = v_upload.id;
  perform core.record_transition_and_event(
    p_juristic_person_id, 'EvidenceItem', v_evidence_id, 0, 1, null, 'captured',
    'Digest, size, media type, object presence, target, and custody recorded',
    'EvidencePromoted', jsonb_build_object('upload_id', p_upload_id, 'target_type', lower(p_target_type), 'target_id', p_target_id, 'digest', lower(p_observed_digest)),
    v_upload.uploader_person_id, null, null, null, null, now()
  );
  return jsonb_build_object('upload_id', p_upload_id, 'evidence_item_id', v_evidence_id, 'evidence_link_id', v_link_id, 'state', 'captured');
end
$$;
comment on function api.promote_evidence_upload(uuid,uuid,text,text,bigint,text,text,uuid,text,core.link_role,text,text,timestamptz,text,uuid) is 'Service-only promotion after object-byte SHA-256, size, MIME, target, object-presence, custody, and quarantine checks.';

revoke all on function core.can_access_evidence_target(uuid,text,uuid), core.can_upload_intake_object(text,text), core.can_read_intake_object(text,text) from public, anon;
grant execute on function core.can_access_evidence_target(uuid,text,uuid), core.can_upload_intake_object(text,text), core.can_read_intake_object(text,text) to authenticated;
revoke all on function api.begin_evidence_upload(uuid,text,uuid,text,text,bigint,text) from public, anon;
grant execute on function api.begin_evidence_upload(uuid,text,uuid,text,text,bigint,text) to authenticated;
revoke all on function api.quarantine_evidence_upload(uuid,uuid,text,text), api.promote_evidence_upload(uuid,uuid,text,text,bigint,text,text,uuid,text,core.link_role,text,text,timestamptz,text,uuid) from public, anon, authenticated;
grant usage on schema api to service_role;
grant execute on function api.quarantine_evidence_upload(uuid,uuid,text,text), api.promote_evidence_upload(uuid,uuid,text,text,bigint,text,text,uuid,text,core.link_role,text,text,timestamptz,text,uuid) to service_role;

-- Replace path-only Storage authorization with intent- and metadata-backed rules.
drop policy if exists o83_storage_intake_insert on storage.objects;
create policy o83_storage_intake_insert on storage.objects
for insert to authenticated
with check (
  bucket_id = 'o83-evidence-intake'
  and core.can_upload_intake_object(bucket_id, name)
);

drop policy if exists o83_storage_intake_select on storage.objects;
create policy o83_storage_intake_select on storage.objects
for select to authenticated
using (
  bucket_id = 'o83-evidence-intake'
  and core.can_read_intake_object(bucket_id, name)
);

-- Originals, renditions, and governed artifacts are written only by trusted
-- server workflows. service_role bypasses RLS; no browser INSERT policy exists.
drop policy if exists o83_storage_trusted_insert on storage.objects;

create or replace view api.evidence_register
with (security_invoker = true) as
select e.id, e.juristic_person_id, e.evidence_number, e.evidence_type,
       e.content_digest, e.byte_size, e.capture_method, e.captured_at,
       e.source_person_id, e.custodian_relationship_id, e.access_state,
       e.classification, l.id as evidence_link_id, l.target_type,
       l.target_id, l.link_role, l.relevance
from evidence.evidence_items e
left join evidence.evidence_links l
  on l.evidence_item_id = e.id and l.juristic_person_id = e.juristic_person_id
where e.lifecycle <> 'archived';
comment on view api.evidence_register is 'Authorized Evidence metadata and target traceability; object bytes remain private behind Storage RLS.';

grant select on api.evidence_register to authenticated;
