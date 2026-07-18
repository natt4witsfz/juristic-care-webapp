# Database Entity and Table Catalog

Version: 1.0  
Status: Production Logical Model

## Purpose

This catalog is the authoritative registry of 128 O83 Care tables. Names are schema-qualified. “Root” means aggregate root; “owned” means lifecycle-controlled by a root; “reference” means governed master/policy data; “event” means append-only; “projection metadata” means a reproducible snapshot or manifest, not a second source of truth.

## Table registry

| # | Table | Kind | Purpose / ownership / lifecycle |
|---:|---|---|---|
| 1 | `iam.user_accounts` | owned | Maps Supabase Auth users to durable Person identity; disable/relink, never reuse |
| 2 | `iam.service_principals` | root | Technical identities with scoped purpose and rotation lifecycle |
| 3 | `iam.access_decisions` | event | Records consequential authorization allow/deny basis and policy version |
| 4 | `org.juristic_persons` | root | Enduring tenant/data owner identity |
| 5 | `org.people` | root | Durable human identity independent of role/account |
| 6 | `org.external_organizations` | root | Vendor, insurer, utility, regulator, emergency service, management company identity |
| 7 | `org.organization_relationships` | owned | Effective party-to-Juristic-Person relationship |
| 8 | `org.role_definitions` | reference | Version-stable role codes and descriptions |
| 9 | `org.role_assignments` | owned | Effective role held under an organization relationship |
| 10 | `org.mandates` | root | Scoped Authority grant, delegation, revocation, and source |
| 11 | `org.responsibility_definitions` | reference | Governed responsibility types/outcomes |
| 12 | `org.responsibility_assignments` | root | Effective accountable duty for scope |
| 13 | `org.responsibility_ledger_entries` | event | Immutable responsibility state/action/context history |
| 14 | `org.handovers` | root | Transfer of future stewardship and current context |
| 15 | `org.handover_items` | owned | Item-level responsibility/commitment/risk/evidence acknowledgement |
| 16 | `org.capability_assertions` | root | Evidence-backed qualification/skill assertion with validity |
| 17 | `org.availability_periods` | owned | Effective availability assertion with source and confidence |
| 18 | `property.properties` | root | Managed property/estate identity under Juristic Person |
| 19 | `property.buildings` | root | Durable Building identity within property |
| 20 | `property.locations` | root | Effective hierarchical place identity including common areas/zones |
| 21 | `property.location_aliases` | owned | Historical/localized/external location labels |
| 22 | `property.rooms` | root | Durable private/common Unit identity linked to location |
| 23 | `property.occupancy_relationships` | owned | Effective Person/organization relationship to Room/Location |
| 24 | `property.asset_types` | reference | Governed Asset/Component type and required context rules |
| 25 | `property.assets` | root | Durable managed Asset identity and lifecycle |
| 26 | `property.asset_components` | owned | Replaceable/diagnosable component identity and lineage |
| 27 | `property.asset_relationships` | owned | Typed effective topology/dependency/replacement relationship |
| 28 | `property.asset_identifiers` | owned | Serial, vendor, legacy, and integration identifiers |
| 29 | `property.maintenance_plans` | root | Versioned proactive maintenance intent/schedule/criteria |
| 30 | `property.maintenance_plan_assets` | owned | Effective plan applicability to Asset/Component |
| 31 | `taxonomy.taxonomies` | root | Vocabulary identity, owner, purpose, governance mode |
| 32 | `taxonomy.taxonomy_versions` | owned | Immutable published vocabulary version |
| 33 | `taxonomy.taxonomy_terms` | owned | Stable code/label/effective status in one version line |
| 34 | `taxonomy.taxonomy_term_relationships` | owned | Typed hierarchy/equivalence/supersession relationships |
| 35 | `intake.reports` | root | Immutable original incoming Report and submitted context |
| 36 | `intake.cases` | root | Exactly one separately traceable Case for one Report |
| 37 | `intake.case_party_relationships` | owned | Reporter, affected party, contact, representative, observer relationship |
| 38 | `intake.case_context_assertions` | owned | Versioned submitted/corrected location, Asset, category, impact assertions |
| 39 | `intake.case_communications` | event | Case-specific inbound/outbound communication history |
| 40 | `intake.case_reopens` | event | Reasoned Case reopen event preserving prior closure |
| 41 | `intake.case_transfers` | root | Accepted/rejected cross-building or cross-tenant transfer decision |
| 42 | `investigation.investigations` | root | Structured investigative question and lifecycle |
| 43 | `investigation.investigation_cases` | owned | Effective Investigation scope membership for Cases |
| 44 | `investigation.observations` | root | Attributed perception/measurement with time/context |
| 45 | `investigation.hypotheses` | root | Proposed explanation and status without truth claim |
| 46 | `investigation.hypothesis_evidence_links` | owned | Evidence supporting/challenging/neutral to Hypothesis |
| 47 | `investigation.understanding_assessments` | root | Versioned known/inferred/disputed/unknown Operational Truth assessment |
| 48 | `investigation.assessment_evidence_links` | owned | Evidence considered/omitted/challenging an Assessment |
| 49 | `incident.incidents` | root | One human-verified operational event |
| 50 | `incident.case_incident_associations` | root | Reasoned many-to-many Case/Incident relationship with Decision/Authority |
| 51 | `incident.incident_assets` | owned | Incident relevance to Asset/Component/Location |
| 52 | `incident.incident_reopens` | event | Human-authorized Reopen preserving prior close |
| 53 | `incident.incident_classifications` | owned | Versioned governed category/severity/safety assertions |
| 54 | `work.operations` | root | Bounded work unit with reactive or proactive origin |
| 55 | `work.incident_operations` | owned | Explicit Incident-to-Operation relationship |
| 56 | `work.maintenance_plan_operations` | owned | Maintenance Plan/version-to-Operation origin |
| 57 | `work.operation_assets` | owned | Asset/Component/Location work subject and effect |
| 58 | `work.work_steps` | owned | Operation-owned executable step; never a root Operation |
| 59 | `work.commitments` | root | Accepted obligation, scope, due boundary, and lifecycle |
| 60 | `work.operation_interruptions` | event | Critical override, safe stop, affected commitment, recovery plan |
| 61 | `work.verification_records` | root | Human verification attempt, criteria, method, result, limitations |
| 62 | `work.priority_decisions` | root | Organizational Priority Decision and supersession |
| 63 | `work.execution_sequence_entries` | event | Material technician ordering/sequence change and rationale |
| 64 | `work.sla_policies` | root | Stable SLA identity and governance owner |
| 65 | `work.sla_policy_versions` | owned | Immutable service class, calendar, target, pause, breach rules |
| 66 | `work.sla_applications` | root | SLA version applied to Case/Operation with classification Decision |
| 67 | `work.sla_clock_events` | event | Start, pause, resume, satisfy, breach, cancel clock history |
| 68 | `evidence.upload_attachments` | root | Upload intent/object metadata before evidentiary promotion |
| 69 | `evidence.evidence_items` | root | Immutable provenanced Evidence identity and original object reference |
| 70 | `evidence.evidence_renditions` | owned | Derived/redacted/annotated/transcribed representation |
| 71 | `evidence.evidence_links` | owned | Typed Evidence-to-claim/domain-record relationship |
| 72 | `evidence.evidence_packages` | root | Stable package identity for one verification/investigation question |
| 73 | `evidence.evidence_package_versions` | owned | Immutable issued package manifest version |
| 74 | `evidence.evidence_package_members` | owned | Item/rendition membership, order, inclusion reason |
| 75 | `evidence.evidence_custody_events` | event | Possession/control/export transfer history |
| 76 | `evidence.evidence_integrity_checks` | event | Digest/availability/manifest verification outcome |
| 77 | `evidence.evidence_dispositions` | event | Restriction, legal hold, archive, lawful disposal Decision/outcome |
| 78 | `decision.decision_records` | root | Accountable human Decision with Authority, rationale, consequences |
| 79 | `decision.decision_evidence_links` | owned | Considered/omitted/supporting/challenging Evidence links |
| 80 | `decision.decision_assessment_links` | owned | Understanding Assessment relationship and role in Decision |
| 81 | `decision.decision_relationships` | owned | Affirm/withdraw/supersede/appeal relationships, acyclic by type |
| 82 | `decision.recommendations` | root | Human/system advisory option with no Authority |
| 83 | `decision.recommendation_sources` | owned | Evidence/Knowledge/record sources and context |
| 84 | `knowledge.knowledge_records` | root | Stable Knowledge/Lesson identity and stewardship |
| 85 | `knowledge.knowledge_versions` | owned | Immutable content, confidence, status, effective/superseded version |
| 86 | `knowledge.validity_contexts` | owned | Assumptions, environment, Asset/model, policy/workflow/version limitations |
| 87 | `knowledge.knowledge_sources` | owned | Decision/Operation/Evidence/outcome/failed-Hypothesis derivation |
| 88 | `knowledge.knowledge_reviews` | event | Publish/challenge/reverify/deprecate/supersede human review |
| 89 | `knowledge.knowledge_usage_outcomes` | event | Context match, use, result, and later evaluation |
| 90 | `workflow.workflow_definitions` | root | Stable workflow identity, business owner, policy authority |
| 91 | `workflow.workflow_versions` | owned | Immutable states/transitions/roles/timers/exceptions definition |
| 92 | `workflow.workflow_instances` | root | One running/completed orchestration bound to exact version |
| 93 | `workflow.workflow_subjects` | owned | Typed relationship from workflow instance to domain aggregates |
| 94 | `workflow.state_transitions` | event | Immutable previous/current state, actor, reason, Authority, evidence |
| 95 | `notification.notification_intents` | root | Governed requirement to communicate source event/purpose |
| 96 | `notification.notification_audiences` | owned | Authorized recipient/relationship/channel/disclosure selection |
| 97 | `notification.message_renditions` | owned | Immutable rendered language/template/policy version and content digest |
| 98 | `notification.delivery_attempts` | event | Provider/channel attempt, result, provider receipt, timestamps |
| 99 | `notification.notification_acknowledgements` | event | Explicit recipient acknowledgement where required |
| 100 | `governance.policies` | root | Stable policy identity and approval owner |
| 101 | `governance.policy_versions` | owned | Immutable approved content/structured rules/effective period |
| 102 | `governance.committees` | root | Governing body and term identity |
| 103 | `governance.committee_memberships` | owned | Effective Person membership, office, voting rights, conflicts |
| 104 | `governance.meetings` | root | Agenda/quorum/session record |
| 105 | `governance.resolutions` | root | Committee Decision/resolution and effective consequence |
| 106 | `governance.resolution_votes` | owned | Member vote, abstention, conflict, dissent |
| 107 | `governance.contracts` | root | Stable Vendor/Juristic-Person agreement identity |
| 108 | `governance.contract_versions` | owned | Immutable executed/amended terms and effective period |
| 109 | `governance.contract_obligations` | owned | Scoped obligation, SLA, Asset/service, evidence, acceptance, remedy |
| 110 | `governance.risks` | root | Hazard/threat, likelihood, impact, owner, controls, review |
| 111 | `governance.risk_links` | owned | Typed Risk relationship to Asset, Incident, policy, Decision, control |
| 112 | `ai.ai_use_cases` | root | Approved purpose, owner, risk, data scope, evaluation and status |
| 113 | `ai.ai_interactions` | root | Prompt purpose/context/model/output metadata and generated artifact digest |
| 114 | `ai.ai_recommendations` | root | AI advisory output with uncertainty, assumptions, validity match |
| 115 | `ai.ai_recommendation_sources` | owned | Durable cited source and context comparison |
| 116 | `ai.ai_reviews` | event | Human accept/decline/correct/escalate evaluation; never AI approval |
| 117 | `audit.domain_events` | event | Immutable accepted domain fact envelope |
| 118 | `audit.outbox_messages` | owned | Transactional publication state for Domain Event |
| 119 | `audit.audit_entries` | event | Tamper-evident security/administrative allow, deny, read, export, change |
| 120 | `analytics.kpi_definitions` | root | Stable KPI identity, owner, purpose, guardrails |
| 121 | `analytics.kpi_versions` | owned | Immutable formula/population/exclusions/dimensions version |
| 122 | `analytics.kpi_observations` | projection metadata | Reproducible as-of metric result and lineage |
| 123 | `analytics.report_snapshots` | projection metadata | Immutable issued/restated report manifest and source snapshot |
| 124 | `memory.memory_manifests` | root | Organizational Memory/export/integrity manifest for declared scope |
| 125 | `memory.memory_manifest_items` | owned | Source record/object/schema/policy/taxonomy digest and status |
| 126 | `memory.archive_batches` | root | Governed archive/restore/disposition custody operation |
| 127 | `memory.archive_batch_items` | owned | Per-record/object archive result and reconciliation |
| 128 | `integration.external_systems` | root | External system identity, trust, owner, contract, lifecycle |
| 129 | `integration.external_identifiers` | owned | Typed effective mapping from O83 identity to external identity |
| 130 | `integration.inbound_messages` | event | Immutable inbound envelope, idempotency, validation, quarantine |
| 131 | `integration.sync_conflicts` | root | Offline/integration conflict, alternatives, human/automatic resolution |

## Entity count versus table count

The approved domain review identified 78 business/supporting objects. This design uses 131 tables because immutable versions, relationship history, event history, package membership, and security/audit separation require tables beyond aggregate count. No additional business feature is introduced; the extra tables preserve meaning and history.
