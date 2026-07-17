# Table Specifications

Version: 1.0  
Status: Production Logical Model

## Purpose

This document defines each table’s primary key, business key, lifecycle, retention class, and archive behavior. Detailed columns are in [04_column_specifications.md](04_column_specifications.md). All primary keys are UUID `id` unless a table is explicitly an immutable event with a UUID event identifier; composite business uniqueness never replaces the primary key.

## Table profiles

| Profile | Meaning |
|---|---|
| ROOT | Durable aggregate identity with tenant business key, optimistic version, lifecycle state |
| OWNED | Entity whose lifecycle belongs to one root and whose business key is root-scoped |
| VERSION | Immutable numbered/effective version under a stable root |
| LINK | Relationship entity with its own history and uniqueness |
| EVENT | Append-only action/transition/fact with occurred/recorded chronology |
| REF | Governed reference identity; code never repurposed |
| SNAPSHOT | Immutable reproducible projection/manifest metadata |
| SECURITY | Restricted identity/access/audit record |

## IAM and organization

- `iam.user_accounts` — SECURITY; BK `(juristic_person_id, auth_user_id)` and non-reused account key; disable/relink lifecycle; identity/audit retention.
- `iam.service_principals` — ROOT/SECURITY; BK service-principal code; active/rotating/revoked; long-term audit archive.
- `iam.access_decisions` — EVENT/SECURITY; BK request/decision ID; immutable; security retention.
- `org.juristic_persons` — ROOT; BK legal registration/business code; active/reorganized/dissolved; permanent ownership archive.
- `org.people` — ROOT/SECURITY; BK O83 person code; active/restricted/deceased/merged-by-alias; privacy retention with action attribution preserved.
- `org.external_organizations` — ROOT; BK organization code; active/inactive/superseded; contract/history archive.
- `org.organization_relationships` — LINK; BK party/type/effective-start; proposed/active/ended/revoked; permanent where actions depend on it.
- `org.role_definitions` — REF; BK stable role code; active/deprecated; permanent version interpretation.
- `org.role_assignments` — LINK; BK relationship/role/effective-start; active/ended/revoked; permanent action-time attribution.
- `org.mandates` — ROOT; BK mandate code; draft/effective/suspended/revoked/expired; permanent Authority history.
- `org.responsibility_definitions` — REF; BK responsibility code; active/deprecated; permanent.
- `org.responsibility_assignments` — ROOT; BK assignment code; proposed/effective/ended/superseded; permanent Responsibility Chain.
- `org.responsibility_ledger_entries` — EVENT; BK ledger event ID; immutable; permanent organizational history.
- `org.handovers` — ROOT; BK handover code; draft/offered/partially-accepted/accepted/failed/closed; permanent.
- `org.handover_items` — OWNED; BK handover/item sequence; pending/accepted/rejected/unavailable; permanent with handover.
- `org.capability_assertions` — ROOT; BK capability assertion code; proposed/verified/effective/expired/revoked/superseded; retain through actions and legal period.
- `org.availability_periods` — OWNED; BK resource/source/start; planned/confirmed/cancelled/superseded; operational retention then archive.

## Property, asset, and taxonomy

- `property.properties`, `property.buildings`, `property.locations`, `property.rooms`, `property.assets` — ROOT; tenant-scoped human business codes; planned/active/inactive/retired/superseded; never recycle codes; permanent asset/location lineage.
- `property.location_aliases`, `property.asset_identifiers` — OWNED; BK issuer/type/value/effective-start; active/ended/superseded; retained with root.
- `property.occupancy_relationships` — LINK; BK room/location/party/effective-start; active/ended/corrected; privacy-governed historical retention.
- `property.asset_types` — REF; BK asset-type code; active/deprecated; permanent interpretation.
- `property.asset_components` — OWNED with durable UUID; BK asset/component code; installed/active/removed/failed/replaced; permanent replacement lineage.
- `property.asset_relationships` — LINK; BK from/to/type/effective-start; effective/ended/superseded; permanent topology history.
- `property.maintenance_plans` — ROOT; BK plan code; draft/effective/suspended/retired/superseded; permanent plan/work lineage.
- `property.maintenance_plan_assets` — LINK; BK plan/asset-or-component/effective-start; effective/ended; retained with plan/asset.
- `taxonomy.taxonomies` — ROOT/REF; BK taxonomy code; draft/active/retired; permanent.
- `taxonomy.taxonomy_versions` — VERSION; BK taxonomy/version number; draft/published/superseded/withdrawn; published versions immutable/permanent.
- `taxonomy.taxonomy_terms` — REF/OWNED; BK taxonomy/stable term code; proposed/active/deprecated; permanent code history.
- `taxonomy.taxonomy_term_relationships` — LINK; BK from/to/type/effective-start; active/ended; permanent hierarchy/version meaning.

## Intake and investigation

- `intake.reports` — ROOT/EVENT-LIKE; BK channel/source message ID or O83 report number; accepted/quarantined/invalid-after-review; original immutable; permanent Case lineage.
- `intake.cases` — ROOT; BK Case number; open/under-investigation/awaiting-response/resolved/closed with Reopen events; never merge/delete; long-term archive.
- `intake.case_party_relationships`, `intake.case_context_assertions` — LINK; BK Case/type/effective-start/version; active/superseded/ended/contested; retain with Case.
- `intake.case_communications` — EVENT; BK communication ID/provider message ID; immutable with correction links; communications retention then protected archive.
- `intake.case_reopens` — EVENT; BK Case/reopen sequence; immutable; permanent.
- `intake.case_transfers` — ROOT; BK transfer code; proposed/accepted/rejected/cancelled/completed; permanent cross-tenant trace.
- `investigation.investigations` — ROOT; BK investigation number; opened/gathering/assessment-ready/concluded/reopened; permanent.
- `investigation.investigation_cases` — LINK; BK Investigation/Case/effective-start; in-scope/out-of-scope/superseded; permanent.
- `investigation.observations` — ROOT/EVENT-LIKE; BK observation number; recorded/corrected/challenged/superseded; permanent.
- `investigation.hypotheses` — ROOT; BK Investigation/hypothesis number; proposed/active/challenged/rejected/supported/superseded; permanent including failures.
- `investigation.hypothesis_evidence_links`, `investigation.assessment_evidence_links` — LINK; BK parent/Evidence/role/version; immutable assertion with supersession; permanent.
- `investigation.understanding_assessments` — ROOT/VERSION; BK Investigation/assessment number; draft/issued/superseded/withdrawn; issued versions immutable/permanent.

## Incident and work

- `incident.incidents` — ROOT; BK Incident number; verified/active/monitoring/closed/verification-withdrawn with Reopen event; permanent.
- `incident.case_incident_associations` — ROOT/LINK; BK association code; proposed/effective/disassociated/superseded; never delete.
- `incident.incident_assets`, `incident.incident_classifications` — LINK; BK Incident/subject-or-term/type/effective-start; effective/superseded; permanent.
- `incident.incident_reopens` — EVENT; BK Incident/reopen sequence; immutable/permanent.
- `work.operations` — ROOT; BK Operation number; proposed/authorized/scheduled/in-progress/paused/awaiting-verification/completed/cancelled; permanent operational archive.
- `work.incident_operations`, `work.maintenance_plan_operations`, `work.operation_assets` — LINK; root/subject/type uniqueness; active/ended/superseded; permanent work origin/subject trace.
- `work.work_steps` — OWNED; BK Operation/step code; planned/ready/in-progress/blocked/completed/skipped/cancelled; retain with Operation.
- `work.commitments` — ROOT; BK Commitment number; offered/accepted/in-progress/renegotiation-requested/fulfilled/released/replaced; permanent accountability history.
- `work.operation_interruptions`, `work.execution_sequence_entries`, `work.sla_clock_events` — EVENT; sequence business key; immutable; operational history retained.
- `work.verification_records` — ROOT/EVENT-LIKE; BK Operation/attempt number; submitted/accepted/failed/inconclusive/superseded; permanent.
- `work.priority_decisions` — ROOT; BK target/decision sequence; effective/superseded; permanent.
- `work.sla_policies` — ROOT/REF; BK SLA code; active/retired; permanent.
- `work.sla_policy_versions` — VERSION; BK SLA/version; draft/published/superseded; published immutable/permanent.
- `work.sla_applications` — ROOT/LINK; BK target/SLA application sequence; active/paused/satisfied/breached/cancelled/superseded; permanent for reporting.

## Evidence and decisions

- `evidence.upload_attachments` — ROOT; BK upload ID/storage object ID; initiated/uploaded/quarantined/scanned/promoted/rejected/disposed; retain through promotion/disposition policy.
- `evidence.evidence_items` — ROOT; BK Evidence number; captured/uploaded/integrity-checked/restricted/disposed as orthogonal status events; immutable identity/permanent unless lawful disposition.
- `evidence.evidence_renditions` — OWNED; BK Evidence/rendition type/version; created/restricted/disposed; immutable bytes/metadata.
- `evidence.evidence_links` — LINK; BK Evidence/target/claim/type/version; active/challenged/superseded; permanent.
- `evidence.evidence_packages` — ROOT; BK package code; open/issued/closed; permanent.
- `evidence.evidence_package_versions` — VERSION; BK package/version; draft/issued/superseded; issued immutable.
- `evidence.evidence_package_members` — LINK; BK package-version/member sequence; immutable in issued version.
- `evidence.evidence_custody_events`, `evidence.evidence_integrity_checks`, `evidence.evidence_dispositions` — EVENT; event ID/sequence; immutable; legal/security retention.
- `decision.decision_records` — ROOT; BK Decision number; draft/decided/in-effect/under-review/superseded/withdrawn; permanent.
- `decision.decision_evidence_links`, `decision.decision_assessment_links`, `decision.decision_relationships` — LINK; typed unique relationship/version; immutable/superseded; permanent.
- `decision.recommendations` — ROOT; BK Recommendation number; draft/issued/accepted-as-input/declined/expired/superseded; retain when consequential.
- `decision.recommendation_sources` — LINK; BK Recommendation/source/role; immutable with issued Recommendation.

## Knowledge, workflow, and notifications

- `knowledge.knowledge_records` — ROOT; BK Knowledge number; draft/active/retired; permanent.
- `knowledge.knowledge_versions` — VERSION; BK Knowledge/version; draft/in-review/published/challenged/deprecated/superseded; published immutable.
- `knowledge.validity_contexts`, `knowledge.knowledge_sources` — OWNED/LINK; parent/version-scoped unique key; immutable with published version.
- `knowledge.knowledge_reviews`, `knowledge.knowledge_usage_outcomes` — EVENT; review/use ID; immutable; permanent learning history.
- `workflow.workflow_definitions` — ROOT; BK workflow code; active/retired; permanent.
- `workflow.workflow_versions` — VERSION; BK workflow/version; draft/published/deprecated; published immutable.
- `workflow.workflow_instances` — ROOT; BK workflow instance number; running/waiting/completed/cancelled/migrated/failed; operational history archive.
- `workflow.workflow_subjects` — LINK; BK instance/subject/type; active/ended; retained with instance.
- `workflow.state_transitions` — EVENT; BK aggregate/sequence; immutable/permanent.
- `notification.notification_intents` — ROOT; BK source event/purpose/policy idempotency key; pending/rendering/delivering/completed/expired/cancelled/failed; retention by communication class.
- `notification.notification_audiences` — OWNED; BK intent/recipient/purpose; pending/suppressed/eligible/completed; retain disclosure decision.
- `notification.message_renditions` — VERSION/OWNED; BK audience/language/template/version; immutable; content retention by class.
- `notification.delivery_attempts`, `notification.notification_acknowledgements` — EVENT; provider/attempt or acknowledgement ID; immutable; retention by regulatory/operational need.

## Governance, AI, audit, analytics, memory, and integration

- `governance.policies`, `governance.committees`, `governance.meetings`, `governance.resolutions`, `governance.contracts`, `governance.risks` — ROOT with stable tenant business codes; governed lifecycles; permanent institutional archive.
- `governance.policy_versions`, `governance.contract_versions` — VERSION; numbered/effective; approved/executed versions immutable and permanent.
- `governance.committee_memberships`, `governance.resolution_votes`, `governance.contract_obligations`, `governance.risk_links` — OWNED/LINK; parent-scoped business uniqueness; historical retention with roots.
- `ai.ai_use_cases` — ROOT; BK use-case code; proposed/approved/suspended/disabled/retired; permanent governance record.
- `ai.ai_interactions`, `ai.ai_recommendations` — ROOT/EVENT-LIKE; BK interaction/recommendation ID; immutable generation, status appended; risk-based retention.
- `ai.ai_recommendation_sources`, `ai.ai_reviews` — LINK/EVENT; parent/source or review ID; immutable; accountability retention.
- `audit.domain_events`, `audit.audit_entries` — EVENT; UUID business key; append-only; partitioned long-term retention.
- `audit.outbox_messages` — OWNED; Domain Event unique; pending/published/retry/quarantined; retained through reconciliation then archived.
- `analytics.kpi_definitions` — ROOT; BK KPI code; active/retired; permanent.
- `analytics.kpi_versions` — VERSION; BK KPI/version; published immutable.
- `analytics.kpi_observations`, `analytics.report_snapshots` — SNAPSHOT; definition/period/as-of/restatement business key; immutable; analytics retention/archive.
- `memory.memory_manifests`, `memory.archive_batches` — ROOT; BK manifest/batch code; preparing/sealed/verified/failed/superseded; permanent custody history.
- `memory.memory_manifest_items`, `memory.archive_batch_items` — OWNED/SNAPSHOT; parent/item sequence; sealed immutable.
- `integration.external_systems` — ROOT; BK external-system code; proposed/active/suspended/retired; permanent integration history.
- `integration.external_identifiers` — LINK; BK system/type/value/effective-start; active/superseded/ended; permanent identity lineage.
- `integration.inbound_messages` — EVENT; BK system/message-id; received/validated/processed/quarantined/failed; retained for replay/audit policy.
- `integration.sync_conflicts` — ROOT; BK conflict number; open/under-review/resolved/accepted-as-is/superseded; permanent where domain history affected.

## Soft delete rule

Only unreferenced drafts and ephemeral staging rows may be physically removed under controlled maintenance. All other tables use explicit lifecycle, revocation, end, supersession, restriction, disposition, or archive states. No generic `is_deleted` flag is permitted on immutable history.
