# O83 Care — Full Architecture Rewrite Task for Codex

## Role

You are the Lead Architecture Documentation Engineer for O83 Care.

Your job is to rewrite the entire approved architecture document set into complete, self-contained Markdown files that are internally consistent, implementation-ready, and faithful to the current O83 Care foundation.

You are not allowed to patch or append fragments.

Every changed document must be rewritten as a complete file from the first line to the final acceptance criteria.

---

## Working Directory

Project root:

`C:\Users\natta\OneDrive\Desktop\Codex`

Expected folders:

```text
source_architecture/
rewritten_architecture/
review/
backup/
```

---

## Non-Negotiable Rules

1. Never modify the source files directly.
2. Copy the original source set into `backup/` before any rewrite.
3. Write all rewritten files into `rewritten_architecture/`.
4. Preserve existing filenames unless this task explicitly requires a new file.
5. Never provide a patch, diff-only response, partial section, or placeholder.
6. Every rewritten Markdown file must be complete and readable by itself.
7. Do not invent business rules.
8. When information is missing or contradictory, record it in `review/OPEN_QUESTIONS.md`; do not guess.
9. Preserve approved intent, context, responsibility, evidence, timestamps, decision history, and organizational memory.
10. Do not begin application coding. This task is documentation rewrite only.
11. Use UTF-8.
12. Use `_` in filenames. Never use `/` inside filenames.
13. Maintain “Clarity over Decoration.”
14. AI assists; humans decide.
15. Human safety and urgent real-world action come before evidence capture or workflow compliance.

---

## Mandatory Reading Order

Read these first, if present:

1. `source_architecture/00_foundation.md`
2. `source_architecture/01_design_principles.md`
3. `source_architecture/18_project_glossary.md`
4. `source_architecture/02_domain_model.md`
5. `source_architecture/03_organization_model.md`
6. `source_architecture/04_operation_model.md`
7. `source_architecture/05_knowledge_model.md`
8. `source_architecture/06_governance_model.md`
9. `source_architecture/07_ai_advisor_model.md`
10. `source_architecture/08_evidence_model.md`
11. `source_architecture/09_decision_model.md`
12. `source_architecture/10_workflow_model.md`

Then read all remaining Markdown files in numeric order.

---

## Current Architecture Decisions That Must Be Reflected

### Operational Truth

Operational Truth is not absolute truth.

It is the organization’s best current understanding at a specific time, based on recorded observations, verifiable evidence, documented decisions, context, and accountable human responsibility.

New evidence may revise current understanding without deleting the previous understanding.

### Reopen

Reopen is not automatically a system failure.

It represents new evidence, recurrence, incomplete resolution, or a revised organizational understanding.

The previous close event remains in history.

### Case First, Incident Later

Every incoming report creates a separate Case first.

Five reports create five Cases before investigation.

Cases must never be automatically merged.

After investigation, an authorized human may determine that multiple Cases relate to one Incident.

Every original Case remains individually traceable after association.

### Repeat Incident Investigation

A later report near a previous problem must not automatically become a reopen or a new unrelated incident.

Investigation must consider:

- same location
- same asset or component
- same symptom
- same root cause
- relationship to the prior repair
- time since prior close
- available evidence

The human decision and reason must be recorded.

### Responsibility Ledger and Responsibility Chain

Do not rely on one global Owner field as the primary accountability model.

Record who was responsible for each responsibility, role, action, decision, verification, handover, and period of time.

Every responsibility record must retain person, role, relationship, timestamps, context, evidence, decision references, state, and handover history.

A new person must not inherit moral responsibility for a predecessor’s decisions, but must be able to learn from the predecessor’s recorded context and outcomes.

### Responsibility, Authority, Commitment, Capability, and Priority

These concepts must remain separate:

- Responsibility: what a person or role is accountable for
- Authority: what a role is permitted to decide, assign, interrupt, override, or approve
- Commitment: the work a person is currently committed to
- Capability: relevant skill, qualification, knowledge, or operational ability
- Availability: whether the person can act at that time
- Organizational Priority: the priority decided by authorized juristic or management roles
- Execution Sequence: the order in which the technician performs assigned work
- SLA or Due Commitment: the required completion boundary

A single `priority` field must not silently represent all of these meanings.

### Priority Decision Architecture

- The system provides recommendations and the supporting facts.
- Residents may provide opinions about urgency and impact.
- The juristic person, dispatcher, building manager, or authorized assigner makes the organizational priority decision.
- Technicians arrange their practical execution sequence while respecting assigned deadlines, safety, emergency overrides, and organizational priority.
- Every override or change must be recorded with the actor, role, reason, timestamp, affected commitments, and consequence.

### Emergency Autonomy

Outside normal working hours, or when authorized assigners are unavailable, technicians and duty staff may act within their responsibility and capability to protect life, safety, property, and essential services.

They must not wait for a software approval when delay would increase harm.

Records, explanations, timestamps, and available evidence must be added as soon as reasonably possible after stabilization.

The system must distinguish:

- event time
- action time
- record creation time
- upload time

### Evolution of Understanding

Preserve:

- observations
- hypotheses
- confidence or uncertainty
- available evidence
- decisions made at that time
- new evidence
- changed hypotheses
- revised decisions
- outcomes

Never rewrite the organization’s previous understanding to make it appear that the final conclusion was always known.

### Organizational Memory

Separate the active Operational System conceptually from long-term Organizational Memory.

Closed and historical records must remain preserved and usable for future learning.

Organizational Memory includes Cases, Incidents, Operations, evidence, decisions, responsibility records, outcomes, failed hypotheses, successful practices, exceptions, and historical context.

### Context-Bound Knowledge

Knowledge is not universally valid.

Every reusable lesson, recommendation, or best practice must include validity context, such as:

- asset and component
- model or version
- location and environment
- governance version
- workflow version
- effective period
- assumptions
- limitations
- evidence base
- last verification
- superseded status

AI must compare historical context with current context before recommending reuse.

### AI as Organizational Mirror

AI may discover patterns, summarize history, compare context, provide warnings, and recommend.

AI must expose sources, assumptions, limitations, and uncertainty.

AI must never approve, punish, verify evidence, close work, hide disagreement, fabricate evidence, or become the accountable decision owner.

### Stewardship

Organizational Memory is an asset of the juristic person for the long-term benefit of the co-owners.

Committee members, juristic managers, staff, contractors, developers, and AI are temporary stewards, not personal owners of organizational memory.

### Founder Independence and Architectural Memory

The system must preserve why important architecture and governance decisions were made.

Architecture Decision Records must retain:

- context
- problem
- alternatives
- decision
- rejected alternatives
- trade-offs
- expected consequences
- responsible person and role
- timestamp
- later reviews
- superseding decisions

The project must remain understandable after the original founder, committee, manager, company, and developers have changed.

---

## Rewrite Scope

Inspect every `.md` file in `source_architecture/`.

For each file:

1. Determine whether it is affected by the current architecture decisions.
2. Rewrite the complete file if affected.
3. Copy it unchanged to `rewritten_architecture/` only if it is genuinely unaffected and already complete.
4. Ensure cross-document language is consistent.
5. Preserve the original filename.
6. Update version and status transparently.
7. Include a short `Revision Summary` inside each rewritten file.
8. Do not claim `Approved` unless the source was previously approved; use `Review` for materially rewritten files.

At minimum, deeply review these files:

```text
00_foundation.md
01_design_principles.md
02_domain_model.md
03_organization_model.md
04_operation_model.md
05_knowledge_model.md
06_governance_model.md
07_ai_advisor_model.md
08_evidence_model.md
09_decision_model.md
10_workflow_model.md
12_notification_model.md
13_reporting_and_analytics_model.md
14_security_and_audit_model.md
16_system_architecture.md
17_ui_ux_principles.md
18_project_glossary.md
19_architecture_decision_records.md
23_data_architecture.md
25_event_driven_architecture.md
28_project_governance.md
29_documentation_standards.md
30_ai_collaboration_principles.md
31_reference_architecture.md
34_database_blueprint.md
36_event_catalog.md
37_ui_blueprint.md
38_ai_prompting_standard.md
41_workflow_catalog.md
42_state_machine_catalog.md
43_permission_matrix.md
44_resident_experience.md
45_technician_experience.md
46_manager_workspace.md
47_committee_workspace.md
48_evidence_standards.md
49_kpi_catalog.md
```

Do not assume the remaining files are unaffected. Inspect all of them.

---

## Required Deliverables

Create:

```text
rewritten_architecture/
  00_foundation.md
  ...
  50_integration_catalog.md

review/
  INVENTORY.md
  CHANGE_IMPACT_MATRIX.md
  CROSS_DOCUMENT_CONTRADICTIONS.md
  OPEN_QUESTIONS.md
  REWRITE_SUMMARY.md
  VALIDATION_REPORT.md
```

### `INVENTORY.md`

List every source file, its source version/status, target version/status, and whether it was rewritten or copied unchanged.

### `CHANGE_IMPACT_MATRIX.md`

Map each current architecture decision to every affected Markdown file and section.

### `CROSS_DOCUMENT_CONTRADICTIONS.md`

List contradictions found before rewriting and explain how they were resolved. If a contradiction cannot be resolved without a human decision, place it in `OPEN_QUESTIONS.md`.

### `VALIDATION_REPORT.md`

Validate the rewritten set against these scenarios:

1. Five duplicate reports exist before technician investigation.
2. Human later associates them with one Incident.
3. A repair recurs two days after close due to a defective replacement part.
4. A similar problem occurs six months later at an uncertain location.
5. A technician performs urgent work outside office hours.
6. Existing PM work is interrupted by a critical incident.
7. Evidence cannot be captured immediately because of danger or battery failure.
8. A manager verifies work without visiting the site.
9. A technician or supervisor fixes work outside the system.
10. New evidence changes the organization’s previous hypothesis.
11. A new employee reviews decisions made by a predecessor.
12. AI finds a historical solution whose asset context is no longer valid.
13. A committee requests removal of an embarrassing timeline record.
14. The original founder and all original staff are no longer present.

For every scenario, report:

- expected system behavior
- responsible role
- authority source
- required records
- evidence behavior
- timeline behavior
- AI boundary
- unresolved gap

---

## Quality Standard

A rewritten file is acceptable only when:

- it is complete and self-contained
- it explains purpose before implementation detail
- its terminology matches the glossary
- facts, observations, opinions, recommendations, and decisions are distinct
- responsibility and authority are distinguishable
- historical records are immutable
- timestamps preserve event chronology
- emergency reality is supported
- AI boundaries are explicit
- organizational memory and context are preserved
- the file is useful to both humans and coding agents
- it does not contain unnecessary filler or repeated slogans

---

## Execution Process

1. Inventory the source folder.
2. Create the backup.
3. Read the mandatory documents.
4. Produce `CHANGE_IMPACT_MATRIX.md`.
5. Rewrite files in dependency order.
6. Run a cross-document consistency review.
7. Run the fourteen validation scenarios.
8. Produce all review reports.
9. Do not modify files outside this project folder.
10. Do not begin coding.
11. Stop after all deliverables are created.

---

## Final Response

When complete, return only:

1. number of files found
2. number rewritten
3. number copied unchanged
4. unresolved questions count
5. failed validation scenarios count
6. location of output folders
7. concise list of decisions requiring human review

Do not proceed to software implementation until the rewritten architecture has been reviewed and approved by the human.
