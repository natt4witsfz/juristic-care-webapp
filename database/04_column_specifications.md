# Column Specifications

Version: 1.0  
Status: Production Logical Model

## Purpose

This dictionary defines logical columns and PostgreSQL-compatible types without generating SQL. Every table’s complete column set is the union of its profile columns and the table-specific columns below.

## Common profiles

### Tenant entity profile

`id uuid`, `juristic_person_id uuid`, `business_key text`, `created_at timestamptz`, `created_by_person_id uuid`, `acting_role_assignment_id uuid nullable`, `row_version bigint`, `archived_at timestamptz nullable`, `archive_batch_id uuid nullable`.

### Immutable event profile

Tenant profile plus `occurred_at timestamptz`, `effective_at timestamptz nullable`, `recorded_at timestamptz`, `uploaded_at timestamptz nullable`, `actor_person_id uuid nullable`, `actor_service_principal_id uuid nullable`, `correlation_id uuid`, `causation_id uuid nullable`, `reason_code text`, `reason_text text nullable`. No updateable business payload after acceptance.

### Effective relationship profile

Tenant profile plus `valid_from timestamptz`, `valid_to timestamptz nullable`, `recorded_from timestamptz`, `recorded_to timestamptz nullable`, `supersedes_id uuid nullable`, `relationship_state text`, `decision_id uuid nullable`.

### Immutable version profile

Tenant profile plus `root_id uuid`, `version_number integer`, `status text`, `effective_from timestamptz nullable`, `effective_to timestamptz nullable`, `supersedes_version_id uuid nullable`, `content_digest text`, `approved_by_decision_id uuid nullable`, `published_at timestamptz nullable`. Published payload is immutable.

### Restricted content profile

Tenant profile plus `classification text`, `retention_class text`, `legal_hold_state text`, `access_purpose_required boolean`, `restricted_at timestamptz nullable`, `restriction_decision_id uuid nullable`.

## IAM and organization columns

- `iam.user_accounts`: tenant profile; `auth_user_id uuid`, `person_id uuid`, `account_state text`, `linked_at`, `disabled_at`, `session_revocation_required boolean`, `last_access_review_at`.
- `iam.service_principals`: tenant profile; `principal_code`, `display_name`, `purpose`, `owner_relationship_id`, `state`, `credential_rotated_at`, `expires_at`.
- `iam.access_decisions`: immutable event; `principal_type`, `principal_id`, `action_code`, `resource_type`, `resource_id`, `purpose_code`, `policy_version_id`, `mandate_id`, `decision_result`, `denial_reason`, `session_id`, `request_context jsonb`.
- `org.juristic_persons`: tenant-like root without self-FK; `legal_name`, `registration_number`, `country_code`, `timezone`, `default_locale`, `state`, `successor_juristic_person_id`.
- `org.people`: restricted tenant profile; `person_code`, `display_name`, `legal_name`, `preferred_name`, `contact_data jsonb`, `identity_state`, `merged_into_person_id`.
- `org.external_organizations`: tenant profile; `organization_code`, `legal_name`, `organization_type_term_id`, `registration_number`, `contact_data jsonb`, `state`, `successor_organization_id`.
- `org.organization_relationships`: effective relationship; `person_id nullable`, `external_organization_id nullable`, `relationship_type_term_id`, `source_policy_id`, `state`, `contact_preferences jsonb`.
- `org.role_definitions`: tenant profile; `role_code`, `name`, `description`, `state`, `deprecated_at`.
- `org.role_assignments`: effective relationship; `organization_relationship_id`, `role_definition_id`, `assignment_source_id`, `state`.
- `org.mandates`: tenant profile; `mandate_code`, `grantee_relationship_id`, `grantee_role_assignment_id nullable`, `grantor_type`, `grantor_id`, `parent_mandate_id`, `authority_actions text[]`, `scope_type`, `scope_id`, `delegation_allowed`, `valid_from`, `valid_to`, `state`, `revoked_at`, `source_type`, `source_id`.
- `org.responsibility_definitions`: tenant profile; `responsibility_code`, `name`, `outcome_definition`, `scope_type`, `state`.
- `org.responsibility_assignments`: effective relationship; `assignment_code`, `responsibility_definition_id`, `responsible_relationship_id`, `responsible_role_assignment_id`, `scope_type`, `scope_id`, `supervising_assignment_id`, `state`.
- `org.responsibility_ledger_entries`: immutable event; `responsibility_assignment_id`, `entry_type`, `subject_type`, `subject_id`, `commitment_id`, `mandate_id`, `decision_id`, `evidence_package_id`, `state_after`, `handover_id`.
- `org.handovers`: tenant profile; `handover_code`, `from_relationship_id`, `to_relationship_id`, `scope_type`, `scope_id`, `offered_at`, `accepted_at`, `state`, `authority_decision_id`, `summary`.
- `org.handover_items`: tenant profile; `handover_id`, `item_sequence`, `subject_type`, `subject_id`, `context_summary`, `risk_summary`, `acknowledgement_state`, `acknowledged_at`, `acknowledged_by_person_id`.
- `org.capability_assertions`: restricted tenant profile; `assertion_code`, `subject_relationship_id`, `capability_term_id`, `level_term_id`, `issuer_type`, `issuer_id`, `evidence_item_id`, `valid_from`, `valid_to`, `verification_state`, `revoked_at`.
- `org.availability_periods`: effective relationship; `subject_relationship_id`, `resource_type`, `resource_id`, `availability_state`, `source_type`, `source_id`, `confidence`, `timezone`, `notes`.

## Property, taxonomy, and intake columns

- `property.properties`: tenant profile; `property_code`, `name`, `legal_description`, `timezone`, `state`.
- `property.buildings`: tenant profile; `building_code`, `property_id`, `name`, `address jsonb`, `commissioned_on`, `retired_on`, `state`.
- `property.locations`: effective relationship; `location_code`, `property_id`, `building_id nullable`, `parent_location_id nullable`, `location_type_term_id`, `name`, `floor_label`, `geometry jsonb nullable`, `state`.
- `property.location_aliases`: effective relationship; `location_id`, `alias_type`, `alias_value`, `locale`, `external_system_id`.
- `property.rooms`: tenant profile; `room_code`, `building_id`, `location_id`, `room_type_term_id`, `display_label`, `state`, `renumbered_from_room_id`.
- `property.occupancy_relationships`: effective relationship; `room_id`, `location_id nullable`, `organization_relationship_id`, `occupancy_type_term_id`, `consent_scope jsonb`, `state`.
- `property.asset_types`: tenant profile; `asset_type_code`, `name`, `component_allowed`, `required_context_schema jsonb`, `state`.
- `property.assets`: tenant profile; `asset_code`, `asset_type_id`, `primary_location_id`, `manufacturer`, `model`, `version`, `serial_number nullable`, `commissioned_on`, `retired_on`, `state`, `predecessor_asset_id`.
- `property.asset_components`: tenant profile; `component_code`, `asset_id`, `parent_component_id`, `asset_type_id`, `manufacturer`, `model`, `version`, `serial_number`, `installed_at`, `removed_at`, `state`, `predecessor_component_id`.
- `property.asset_relationships`: effective relationship; `from_asset_id`, `from_component_id`, `to_asset_id`, `to_component_id`, `relationship_type_term_id`, `state`.
- `property.asset_identifiers`: effective relationship; `asset_id`, `component_id`, `identifier_type`, `identifier_value`, `issuer`, `external_system_id`.
- `property.maintenance_plans`: tenant profile; `plan_code`, `name`, `policy_version_id`, `workflow_version_id`, `operation_type_term_id`, `schedule_definition jsonb`, `criteria_definition jsonb`, `state`, `effective_from`, `effective_to`.
- `property.maintenance_plan_assets`: effective relationship; `maintenance_plan_id`, `asset_id`, `component_id`, `applicability_context jsonb`, `state`.
- `taxonomy.taxonomies`: tenant profile; `taxonomy_code`, `name`, `purpose`, `owner_responsibility_id`, `governance_mode`, `state`.
- `taxonomy.taxonomy_versions`: immutable version; `taxonomy_id`, `version_number`, `change_summary`, `status`.
- `taxonomy.taxonomy_terms`: tenant profile; `taxonomy_id`, `term_code`, `canonical_label`, `descriptions jsonb`, `introduced_version_id`, `deprecated_version_id`, `state`.
- `taxonomy.taxonomy_term_relationships`: effective relationship; `from_term_id`, `to_term_id`, `relationship_type`, `state`.
- `intake.reports`: restricted immutable event profile; `report_number`, `channel`, `source_message_id`, `source_relationship_id`, `submitted_payload jsonb`, `submitted_text`, `submitted_location_text`, `safety_opinion`, `impact_opinion`, `language`, `acceptance_state`.
- `intake.cases`: tenant profile; `case_number`, `report_id`, `current_state`, `opened_at`, `resolved_at`, `closed_at`, `current_summary`, `current_priority_decision_id`.
- `intake.case_party_relationships`: effective relationship; `case_id`, `organization_relationship_id`, `party_role_term_id`, `contact_permission`, `visibility_scope`, `state`.
- `intake.case_context_assertions`: effective relationship; `case_id`, `assertion_type`, `value_text nullable`, `location_id nullable`, `room_id nullable`, `asset_id nullable`, `component_id nullable`, `taxonomy_term_id nullable`, `source_type`, `source_id`, `confidence`, `is_submitted_value`, `state`.
- `intake.case_communications`: immutable event; `case_id`, `case_party_relationship_id`, `direction`, `channel`, `subject`, `content_digest`, `content_reference`, `notification_intent_id`, `delivery_attempt_id`.
- `intake.case_reopens`: immutable event; `case_id`, `reopen_sequence`, `decision_id`, `prior_close_transition_id`, `reopen_reason_type`, `new_evidence_item_id`.
- `intake.case_transfers`: tenant profile; `transfer_code`, `source_case_id`, `source_juristic_person_id`, `destination_juristic_person_id`, `destination_case_id`, `requested_at`, `accepted_at`, `state`, `decision_id`, `scope_manifest_id`, `sla_treatment`.

## Investigation, Incident, and Work columns

- `investigation.investigations`: tenant profile; `investigation_number`, `question`, `initiating_case_id`, `responsibility_assignment_id`, `workflow_instance_id`, `current_state`, `opened_at`, `concluded_at`.
- `investigation.investigation_cases`: effective relationship; `investigation_id`, `case_id`, `scope_role`, `inclusion_reason`, `state`.
- `investigation.observations`: immutable event; `observation_number`, `investigation_id`, `observer_relationship_id`, `observation_type`, `narrative`, `measured_value jsonb`, `location_id`, `asset_id`, `component_id`, `source_device`, `confidence`, `correction_of_observation_id`.
- `investigation.hypotheses`: tenant profile; `hypothesis_number`, `investigation_id`, `statement`, `author_person_id`, `confidence`, `state`, `supersedes_hypothesis_id`.
- `investigation.hypothesis_evidence_links`: tenant profile; `hypothesis_id`, `evidence_item_id`, `link_role`, `relevance`, `reviewer_person_id`, `supersedes_link_id`.
- `investigation.understanding_assessments`: immutable version-like profile; `assessment_number`, `investigation_id`, `known_summary`, `inferred_summary`, `disputed_summary`, `unknown_summary`, `confidence`, `recommendation_summary`, `status`, `supersedes_assessment_id`, `issued_at`.
- `investigation.assessment_evidence_links`: tenant profile; `assessment_id`, `evidence_item_id`, `consideration_role`, `relevance`, `reliability_assessment`, `omission_reason`, `supersedes_link_id`.
- `incident.incidents`: tenant profile; `incident_number`, `verification_decision_id`, `verification_assessment_id`, `verified_at`, `current_state`, `current_summary`, `activated_at`, `monitoring_started_at`, `closed_at`, `verification_withdrawn_at`.
- `incident.case_incident_associations`: tenant profile; `association_code`, `case_id`, `incident_id`, `relationship_type`, `relevance`, `decision_id`, `mandate_id`, `assessment_id`, `effective_from`, `effective_to`, `state`, `supersedes_association_id`.
- `incident.incident_assets`: effective relationship; `incident_id`, `asset_id`, `component_id`, `location_id`, `relationship_type`, `confidence`, `source_assessment_id`, `state`.
- `incident.incident_reopens`: immutable event; `incident_id`, `reopen_sequence`, `decision_id`, `prior_close_transition_id`, `relationship_to_prior_repair`, `reason_type`.
- `incident.incident_classifications`: effective relationship; `incident_id`, `classification_type`, `taxonomy_term_id`, `decision_id`, `assessment_id`, `confidence`, `state`.
- `work.operations`: tenant profile; `operation_number`, `operation_type_term_id`, `title`, `scope`, `desired_outcome`, `hazards jsonb`, `responsibility_assignment_id`, `workflow_instance_id`, `current_state`, `proposed_at`, `authorized_at`, `started_at`, `completed_at`, `cancelled_at`.
- `work.incident_operations`: effective relationship; `incident_id`, `operation_id`, `relationship_type`, `scope_note`, `state`.
- `work.maintenance_plan_operations`: effective relationship; `maintenance_plan_id`, `operation_id`, `planned_occurrence_key`, `scheduled_for`, `plan_version_reference`, `state`.
- `work.operation_assets`: effective relationship; `operation_id`, `asset_id`, `component_id`, `location_id`, `subject_role`, `expected_effect`, `state`.
- `work.work_steps`: tenant profile; `operation_id`, `step_code`, `parent_step_id`, `sequence_hint`, `title`, `instructions`, `required_capability_term_id`, `current_state`, `started_at`, `completed_at`, `skip_reason`.
- `work.commitments`: tenant profile; `commitment_number`, `operation_id`, `work_step_id`, `offered_by_person_id`, `accepted_by_relationship_id`, `scope`, `due_at`, `accepted_at`, `current_state`, `replaces_commitment_id`, `released_by_decision_id`.
- `work.operation_interruptions`: immutable event; `operation_id`, `commitment_id`, `interrupting_incident_id`, `interrupting_operation_id`, `priority_decision_id`, `safe_stop_state`, `schedule_impact`, `recovery_plan`, `resumed_at`.
- `work.verification_records`: immutable event-like profile; `verification_number`, `operation_id`, `attempt_number`, `verifier_relationship_id`, `verifier_role_assignment_id`, `criteria_policy_version_id`, `method`, `remote`, `result`, `limitations`, `evidence_package_version_id`, `decision_id`.
- `work.priority_decisions`: tenant profile; `decision_id`, `target_type`, `case_id`, `incident_id`, `operation_id`, `priority_term_id`, `effective_from`, `effective_to`, `supersedes_priority_id`, `consequence_summary`.
- `work.execution_sequence_entries`: immutable event; `technician_relationship_id`, `operation_id`, `commitment_id`, `sequence_rank`, `constraint_summary`, `previous_entry_id`, `material_change`, `decision_id`.
- `work.sla_policies`: tenant profile; `sla_code`, `name`, `owner_responsibility_id`, `state`.
- `work.sla_policy_versions`: immutable version; `sla_policy_id`, `service_class_term_id`, `calendar_definition jsonb`, `target_duration interval`, `start_rule`, `satisfaction_rule`, `pause_rules jsonb`, `breach_rules jsonb`, `source_policy_version_id`, `contract_obligation_id`.
- `work.sla_applications`: tenant profile; `sla_application_number`, `sla_policy_version_id`, `case_id`, `operation_id`, `classification_decision_id`, `clock_started_at`, `current_clock_state`, `due_at`, `satisfied_at`, `breached_at`, `supersedes_application_id`.
- `work.sla_clock_events`: immutable event; `sla_application_id`, `clock_event_type`, `duration_effect interval`, `source_type`, `source_id`, `blocking_party_type`, `blocking_party_id`.

## Evidence, Decision, Knowledge, and AI columns

- `evidence.upload_attachments`: restricted tenant profile; `upload_id`, `storage_bucket`, `storage_object_key`, `original_filename`, `media_type`, `byte_size`, `expected_digest`, `observed_digest`, `uploader_person_id`, `upload_state`, `scan_state`, `quarantine_reason`, `promoted_evidence_item_id`, `disposed_at`.
- `evidence.evidence_items`: restricted tenant profile; `evidence_number`, `evidence_type`, `original_attachment_id`, `original_storage_bucket`, `original_storage_object_key`, `content_digest`, `byte_size`, `capture_method`, `captured_at`, `source_person_id`, `source_device`, `custodian_relationship_id`, `location_id`, `classification`, `retention_policy_version_id`, `current_access_state`.
- `evidence.evidence_renditions`: restricted tenant profile; `evidence_item_id`, `parent_rendition_id`, `rendition_type`, `version_number`, `storage_bucket`, `storage_object_key`, `content_digest`, `transformation_method`, `tool_version`, `created_by_person_id`, `redaction_basis`, `language`.
- `evidence.evidence_links`: tenant profile; `evidence_item_id`, `rendition_id`, `target_type`, `target_id`, `claim_type`, `claim_id`, `link_role`, `relevance`, `reviewer_person_id`, `state`, `supersedes_link_id`.
- `evidence.evidence_packages`: tenant profile; `package_code`, `question`, `owner_relationship_id`, `state`.
- `evidence.evidence_package_versions`: immutable version; `evidence_package_id`, `compiler_person_id`, `selection_criteria`, `omissions_summary`, `issued_at`.
- `evidence.evidence_package_members`: tenant profile; `package_version_id`, `member_sequence`, `evidence_item_id`, `rendition_id`, `inclusion_role`, `inclusion_reason`.
- `evidence.evidence_custody_events`: immutable event; `evidence_item_id`, `package_version_id`, `from_custodian_id`, `to_custodian_id`, `custody_action`, `export_manifest_id`.
- `evidence.evidence_integrity_checks`: immutable event; `evidence_item_id`, `rendition_id`, `memory_manifest_id`, `check_type`, `expected_digest`, `observed_digest`, `availability_result`, `checker_principal_id`.
- `evidence.evidence_dispositions`: immutable event; `evidence_item_id`, `rendition_id`, `disposition_type`, `policy_version_id`, `decision_id`, `legal_hold_state`, `archive_batch_id`, `content_removed`, `tombstone_scope`.
- `decision.decision_records`: tenant profile; `decision_number`, `decision_class`, `question`, `context_summary`, `alternatives jsonb`, `outcome`, `rationale`, `responsible_person_id`, `acting_role_assignment_id`, `mandate_id`, `authority_source_type`, `authority_source_id`, `decided_at`, `effective_from`, `effective_to`, `expected_consequences`, `affected_commitments jsonb`, `dissent_summary`, `review_due_at`, `current_status`.
- `decision.decision_evidence_links`: tenant profile; `decision_id`, `evidence_item_id`, `consideration_role`, `relevance`, `reliability`, `omission_reason`.
- `decision.decision_assessment_links`: tenant profile; `decision_id`, `assessment_id`, `relationship_role`.
- `decision.decision_relationships`: tenant profile; `from_decision_id`, `to_decision_id`, `relationship_type`, `effective_at`, `reason`.
- `decision.recommendations`: tenant profile; `recommendation_number`, `author_type`, `author_person_id`, `author_service_principal_id`, `question`, `recommendation_text`, `assumptions`, `uncertainty`, `limitations`, `issued_at`, `expires_at`, `status`.
- `decision.recommendation_sources`: tenant profile; `recommendation_id`, `source_type`, `source_id`, `source_role`, `context_match`, `citation_label`.
- `knowledge.knowledge_records`: tenant profile; `knowledge_number`, `knowledge_type`, `title`, `steward_responsibility_id`, `current_published_version_id`, `state`.
- `knowledge.knowledge_versions`: immutable version; `knowledge_record_id`, `content`, `confidence`, `assumptions`, `limitations`, `author_person_id`, `review_status`, `last_verified_at`.
- `knowledge.validity_contexts`: tenant profile; `knowledge_version_id`, `asset_id`, `component_id`, `asset_type_id`, `manufacturer`, `model`, `version`, `location_id`, `environment jsonb`, `governance_policy_version_id`, `workflow_version_id`, `valid_from`, `valid_to`, `context_expression jsonb`.
- `knowledge.knowledge_sources`: tenant profile; `knowledge_version_id`, `source_type`, `source_id`, `source_role`, `outcome_summary`.
- `knowledge.knowledge_reviews`: immutable event; `knowledge_version_id`, `reviewer_person_id`, `review_type`, `result`, `decision_id`, `findings`.
- `knowledge.knowledge_usage_outcomes`: immutable event; `knowledge_version_id`, `case_id`, `incident_id`, `operation_id`, `context_match`, `used_by_person_id`, `use_decision_id`, `outcome_assessment_id`, `result`.
- `ai.ai_use_cases`: restricted tenant profile; `use_case_code`, `purpose`, `business_owner_responsibility_id`, `risk_owner_responsibility_id`, `technical_steward_relationship_id`, `approved_data_scope jsonb`, `prohibited_actions text[]`, `evaluation_policy jsonb`, `state`, `approved_by_decision_id`.
- `ai.ai_interactions`: restricted immutable event profile; `ai_use_case_id`, `requesting_person_id`, `provider_external_system_id`, `model_name`, `model_version`, `prompt_purpose`, `context_manifest_id`, `input_digest`, `output_digest`, `output_reference`, `uncertainty`, `safety_result`.
- `ai.ai_recommendations`: restricted tenant profile; `ai_interaction_id`, `recommendation_id`, `recommendation_text`, `assumptions`, `limitations`, `uncertainty`, `context_match`, `generated_at`, `review_state`.
- `ai.ai_recommendation_sources`: tenant profile; `ai_recommendation_id`, `source_type`, `source_id`, `citation`, `context_match`, `mismatch_summary`.
- `ai.ai_reviews`: immutable event; `ai_interaction_id`, `ai_recommendation_id`, `reviewer_person_id`, `review_result`, `correction_summary`, `adoption_decision_id`, `harm_severity`, `use_case_disabled`.

## Workflow, Notification, Governance, Audit, Analytics, Memory, Integration columns

- `workflow.workflow_definitions`: tenant profile; `workflow_code`, `name`, `business_owner_responsibility_id`, `policy_authority_id`, `state`.
- `workflow.workflow_versions`: immutable version; `workflow_definition_id`, `states jsonb`, `transitions jsonb`, `role_requirements jsonb`, `timers jsonb`, `exception_rules jsonb`.
- `workflow.workflow_instances`: tenant profile; `instance_number`, `workflow_version_id`, `responsibility_assignment_id`, `current_state`, `started_at`, `completed_at`, `migration_decision_id`, `previous_instance_id`.
- `workflow.workflow_subjects`: tenant profile; `workflow_instance_id`, `subject_type`, `subject_id`, `subject_role`, `is_primary`, `effective_from`, `effective_to`.
- `workflow.state_transitions`: immutable event; `workflow_instance_id`, `aggregate_type`, `aggregate_id`, `aggregate_version_before`, `aggregate_version_after`, `previous_state`, `current_state`, `decision_id`, `mandate_id`, `evidence_package_id`.
- `notification.notification_intents`: tenant profile; `source_event_id`, `purpose_code`, `urgency`, `policy_version_id`, `template_code`, `required_acknowledgement`, `expires_at`, `state`, `responsibility_assignment_id`.
- `notification.notification_audiences`: restricted tenant profile; `notification_intent_id`, `case_party_relationship_id`, `organization_relationship_id`, `recipient_address_reference`, `channel`, `locale`, `disclosure_scope`, `eligibility_state`, `suppression_reason`.
- `notification.message_renditions`: restricted tenant profile; `notification_intent_id`, `audience_id`, `locale`, `template_version`, `subject`, `content_reference`, `content_digest`, `corrects_rendition_id`.
- `notification.delivery_attempts`: immutable event; `audience_id`, `rendition_id`, `provider_external_system_id`, `attempt_number`, `idempotency_key`, `provider_message_id`, `result`, `provider_status`, `sent_at`, `delivered_at`, `failure_reason`.
- `notification.notification_acknowledgements`: immutable event; `audience_id`, `delivery_attempt_id`, `acknowledging_relationship_id`, `acknowledgement_method`.
- `governance.policies`: tenant profile; `policy_code`, `title`, `owner_responsibility_id`, `state`.
- `governance.policy_versions`: immutable version; `policy_id`, `content_reference`, `structured_rules jsonb`, `approved_by_resolution_id`, `review_due_at`.
- `governance.committees`: tenant profile; `committee_code`, `name`, `term_start`, `term_end`, `appointment_source`, `state`.
- `governance.committee_memberships`: effective relationship; `committee_id`, `person_id`, `organization_relationship_id`, `office_term_id`, `voting_rights`, `conflict_declaration`, `state`.
- `governance.meetings`: tenant profile; `meeting_code`, `committee_id`, `scheduled_at`, `held_at`, `location`, `chair_membership_id`, `secretary_membership_id`, `quorum_policy_version_id`, `quorum_result`, `state`.
- `governance.resolutions`: tenant profile; `resolution_code`, `meeting_id`, `decision_id`, `title`, `outcome`, `effective_at`, `review_due_at`, `state`.
- `governance.resolution_votes`: immutable event; `resolution_id`, `committee_membership_id`, `vote`, `conflict_state`, `dissent_text`.
- `governance.contracts`: tenant profile; `contract_code`, `vendor_organization_id`, `title`, `owner_responsibility_id`, `state`, `started_on`, `ended_on`.
- `governance.contract_versions`: immutable version; `contract_id`, `executed_at`, `terms_reference`, `terms_digest`, `approved_by_decision_id`, `termination_terms jsonb`.
- `governance.contract_obligations`: tenant profile; `contract_version_id`, `obligation_code`, `obligation_type`, `service_scope jsonb`, `sla_policy_version_id`, `responsible_party_id`, `acceptance_criteria`, `evidence_requirements`, `remedy_rules jsonb`, `effective_from`, `effective_to`.
- `governance.risks`: tenant profile; `risk_code`, `title`, `description`, `risk_type_term_id`, `likelihood`, `impact`, `owner_responsibility_id`, `control_summary`, `review_due_at`, `state`, `acceptance_decision_id`.
- `governance.risk_links`: tenant profile; `risk_id`, `target_type`, `target_id`, `relationship_type`, `control_policy_version_id`.
- `audit.domain_events`: immutable event; `event_type`, `schema_version`, `aggregate_type`, `aggregate_id`, `aggregate_version`, `payload jsonb`, `classification`, `producer`.
- `audit.outbox_messages`: tenant profile; `domain_event_id`, `destination`, `publication_state`, `attempt_count`, `next_attempt_at`, `published_at`, `last_error`, `quarantined_at`.
- `audit.audit_entries`: restricted immutable event; `principal_type`, `principal_id`, `session_id`, `action_code`, `target_type`, `target_id`, `result`, `policy_version_id`, `mandate_id`, `access_decision_id`, `request_metadata jsonb`, `before_reference`, `after_reference`.
- `analytics.kpi_definitions`: tenant profile; `kpi_code`, `name`, `purpose`, `owner_responsibility_id`, `guardrails`, `state`.
- `analytics.kpi_versions`: immutable version; `kpi_definition_id`, `formula_definition jsonb`, `population_definition jsonb`, `exclusions jsonb`, `dimensions jsonb`, `freshness_target interval`.
- `analytics.kpi_observations`: snapshot profile; `kpi_version_id`, `period_start`, `period_end`, `as_of_at`, `dimension_values jsonb`, `numerator`, `denominator`, `value`, `suppression_state`, `source_manifest_id`, `restates_observation_id`.
- `analytics.report_snapshots`: snapshot profile; `report_code`, `report_version`, `period_start`, `period_end`, `as_of_at`, `source_manifest_id`, `content_reference`, `content_digest`, `published_by_person_id`, `restates_snapshot_id`.
- `memory.memory_manifests`: tenant profile; `manifest_code`, `manifest_type`, `scope_definition jsonb`, `as_of_at`, `schema_catalog_version`, `state`, `sealed_at`, `verified_at`, `content_digest`, `custodian_relationship_id`.
- `memory.memory_manifest_items`: tenant profile; `memory_manifest_id`, `item_sequence`, `source_type`, `source_id`, `source_version`, `object_reference`, `content_digest`, `retention_state`, `verification_result`.
- `memory.archive_batches`: tenant profile; `archive_batch_code`, `policy_version_id`, `decision_id`, `source_tier`, `destination_tier`, `state`, `started_at`, `completed_at`, `custodian_relationship_id`.
- `memory.archive_batch_items`: tenant profile; `archive_batch_id`, `item_sequence`, `source_type`, `source_id`, `object_reference`, `result`, `error`, `reconciled_at`.
- `integration.external_systems`: tenant profile; `system_code`, `name`, `system_type`, `owner_relationship_id`, `contract_id`, `trust_level`, `data_classification`, `state`, `activated_at`, `retired_at`.
- `integration.external_identifiers`: effective relationship; `external_system_id`, `entity_type`, `entity_id`, `identifier_type`, `identifier_value`, `state`.
- `integration.inbound_messages`: immutable event; `external_system_id`, `external_message_id`, `message_type`, `schema_version`, `payload_reference`, `payload_digest`, `validation_state`, `processing_state`, `result_type`, `result_id`, `quarantine_reason`.
- `integration.sync_conflicts`: tenant profile; `conflict_number`, `external_system_id`, `inbound_message_id`, `aggregate_type`, `aggregate_id`, `expected_version`, `actual_version`, `conflict_type`, `alternatives jsonb`, `resolution`, `resolved_by_person_id`, `resolution_decision_id`, `state`.

## Column governance

Unstructured `jsonb` is allowed only for versioned rule/content payloads, provider envelopes, measurements with governed schemas, and extensible context—not for core foreign relationships, Authority, state, tenant identity, or business keys. Arrays are not used to hide many-to-many relationships. Text fields do not replace taxonomy codes where workflow or reporting depends on meaning.
