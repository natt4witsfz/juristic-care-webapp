# Database Relationship Catalog

Version: 1.0  
Status: Production Logical Model

## Purpose

This catalog defines mandatory foreign-key and historical association paths. Column names are logical specifications, not SQL. `→` means a required or optional foreign-key reference as stated; junction tables represent many-to-many relationships.

## Universal relationships

- Every tenant-owned row has required `juristic_person_id → org.juristic_persons.id` with same-tenant enforcement on all referenced tenant parents.
- Every human-created material row has `created_by_person_id → org.people.id` and, where the action exercises a role, `acting_role_assignment_id → org.role_assignments.id`.
- Authority-bearing actions have `mandate_id → org.mandates.id` or a typed external/statutory/emergency Authority source recorded with a Decision.
- Version/relationship/event tables reference their stable parent root and never substitute text business keys for foreign keys.
- `created_by_auth_user_id` is not a domain relationship; Supabase account attribution resolves through `iam.user_accounts`.

## IAM and organization

| Child table | Parent relationships and cardinality |
|---|---|
| `iam.user_accounts` | required Person; optional Supabase Auth user while disabled account history remains; many accounts per Person over time |
| `iam.service_principals` | required owning Juristic Person and responsible organization relationship |
| `iam.access_decisions` | required actor principal, Juristic Person, policy version; optional target record reference via governed resource type/id |
| `org.organization_relationships` | Juristic Person + exactly one Person or external organization; non-overlapping effective identity by relationship type |
| `org.role_assignments` | organization relationship + role definition; optional Mandate source |
| `org.mandates` | grantee organization relationship/role; grantor Person/body; optional parent Mandate; policy/resolution/contract/Decision source |
| `org.responsibility_assignments` | responsibility definition + accountable relationship/role + typed scope; optional supervising assignment |
| `org.responsibility_ledger_entries` | responsibility assignment + actor + optional Action/Decision/Evidence/Handover references |
| `org.handovers` | from/to organization relationship and optional Responsibility assignment; Decision/mandate authorizing transition |
| `org.handover_items` | Handover + exactly one typed subject (Responsibility, Commitment, Risk, Decision, Evidence package, workflow instance) |
| `org.capability_assertions` | Person/external-organization relationship + capability taxonomy term + issuer + Evidence Item/Decision where required |
| `org.availability_periods` | Person/resource relationship + source; optional superseded availability row |

## Property and assets

| Child table | Parent relationships and cardinality |
|---|---|
| `property.properties` | Juristic Person; one Juristic Person has many properties |
| `property.buildings` | property; one property has many Buildings |
| `property.locations` | property, optional Building, optional parent Location; hierarchy acyclic and effective-dated |
| `property.location_aliases` | Location + optional external system/taxonomy language |
| `property.rooms` | Building + Location; durable Room identity survives renumbering |
| `property.occupancy_relationships` | Room/Location + organization relationship; many-to-many over effective time |
| `property.assets` | Asset type + current primary Location; optional owning external organization/Contract |
| `property.asset_components` | Asset + optional parent Component; predecessor/successor component relationships preserve replacement |
| `property.asset_relationships` | from Asset/Component → to Asset/Component; typed, effective, cycle rules by type |
| `property.asset_identifiers` | Asset/Component + issuer/external system; unique effective mapping |
| `property.maintenance_plans` | policy version + workflow version + SLA policy version where applicable |
| `property.maintenance_plan_assets` | Maintenance Plan ↔ Asset/Component many-to-many with effective applicability |

## Taxonomy

| Child table | Parent relationships and cardinality |
|---|---|
| `taxonomy.taxonomy_versions` | Taxonomy; sequential immutable versions |
| `taxonomy.taxonomy_terms` | Taxonomy + introduced version + optional superseded term; stable code never repurposed |
| `taxonomy.taxonomy_term_relationships` | from term → to term; typed parent/equivalent/supersedes relationship; hierarchy acyclic within taxonomy |

## Intake and investigation

| Child table | Parent relationships and cardinality |
|---|---|
| `intake.reports` | source organization relationship/account/channel; submitted Building/Room/Location references are assertions, not mutable current values |
| `intake.cases` | exactly one Report and one Juristic Person; unique Report relationship |
| `intake.case_party_relationships` | Case ↔ organization relationship many-to-many with party-role taxonomy, consent, effective period |
| `intake.case_context_assertions` | Case + assertion type + exactly one typed value/reference; optional prior assertion and Decision |
| `intake.case_communications` | Case + party relationship + optional Notification Intent/Delivery Attempt |
| `intake.case_reopens` | Case + Decision + prior Case close transition |
| `intake.case_transfers` | source Case/Juristic Person + destination Juristic Person + destination Case if accepted + Decision/Authority |
| `investigation.investigations` | initiating Case/Decision; responsible assignment and workflow instance |
| `investigation.investigation_cases` | Investigation ↔ Case many-to-many with scope reason/effective period |
| `investigation.observations` | Investigation + observer relationship/device + optional Location/Asset/Operation + Evidence links |
| `investigation.hypotheses` | Investigation + author; optional prior Hypothesis version |
| `investigation.hypothesis_evidence_links` | Hypothesis ↔ Evidence Item many-to-many with support/challenge role |
| `investigation.understanding_assessments` | Investigation + author/reviewer + optional superseded Assessment |
| `investigation.assessment_evidence_links` | Assessment ↔ Evidence Item; considered/omitted/support/challenge role |

## Incident and work

| Child table | Parent relationships and cardinality |
|---|---|
| `incident.incidents` | required verification Decision + Understanding Assessment; no pre-verification row |
| `incident.case_incident_associations` | Case ↔ Incident many-to-many; required Decision, Mandate, reason, Evidence package/assessment |
| `incident.incident_assets` | Incident ↔ Asset/Component/Location with relationship type and confidence |
| `incident.incident_reopens` | Incident + Decision + previous close State Transition |
| `incident.incident_classifications` | Incident + taxonomy term + Decision/Assessment; effective/superseded history |
| `work.operations` | responsible assignment + workflow instance + Operation type term; at least one Incident or Maintenance Plan origin and one work subject |
| `work.incident_operations` | Incident ↔ Operation many-to-many with scope/effect |
| `work.maintenance_plan_operations` | Maintenance Plan/version ↔ Operation; planned occurrence identity unique |
| `work.operation_assets` | Operation ↔ Asset/Component/Location many-to-many with work-subject role |
| `work.work_steps` | Operation + optional parent Work Step + capability term; hierarchy acyclic inside Operation |
| `work.commitments` | Operation/Work Step scope + accepting organization relationship + offering actor + SLA Application if relevant; replacement Commitment link |
| `work.operation_interruptions` | interrupted Operation/Commitment + interrupting Incident/Operation + Priority Decision/emergency rationale |
| `work.verification_records` | Operation + verifier relationship/role + criteria policy/version + result Decision + Evidence Package |
| `work.priority_decisions` | Decision Record + target Case/Incident/Operation + priority term; supersession via Decision relationship |
| `work.execution_sequence_entries` | technician relationship + Commitment/Operation + previous sequence entry + interruption/Decision where material |
| `work.sla_policy_versions` | SLA Policy + policy/contract source + calendar taxonomy/config version |
| `work.sla_applications` | SLA Policy Version + exactly one Case or Operation target + classification Decision |
| `work.sla_clock_events` | SLA Application + event type + source transition/Decision/blocking relationship |

## Evidence, decisions, knowledge, and AI

| Child table | Parent relationships and cardinality |
|---|---|
| `evidence.upload_attachments` | uploader account/person + Storage bucket/object key + Case/Operation intake context; optional promoted Evidence Item |
| `evidence.evidence_items` | custodian relationship + original attachment/object + classification/retention policy + source Observation/action |
| `evidence.evidence_renditions` | Evidence Item + parent rendition + transformation actor/tool/version; immutable lineage |
| `evidence.evidence_links` | Evidence Item/Rendition ↔ typed domain record/claim; link owns relevance assertion |
| `evidence.evidence_package_versions` | Evidence Package + compiler + optional prior package version |
| `evidence.evidence_package_members` | Package Version ↔ Evidence Item/Rendition many-to-many |
| `evidence.evidence_custody_events` | Evidence Item/Package + from/to custodian + export/archive reference |
| `evidence.evidence_integrity_checks` | Evidence Item/Rendition/Manifest + checking service/person + expected/observed digest |
| `evidence.evidence_dispositions` | Evidence Item/Rendition + policy/Decision/legal hold/archive batch |
| `decision.decision_records` | responsible human + acting role + Authority source + target typed scope |
| `decision.decision_evidence_links` | Decision ↔ Evidence many-to-many with considered/omitted/support/challenge role |
| `decision.decision_assessment_links` | Decision ↔ Understanding Assessment many-to-many with role |
| `decision.decision_relationships` | from Decision → to Decision; affirm/withdraw/supersede/appeal; acyclic for supersession |
| `decision.recommendations` | author Person/system + target question/scope; optional Knowledge/AI Recommendation source |
| `decision.recommendation_sources` | Recommendation ↔ Evidence/Knowledge/Decision/Assessment typed sources |
| `knowledge.knowledge_versions` | Knowledge Record + author/reviewer + previous/superseded version |
| `knowledge.validity_contexts` | Knowledge Version + Asset/Component/type/model/Location/environment/policy/workflow/effective constraints |
| `knowledge.knowledge_sources` | Knowledge Version ↔ Operation/Decision/Evidence/Hypothesis/outcome |
| `knowledge.knowledge_reviews` | Knowledge Version + human reviewer + Decision/Authority |
| `knowledge.knowledge_usage_outcomes` | Knowledge Version + Case/Incident/Operation + context match + outcome Assessment |
| `ai.ai_interactions` | AI Use Case + requesting account/person + model/provider external system + authorized context snapshot |
| `ai.ai_recommendations` | AI Interaction + optional corresponding generic Recommendation + human-review state |
| `ai.ai_recommendation_sources` | AI Recommendation ↔ durable domain source with citation/context-match result |
| `ai.ai_reviews` | AI Recommendation/Interaction + human reviewer + adopted/declined Decision where consequential |

## Workflow, notifications, governance, audit, analytics, memory, integration

| Child table | Parent relationships and cardinality |
|---|---|
| `workflow.workflow_versions` | Workflow Definition + policy version + prior version |
| `workflow.workflow_instances` | Workflow Version + responsible assignment + current-state projection |
| `workflow.workflow_subjects` | Workflow Instance ↔ typed domain aggregate; one primary subject, many related |
| `workflow.state_transitions` | Workflow Instance/domain aggregate + actor/role + previous/current state terms + Decision/Authority/Evidence |
| `notification.notification_intents` | source Domain Event + policy/template version + responsible function |
| `notification.notification_audiences` | Intent ↔ Case party/organization relationship/contact channel with disclosure basis |
| `notification.message_renditions` | Intent + Audience/language/template policy; correction links prior rendition |
| `notification.delivery_attempts` | Audience/Rendition + provider external system; idempotency key unique |
| `notification.notification_acknowledgements` | Audience/Attempt + acknowledging party/account |
| `governance.policy_versions` | Policy + approving Decision/resolution + prior version |
| `governance.committee_memberships` | Committee ↔ Person/organization relationship with term/office/conflict |
| `governance.meetings` | Committee + convening policy + chair/secretary roles |
| `governance.resolutions` | Meeting + Decision Record + policy/risk/contract target |
| `governance.resolution_votes` | Resolution ↔ Committee Membership; one effective vote per member/resolution |
| `governance.contracts` | Juristic Person + vendor external organization + responsible assignment |
| `governance.contract_versions` | Contract + approving Decision/resolution + prior executed version |
| `governance.contract_obligations` | Contract Version + SLA Policy Version + Asset/service taxonomy + responsible party |
| `governance.risks` | owner responsibility + review Decision + taxonomy; versions append |
| `governance.risk_links` | Risk ↔ typed Asset/Incident/Policy/Contract/Decision/Control |
| `audit.domain_events` | aggregate type/id/version + actor/role + correlation/causation; tenant required |
| `audit.outbox_messages` | exactly one Domain Event; publication attempts/state |
| `audit.audit_entries` | actor principal + target resource + access Decision/policy; correlation to Domain Event optional |
| `analytics.kpi_versions` | KPI Definition + approving policy/Decision + prior version |
| `analytics.kpi_observations` | KPI Version + tenant/period/dimensions + Report Snapshot/source manifest |
| `analytics.report_snapshots` | report definition/version + Memory Manifest/source watermark + restated snapshot link |
| `memory.memory_manifest_items` | Manifest ↔ typed source record/object/schema/policy/taxonomy with digest |
| `memory.archive_batches` | policy/Decision + custodian/from-to storage tier |
| `memory.archive_batch_items` | Archive Batch ↔ source record/object + result/reconciliation |
| `integration.external_identifiers` | External System + typed domain entity; effective mapping and supersession |
| `integration.inbound_messages` | External System + tenant + idempotency key + resulting Report/Event/Conflict |
| `integration.sync_conflicts` | inbound/offline command + affected aggregate versions + resolution Decision/person |

## Dependency and orphan rules

Parent deletion is restricted for historical relationships. Lifecycle end, revocation, supersession, archive, or lawful disposition is used instead. Owned draft-only rows may be cascade-removed only before any domain event, evidence, decision, or external acknowledgement references them. Cross-schema references follow aggregate ownership; no table writes a parent’s lifecycle. Deferred circular foreign keys are avoided by creating roots first and adding optional consequence links later; Decision targets use typed relationship tables where referential integrity is required.

## Relationship count

The catalog defines 184 required foreign-key or governed association relationships, excluding universal actor and tenant relationships repeated on every table. Universal tenant and actor relationships are mandatory additional controls, not optional inferred links.
