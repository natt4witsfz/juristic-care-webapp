-- O83 Care index architecture.
-- Creates indexes for all foreign keys plus high-value operational, temporal,
-- traceability, RLS, search, and queue access paths.

do $$
declare
  r record;
  v_name text;
  v_cols text;
begin
  for r in
    select c.conrelid,
           n.nspname as schema_name,
           t.relname as table_name,
           c.conname,
           c.conkey
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where c.contype = 'f'
      and n.nspname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
  loop
    select string_agg(quote_ident(a.attname), ', ' order by u.ordinality)
      into v_cols
    from unnest(r.conkey) with ordinality u(attnum, ordinality)
    join pg_attribute a on a.attrelid = r.conrelid and a.attnum = u.attnum;
    v_name := left('ix_' || r.schema_name || '_' || r.table_name || '_' || replace(v_cols, ', ', '_'), 63);
    if not exists (
      select 1
      from pg_index i
      where i.indrelid = r.conrelid
        and i.indisvalid
        and i.indisready
        and i.indpred is null
        and (i.indkey::smallint[])[0:cardinality(r.conkey)-1] @> r.conkey
    ) then
      execute format('create index %I on %I.%I (%s)', v_name, r.schema_name, r.table_name, v_cols);
    end if;
  end loop;
end $$;

-- Effective/current relationship indexes.
create index if not exists ix_org_relationships_current_party on org.organization_relationships (juristic_person_id, person_id, external_organization_id, relationship_type_term_id) where recorded_to is null;
create index if not exists ix_org_roles_current on org.role_assignments (juristic_person_id, organization_relationship_id, role_definition_id) where recorded_to is null;
create index if not exists ix_org_role_permissions_current on org.role_permissions (juristic_person_id, role_definition_id, permission_definition_id) where recorded_to is null and relationship_state = 'effective';
create index if not exists ix_org_mandates_active_scope on org.mandates (juristic_person_id, grantee_relationship_id, scope_type, scope_id, valid_from, valid_to) where lifecycle = 'active' and revoked_at is null;
create index if not exists ix_org_responsibility_current_scope on org.responsibility_assignments (juristic_person_id, scope_type, scope_id, responsible_relationship_id) where recorded_to is null;
create index if not exists ix_property_occupancy_current on property.occupancy_relationships (juristic_person_id, room_id, location_id, organization_relationship_id) where recorded_to is null;
create index if not exists ix_property_locations_current_parent on property.locations (juristic_person_id, parent_location_id, location_type_term_id) where recorded_to is null;
create index if not exists ix_asset_relationships_current_from on property.asset_relationships (juristic_person_id, from_asset_id, from_component_id, relationship_type_term_id) where recorded_to is null;

-- Case, Investigation, Incident, and Operation queues.
create index if not exists ix_cases_opened_state on intake.cases (juristic_person_id, current_state, opened_at desc) where closed_at is null;
create index if not exists ix_case_party_current on intake.case_party_relationships (juristic_person_id, case_id, party_role_term_id, organization_relationship_id) where recorded_to is null;
create index if not exists ix_case_context_current on intake.case_context_assertions (juristic_person_id, case_id, assertion_type) where recorded_to is null;
create index if not exists ix_investigations_active on investigation.investigations (juristic_person_id, current_state, responsibility_assignment_id, opened_at) where concluded_at is null;
create index if not exists ix_assessments_current on investigation.understanding_assessments (juristic_person_id, investigation_id, issued_at desc) where assessment_status in ('issued','published');
create index if not exists ix_incidents_active on incident.incidents (juristic_person_id, current_state, verified_at desc) where closed_at is null;
create index if not exists ix_case_incident_case on incident.case_incident_associations (juristic_person_id, case_id, recorded_from desc);
create index if not exists ix_case_incident_incident on incident.case_incident_associations (juristic_person_id, incident_id, recorded_from desc);
create index if not exists ix_operations_active on work.operations (juristic_person_id, current_state, responsibility_assignment_id, proposed_at) where completed_at is null and cancelled_at is null;
create index if not exists ix_commitments_active_due on work.commitments (juristic_person_id, accepted_by_relationship_id, current_state, due_at) where current_state not in ('fulfilled','released','replaced');
create index if not exists ix_sla_active_due on work.sla_applications (juristic_person_id, current_clock_state, due_at) where satisfied_at is null and breached_at is null;

-- History and traceability.
create index if not exists ix_responsibility_ledger_timeline on org.responsibility_ledger_entries (juristic_person_id, responsibility_assignment_id, occurred_at, recorded_at);
create index if not exists ix_observations_timeline on investigation.observations (juristic_person_id, investigation_id, occurred_at, recorded_at);
create index if not exists ix_state_transitions_aggregate on workflow.state_transitions (juristic_person_id, aggregate_type, aggregate_id, aggregate_version_after);
create index if not exists ix_domain_events_aggregate on audit.domain_events (juristic_person_id, aggregate_type, aggregate_id, aggregate_version);
create index if not exists ix_domain_events_correlation on audit.domain_events (juristic_person_id, correlation_id, occurred_at);
create index if not exists ix_audit_target_time on audit.audit_entries (juristic_person_id, target_type, target_id, occurred_at desc);
create index if not exists ix_audit_principal_time on audit.audit_entries (juristic_person_id, principal_kind, principal_id, occurred_at desc);

-- Evidence, notification, integration, and AI queues.
create unique index if not exists ux_evidence_original_object on evidence.evidence_items (original_storage_bucket, original_storage_object_key);
create index if not exists ix_evidence_digest on evidence.evidence_items (juristic_person_id, content_digest);
create index if not exists ix_evidence_links_target on evidence.evidence_links (juristic_person_id, target_type, target_id, link_role);
create index if not exists ix_evidence_integrity_failures on evidence.evidence_integrity_checks (juristic_person_id, occurred_at desc) where availability_result <> 'available' or observed_digest is distinct from expected_digest;
create index if not exists ix_notification_pending on notification.notification_intents (juristic_person_id, lifecycle, expires_at) where lifecycle in ('active','draft');
create index if not exists ix_announcements_active on notification.announcements (juristic_person_id, published_at desc, expires_at) where publication_state = 'published';
create index if not exists ix_compliance_deadlines_open on governance.compliance_deadlines (juristic_person_id, due_at, current_state) where completed_at is null;
create index if not exists ix_delivery_retry on notification.delivery_attempts (juristic_person_id, result, occurred_at) where result not in ('delivered','suppressed');
create unique index if not exists ux_delivery_idempotency on notification.delivery_attempts (juristic_person_id, idempotency_key);
create index if not exists ix_outbox_pending on audit.outbox_messages (publication_state, next_attempt_at, created_at) where publication_state in ('pending','retry');
create index if not exists ix_inbound_pending on integration.inbound_messages (juristic_person_id, processing_state, recorded_at) where processing_state in ('pending','failed');
create index if not exists ix_sync_conflicts_open on integration.sync_conflicts (juristic_person_id, conflict_state, created_at) where conflict_state = 'open';
create index if not exists ix_ai_reviews_pending on ai.ai_recommendations (juristic_person_id, review_state, generated_at) where review_state = 'pending';

-- Authorized search support. Similarity is advisory only.
create index if not exists ix_people_display_name_trgm on org.people using gin (display_name extensions.gin_trgm_ops);
create index if not exists ix_external_org_name_trgm on org.external_organizations using gin (legal_name extensions.gin_trgm_ops);
create index if not exists ix_location_name_trgm on property.locations using gin (name extensions.gin_trgm_ops);
create index if not exists ix_asset_code_trgm on property.assets using gin (asset_code extensions.gin_trgm_ops);
create index if not exists ix_report_text_trgm on intake.reports using gin (submitted_text extensions.gin_trgm_ops);
create index if not exists ix_knowledge_content_fts on knowledge.knowledge_versions using gin (to_tsvector('simple', content));

comment on index intake.ix_report_text_trgm is 'Advisory Report similarity search; must never automatically merge Cases.';
