-- O83 Care security-invoker projections.
-- Views do not own truth and obey underlying RLS policies.

create or replace view api.current_cases
with (security_invoker = true) as
select c.id, c.juristic_person_id, c.case_number, c.report_id, c.current_state,
       c.opened_at, c.resolved_at, c.closed_at, c.current_summary,
       c.current_priority_decision_id, c.row_version
from intake.cases c
where c.lifecycle <> 'archived';
comment on view api.current_cases is 'Current Case projection; immutable Report and transition history remain authoritative.';

create or replace view api.current_incidents
with (security_invoker = true) as
select i.id, i.juristic_person_id, i.incident_number, i.current_state,
       i.current_summary, i.verified_at, i.activated_at,
       i.monitoring_started_at, i.closed_at, i.verification_decision_id,
       i.verification_assessment_id, i.row_version
from incident.incidents i
where i.lifecycle <> 'archived';
comment on view api.current_incidents is 'Current verified Incident projection; suspected events remain Investigations.';

create or replace view api.operation_queue
with (security_invoker = true) as
select o.id, o.juristic_person_id, o.operation_number, o.title, o.current_state,
       o.responsibility_assignment_id, o.proposed_at, o.authorized_at,
       o.started_at, o.completed_at, o.row_version
from work.operations o
where o.cancelled_at is null and o.completed_at is null;
comment on view api.operation_queue is 'Active Operation queue projection; Organizational Priority, SLA, and sequence remain separate records.';

create or replace view api.responsibility_chain
with (security_invoker = true) as
select ra.juristic_person_id, ra.id as responsibility_assignment_id,
       ra.assignment_code, ra.scope_type, ra.scope_id,
       ra.responsible_relationship_id, ra.responsible_role_assignment_id,
       le.id as ledger_entry_id, le.entry_type, le.occurred_at,
       le.recorded_at, le.subject_type, le.subject_id, le.commitment_id,
       le.mandate_id, le.decision_id, le.handover_id, le.state_after
from org.responsibility_assignments ra
left join org.responsibility_ledger_entries le
  on le.responsibility_assignment_id = ra.id
 and le.juristic_person_id = ra.juristic_person_id;
comment on view api.responsibility_chain is 'Rebuildable Responsibility Chain over assignments and immutable ledger entries.';

create or replace view api.decision_evolution
with (security_invoker = true) as
select d.juristic_person_id, d.id as decision_id, d.decision_number,
       d.decision_class, d.question, d.outcome, d.rationale, d.decided_at,
       d.decision_status, r.relationship_type,
       r.to_decision_id as related_decision_id, r.effective_at as relationship_effective_at
from decision.decision_records d
left join decision.decision_relationships r
  on r.from_decision_id = d.id and r.juristic_person_id = d.juristic_person_id;
comment on view api.decision_evolution is 'Decision history and typed evolution edges; previous Decisions remain visible.';

create or replace view api.operational_truth
with (security_invoker = true) as
select distinct on (a.investigation_id)
       a.juristic_person_id, a.investigation_id, a.id as assessment_id,
       a.assessment_number, a.known_summary, a.inferred_summary,
       a.disputed_summary, a.unknown_summary, a.confidence,
       a.recommendation_summary, a.issued_at
from investigation.understanding_assessments a
where a.assessment_status in ('issued','published')
order by a.investigation_id, a.issued_at desc nulls last, a.created_at desc;
comment on view api.operational_truth is 'Best current Understanding Assessment; never absolute truth or a mutable fact.';

create or replace view api.current_knowledge
with (security_invoker = true) as
select kr.id, kr.juristic_person_id, kr.knowledge_number, kr.knowledge_type,
       kr.title, kv.id as knowledge_version_id, kv.version_number,
       kv.content, kv.confidence, kv.assumptions, kv.limitations,
       kv.last_verified_at
from knowledge.knowledge_records kr
join knowledge.knowledge_versions kv on kv.id = kr.current_published_version_id
where kv.status = 'published';
comment on view api.current_knowledge is 'Published Knowledge projection; Validity Context must be checked before reuse.';

create or replace view api.resident_case_status
with (security_invoker = true) as
select c.id, c.juristic_person_id, c.case_number, c.current_state,
       c.opened_at, c.resolved_at, c.closed_at, c.current_summary,
       cp.organization_relationship_id, cp.party_role_term_id
from intake.cases c
join intake.case_party_relationships cp on cp.case_id = c.id
where cp.recorded_to is null;
comment on view api.resident_case_status is 'Privacy-limited Case status projection filtered by underlying RLS and party relationships.';

create or replace view api.active_announcements
with (security_invoker = true) as
select a.id, a.juristic_person_id, a.announcement_number, a.title, a.body,
       a.severity, a.audience_roles, a.published_at, a.expires_at,
       a.acknowledgement_required
from notification.announcements a
where a.publication_state = 'published'
  and a.published_at <= now()
  and (a.expires_at is null or a.expires_at > now());
comment on view api.active_announcements is 'Currently published announcements filtered by underlying tenant and role RLS.';

create or replace view api.open_compliance_deadlines
with (security_invoker = true) as
select d.id, d.juristic_person_id, d.deadline_number, d.title, d.description,
       d.source_type, d.source_reference, d.due_at, d.current_state,
       d.responsibility_assignment_id
from governance.compliance_deadlines d
where d.completed_at is null and d.lifecycle = 'active';
comment on view api.open_compliance_deadlines is 'Open compliance deadlines; underlying RLS controls governance visibility.';

create or replace view api.organization_chart
with (security_invoker = true) as
select rel.juristic_person_id, p.id as person_id, p.display_name,
       rel.id as organization_relationship_id, rd.role_code, rd.name as role_name,
       ra.recorded_from as role_started_at
from org.organization_relationships rel
join org.people p on p.id = rel.person_id
join org.role_assignments ra on ra.organization_relationship_id = rel.id
join org.role_definitions rd on rd.id = ra.role_definition_id
where rel.recorded_to is null and rel.relationship_state = 'effective'
  and ra.recorded_to is null and ra.relationship_state = 'effective';
comment on view api.organization_chart is 'Current role chart; historical assignments remain in source tables.';
