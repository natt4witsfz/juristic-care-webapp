-- O83 Care production-go continuity, notification, reporting, and administration.
-- This forward-only migration preserves the approved domain boundaries and keeps
-- browser access behind reviewed functions, security-invoker views, and RLS.

create or replace function core.notification_responsibility_for_event(
  p_juristic_person_id uuid,
  p_aggregate_type text,
  p_aggregate_id uuid
)
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare v_result uuid;
begin
  if lower(p_aggregate_type) = 'operation' then
    select o.responsibility_assignment_id into v_result
    from work.operations o where o.id = p_aggregate_id and o.juristic_person_id = p_juristic_person_id;
  elsif lower(p_aggregate_type) = 'workstep' then
    select o.responsibility_assignment_id into v_result
    from work.work_steps s join work.operations o on o.id = s.operation_id
    where s.id = p_aggregate_id and s.juristic_person_id = p_juristic_person_id;
  elsif lower(p_aggregate_type) = 'commitment' then
    select o.responsibility_assignment_id into v_result
    from work.commitments c join work.operations o on o.id = c.operation_id
    where c.id = p_aggregate_id and c.juristic_person_id = p_juristic_person_id;
  elsif lower(p_aggregate_type) = 'investigation' then
    select i.responsibility_assignment_id into v_result
    from investigation.investigations i where i.id = p_aggregate_id and i.juristic_person_id = p_juristic_person_id;
  elsif lower(p_aggregate_type) = 'responsibilityassignment' then
    select r.id into v_result from org.responsibility_assignments r
    where r.id = p_aggregate_id and r.juristic_person_id = p_juristic_person_id;
  elsif lower(p_aggregate_type) = 'incident' then
    select r.id into v_result
    from org.responsibility_assignments r
    where r.juristic_person_id = p_juristic_person_id
      and r.scope_type = 'incident' and r.scope_id = p_aggregate_id
      and r.recorded_to is null and r.relationship_state = 'effective'
    order by r.recorded_from desc limit 1;
  elsif lower(p_aggregate_type) = 'evidenceitem' then
    select case lower(l.target_type)
      when 'operation' then (select o.responsibility_assignment_id from work.operations o where o.id = l.target_id)
      when 'investigation' then (select i.responsibility_assignment_id from investigation.investigations i where i.id = l.target_id)
      when 'incident' then (select r.id from org.responsibility_assignments r where r.scope_type = 'incident' and r.scope_id = l.target_id and r.recorded_to is null order by r.recorded_from desc limit 1)
      else null end
    into v_result
    from evidence.evidence_links l
    where l.evidence_item_id = p_aggregate_id and l.juristic_person_id = p_juristic_person_id
    order by l.created_at limit 1;
  end if;
  return v_result;
end
$$;
comment on function core.notification_responsibility_for_event(uuid,text,uuid) is 'Resolves a governed event recipient from explicit Responsibility; returns null instead of guessing.';

create or replace function notification.create_in_app_notification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_responsibility_id uuid;
  v_relationship_id uuid;
  v_intent_id uuid := extensions.gen_random_uuid();
  v_audience_id uuid := extensions.gen_random_uuid();
  v_digest text;
begin
  v_responsibility_id := core.notification_responsibility_for_event(new.juristic_person_id, new.aggregate_type, new.aggregate_id);
  if v_responsibility_id is null then return new; end if;
  select r.responsible_relationship_id into v_relationship_id
  from org.responsibility_assignments r
  where r.id = v_responsibility_id and r.juristic_person_id = new.juristic_person_id;
  if v_relationship_id is null then return new; end if;
  v_digest := encode(extensions.digest(pg_catalog.convert_to(new.payload::text, 'UTF8'), 'sha256'), 'hex');
  insert into notification.notification_intents (
    id, juristic_person_id, business_key, created_by_person_id, source_event_id,
    purpose_code, urgency, template_code, required_acknowledgement,
    responsibility_assignment_id
  ) values (
    v_intent_id, new.juristic_person_id, 'notification-intent:' || new.id::text,
    new.created_by_person_id, new.id, lower(new.event_type),
    case when lower(new.event_type) ~ '(emergency|fire|trapped|failed|quarantined)' then 'critical' else 'normal' end,
    'domain-event-v1', lower(new.event_type) ~ '(responsibilitytransferred|operationverificationfailed|incidentreopened)',
    v_responsibility_id
  ) on conflict do nothing;
  if not found then return new; end if;
  insert into notification.notification_audiences (
    id, juristic_person_id, business_key, created_by_person_id,
    notification_intent_id, organization_relationship_id, channel,
    disclosure_scope, eligibility_state
  ) values (
    v_audience_id, new.juristic_person_id, 'notification-audience:' || new.id::text || ':' || v_relationship_id::text,
    new.created_by_person_id, v_intent_id, v_relationship_id, 'in_app',
    jsonb_build_object('aggregate_type', new.aggregate_type, 'aggregate_id', new.aggregate_id), 'eligible'
  );
  insert into notification.message_renditions (
    juristic_person_id, business_key, created_by_person_id,
    notification_intent_id, audience_id, locale, template_version,
    subject, content_reference, content_digest
  ) values (
    new.juristic_person_id, 'notification-rendition:' || new.id::text || ':en-v1',
    new.created_by_person_id, v_intent_id, v_audience_id, 'en', 'domain-event-v1',
    new.event_type, 'domain-event:' || new.id::text, v_digest
  );
  return new;
end
$$;
comment on function notification.create_in_app_notification() is 'Creates an immutable in-app rendition only when an explicit Responsibility identifies the audience.';

drop trigger if exists trg_domain_events_create_in_app_notification on audit.domain_events;
create trigger trg_domain_events_create_in_app_notification
after insert on audit.domain_events
for each row execute function notification.create_in_app_notification();

create or replace function core.is_notification_audience(p_audience_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from notification.notification_audiences a
    where a.id = p_audience_id
      and a.organization_relationship_id = core.current_relationship_id(a.juristic_person_id)
      and a.eligibility_state = 'eligible'
  )
$$;
comment on function core.is_notification_audience(uuid) is 'Matches a Notification Audience to the current effective organization relationship.';

drop policy if exists o83_notification_recipient_audience_select on notification.notification_audiences;
create policy o83_notification_recipient_audience_select on notification.notification_audiences
for select to authenticated using (core.is_notification_audience(id));

drop policy if exists o83_notification_recipient_intent_select on notification.notification_intents;
create policy o83_notification_recipient_intent_select on notification.notification_intents
for select to authenticated using (
  exists (select 1 from notification.notification_audiences a where a.notification_intent_id = notification_intents.id and core.is_notification_audience(a.id))
);

drop policy if exists o83_notification_recipient_rendition_select on notification.message_renditions;
create policy o83_notification_recipient_rendition_select on notification.message_renditions
for select to authenticated using (core.is_notification_audience(audience_id));

drop policy if exists o83_notification_recipient_delivery_select on notification.delivery_attempts;
create policy o83_notification_recipient_delivery_select on notification.delivery_attempts
for select to authenticated using (core.is_notification_audience(audience_id));

drop policy if exists o83_notification_recipient_ack_select on notification.notification_acknowledgements;
create policy o83_notification_recipient_ack_select on notification.notification_acknowledgements
for select to authenticated using (core.is_notification_audience(audience_id));

create or replace function api.acknowledge_notification(
  p_juristic_person_id uuid,
  p_audience_id uuid,
  p_method text,
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
  v_id uuid;
begin
  if v_person_id is null or v_relationship_id is null or not core.is_notification_audience(p_audience_id) then
    raise exception using errcode = '42501', message = 'Notification acknowledgement is limited to its recipient.';
  end if;
  select a.id into v_id from notification.notification_acknowledgements a
  where a.juristic_person_id = p_juristic_person_id and a.audience_id = p_audience_id
    and a.acknowledging_relationship_id = v_relationship_id limit 1;
  if v_id is null then
    v_id := extensions.gen_random_uuid();
    insert into notification.notification_acknowledgements (
      id, juristic_person_id, business_key, created_by_person_id, audience_id,
      acknowledging_relationship_id, acknowledgement_method, occurred_at
    ) values (
      v_id, p_juristic_person_id, 'notification-ack:' || p_audience_id::text || ':' || v_relationship_id::text,
      v_person_id, p_audience_id, v_relationship_id,
      coalesce(nullif(btrim(p_method), ''), 'in_app'), coalesce(p_occurred_at, now())
    );
  end if;
  return jsonb_build_object('acknowledgement_id', v_id, 'audience_id', p_audience_id, 'state', 'acknowledged');
end
$$;
comment on function api.acknowledge_notification(uuid,uuid,text,timestamptz) is 'Idempotently records the actual recipient relationship acknowledgement.';

create or replace view api.notification_center
with (security_invoker = true) as
select n.id as notification_intent_id, n.juristic_person_id, n.urgency,
       n.purpose_code, n.required_acknowledgement, n.expires_at,
       a.id as audience_id, a.channel, a.organization_relationship_id,
       m.subject, m.content_reference, m.content_digest,
       e.event_type, e.aggregate_type, e.aggregate_id, e.payload, e.occurred_at,
       ack.id as acknowledgement_id, ack.occurred_at as acknowledged_at
from notification.notification_intents n
join notification.notification_audiences a on a.notification_intent_id = n.id
join notification.message_renditions m on m.audience_id = a.id
join audit.domain_events e on e.id = n.source_event_id
left join notification.notification_acknowledgements ack on ack.audience_id = a.id;
comment on view api.notification_center is 'Responsibility-routed in-app notifications with immutable source event, rendition digest, and acknowledgement.';

-- Immutable offline envelopes retain exact payload, digest, occurred time,
-- recorded time, expected version, and explicit conflict outcome.
create table integration.inbound_message_payloads (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null references org.juristic_persons(id),
  inbound_message_id uuid not null unique references integration.inbound_messages(id),
  payload jsonb not null,
  content_digest text not null,
  created_at timestamptz not null default now(),
  created_by_person_id uuid references org.people(id),
  constraint ck_inbound_payload_digest check (content_digest ~ '^[0-9a-f]{64}$')
);
comment on table integration.inbound_message_payloads is 'Immutable offline payload paired one-to-one with its idempotent inbound envelope.';
alter table integration.inbound_message_payloads enable row level security;
alter table integration.inbound_message_payloads force row level security;
revoke all on integration.inbound_message_payloads from public, anon, authenticated;
create index ix_inbound_payload_tenant_message on integration.inbound_message_payloads (juristic_person_id, inbound_message_id);
create index ix_inbound_payload_created_by on integration.inbound_message_payloads (created_by_person_id);
create policy o83_admin_select_integration_inbound_message_payloads on integration.inbound_message_payloads
for select to authenticated using (core.has_role(juristic_person_id, 'admin'));
create policy o83_manager_select_integration_inbound_message_payloads on integration.inbound_message_payloads
for select to authenticated using (core.has_role(juristic_person_id, 'juristic_manager'));
create trigger trg_integration_inbound_message_payloads_immutable
before update or delete on integration.inbound_message_payloads
for each row execute function core.reject_history_change();
create trigger trg_integration_inbound_message_payloads_audit
after insert or update or delete on integration.inbound_message_payloads
for each row execute function audit.capture_row_change();

create or replace function api.submit_offline_envelope(
  p_juristic_person_id uuid,
  p_external_message_id text,
  p_message_type text,
  p_schema_version text,
  p_payload jsonb,
  p_payload_digest text,
  p_aggregate_type text,
  p_aggregate_id uuid,
  p_expected_version bigint,
  p_occurred_at timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_relationship_id uuid := core.current_relationship_id(p_juristic_person_id);
  v_system_id uuid;
  v_message_id uuid := extensions.gen_random_uuid();
  v_conflict_id uuid;
  v_actual_version bigint;
  v_digest text := encode(extensions.digest(pg_catalog.convert_to(coalesce(p_payload, '{}'::jsonb)::text, 'UTF8'), 'sha256'), 'hex');
begin
  if v_person_id is null or v_relationship_id is null then
    raise exception using errcode = '42501', message = 'An effective authenticated relationship is required.';
  end if;
  if nullif(btrim(p_external_message_id), '') is null or nullif(btrim(p_message_type), '') is null then
    raise exception using errcode = '22023', message = 'Offline message identity and type are required.';
  end if;
  if p_payload_digest is not null and lower(p_payload_digest) <> v_digest then
    raise exception using errcode = '23514', message = 'Offline payload digest does not match the submitted bytes.';
  end if;
  select m.id into v_message_id from integration.inbound_messages m
  join integration.external_systems s on s.id = m.external_system_id
  where s.juristic_person_id = p_juristic_person_id
    and s.system_code = 'offline-client:' || v_relationship_id::text
    and m.external_message_id = p_external_message_id;
  if found then
    return jsonb_build_object('inbound_message_id', v_message_id, 'state', 'duplicate');
  end if;
  select s.id into v_system_id from integration.external_systems s
  where s.juristic_person_id = p_juristic_person_id
    and s.system_code = 'offline-client:' || v_relationship_id::text
    and s.retired_at is null limit 1;
  if v_system_id is null then
    v_system_id := extensions.gen_random_uuid();
    insert into integration.external_systems (
      id, juristic_person_id, business_key, created_by_person_id, system_code,
      name, system_type, owner_relationship_id, trust_level,
      data_classification, activated_at
    ) values (
      v_system_id, p_juristic_person_id, 'external-system:offline:' || v_relationship_id::text,
      v_person_id, 'offline-client:' || v_relationship_id::text,
      'Offline client for relationship ' || v_relationship_id::text, 'offline_client',
      v_relationship_id, 'untrusted_input', 'confidential', now()
    );
  end if;
  if lower(p_aggregate_type) = 'case' then select row_version into v_actual_version from intake.cases where id = p_aggregate_id and juristic_person_id = p_juristic_person_id;
  elsif lower(p_aggregate_type) = 'investigation' then select row_version into v_actual_version from investigation.investigations where id = p_aggregate_id and juristic_person_id = p_juristic_person_id;
  elsif lower(p_aggregate_type) = 'incident' then select row_version into v_actual_version from incident.incidents where id = p_aggregate_id and juristic_person_id = p_juristic_person_id;
  elsif lower(p_aggregate_type) = 'operation' then select row_version into v_actual_version from work.operations where id = p_aggregate_id and juristic_person_id = p_juristic_person_id;
  elsif lower(p_aggregate_type) = 'workstep' then select row_version into v_actual_version from work.work_steps where id = p_aggregate_id and juristic_person_id = p_juristic_person_id;
  else raise exception using errcode = '22023', message = 'Unsupported offline aggregate type.';
  end if;
  if v_actual_version is null then raise exception using errcode = 'P0002', message = 'Offline command aggregate was not found in this organization.'; end if;
  v_message_id := extensions.gen_random_uuid();
  insert into integration.inbound_messages (
    id, juristic_person_id, business_key, created_by_person_id, external_system_id,
    external_message_id, message_type, schema_version, payload_reference,
    payload_digest, validation_state, processing_state, occurred_at
  ) values (
    v_message_id, p_juristic_person_id, 'inbound:' || v_system_id::text || ':' || p_external_message_id,
    v_person_id, v_system_id, p_external_message_id, btrim(p_message_type),
    coalesce(nullif(btrim(p_schema_version), ''), '1'), 'database:integration.inbound_message_payloads',
    v_digest, 'valid', case when v_actual_version = p_expected_version then 'pending' else 'conflict' end,
    p_occurred_at
  );
  insert into integration.inbound_message_payloads (
    juristic_person_id, inbound_message_id, payload, content_digest, created_by_person_id
  ) values (p_juristic_person_id, v_message_id, p_payload, v_digest, v_person_id);
  if v_actual_version is distinct from p_expected_version then
    v_conflict_id := extensions.gen_random_uuid();
    insert into integration.sync_conflicts (
      id, juristic_person_id, business_key, created_by_person_id, conflict_number,
      external_system_id, inbound_message_id, aggregate_type, aggregate_id,
      expected_version, actual_version, conflict_type, alternatives
    ) values (
      v_conflict_id, p_juristic_person_id, 'sync-conflict:' || v_conflict_id::text,
      v_person_id, 'CNF-' || upper(left(replace(v_conflict_id::text, '-', ''), 12)),
      v_system_id, v_message_id, p_aggregate_type, p_aggregate_id,
      p_expected_version, v_actual_version, 'optimistic_concurrency',
      jsonb_build_array('reload_and_reapply', 'withdraw', 'manager_review')
    );
  end if;
  insert into audit.domain_events (
    juristic_person_id, business_key, created_by_person_id, event_type, schema_version,
    aggregate_type, aggregate_id, aggregate_version, payload, producer,
    occurred_at, actor_kind, actor_id, correlation_id
  ) values (
    p_juristic_person_id, 'event:offline:' || v_message_id::text, v_person_id,
    case when v_conflict_id is null then 'OfflineEnvelopeAccepted' else 'OfflineConflictDetected' end,
    1, p_aggregate_type, p_aggregate_id, v_actual_version,
    jsonb_build_object('inbound_message_id', v_message_id, 'expected_version', p_expected_version, 'actual_version', v_actual_version, 'conflict_id', v_conflict_id),
    'api.submit_offline_envelope', coalesce(p_occurred_at, now()), 'person', v_person_id,
    extensions.gen_random_uuid()
  );
  return jsonb_build_object('inbound_message_id', v_message_id, 'state', case when v_conflict_id is null then 'pending' else 'conflict' end, 'conflict_id', v_conflict_id, 'actual_version', v_actual_version);
end
$$;
comment on function api.submit_offline_envelope(uuid,text,text,text,jsonb,text,text,uuid,bigint,timestamptz) is 'Accepts an idempotent digest-verified offline envelope and creates an explicit optimistic-concurrency conflict instead of overwriting history.';

create or replace view api.offline_submission_status
with (security_invoker = true) as
select m.id, m.juristic_person_id, m.external_message_id, m.message_type,
       m.schema_version, m.payload_digest, m.validation_state, m.processing_state,
       m.result_type, m.result_id, m.quarantine_reason, m.occurred_at, m.recorded_at,
       c.id as conflict_id, c.expected_version, c.actual_version,
       c.conflict_type, c.alternatives, c.conflict_state
from integration.inbound_messages m
left join integration.sync_conflicts c on c.inbound_message_id = m.id;
comment on view api.offline_submission_status is 'Offline envelope acceptance and conflict projection with occurred and recorded time preserved.';

-- Governed Organizational Memory transfer and reproducible report snapshots.
create or replace function api.begin_memory_transfer(
  p_juristic_person_id uuid,
  p_manifest_type text,
  p_scope_definition jsonb,
  p_custodian_relationship_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := core.current_person_id(p_juristic_person_id);
  v_manifest_id uuid := extensions.gen_random_uuid();
  v_object_key text;
begin
  if v_person_id is null or not core.has_permission(p_juristic_person_id, 'report.read')
     or not core.has_any_role(p_juristic_person_id, array['admin','committee','juristic_manager','auditor']) then
    raise exception using errcode = '42501', message = 'Governed Memory transfer permission is required.';
  end if;
  if lower(p_manifest_type) not in ('export','import_validation','report_snapshot','restore_validation') then
    raise exception using errcode = '22023', message = 'Unsupported Memory manifest type.';
  end if;
  if not exists (
    select 1 from org.organization_relationships r
    where r.id = p_custodian_relationship_id and r.juristic_person_id = p_juristic_person_id
      and r.recorded_to is null and r.relationship_state = 'effective'
  ) then raise exception using errcode = 'P0002', message = 'Effective custodian relationship is required.'; end if;
  v_object_key := p_juristic_person_id::text || '/' || v_manifest_id::text || '/manifest.json';
  perform pg_catalog.set_config('app.change_reason', 'Governed Organizational Memory transfer initiated', true);
  insert into memory.memory_manifests (
    id, juristic_person_id, business_key, created_by_person_id, manifest_code,
    manifest_type, scope_definition, as_of_at, schema_catalog_version,
    manifest_state, custodian_relationship_id
  ) values (
    v_manifest_id, p_juristic_person_id, 'memory-manifest:' || v_manifest_id::text,
    v_person_id, 'MEM-' || upper(left(replace(v_manifest_id::text, '-', ''), 12)),
    lower(p_manifest_type), coalesce(p_scope_definition, '{}'::jsonb), now(),
    'o83-care-v2', 'preparing', p_custodian_relationship_id
  );
  return jsonb_build_object('manifest_id', v_manifest_id, 'bucket', 'o83-memory-archive', 'object_key', v_object_key, 'state', 'preparing');
end
$$;
comment on function api.begin_memory_transfer(uuid,text,jsonb,uuid) is 'Creates a governed preparing manifest; export/import bytes require the private server-side Memory workflow.';

create or replace function api.finalize_memory_transfer(
  p_juristic_person_id uuid,
  p_manifest_id uuid,
  p_object_key text,
  p_content_digest text,
  p_items jsonb,
  p_verification_result text,
  p_report_code text default null,
  p_period_start timestamptz default null,
  p_period_end timestamptz default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_manifest memory.memory_manifests%rowtype;
  v_item jsonb;
  v_sequence bigint := 0;
  v_report_id uuid;
begin
  select * into v_manifest from memory.memory_manifests m
  where m.id = p_manifest_id and m.juristic_person_id = p_juristic_person_id for update;
  if not found or v_manifest.manifest_state <> 'preparing' then
    raise exception using errcode = '23514', message = 'Preparing Memory manifest was not found.';
  end if;
  if lower(coalesce(p_content_digest, '')) !~ '^[0-9a-f]{64}$' then
    raise exception using errcode = '22023', message = 'A lowercase SHA-256 manifest digest is required.';
  end if;
  if p_object_key !~ ('^' || p_juristic_person_id::text || '/' || p_manifest_id::text || '/')
     or not exists (select 1 from storage.objects o where o.bucket_id = 'o83-memory-archive' and o.name = p_object_key) then
    raise exception using errcode = 'P0002', message = 'Private Memory archive object was not found at the issued path.';
  end if;
  if jsonb_typeof(coalesce(p_items, '[]'::jsonb)) <> 'array' or jsonb_array_length(coalesce(p_items, '[]'::jsonb)) > 100000 then
    raise exception using errcode = '22023', message = 'Memory manifest items must be a bounded JSON array.';
  end if;
  perform pg_catalog.set_config('app.change_reason', 'Organizational Memory manifest digest verified and sealed', true);
  for v_item in select value from jsonb_array_elements(coalesce(p_items, '[]'::jsonb)) loop
    v_sequence := v_sequence + 1;
    if lower(coalesce(v_item->>'content_digest', '')) !~ '^[0-9a-f]{64}$' then
      raise exception using errcode = '22023', message = 'Every Memory item requires a lowercase SHA-256 digest.';
    end if;
    insert into memory.memory_manifest_items (
      juristic_person_id, business_key, created_by_person_id, memory_manifest_id,
      item_sequence, source_type, source_id, source_version, object_reference,
      content_digest, retention_state, verification_result
    ) values (
      p_juristic_person_id, 'memory-item:' || p_manifest_id::text || ':' || v_sequence::text,
      v_manifest.created_by_person_id, p_manifest_id, v_sequence,
      coalesce(nullif(v_item->>'source_type', ''), 'record'), nullif(v_item->>'source_id', '')::uuid,
      v_item->>'source_version', v_item->>'object_reference', lower(v_item->>'content_digest'),
      v_item->>'retention_state', coalesce(nullif(v_item->>'verification_result', ''), p_verification_result)
    );
  end loop;
  update memory.memory_manifests
  set manifest_state = case when lower(p_verification_result) = 'passed' then 'sealed' else 'verification_failed' end,
      sealed_at = case when lower(p_verification_result) = 'passed' then now() else null end,
      verified_at = now(), content_digest = lower(p_content_digest),
      row_version = row_version + 1, updated_at = now()
  where id = p_manifest_id;
  if nullif(btrim(p_report_code), '') is not null and lower(p_verification_result) = 'passed' then
    v_report_id := extensions.gen_random_uuid();
    insert into analytics.report_snapshots (
      id, juristic_person_id, business_key, created_by_person_id, report_code,
      report_version, period_start, period_end, as_of_at, source_manifest_id,
      content_reference, content_digest, published_by_person_id
    ) values (
      v_report_id, p_juristic_person_id, 'report-snapshot:' || v_report_id::text,
      v_manifest.created_by_person_id, btrim(p_report_code), to_char(now(), 'YYYYMMDDHH24MISS'),
      p_period_start, p_period_end, v_manifest.as_of_at, p_manifest_id,
      'storage://o83-memory-archive/' || p_object_key, lower(p_content_digest),
      v_manifest.created_by_person_id
    );
  end if;
  return jsonb_build_object('manifest_id', p_manifest_id, 'state', case when lower(p_verification_result) = 'passed' then 'sealed' else 'verification_failed' end, 'item_count', v_sequence, 'report_snapshot_id', v_report_id);
end
$$;
comment on function api.finalize_memory_transfer(uuid,uuid,text,text,jsonb,text,text,timestamptz,timestamptz) is 'Service-only seal of a private digest-verified Memory archive and optional reproducible report snapshot.';

drop trigger if exists trg_memory_memory_manifest_items_immutable on memory.memory_manifest_items;
create trigger trg_memory_memory_manifest_items_immutable
before update or delete on memory.memory_manifest_items
for each row execute function core.reject_history_change();

drop trigger if exists trg_analytics_report_snapshots_immutable on analytics.report_snapshots;
create trigger trg_analytics_report_snapshots_immutable
before update or delete on analytics.report_snapshots
for each row execute function core.reject_history_change();

create or replace function core.protect_completed_memory_manifest()
returns trigger
language plpgsql
security invoker
set search_path = pg_catalog
as $$
begin
  if tg_op = 'DELETE' or old.manifest_state in ('sealed', 'verification_failed') then
    raise exception 'Completed Organizational Memory manifests are immutable';
  end if;
  return new;
end
$$;
comment on function core.protect_completed_memory_manifest() is 'Allows a preparing manifest to be finalized once, then preserves the completed Organizational Memory record.';

drop trigger if exists trg_memory_memory_manifests_completed_immutable on memory.memory_manifests;
create trigger trg_memory_memory_manifests_completed_immutable
before update or delete on memory.memory_manifests
for each row execute function core.protect_completed_memory_manifest();

create or replace view api.governed_reports
with (security_invoker = true) as
select r.id, r.juristic_person_id, r.report_code, r.report_version,
       r.period_start, r.period_end, r.as_of_at, r.source_manifest_id,
       r.content_reference, r.content_digest, r.published_by_person_id,
       r.restates_snapshot_id, r.created_at
from analytics.report_snapshots r;
comment on view api.governed_reports is 'Immutable report snapshots with source manifest, as-of time, digest, publisher, and restatement lineage.';

create or replace view api.memory_transfer_catalog
with (security_invoker = true) as
select m.id, m.juristic_person_id, m.manifest_code, m.manifest_type,
       m.scope_definition, m.as_of_at, m.schema_catalog_version,
       m.manifest_state, m.sealed_at, m.verified_at, m.content_digest,
       m.custodian_relationship_id, count(i.id) as item_count
from memory.memory_manifests m
left join memory.memory_manifest_items i on i.memory_manifest_id = m.id
group by m.id;
comment on view api.memory_transfer_catalog is 'Governed Organizational Memory exports, import validations, reports, and restore validations.';

-- Administration commands preserve Authority, Mandate, audit, event, and history.
create or replace function api.set_account_state(
  p_juristic_person_id uuid,
  p_user_account_id uuid,
  p_expected_version bigint,
  p_new_state text,
  p_reason text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare v_account iam.user_accounts%rowtype; v_person_id uuid := core.current_person_id(p_juristic_person_id);
begin
  if nullif(btrim(p_reason), '') is null then raise exception using errcode = '22023', message = 'Account state reason is required.'; end if;
  select * into v_account from iam.user_accounts a where a.id = p_user_account_id and a.juristic_person_id = p_juristic_person_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'User account was not found.'; end if;
  if v_account.row_version <> p_expected_version then raise exception using errcode = '40001', message = 'User account changed; reload before updating.'; end if;
  if p_new_state not in ('invited','active','suspended','disabled') then raise exception using errcode = '22023', message = 'Unsupported account state.'; end if;
  perform core.assert_command_authority(p_juristic_person_id, 'permission.manage', p_acting_role_assignment_id, p_mandate_id, 'administration.account_state', 'user_account', p_user_account_id);
  perform pg_catalog.set_config('app.change_reason', btrim(p_reason), true);
  update iam.user_accounts set account_state = p_new_state,
    disabled_at = case when p_new_state in ('suspended','disabled') then now() else null end,
    row_version = row_version + 1, updated_at = now() where id = p_user_account_id;
  perform core.record_transition_and_event(p_juristic_person_id, 'UserAccount', p_user_account_id,
    v_account.row_version, v_account.row_version + 1, v_account.account_state::text, p_new_state::text,
    p_reason, 'UserAccountStateChanged', jsonb_build_object('reason', p_reason), v_person_id,
    p_acting_role_assignment_id, null, p_mandate_id, null, now());
  return jsonb_build_object('user_account_id', p_user_account_id, 'state', p_new_state, 'row_version', v_account.row_version + 1);
end
$$;
comment on function api.set_account_state(uuid,uuid,bigint,text,text,uuid,uuid) is 'Mandate-bound account lifecycle command; Auth provider actions remain a separate trusted workflow.';

create or replace view api.administration_directory
with (security_invoker = true) as
select p.id as person_id, p.juristic_person_id, p.display_name,
       r.id as organization_relationship_id, r.relationship_state,
       a.id as user_account_id, a.account_state, a.row_version as account_row_version,
       rd.role_code, rd.name as role_name, ra.id as role_assignment_id,
       ra.recorded_from as role_started_at, ra.recorded_to as role_ended_at
from org.people p
join org.organization_relationships r on r.person_id = p.id
left join iam.user_accounts a on a.person_id = p.id and a.juristic_person_id = p.juristic_person_id
left join org.role_assignments ra on ra.organization_relationship_id = r.id and ra.recorded_to is null
left join org.role_definitions rd on rd.id = ra.role_definition_id;
comment on view api.administration_directory is 'RLS-filtered people, effective relationships, account state, and role assignments without Auth secrets.';

-- Operational projections keep UI reads traceable while preserving source tables.
create or replace view api.investigation_workspace
with (security_invoker = true) as
select i.id, i.juristic_person_id, i.investigation_number, i.question,
       i.current_state, i.opened_at, i.concluded_at, i.responsibility_assignment_id,
       i.row_version, count(distinct ic.case_id) as case_count,
       max(a.issued_at) as latest_assessment_at
from investigation.investigations i
left join investigation.investigation_cases ic on ic.investigation_id = i.id and ic.recorded_to is null
left join investigation.understanding_assessments a on a.investigation_id = i.id and a.assessment_status in ('issued','published')
group by i.id;

create or replace view api.incident_workspace
with (security_invoker = true) as
select i.id, i.juristic_person_id, i.incident_number, i.current_state,
       i.current_summary, i.verified_at, i.closed_at, i.row_version,
       count(distinct ca.case_id) as associated_case_count,
       count(distinct io.operation_id) as operation_count
from incident.incidents i
left join incident.case_incident_associations ca on ca.incident_id = i.id and ca.recorded_to is null
left join work.incident_operations io on io.incident_id = i.id and io.relationship_state = 'effective'
group by i.id;

create or replace view api.operation_workspace
with (security_invoker = true) as
select o.id, o.juristic_person_id, o.operation_number, o.title, o.scope,
       o.desired_outcome, o.hazards, o.current_state, o.responsibility_assignment_id,
       o.proposed_at, o.authorized_at, o.started_at,
       o.completed_at, o.row_version, io.incident_id,
       count(distinct s.id) as task_count,
       count(distinct s.id) filter (where s.current_state in ('completed','skipped')) as terminal_task_count,
       count(distinct c.id) filter (where c.current_state not in ('fulfilled','released','replaced')) as active_commitment_count,
       max(v.occurred_at) as latest_verification_at
from work.operations o
left join work.incident_operations io on io.operation_id = o.id and io.relationship_state = 'effective'
left join work.work_steps s on s.operation_id = o.id
left join work.commitments c on c.operation_id = o.id
left join work.verification_records v on v.operation_id = o.id
group by o.id, io.incident_id;

create or replace view api.operation_tasks
with (security_invoker = true) as
select s.id, s.juristic_person_id, s.operation_id, s.step_code,
       s.sequence_hint, s.title, s.instructions, s.current_state,
       s.started_at, s.completed_at, s.row_version,
       c.id as commitment_id, c.accepted_by_relationship_id,
       c.current_state as commitment_state, c.due_at
from work.work_steps s
left join work.commitments c on c.work_step_id = s.id and c.current_state not in ('released','replaced');

create or replace view api.aggregate_timeline
with (security_invoker = true) as
select t.id, t.juristic_person_id, t.aggregate_type, t.aggregate_id,
       t.aggregate_version_before, t.aggregate_version_after,
       t.previous_state, t.current_state, t.reason, t.decision_id,
       t.mandate_id, t.evidence_package_id, t.occurred_at, t.recorded_at,
       t.correlation_id
from workflow.state_transitions t;

drop policy if exists o83_current_relationship_mandate_select on org.mandates;
create policy o83_current_relationship_mandate_select on org.mandates
for select to authenticated using (
  core.current_person_id(juristic_person_id) is not null
  and grantee_relationship_id = core.current_relationship_id(juristic_person_id)
  and lifecycle = 'active' and revoked_at is null
  and valid_from <= now() and (valid_to is null or valid_to > now())
);

create or replace view api.current_authority_context
with (security_invoker = true) as
select ra.juristic_person_id, ra.id as role_assignment_id, rd.role_code,
       m.id as mandate_id, m.mandate_code, m.authority_actions, m.scope_type,
       m.scope_id, m.valid_from, m.valid_to
from org.role_assignments ra
join org.role_definitions rd on rd.id = ra.role_definition_id
join org.organization_relationships rel on rel.id = ra.organization_relationship_id
join org.mandates m on m.grantee_relationship_id = rel.id and m.juristic_person_id = rel.juristic_person_id
where rel.id = core.current_relationship_id(rel.juristic_person_id)
  and rel.recorded_to is null and rel.relationship_state = 'effective'
  and ra.recorded_to is null and ra.relationship_state = 'effective'
  and m.lifecycle = 'active' and m.revoked_at is null
  and m.valid_from <= now() and (m.valid_to is null or m.valid_to > now());
comment on view api.current_authority_context is 'Current caller role-assignment and Mandate choices; permission, action, and exact scope remain independently enforced by commands.';

create or replace view api.case_incident_links
with (security_invoker = true) as
select a.id, a.juristic_person_id, a.case_id, a.incident_id,
       a.assessment_id, a.relationship_type, a.relevance,
       a.decision_id, a.mandate_id, a.relationship_state,
       a.recorded_from, a.recorded_to
from incident.case_incident_associations a;

create or replace view api.reference_options
with (security_invoker = true) as
select r.juristic_person_id, 'responsibility_assignment'::text as option_type,
       r.id as option_id, r.assignment_code as option_code,
       r.scope_type || ':' || r.scope_id::text as option_label
from org.responsibility_assignments r
where r.recorded_to is null and r.relationship_state = 'effective'
union all
select t.juristic_person_id, 'taxonomy_term:' || tx.taxonomy_code,
       t.id, t.term_code, t.canonical_label
from taxonomy.taxonomy_terms t
join taxonomy.taxonomy_versions v on v.id = t.introduced_version_id
join taxonomy.taxonomies tx on tx.id = v.taxonomy_id
where t.lifecycle = 'active' and v.status = 'published'
union all
select rd.juristic_person_id, 'role_definition', rd.id, rd.role_code, rd.name
from org.role_definitions rd
where rd.lifecycle = 'active';
comment on view api.reference_options is 'RLS-filtered identifiers and labels for Responsibility and published taxonomy form choices.';

grant select on api.notification_center, api.offline_submission_status,
  api.governed_reports, api.memory_transfer_catalog, api.administration_directory,
  api.investigation_workspace, api.incident_workspace, api.operation_workspace,
  api.operation_tasks, api.aggregate_timeline, api.current_authority_context,
  api.case_incident_links, api.reference_options to authenticated;

revoke all on function core.notification_responsibility_for_event(uuid,text,uuid), core.is_notification_audience(uuid) from public, anon;
grant execute on function core.is_notification_audience(uuid) to authenticated;
revoke all on function notification.create_in_app_notification() from public, anon, authenticated;
revoke all on function api.acknowledge_notification(uuid,uuid,text,timestamptz),
  api.submit_offline_envelope(uuid,text,text,text,jsonb,text,text,uuid,bigint,timestamptz),
  api.begin_memory_transfer(uuid,text,jsonb,uuid),
  api.set_account_state(uuid,uuid,bigint,text,text,uuid,uuid) from public, anon;
grant execute on function api.acknowledge_notification(uuid,uuid,text,timestamptz),
  api.submit_offline_envelope(uuid,text,text,text,jsonb,text,text,uuid,bigint,timestamptz),
  api.begin_memory_transfer(uuid,text,jsonb,uuid),
  api.set_account_state(uuid,uuid,bigint,text,text,uuid,uuid) to authenticated;
revoke all on function api.finalize_memory_transfer(uuid,uuid,text,text,jsonb,text,text,timestamptz,timestamptz) from public, anon, authenticated;
grant execute on function api.finalize_memory_transfer(uuid,uuid,text,text,jsonb,text,text,timestamptz,timestamptz) to service_role;

create or replace function api.assign_role(
  p_juristic_person_id uuid,
  p_organization_relationship_id uuid,
  p_role_definition_id uuid,
  p_reason text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_effective_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare v_person_id uuid := core.current_person_id(p_juristic_person_id); v_id uuid := extensions.gen_random_uuid();
begin
  if nullif(btrim(p_reason), '') is null then raise exception using errcode = '22023', message = 'Role assignment reason is required.'; end if;
  if not exists (select 1 from org.organization_relationships r where r.id = p_organization_relationship_id and r.juristic_person_id = p_juristic_person_id and r.recorded_to is null and r.relationship_state = 'effective') then
    raise exception using errcode = 'P0002', message = 'Effective organization relationship was not found.';
  end if;
  if not exists (select 1 from org.role_definitions r where r.id = p_role_definition_id and r.juristic_person_id = p_juristic_person_id and r.lifecycle = 'active') then
    raise exception using errcode = 'P0002', message = 'Active role definition was not found.';
  end if;
  if exists (select 1 from org.role_assignments a where a.juristic_person_id = p_juristic_person_id and a.organization_relationship_id = p_organization_relationship_id and a.role_definition_id = p_role_definition_id and a.recorded_to is null and a.relationship_state = 'effective') then
    raise exception using errcode = '23505', message = 'The relationship already holds this effective role.';
  end if;
  perform core.assert_command_authority(p_juristic_person_id, 'permission.manage', p_acting_role_assignment_id, p_mandate_id, 'administration.role_assign', 'organization_relationship', p_organization_relationship_id);
  perform pg_catalog.set_config('app.change_reason', btrim(p_reason), true);
  insert into org.role_assignments (
    id, juristic_person_id, business_key, created_by_person_id,
    organization_relationship_id, role_definition_id, assignment_source_type,
    assignment_source_id, recorded_from
  ) values (
    v_id, p_juristic_person_id, 'role-assignment:' || v_id::text, v_person_id,
    p_organization_relationship_id, p_role_definition_id, 'mandate', p_mandate_id,
    coalesce(p_effective_at, now())
  );
  perform core.record_transition_and_event(p_juristic_person_id, 'RoleAssignment', v_id, 0, 1,
    null, 'effective', p_reason, 'RoleAssigned', jsonb_build_object('organization_relationship_id', p_organization_relationship_id, 'role_definition_id', p_role_definition_id),
    v_person_id, p_acting_role_assignment_id, null, p_mandate_id, null, coalesce(p_effective_at, now()));
  return jsonb_build_object('role_assignment_id', v_id, 'state', 'effective');
end
$$;
comment on function api.assign_role(uuid,uuid,uuid,text,uuid,uuid,timestamptz) is 'Creates a reasoned Mandate-bound effective role assignment without changing Responsibility or Commitment.';

create or replace function api.end_role_assignment(
  p_juristic_person_id uuid,
  p_role_assignment_id uuid,
  p_expected_version bigint,
  p_reason text,
  p_acting_role_assignment_id uuid,
  p_mandate_id uuid,
  p_effective_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare v_person_id uuid := core.current_person_id(p_juristic_person_id); v_role org.role_assignments%rowtype;
begin
  if nullif(btrim(p_reason), '') is null then raise exception using errcode = '22023', message = 'Role end reason is required.'; end if;
  select * into v_role from org.role_assignments r where r.id = p_role_assignment_id and r.juristic_person_id = p_juristic_person_id for update;
  if not found or v_role.recorded_to is not null then raise exception using errcode = 'P0002', message = 'Effective role assignment was not found.'; end if;
  if v_role.row_version <> p_expected_version then raise exception using errcode = '40001', message = 'Role assignment changed; reload before ending it.'; end if;
  perform core.assert_command_authority(p_juristic_person_id, 'permission.manage', p_acting_role_assignment_id, p_mandate_id, 'administration.role_end', 'role_assignment', p_role_assignment_id);
  perform pg_catalog.set_config('app.change_reason', btrim(p_reason), true);
  update org.role_assignments set recorded_to = coalesce(p_effective_at, now()), relationship_state = 'ended',
    lifecycle = 'inactive', row_version = row_version + 1, updated_at = now() where id = p_role_assignment_id;
  perform core.record_transition_and_event(p_juristic_person_id, 'RoleAssignment', p_role_assignment_id,
    v_role.row_version, v_role.row_version + 1, 'effective', 'ended', p_reason, 'RoleAssignmentEnded', '{}'::jsonb,
    v_person_id, p_acting_role_assignment_id, null, p_mandate_id, null, coalesce(p_effective_at, now()));
  return jsonb_build_object('role_assignment_id', p_role_assignment_id, 'state', 'ended', 'row_version', v_role.row_version + 1);
end
$$;
comment on function api.end_role_assignment(uuid,uuid,bigint,text,uuid,uuid,timestamptz) is 'Ends an effective role assignment with Authority, Mandate, reason, version check, event, and audit history.';

revoke all on function api.assign_role(uuid,uuid,uuid,text,uuid,uuid,timestamptz), api.end_role_assignment(uuid,uuid,bigint,text,uuid,uuid,timestamptz) from public, anon;
grant execute on function api.assign_role(uuid,uuid,uuid,text,uuid,uuid,timestamptz), api.end_role_assignment(uuid,uuid,bigint,text,uuid,uuid,timestamptz) to authenticated;
