-- O83 Care object privileges paired with RLS.

-- Start from deny-by-default for application roles.
revoke all on all tables in schema iam, org, property, taxonomy, intake,
  investigation, incident, work, evidence, decision, knowledge, workflow,
  notification, governance, ai, audit, analytics, memory, integration
from anon, authenticated;

revoke all on all functions in schema core, iam, org, property, taxonomy, intake,
  investigation, incident, work, evidence, decision, knowledge, workflow,
  notification, governance, ai, audit, analytics, memory, integration
from public, anon, authenticated;

-- Authenticated role can reach tables; RLS determines rows and operations.
grant usage on schema iam, org, property, taxonomy, intake, investigation,
  incident, work, evidence, decision, knowledge, workflow, notification,
  governance, ai, audit, analytics, memory, integration to authenticated;
grant usage on schema api to authenticated;

grant select, insert, update on all tables in schema iam, org, property, taxonomy,
  intake, investigation, incident, work, evidence, decision, knowledge,
  workflow, notification, governance, ai, analytics, memory, integration
to authenticated;

grant select on audit.domain_events, audit.audit_entries to authenticated;
grant select, insert, update on audit.outbox_messages to authenticated;

-- No authoritative table DELETE privilege is granted to authenticated users.
revoke delete on all tables in schema iam, org, property, taxonomy, intake,
  investigation, incident, work, evidence, decision, knowledge, workflow,
  notification, governance, ai, audit, analytics, memory, integration
from authenticated;

grant select on api.current_cases, api.current_incidents, api.operation_queue,
  api.responsibility_chain, api.decision_evolution, api.operational_truth,
  api.current_knowledge, api.resident_case_status, api.active_announcements,
  api.open_compliance_deadlines, api.organization_chart to authenticated;

-- Re-grant only reviewed helper functions after the blanket revoke.
grant execute on function core.current_person_id(uuid), core.current_service_principal_id(uuid),
  core.has_role(uuid,text), core.has_any_role(uuid,text[]), core.is_case_party(uuid),
  core.has_active_mandate(uuid,text,text,uuid), core.current_change_reason(),
  core.storage_tenant_id(text), core.can_read_evidence_object(text,text),
  core.is_ai_service(uuid), core.can_access_operation(uuid) to authenticated;

grant execute on function api.resolve_current_access(),
  api.create_case(uuid,text,text,text,timestamptz),
  api.create_investigation(uuid,uuid,text) to authenticated;

-- Harden future defaults in private schemas. SQL generators must still review every grant.
alter default privileges in schema iam, org, property, taxonomy, intake,
  investigation, incident, work, evidence, decision, knowledge, workflow,
  notification, governance, ai, audit, analytics, memory, integration
revoke all on tables from public, anon, authenticated;

alter default privileges in schema core, iam, org, property, taxonomy, intake,
  investigation, incident, work, evidence, decision, knowledge, workflow,
  notification, governance, ai, audit, analytics, memory, integration
revoke execute on functions from public, anon, authenticated;
