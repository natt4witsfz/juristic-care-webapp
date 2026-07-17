-- O83 Care foreign keys, unique rules, and check constraints.
-- Helper functions are internal, idempotent, and not exposed to application roles.

create or replace function core.ensure_fk(p_table regclass, p_name text, p_column text, p_target regclass, p_target_column text default 'id')
returns void language plpgsql set search_path = pg_catalog, core as $$
begin
  if not exists (select 1 from pg_constraint where conrelid = p_table and conname = p_name) then
    execute format('alter table %s add constraint %I foreign key (%I) references %s(%I) on delete restrict', p_table, p_name, p_column, p_target, p_target_column);
  end if;
end $$;
comment on function core.ensure_fk(regclass,text,text,regclass,text) is 'Internal idempotent migration helper for O83 foreign keys.';
revoke all on function core.ensure_fk(regclass,text,text,regclass,text) from public, anon, authenticated;

do $$
declare r record; c_name text;
begin
  for r in
    select format('%I.%I', schemaname, tablename)::regclass as rel, schemaname, tablename
    from pg_tables
    where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
      and not (schemaname = 'org' and tablename = 'juristic_persons')
  loop
    c_name := left('fk_' || r.schemaname || '_' || r.tablename || '_juristic_person', 63);
    perform core.ensure_fk(r.rel, c_name, 'juristic_person_id', 'org.juristic_persons'::regclass, 'id');
  end loop;
end $$;

select core.ensure_fk('iam.user_accounts'::regclass, 'fk_iam_user_accounts_auth_user_id', 'auth_user_id', 'auth.users'::regclass, 'id');
select core.ensure_fk('iam.user_accounts'::regclass, 'fk_iam_user_accounts_person_id', 'person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('iam.service_principals'::regclass, 'fk_iam_service_principals_owner_relationship_id', 'owner_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('iam.service_principals'::regclass, 'fk_iam_service_principals_auth_user_id', 'auth_user_id', 'auth.users'::regclass, 'id');
select core.ensure_fk('iam.access_decisions'::regclass, 'fk_iam_access_decisions_policy_version_id', 'policy_version_id', 'governance.policy_versions'::regclass, 'id');
select core.ensure_fk('iam.access_decisions'::regclass, 'fk_iam_access_decisions_mandate_id', 'mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('org.juristic_persons'::regclass, 'fk_org_juristic_persons_successor_juristic_person_id', 'successor_juristic_person_id', 'org.juristic_persons'::regclass, 'id');
select core.ensure_fk('org.people'::regclass, 'fk_org_people_merged_into_person_id', 'merged_into_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('org.external_organizations'::regclass, 'fk_org_external_organizations_successor_organization_id', 'successor_organization_id', 'org.external_organizations'::regclass, 'id');
select core.ensure_fk('org.organization_relationships'::regclass, 'fk_org_organization_relationships_person_id', 'person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('org.organization_relationships'::regclass, 'fk_org_organization_relationships_external_organization_id', 'external_organization_id', 'org.external_organizations'::regclass, 'id');
select core.ensure_fk('org.organization_relationships'::regclass, 'fk_org_organization_relationships_relationship_type_term_id', 'relationship_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('org.role_assignments'::regclass, 'fk_org_role_assignments_organization_relationship_id', 'organization_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.role_assignments'::regclass, 'fk_org_role_assignments_role_definition_id', 'role_definition_id', 'org.role_definitions'::regclass, 'id');
select core.ensure_fk('org.role_permissions'::regclass, 'fk_org_role_permissions_role_definition_id', 'role_definition_id', 'org.role_definitions'::regclass, 'id');
select core.ensure_fk('org.role_permissions'::regclass, 'fk_org_role_permissions_permission_definition_id', 'permission_definition_id', 'org.permission_definitions'::regclass, 'id');
select core.ensure_fk('org.role_permissions'::regclass, 'fk_org_role_permissions_supersedes_id', 'supersedes_id', 'org.role_permissions'::regclass, 'id');
select core.ensure_fk('org.mandates'::regclass, 'fk_org_mandates_grantee_relationship_id', 'grantee_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.mandates'::regclass, 'fk_org_mandates_grantee_role_assignment_id', 'grantee_role_assignment_id', 'org.role_assignments'::regclass, 'id');
select core.ensure_fk('org.mandates'::regclass, 'fk_org_mandates_parent_mandate_id', 'parent_mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('org.responsibility_assignments'::regclass, 'fk_org_responsibility_assignments_responsibility_definition_id', 'responsibility_definition_id', 'org.responsibility_definitions'::regclass, 'id');
select core.ensure_fk('org.responsibility_assignments'::regclass, 'fk_org_responsibility_assignments_responsible_relationship_id', 'responsible_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.responsibility_assignments'::regclass, 'fk_org_responsibility_assignments_responsible_role_assignment_i', 'responsible_role_assignment_id', 'org.role_assignments'::regclass, 'id');
select core.ensure_fk('org.responsibility_assignments'::regclass, 'fk_org_responsibility_assignments_supervising_assignment_id', 'supervising_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('org.responsibility_ledger_entries'::regclass, 'fk_org_responsibility_ledger_entries_responsibility_assignment_', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('org.responsibility_ledger_entries'::regclass, 'fk_org_responsibility_ledger_entries_mandate_id', 'mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('org.responsibility_ledger_entries'::regclass, 'fk_org_responsibility_ledger_entries_handover_id', 'handover_id', 'org.handovers'::regclass, 'id');
select core.ensure_fk('org.handovers'::regclass, 'fk_org_handovers_from_relationship_id', 'from_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.handovers'::regclass, 'fk_org_handovers_to_relationship_id', 'to_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.handovers'::regclass, 'fk_org_handovers_authority_decision_id', 'authority_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('org.handover_items'::regclass, 'fk_org_handover_items_handover_id', 'handover_id', 'org.handovers'::regclass, 'id');
select core.ensure_fk('org.handover_items'::regclass, 'fk_org_handover_items_acknowledged_by_person_id', 'acknowledged_by_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('org.capability_assertions'::regclass, 'fk_org_capability_assertions_subject_relationship_id', 'subject_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.capability_assertions'::regclass, 'fk_org_capability_assertions_capability_term_id', 'capability_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('org.capability_assertions'::regclass, 'fk_org_capability_assertions_level_term_id', 'level_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('org.capability_assertions'::regclass, 'fk_org_capability_assertions_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('org.availability_periods'::regclass, 'fk_org_availability_periods_subject_relationship_id', 'subject_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('property.buildings'::regclass, 'fk_property_buildings_property_id', 'property_id', 'property.properties'::regclass, 'id');
select core.ensure_fk('property.locations'::regclass, 'fk_property_locations_property_id', 'property_id', 'property.properties'::regclass, 'id');
select core.ensure_fk('property.locations'::regclass, 'fk_property_locations_building_id', 'building_id', 'property.buildings'::regclass, 'id');
select core.ensure_fk('property.locations'::regclass, 'fk_property_locations_parent_location_id', 'parent_location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('property.locations'::regclass, 'fk_property_locations_location_type_term_id', 'location_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('property.location_aliases'::regclass, 'fk_property_location_aliases_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('property.location_aliases'::regclass, 'fk_property_location_aliases_external_system_id', 'external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('property.rooms'::regclass, 'fk_property_rooms_building_id', 'building_id', 'property.buildings'::regclass, 'id');
select core.ensure_fk('property.rooms'::regclass, 'fk_property_rooms_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('property.rooms'::regclass, 'fk_property_rooms_room_type_term_id', 'room_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('property.rooms'::regclass, 'fk_property_rooms_renumbered_from_room_id', 'renumbered_from_room_id', 'property.rooms'::regclass, 'id');
select core.ensure_fk('property.occupancy_relationships'::regclass, 'fk_property_occupancy_relationships_room_id', 'room_id', 'property.rooms'::regclass, 'id');
select core.ensure_fk('property.occupancy_relationships'::regclass, 'fk_property_occupancy_relationships_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('property.occupancy_relationships'::regclass, 'fk_property_occupancy_relationships_organization_relationship_i', 'organization_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('property.occupancy_relationships'::regclass, 'fk_property_occupancy_relationships_occupancy_type_term_id', 'occupancy_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('property.assets'::regclass, 'fk_property_assets_asset_type_id', 'asset_type_id', 'property.asset_types'::regclass, 'id');
select core.ensure_fk('property.assets'::regclass, 'fk_property_assets_primary_location_id', 'primary_location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('property.assets'::regclass, 'fk_property_assets_predecessor_asset_id', 'predecessor_asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.asset_components'::regclass, 'fk_property_asset_components_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.asset_components'::regclass, 'fk_property_asset_components_parent_component_id', 'parent_component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('property.asset_components'::regclass, 'fk_property_asset_components_asset_type_id', 'asset_type_id', 'property.asset_types'::regclass, 'id');
select core.ensure_fk('property.asset_components'::regclass, 'fk_property_asset_components_predecessor_component_id', 'predecessor_component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('property.asset_relationships'::regclass, 'fk_property_asset_relationships_from_asset_id', 'from_asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.asset_relationships'::regclass, 'fk_property_asset_relationships_from_component_id', 'from_component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('property.asset_relationships'::regclass, 'fk_property_asset_relationships_to_asset_id', 'to_asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.asset_relationships'::regclass, 'fk_property_asset_relationships_to_component_id', 'to_component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('property.asset_relationships'::regclass, 'fk_property_asset_relationships_relationship_type_term_id', 'relationship_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('property.asset_identifiers'::regclass, 'fk_property_asset_identifiers_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.asset_identifiers'::regclass, 'fk_property_asset_identifiers_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('property.asset_identifiers'::regclass, 'fk_property_asset_identifiers_external_system_id', 'external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('property.maintenance_plans'::regclass, 'fk_property_maintenance_plans_operation_type_term_id', 'operation_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('property.maintenance_plan_assets'::regclass, 'fk_property_maintenance_plan_assets_maintenance_plan_id', 'maintenance_plan_id', 'property.maintenance_plans'::regclass, 'id');
select core.ensure_fk('property.maintenance_plan_assets'::regclass, 'fk_property_maintenance_plan_assets_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.maintenance_plan_assets'::regclass, 'fk_property_maintenance_plan_assets_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_versions'::regclass, 'fk_taxonomy_taxonomy_versions_taxonomy_id', 'taxonomy_id', 'taxonomy.taxonomies'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_versions'::regclass, 'fk_taxonomy_taxonomy_versions_supersedes_version_id', 'supersedes_version_id', 'taxonomy.taxonomy_versions'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_terms'::regclass, 'fk_taxonomy_taxonomy_terms_taxonomy_id', 'taxonomy_id', 'taxonomy.taxonomies'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_terms'::regclass, 'fk_taxonomy_taxonomy_terms_introduced_version_id', 'introduced_version_id', 'taxonomy.taxonomy_versions'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_terms'::regclass, 'fk_taxonomy_taxonomy_terms_deprecated_version_id', 'deprecated_version_id', 'taxonomy.taxonomy_versions'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_term_relationships'::regclass, 'fk_taxonomy_taxonomy_term_relationships_from_term_id', 'from_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_term_relationships'::regclass, 'fk_taxonomy_taxonomy_term_relationships_to_term_id', 'to_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('intake.cases'::regclass, 'fk_intake_cases_report_id', 'report_id', 'intake.reports'::regclass, 'id');
select core.ensure_fk('intake.case_party_relationships'::regclass, 'fk_intake_case_party_relationships_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('intake.case_party_relationships'::regclass, 'fk_intake_case_party_relationships_organization_relationship_id', 'organization_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('intake.case_party_relationships'::regclass, 'fk_intake_case_party_relationships_party_role_term_id', 'party_role_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_room_id', 'room_id', 'property.rooms'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_taxonomy_term_id', 'taxonomy_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_supersedes_id', 'supersedes_id', 'intake.case_context_assertions'::regclass, 'id');
select core.ensure_fk('intake.case_communications'::regclass, 'fk_intake_case_communications_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('intake.case_communications'::regclass, 'fk_intake_case_communications_case_party_relationship_id', 'case_party_relationship_id', 'intake.case_party_relationships'::regclass, 'id');
select core.ensure_fk('intake.case_reopens'::regclass, 'fk_intake_case_reopens_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('intake.case_reopens'::regclass, 'fk_intake_case_reopens_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('intake.case_reopens'::regclass, 'fk_intake_case_reopens_new_evidence_item_id', 'new_evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('intake.case_transfers'::regclass, 'fk_intake_case_transfers_source_case_id', 'source_case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('intake.case_transfers'::regclass, 'fk_intake_case_transfers_source_juristic_person_id', 'source_juristic_person_id', 'org.juristic_persons'::regclass, 'id');
select core.ensure_fk('intake.case_transfers'::regclass, 'fk_intake_case_transfers_destination_juristic_person_id', 'destination_juristic_person_id', 'org.juristic_persons'::regclass, 'id');
select core.ensure_fk('intake.case_transfers'::regclass, 'fk_intake_case_transfers_destination_case_id', 'destination_case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('investigation.investigations'::regclass, 'fk_investigation_investigations_initiating_case_id', 'initiating_case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('investigation.investigations'::regclass, 'fk_investigation_investigations_responsibility_assignment_id', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('investigation.investigations'::regclass, 'fk_investigation_investigations_workflow_instance_id', 'workflow_instance_id', 'workflow.workflow_instances'::regclass, 'id');
select core.ensure_fk('investigation.investigation_cases'::regclass, 'fk_investigation_investigation_cases_investigation_id', 'investigation_id', 'investigation.investigations'::regclass, 'id');
select core.ensure_fk('investigation.investigation_cases'::regclass, 'fk_investigation_investigation_cases_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_investigation_id', 'investigation_id', 'investigation.investigations'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_observer_relationship_id', 'observer_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_correction_of_observation_id', 'correction_of_observation_id', 'investigation.observations'::regclass, 'id');
select core.ensure_fk('investigation.hypotheses'::regclass, 'fk_investigation_hypotheses_investigation_id', 'investigation_id', 'investigation.investigations'::regclass, 'id');
select core.ensure_fk('investigation.hypotheses'::regclass, 'fk_investigation_hypotheses_author_person_id', 'author_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('investigation.hypotheses'::regclass, 'fk_investigation_hypotheses_supersedes_hypothesis_id', 'supersedes_hypothesis_id', 'investigation.hypotheses'::regclass, 'id');
select core.ensure_fk('investigation.hypothesis_evidence_links'::regclass, 'fk_investigation_hypothesis_evidence_links_hypothesis_id', 'hypothesis_id', 'investigation.hypotheses'::regclass, 'id');
select core.ensure_fk('investigation.hypothesis_evidence_links'::regclass, 'fk_investigation_hypothesis_evidence_links_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('investigation.understanding_assessments'::regclass, 'fk_investigation_understanding_assessments_investigation_id', 'investigation_id', 'investigation.investigations'::regclass, 'id');
select core.ensure_fk('investigation.understanding_assessments'::regclass, 'fk_investigation_understanding_assessments_supersedes_assessmen', 'supersedes_assessment_id', 'investigation.understanding_assessments'::regclass, 'id');
select core.ensure_fk('investigation.assessment_evidence_links'::regclass, 'fk_investigation_assessment_evidence_links_assessment_id', 'assessment_id', 'investigation.understanding_assessments'::regclass, 'id');
select core.ensure_fk('investigation.assessment_evidence_links'::regclass, 'fk_investigation_assessment_evidence_links_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('incident.incidents'::regclass, 'fk_incident_incidents_verification_decision_id', 'verification_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('incident.incidents'::regclass, 'fk_incident_incidents_verification_assessment_id', 'verification_assessment_id', 'investigation.understanding_assessments'::regclass, 'id');
select core.ensure_fk('incident.case_incident_associations'::regclass, 'fk_incident_case_incident_associations_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('incident.case_incident_associations'::regclass, 'fk_incident_case_incident_associations_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('incident.case_incident_associations'::regclass, 'fk_incident_case_incident_associations_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('incident.case_incident_associations'::regclass, 'fk_incident_case_incident_associations_mandate_id', 'mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('incident.case_incident_associations'::regclass, 'fk_incident_case_incident_associations_assessment_id', 'assessment_id', 'investigation.understanding_assessments'::regclass, 'id');
select core.ensure_fk('incident.incident_assets'::regclass, 'fk_incident_incident_assets_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('incident.incident_assets'::regclass, 'fk_incident_incident_assets_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('incident.incident_assets'::regclass, 'fk_incident_incident_assets_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('incident.incident_assets'::regclass, 'fk_incident_incident_assets_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('incident.incident_reopens'::regclass, 'fk_incident_incident_reopens_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('incident.incident_reopens'::regclass, 'fk_incident_incident_reopens_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('incident.incident_classifications'::regclass, 'fk_incident_incident_classifications_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('incident.incident_classifications'::regclass, 'fk_incident_incident_classifications_taxonomy_term_id', 'taxonomy_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('incident.incident_classifications'::regclass, 'fk_incident_incident_classifications_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('work.operations'::regclass, 'fk_work_operations_operation_type_term_id', 'operation_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('work.operations'::regclass, 'fk_work_operations_responsibility_assignment_id', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('work.operations'::regclass, 'fk_work_operations_workflow_instance_id', 'workflow_instance_id', 'workflow.workflow_instances'::regclass, 'id');
select core.ensure_fk('work.incident_operations'::regclass, 'fk_work_incident_operations_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('work.incident_operations'::regclass, 'fk_work_incident_operations_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.maintenance_plan_operations'::regclass, 'fk_work_maintenance_plan_operations_maintenance_plan_id', 'maintenance_plan_id', 'property.maintenance_plans'::regclass, 'id');
select core.ensure_fk('work.maintenance_plan_operations'::regclass, 'fk_work_maintenance_plan_operations_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.operation_assets'::regclass, 'fk_work_operation_assets_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.operation_assets'::regclass, 'fk_work_operation_assets_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('work.operation_assets'::regclass, 'fk_work_operation_assets_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('work.operation_assets'::regclass, 'fk_work_operation_assets_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('work.work_steps'::regclass, 'fk_work_work_steps_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.work_steps'::regclass, 'fk_work_work_steps_parent_step_id', 'parent_step_id', 'work.work_steps'::regclass, 'id');
select core.ensure_fk('work.commitments'::regclass, 'fk_work_commitments_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.commitments'::regclass, 'fk_work_commitments_work_step_id', 'work_step_id', 'work.work_steps'::regclass, 'id');
select core.ensure_fk('work.commitments'::regclass, 'fk_work_commitments_offered_by_person_id', 'offered_by_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('work.commitments'::regclass, 'fk_work_commitments_accepted_by_relationship_id', 'accepted_by_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('work.commitments'::regclass, 'fk_work_commitments_replaces_commitment_id', 'replaces_commitment_id', 'work.commitments'::regclass, 'id');
select core.ensure_fk('work.operation_interruptions'::regclass, 'fk_work_operation_interruptions_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.operation_interruptions'::regclass, 'fk_work_operation_interruptions_commitment_id', 'commitment_id', 'work.commitments'::regclass, 'id');
select core.ensure_fk('work.operation_interruptions'::regclass, 'fk_work_operation_interruptions_interrupting_incident_id', 'interrupting_incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('work.operation_interruptions'::regclass, 'fk_work_operation_interruptions_interrupting_operation_id', 'interrupting_operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.verification_records'::regclass, 'fk_work_verification_records_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.verification_records'::regclass, 'fk_work_verification_records_verifier_relationship_id', 'verifier_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('work.verification_records'::regclass, 'fk_work_verification_records_verifier_role_assignment_id', 'verifier_role_assignment_id', 'org.role_assignments'::regclass, 'id');
select core.ensure_fk('work.verification_records'::regclass, 'fk_work_verification_records_evidence_package_version_id', 'evidence_package_version_id', 'evidence.evidence_package_versions'::regclass, 'id');
select core.ensure_fk('work.verification_records'::regclass, 'fk_work_verification_records_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('work.priority_decisions'::regclass, 'fk_work_priority_decisions_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('work.priority_decisions'::regclass, 'fk_work_priority_decisions_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('work.priority_decisions'::regclass, 'fk_work_priority_decisions_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('work.priority_decisions'::regclass, 'fk_work_priority_decisions_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.priority_decisions'::regclass, 'fk_work_priority_decisions_priority_term_id', 'priority_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('work.execution_sequence_entries'::regclass, 'fk_work_execution_sequence_entries_technician_relationship_id', 'technician_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('work.execution_sequence_entries'::regclass, 'fk_work_execution_sequence_entries_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.execution_sequence_entries'::regclass, 'fk_work_execution_sequence_entries_commitment_id', 'commitment_id', 'work.commitments'::regclass, 'id');
select core.ensure_fk('work.execution_sequence_entries'::regclass, 'fk_work_execution_sequence_entries_previous_entry_id', 'previous_entry_id', 'work.execution_sequence_entries'::regclass, 'id');
select core.ensure_fk('work.sla_policies'::regclass, 'fk_work_sla_policies_owner_responsibility_id', 'owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('work.sla_policy_versions'::regclass, 'fk_work_sla_policy_versions_sla_policy_id', 'sla_policy_id', 'work.sla_policies'::regclass, 'id');
select core.ensure_fk('work.sla_policy_versions'::regclass, 'fk_work_sla_policy_versions_service_class_term_id', 'service_class_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('work.sla_policy_versions'::regclass, 'fk_work_sla_policy_versions_supersedes_version_id', 'supersedes_version_id', 'work.sla_policy_versions'::regclass, 'id');
select core.ensure_fk('work.sla_applications'::regclass, 'fk_work_sla_applications_sla_policy_version_id', 'sla_policy_version_id', 'work.sla_policy_versions'::regclass, 'id');
select core.ensure_fk('work.sla_applications'::regclass, 'fk_work_sla_applications_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('work.sla_applications'::regclass, 'fk_work_sla_applications_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.sla_applications'::regclass, 'fk_work_sla_applications_classification_decision_id', 'classification_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('work.sla_clock_events'::regclass, 'fk_work_sla_clock_events_sla_application_id', 'sla_application_id', 'work.sla_applications'::regclass, 'id');
select core.ensure_fk('evidence.upload_attachments'::regclass, 'fk_evidence_upload_attachments_uploader_person_id', 'uploader_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('evidence.upload_attachments'::regclass, 'fk_evidence_upload_attachments_promoted_evidence_item_id', 'promoted_evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_items'::regclass, 'fk_evidence_evidence_items_original_attachment_id', 'original_attachment_id', 'evidence.upload_attachments'::regclass, 'id');
select core.ensure_fk('evidence.evidence_items'::regclass, 'fk_evidence_evidence_items_source_person_id', 'source_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('evidence.evidence_items'::regclass, 'fk_evidence_evidence_items_custodian_relationship_id', 'custodian_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('evidence.evidence_items'::regclass, 'fk_evidence_evidence_items_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('evidence.evidence_renditions'::regclass, 'fk_evidence_evidence_renditions_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_renditions'::regclass, 'fk_evidence_evidence_renditions_parent_rendition_id', 'parent_rendition_id', 'evidence.evidence_renditions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_links'::regclass, 'fk_evidence_evidence_links_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_links'::regclass, 'fk_evidence_evidence_links_rendition_id', 'rendition_id', 'evidence.evidence_renditions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_packages'::regclass, 'fk_evidence_evidence_packages_owner_relationship_id', 'owner_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('evidence.evidence_package_versions'::regclass, 'fk_evidence_evidence_package_versions_evidence_package_id', 'evidence_package_id', 'evidence.evidence_packages'::regclass, 'id');
select core.ensure_fk('evidence.evidence_package_versions'::regclass, 'fk_evidence_evidence_package_versions_compiler_person_id', 'compiler_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('evidence.evidence_package_members'::regclass, 'fk_evidence_evidence_package_members_package_version_id', 'package_version_id', 'evidence.evidence_package_versions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_package_members'::regclass, 'fk_evidence_evidence_package_members_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_package_members'::regclass, 'fk_evidence_evidence_package_members_rendition_id', 'rendition_id', 'evidence.evidence_renditions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_custody_events'::regclass, 'fk_evidence_evidence_custody_events_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_custody_events'::regclass, 'fk_evidence_evidence_custody_events_package_version_id', 'package_version_id', 'evidence.evidence_package_versions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_integrity_checks'::regclass, 'fk_evidence_evidence_integrity_checks_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_integrity_checks'::regclass, 'fk_evidence_evidence_integrity_checks_rendition_id', 'rendition_id', 'evidence.evidence_renditions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_dispositions'::regclass, 'fk_evidence_evidence_dispositions_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_dispositions'::regclass, 'fk_evidence_evidence_dispositions_rendition_id', 'rendition_id', 'evidence.evidence_renditions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_dispositions'::regclass, 'fk_evidence_evidence_dispositions_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('decision.decision_records'::regclass, 'fk_decision_decision_records_responsible_person_id', 'responsible_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('decision.decision_records'::regclass, 'fk_decision_decision_records_acting_role_assignment_id', 'acting_role_assignment_id', 'org.role_assignments'::regclass, 'id');
select core.ensure_fk('decision.decision_records'::regclass, 'fk_decision_decision_records_mandate_id', 'mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('decision.decision_evidence_links'::regclass, 'fk_decision_decision_evidence_links_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('decision.decision_evidence_links'::regclass, 'fk_decision_decision_evidence_links_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('decision.decision_assessment_links'::regclass, 'fk_decision_decision_assessment_links_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('decision.decision_assessment_links'::regclass, 'fk_decision_decision_assessment_links_assessment_id', 'assessment_id', 'investigation.understanding_assessments'::regclass, 'id');
select core.ensure_fk('decision.decision_relationships'::regclass, 'fk_decision_decision_relationships_from_decision_id', 'from_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('decision.decision_relationships'::regclass, 'fk_decision_decision_relationships_to_decision_id', 'to_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('decision.recommendations'::regclass, 'fk_decision_recommendations_author_person_id', 'author_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('decision.recommendations'::regclass, 'fk_decision_recommendations_author_service_principal_id', 'author_service_principal_id', 'iam.service_principals'::regclass, 'id');
select core.ensure_fk('decision.recommendation_sources'::regclass, 'fk_decision_recommendation_sources_recommendation_id', 'recommendation_id', 'decision.recommendations'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_records'::regclass, 'fk_knowledge_knowledge_records_steward_responsibility_id', 'steward_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_versions'::regclass, 'fk_knowledge_knowledge_versions_knowledge_record_id', 'knowledge_record_id', 'knowledge.knowledge_records'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_versions'::regclass, 'fk_knowledge_knowledge_versions_author_person_id', 'author_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_versions'::regclass, 'fk_knowledge_knowledge_versions_supersedes_version_id', 'supersedes_version_id', 'knowledge.knowledge_versions'::regclass, 'id');
select core.ensure_fk('knowledge.validity_contexts'::regclass, 'fk_knowledge_validity_contexts_knowledge_version_id', 'knowledge_version_id', 'knowledge.knowledge_versions'::regclass, 'id');
select core.ensure_fk('knowledge.validity_contexts'::regclass, 'fk_knowledge_validity_contexts_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('knowledge.validity_contexts'::regclass, 'fk_knowledge_validity_contexts_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('knowledge.validity_contexts'::regclass, 'fk_knowledge_validity_contexts_asset_type_id', 'asset_type_id', 'property.asset_types'::regclass, 'id');
select core.ensure_fk('knowledge.validity_contexts'::regclass, 'fk_knowledge_validity_contexts_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_sources'::regclass, 'fk_knowledge_knowledge_sources_knowledge_version_id', 'knowledge_version_id', 'knowledge.knowledge_versions'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_reviews'::regclass, 'fk_knowledge_knowledge_reviews_knowledge_version_id', 'knowledge_version_id', 'knowledge.knowledge_versions'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_reviews'::regclass, 'fk_knowledge_knowledge_reviews_reviewer_person_id', 'reviewer_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_reviews'::regclass, 'fk_knowledge_knowledge_reviews_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_usage_outcomes'::regclass, 'fk_knowledge_knowledge_usage_outcomes_knowledge_version_id', 'knowledge_version_id', 'knowledge.knowledge_versions'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_usage_outcomes'::regclass, 'fk_knowledge_knowledge_usage_outcomes_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_usage_outcomes'::regclass, 'fk_knowledge_knowledge_usage_outcomes_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_usage_outcomes'::regclass, 'fk_knowledge_knowledge_usage_outcomes_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('workflow.workflow_definitions'::regclass, 'fk_workflow_workflow_definitions_business_owner_responsibility_', 'business_owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('workflow.workflow_versions'::regclass, 'fk_workflow_workflow_versions_workflow_definition_id', 'workflow_definition_id', 'workflow.workflow_definitions'::regclass, 'id');
select core.ensure_fk('workflow.workflow_versions'::regclass, 'fk_workflow_workflow_versions_supersedes_version_id', 'supersedes_version_id', 'workflow.workflow_versions'::regclass, 'id');
select core.ensure_fk('workflow.workflow_instances'::regclass, 'fk_workflow_workflow_instances_workflow_version_id', 'workflow_version_id', 'workflow.workflow_versions'::regclass, 'id');
select core.ensure_fk('workflow.workflow_instances'::regclass, 'fk_workflow_workflow_instances_responsibility_assignment_id', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('workflow.workflow_instances'::regclass, 'fk_workflow_workflow_instances_previous_instance_id', 'previous_instance_id', 'workflow.workflow_instances'::regclass, 'id');
select core.ensure_fk('workflow.workflow_subjects'::regclass, 'fk_workflow_workflow_subjects_workflow_instance_id', 'workflow_instance_id', 'workflow.workflow_instances'::regclass, 'id');
select core.ensure_fk('workflow.state_transitions'::regclass, 'fk_workflow_state_transitions_workflow_instance_id', 'workflow_instance_id', 'workflow.workflow_instances'::regclass, 'id');
select core.ensure_fk('workflow.state_transitions'::regclass, 'fk_workflow_state_transitions_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('workflow.state_transitions'::regclass, 'fk_workflow_state_transitions_mandate_id', 'mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('notification.notification_intents'::regclass, 'fk_notification_notification_intents_source_event_id', 'source_event_id', 'audit.domain_events'::regclass, 'id');
select core.ensure_fk('notification.notification_intents'::regclass, 'fk_notification_notification_intents_responsibility_assignment_', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('notification.notification_audiences'::regclass, 'fk_notification_notification_audiences_notification_intent_id', 'notification_intent_id', 'notification.notification_intents'::regclass, 'id');
select core.ensure_fk('notification.notification_audiences'::regclass, 'fk_notification_notification_audiences_case_party_relationship_', 'case_party_relationship_id', 'intake.case_party_relationships'::regclass, 'id');
select core.ensure_fk('notification.notification_audiences'::regclass, 'fk_notification_notification_audiences_organization_relationshi', 'organization_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('notification.message_renditions'::regclass, 'fk_notification_message_renditions_notification_intent_id', 'notification_intent_id', 'notification.notification_intents'::regclass, 'id');
select core.ensure_fk('notification.message_renditions'::regclass, 'fk_notification_message_renditions_audience_id', 'audience_id', 'notification.notification_audiences'::regclass, 'id');
select core.ensure_fk('notification.message_renditions'::regclass, 'fk_notification_message_renditions_corrects_rendition_id', 'corrects_rendition_id', 'notification.message_renditions'::regclass, 'id');
select core.ensure_fk('notification.delivery_attempts'::regclass, 'fk_notification_delivery_attempts_audience_id', 'audience_id', 'notification.notification_audiences'::regclass, 'id');
select core.ensure_fk('notification.delivery_attempts'::regclass, 'fk_notification_delivery_attempts_rendition_id', 'rendition_id', 'notification.message_renditions'::regclass, 'id');
select core.ensure_fk('notification.delivery_attempts'::regclass, 'fk_notification_delivery_attempts_provider_external_system_id', 'provider_external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('notification.notification_acknowledgements'::regclass, 'fk_notification_notification_acknowledgements_audience_id', 'audience_id', 'notification.notification_audiences'::regclass, 'id');
select core.ensure_fk('notification.notification_acknowledgements'::regclass, 'fk_notification_notification_acknowledgements_delivery_attempt_', 'delivery_attempt_id', 'notification.delivery_attempts'::regclass, 'id');
select core.ensure_fk('notification.notification_acknowledgements'::regclass, 'fk_notification_notification_acknowledgements_acknowledging_rel', 'acknowledging_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('governance.compliance_deadlines'::regclass, 'fk_governance_compliance_deadlines_responsibility_assignment_id', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('governance.compliance_deadlines'::regclass, 'fk_governance_compliance_deadlines_evidence_package_version_id', 'completion_evidence_package_version_id', 'evidence.evidence_package_versions'::regclass, 'id');
select core.ensure_fk('governance.compliance_deadlines'::regclass, 'fk_governance_compliance_deadlines_supersedes_deadline_id', 'supersedes_deadline_id', 'governance.compliance_deadlines'::regclass, 'id');
select core.ensure_fk('governance.policies'::regclass, 'fk_governance_policies_owner_responsibility_id', 'owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('governance.policy_versions'::regclass, 'fk_governance_policy_versions_policy_id', 'policy_id', 'governance.policies'::regclass, 'id');
select core.ensure_fk('governance.policy_versions'::regclass, 'fk_governance_policy_versions_supersedes_version_id', 'supersedes_version_id', 'governance.policy_versions'::regclass, 'id');
select core.ensure_fk('governance.committee_memberships'::regclass, 'fk_governance_committee_memberships_committee_id', 'committee_id', 'governance.committees'::regclass, 'id');
select core.ensure_fk('governance.committee_memberships'::regclass, 'fk_governance_committee_memberships_person_id', 'person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('governance.committee_memberships'::regclass, 'fk_governance_committee_memberships_organization_relationship_i', 'organization_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('governance.meetings'::regclass, 'fk_governance_meetings_committee_id', 'committee_id', 'governance.committees'::regclass, 'id');
select core.ensure_fk('governance.meetings'::regclass, 'fk_governance_meetings_chair_membership_id', 'chair_membership_id', 'governance.committee_memberships'::regclass, 'id');
select core.ensure_fk('governance.meetings'::regclass, 'fk_governance_meetings_secretary_membership_id', 'secretary_membership_id', 'governance.committee_memberships'::regclass, 'id');
select core.ensure_fk('governance.resolutions'::regclass, 'fk_governance_resolutions_meeting_id', 'meeting_id', 'governance.meetings'::regclass, 'id');
select core.ensure_fk('governance.resolutions'::regclass, 'fk_governance_resolutions_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('governance.resolution_votes'::regclass, 'fk_governance_resolution_votes_resolution_id', 'resolution_id', 'governance.resolutions'::regclass, 'id');
select core.ensure_fk('governance.resolution_votes'::regclass, 'fk_governance_resolution_votes_committee_membership_id', 'committee_membership_id', 'governance.committee_memberships'::regclass, 'id');
select core.ensure_fk('governance.contracts'::regclass, 'fk_governance_contracts_vendor_organization_id', 'vendor_organization_id', 'org.external_organizations'::regclass, 'id');
select core.ensure_fk('governance.contracts'::regclass, 'fk_governance_contracts_owner_responsibility_id', 'owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('governance.contract_versions'::regclass, 'fk_governance_contract_versions_contract_id', 'contract_id', 'governance.contracts'::regclass, 'id');
select core.ensure_fk('governance.contract_versions'::regclass, 'fk_governance_contract_versions_approved_by_decision_id', 'approved_by_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('governance.contract_versions'::regclass, 'fk_governance_contract_versions_supersedes_version_id', 'supersedes_version_id', 'governance.contract_versions'::regclass, 'id');
select core.ensure_fk('governance.contract_obligations'::regclass, 'fk_governance_contract_obligations_contract_version_id', 'contract_version_id', 'governance.contract_versions'::regclass, 'id');
select core.ensure_fk('governance.contract_obligations'::regclass, 'fk_governance_contract_obligations_sla_policy_version_id', 'sla_policy_version_id', 'work.sla_policy_versions'::regclass, 'id');
select core.ensure_fk('governance.risks'::regclass, 'fk_governance_risks_owner_responsibility_id', 'owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('governance.risks'::regclass, 'fk_governance_risks_acceptance_decision_id', 'acceptance_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('governance.risk_links'::regclass, 'fk_governance_risk_links_risk_id', 'risk_id', 'governance.risks'::regclass, 'id');
select core.ensure_fk('ai.ai_use_cases'::regclass, 'fk_ai_ai_use_cases_business_owner_responsibility_id', 'business_owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('ai.ai_use_cases'::regclass, 'fk_ai_ai_use_cases_risk_owner_responsibility_id', 'risk_owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('ai.ai_use_cases'::regclass, 'fk_ai_ai_use_cases_technical_steward_relationship_id', 'technical_steward_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('ai.ai_use_cases'::regclass, 'fk_ai_ai_use_cases_approved_by_decision_id', 'approved_by_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('ai.ai_interactions'::regclass, 'fk_ai_ai_interactions_ai_use_case_id', 'ai_use_case_id', 'ai.ai_use_cases'::regclass, 'id');
select core.ensure_fk('ai.ai_interactions'::regclass, 'fk_ai_ai_interactions_requesting_person_id', 'requesting_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('ai.ai_interactions'::regclass, 'fk_ai_ai_interactions_provider_external_system_id', 'provider_external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('ai.ai_recommendations'::regclass, 'fk_ai_ai_recommendations_ai_interaction_id', 'ai_interaction_id', 'ai.ai_interactions'::regclass, 'id');
select core.ensure_fk('ai.ai_recommendations'::regclass, 'fk_ai_ai_recommendations_recommendation_id', 'recommendation_id', 'decision.recommendations'::regclass, 'id');
select core.ensure_fk('ai.ai_recommendation_sources'::regclass, 'fk_ai_ai_recommendation_sources_ai_recommendation_id', 'ai_recommendation_id', 'ai.ai_recommendations'::regclass, 'id');
select core.ensure_fk('ai.ai_reviews'::regclass, 'fk_ai_ai_reviews_ai_interaction_id', 'ai_interaction_id', 'ai.ai_interactions'::regclass, 'id');
select core.ensure_fk('ai.ai_reviews'::regclass, 'fk_ai_ai_reviews_ai_recommendation_id', 'ai_recommendation_id', 'ai.ai_recommendations'::regclass, 'id');
select core.ensure_fk('ai.ai_reviews'::regclass, 'fk_ai_ai_reviews_reviewer_person_id', 'reviewer_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('ai.ai_reviews'::regclass, 'fk_ai_ai_reviews_adoption_decision_id', 'adoption_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('audit.domain_events'::regclass, 'fk_audit_domain_events_acting_role_assignment_id', 'acting_role_assignment_id', 'org.role_assignments'::regclass, 'id');
select core.ensure_fk('audit.outbox_messages'::regclass, 'fk_audit_outbox_messages_domain_event_id', 'domain_event_id', 'audit.domain_events'::regclass, 'id');
select core.ensure_fk('audit.audit_entries'::regclass, 'fk_audit_audit_entries_access_decision_id', 'access_decision_id', 'iam.access_decisions'::regclass, 'id');
select core.ensure_fk('analytics.kpi_definitions'::regclass, 'fk_analytics_kpi_definitions_owner_responsibility_id', 'owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('analytics.kpi_versions'::regclass, 'fk_analytics_kpi_versions_kpi_definition_id', 'kpi_definition_id', 'analytics.kpi_definitions'::regclass, 'id');
select core.ensure_fk('analytics.kpi_versions'::regclass, 'fk_analytics_kpi_versions_supersedes_version_id', 'supersedes_version_id', 'analytics.kpi_versions'::regclass, 'id');
select core.ensure_fk('analytics.kpi_observations'::regclass, 'fk_analytics_kpi_observations_kpi_version_id', 'kpi_version_id', 'analytics.kpi_versions'::regclass, 'id');
select core.ensure_fk('analytics.kpi_observations'::regclass, 'fk_analytics_kpi_observations_source_manifest_id', 'source_manifest_id', 'memory.memory_manifests'::regclass, 'id');
select core.ensure_fk('analytics.report_snapshots'::regclass, 'fk_analytics_report_snapshots_source_manifest_id', 'source_manifest_id', 'memory.memory_manifests'::regclass, 'id');
select core.ensure_fk('analytics.report_snapshots'::regclass, 'fk_analytics_report_snapshots_published_by_person_id', 'published_by_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('memory.memory_manifests'::regclass, 'fk_memory_memory_manifests_custodian_relationship_id', 'custodian_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('memory.memory_manifest_items'::regclass, 'fk_memory_memory_manifest_items_memory_manifest_id', 'memory_manifest_id', 'memory.memory_manifests'::regclass, 'id');
select core.ensure_fk('memory.archive_batches'::regclass, 'fk_memory_archive_batches_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('memory.archive_batches'::regclass, 'fk_memory_archive_batches_custodian_relationship_id', 'custodian_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('memory.archive_batch_items'::regclass, 'fk_memory_archive_batch_items_archive_batch_id', 'archive_batch_id', 'memory.archive_batches'::regclass, 'id');
select core.ensure_fk('integration.external_systems'::regclass, 'fk_integration_external_systems_owner_relationship_id', 'owner_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('integration.external_systems'::regclass, 'fk_integration_external_systems_contract_id', 'contract_id', 'governance.contracts'::regclass, 'id');
select core.ensure_fk('integration.external_identifiers'::regclass, 'fk_integration_external_identifiers_external_system_id', 'external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('integration.inbound_messages'::regclass, 'fk_integration_inbound_messages_external_system_id', 'external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('integration.sync_conflicts'::regclass, 'fk_integration_sync_conflicts_external_system_id', 'external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('integration.sync_conflicts'::regclass, 'fk_integration_sync_conflicts_inbound_message_id', 'inbound_message_id', 'integration.inbound_messages'::regclass, 'id');
select core.ensure_fk('integration.sync_conflicts'::regclass, 'fk_integration_sync_conflicts_resolved_by_person_id', 'resolved_by_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('integration.sync_conflicts'::regclass, 'fk_integration_sync_conflicts_resolution_decision_id', 'resolution_decision_id', 'decision.decision_records'::regclass, 'id');

-- Universal business key and temporal checks.
do $$
declare r record; c_name text;
begin
  for r in
    select schemaname, tablename, format('%I.%I', schemaname, tablename)::regclass as rel
    from pg_tables
    where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
  loop
    c_name := left('uq_' || r.schemaname || '_' || r.tablename || '_business_key', 63);
    if not exists (select 1 from pg_constraint where conrelid = r.rel and conname = c_name) then
      if r.schemaname = 'org' and r.tablename = 'juristic_persons' then
        execute format('alter table %s add constraint %I unique (business_key)', r.rel, c_name);
      else
        execute format('alter table %s add constraint %I unique (juristic_person_id, business_key)', r.rel, c_name);
      end if;
    end if;
    c_name := left('ck_' || r.schemaname || '_' || r.tablename || '_row_version', 63);
    if not exists (select 1 from pg_constraint where conrelid = r.rel and conname = c_name) then
      execute format('alter table %s add constraint %I check (row_version > 0)', r.rel, c_name);
    end if;
    c_name := left('ck_' || r.schemaname || '_' || r.tablename || '_valid_period', 63);
    if not exists (select 1 from pg_constraint where conrelid = r.rel and conname = c_name) then
      execute format('alter table %s add constraint %I check (valid_to is null or valid_from is null or valid_to > valid_from)', r.rel, c_name);
    end if;
  end loop;
end $$;

-- Domain-specific cardinality and integrity checks.
do $$ begin
  alter table org.organization_relationships add constraint ck_org_relationship_party_xor check ((person_id is not null)::int + (external_organization_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table org.role_permissions add constraint ck_org_role_permissions_effect check (effect in ('allow','deny'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table org.role_permissions add constraint uq_org_role_permissions_effective unique nulls not distinct (role_definition_id, permission_definition_id, recorded_to);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table notification.announcements add constraint ck_announcement_publication check ((publication_state = 'published' and published_at is not null) or publication_state <> 'published');
exception when duplicate_object then null; end $$;
do $$ begin
  alter table governance.compliance_deadlines add constraint ck_compliance_completion check ((current_state = 'completed' and completed_at is not null) or current_state <> 'completed');
exception when duplicate_object then null; end $$;
do $$ begin
  alter table property.occupancy_relationships add constraint ck_occupancy_place_xor check ((room_id is not null)::int + (location_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table property.asset_relationships add constraint ck_asset_rel_from_one check ((from_asset_id is not null)::int + (from_component_id is not null)::int = 1), add constraint ck_asset_rel_to_one check ((to_asset_id is not null)::int + (to_component_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table property.asset_identifiers add constraint ck_asset_identifier_subject_xor check ((asset_id is not null)::int + (component_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table property.maintenance_plan_assets add constraint ck_plan_asset_subject_xor check ((asset_id is not null)::int + (component_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table intake.cases add constraint uq_cases_report unique (report_id);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table incident.incident_assets add constraint ck_incident_asset_subject check ((asset_id is not null)::int + (component_id is not null)::int + (location_id is not null)::int >= 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table work.operation_assets add constraint ck_operation_asset_subject check ((asset_id is not null)::int + (component_id is not null)::int + (location_id is not null)::int >= 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table work.sla_applications add constraint ck_sla_target_xor check ((case_id is not null)::int + (operation_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table evidence.evidence_package_members add constraint ck_package_member_rendition check (rendition_id is null or evidence_item_id is not null);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table decision.recommendations add constraint ck_recommendation_author check ((author_kind = 'person' and author_person_id is not null and author_service_principal_id is null) or (author_kind <> 'person' and author_service_principal_id is not null));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table decision.decision_relationships add constraint ck_decision_relationship_not_self check (from_decision_id <> to_decision_id);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table taxonomy.taxonomy_term_relationships add constraint ck_taxonomy_relationship_not_self check (from_term_id <> to_term_id);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table workflow.workflow_subjects add constraint uq_workflow_primary_subject unique nulls not distinct (workflow_instance_id, is_primary) deferrable initially deferred;
exception when duplicate_object then null; end $$;
do $$ begin
  alter table governance.resolution_votes add constraint uq_resolution_member_vote unique (resolution_id, committee_membership_id);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table audit.outbox_messages add constraint uq_outbox_event_destination unique (domain_event_id, destination);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table integration.inbound_messages add constraint uq_inbound_external_message unique (external_system_id, external_message_id);
exception when duplicate_object then null; end $$;

comment on function core.ensure_fk(regclass,text,text,regclass,text) is 'Internal helper retained for future idempotent migrations; execute is revoked from application roles.';
