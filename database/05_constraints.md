# Database Constraints and Business Rules

Version: 1.0  
Status: Production Logical Model

## Purpose

Constraints prevent invalid meaning at the closest safe boundary. Declarative primary, foreign, unique, not-null, check, exclusion, and generated-value constraints are preferred. Cross-aggregate or history-aware rules that cannot be declarative require a documented transactional invariant and validation test; they must not be left to UI behavior.

## Universal constraints

- IDs are non-null UUIDs and never reused.
- Tenant-owned child and parent must share `juristic_person_id`; cross-tenant relationships use `intake.case_transfers` or another explicit governed sharing record.
- Business keys are unique within `(juristic_person_id, entity namespace)` and cannot be changed after external acknowledgement without alias history.
- `row_version` increases monotonically for mutable aggregate roots.
- Effective periods satisfy start before end; prohibited overlaps use exclusion semantics by relationship type.
- An actor is either human or service principal as allowed; consequential Decisions require a human.
- Published/issued/executed/sealed versions cannot change business payload or digest.
- Archived rows cannot return to active state except through a recorded restore batch/Decision.

## Core business invariants

1. One accepted `intake.reports` row has exactly one `intake.cases` row, and each Case references exactly one Report.
2. Cases cannot be merged. Duplicate/similar status is a classification or association, never identity replacement.
3. `incident.incidents` requires a human `decision.decision_records` verification Decision and an issued Understanding Assessment. No suspected Incident row is allowed.
4. `incident.case_incident_associations` requires Case, Incident, human Decision, Authority source, reason, and effective time. Disassociation creates a new state/version, never deletion.
5. An Operation must have at least one origin (`incident_operations` or `maintenance_plan_operations`) and at least one work subject (`operation_assets` or an explicitly approved non-asset Location scope) before authorization.
6. A Work Step belongs to one Operation; parent Work Step belongs to the same Operation; step hierarchy is acyclic.
7. Commitment acceptance requires accepting relationship effective at acceptance time; replacement links one prior Commitment and cannot erase prior due/outcome.
8. Organizational Priority, Execution Sequence, SLA Application, due Commitment, Responsibility, Authority, Capability, and Availability remain different records.
9. High-risk verification cannot use the same effective performer and verifier unless an emergency exception Decision explicitly permits and later independent review is required.
10. Emergency action may precede recording, but action time cannot be later falsified as approval time.

## Temporal and graph constraints

- Mandate delegation is acyclic; child scope/action set is a subset of active parent; child validity cannot exceed parent.
- Decision `supersedes` and `withdraws` graphs are acyclic. A Decision cannot supersede itself or a later recorded Decision without an explicit correction Decision.
- Asset `parent`, `feeds`, and `controls` relationships follow type-specific cycle policy; `replaced_by` is acyclic and temporally ordered.
- Taxonomy `parent` hierarchy is acyclic within one Taxonomy. Stable term code never changes meaning across versions.
- Workflow version ancestry and instance migration are acyclic; an instance binds exactly one active version at any time.
- Responsibility and Mandate periods may overlap only when policy explicitly permits joint responsibility/Authority; overlap is visible, not silently collapsed.

## Evidence constraints

- Original Evidence object key and digest are immutable.
- A Rendition references its Evidence Item and transformation provenance; it cannot claim to be original.
- Issued Evidence Package Version membership is immutable.
- Evidence disposition requires policy and human Decision/Authority when content is restricted, placed on hold, archived, or removed.
- Legal hold blocks destructive disposition.
- Attachment promotion to Evidence is one-to-zero-or-one; rejected/quarantined attachment remains traceable.

## Decision, knowledge, and AI constraints

- Consequential Decision requires responsible human, acting role, Authority source, decision time, outcome, and rationale.
- Evidence considered and omitted must be representable; empty evidence is allowed only with explicit reason/emergency context.
- Published Knowledge Version requires Validity Context, at least one source, human review, assumptions, limitations, and verification time/state.
- AI Recommendation requires approved active AI Use Case, source citations or an explicit no-source limitation, model/provider version, uncertainty, and human review before adoption.
- AI Review cannot create a human Decision unless a human reviewer is the actor; AI/service principals cannot be responsible Decision owners.

## SLA and contract constraints

- SLA Application references an immutable SLA Policy Version effective for the classification Decision.
- Target is exactly one Case or Operation.
- Clock events form an ordered state machine; resume requires a prior open pause; satisfaction and cancellation stop the active clock; later restatement appends, never edits.
- Contract Obligation validity lies within Contract Version validity and references responsible party, service scope, acceptance/evidence rules, and remedy behavior.

## Orphan prevention

Historical parents use restricted deletion. A parent can be archived while children remain addressable. Draft-only owned rows may be removed before publication/event/reference; otherwise end/supersede/dispose. Periodic orphan checks cover Storage objects, outbox events, evidence links, manifest items, external identifiers, workflow subjects, and projection lineage.

## Unique rules

- Report source idempotency: `(tenant, channel/external_system, source_message_id)` when supplied.
- One Case per Report.
- One effective account link per Supabase Auth user and tenant.
- One active external identifier mapping per `(system, type, value)` and entity type.
- One effective vote per Resolution and Committee Membership.
- One Package Version number per Evidence Package; one Version number per policy/workflow/SLA/KPI/Knowledge root.
- One outbox row per Domain Event/destination.
- One processed result per inbound idempotency key unless a recorded replay generation is opened.
