# O83 Care Engineering Implementation Master Roadmap

Version: 1.0  
Status: Execution Baseline  
Role owner: Technical Program Manager  
Planning horizon: 16 ordered sprints, 5 release gates

## Purpose

This roadmap translates the approved O83 Care architecture, database design, and SQL implementation into independently executable engineering increments. It governs sequencing and acceptance; it does not contain application code. The roadmap preserves the architecture invariants: every Report creates a separate Case, only authorized human investigation verifies an Incident, Operations perform work, history is immutable, Operational Truth is revisable, organizational powers remain separate, safety precedes workflow, AI remains advisory, knowledge is context-bound, and Organizational Memory belongs to the Juristic Person.

## Baseline and assumptions

The implementation starts from the 32 files in `architecture_v2/`, 15 database documents, 17 SQL scripts, and the approved review corpus. The SQL is a generated baseline, not a production-deployed database: live PostgreSQL parsing, migration execution, Supabase advisors, the full RLS matrix, Storage reconciliation, restore testing, and production-shaped query plans remain Sprint 0–15 gates. Jurisdictional retention periods, SLA calendars, notification providers, recovery objectives, supported languages, and exact committee authority rules are governed configuration inputs.

Sprints are dependency-ordered, not calendar promises. A sprint may begin only after every listed predecessor passes its completion gate. Teams may work in parallel inside a sprint where aggregate ownership and contracts permit it.

## Delivery principles

1. Implement vertical slices around business outcomes, not tables or screens alone.
2. Keep domain writes behind authorized commands; expose purpose-specific queries and projections.
3. Preserve actor, acting role, Authority, reason, evidence basis, event/action/record/upload time, prior state, and resulting state for material changes.
4. Treat RLS, object grants, Storage authorization, service credentials, and domain Authority as distinct controls.
5. Use append, relate, and supersede semantics; do not add generic destructive edit or delete paths.
6. Make degraded, offline, provider-failure, and human-error paths testable from the first relevant feature.
7. Require one manual path for every AI-assisted capability and one non-digital continuity path for safety-critical operations.
8. Ship search, analytics, and Organizational Memory as rebuildable projections over authoritative records.

## Workstreams

| Workstream | Features | Primary outcome |
|---|---|---|
| Platform and assurance | F01–F05, F37, F47–F48 | Reproducible environments, security, observability, durable events, continuity, release safety |
| Organization and managed estate | F06–F11 | Durable parties, powers, property, assets, and governed vocabularies |
| Intake and resident service | F12–F15, F40 | Safe Report-to-Case service with correction, transfer, communication, and dispute history |
| Understanding and event verification | F16–F19 | Investigation, revisable Operational Truth, human Incident verification, recurrence |
| Operational delivery | F20–F24, F41 | Operations, Commitments, sequencing, SLA, technician field work, offline recovery |
| Evidence and decisions | F25–F29 | Private object handling, provenance, verification, accountable decisions, workflow history |
| Communication and external systems | F30–F31 | Durable notifications and anti-corruption boundaries |
| Governance and stewardship | F32–F36, F46 | Policy, committee, vendors, safety control, knowledge, memory, retention |
| Insight and workspaces | F38–F39, F42–F45 | Search, governed reporting, role workspaces, mediated AI advice |

## Sprint and release map

| Sprint | Theme | Feature IDs | Exit unlocks |
|---:|---|---|---|
| 0 | Bootstrap and live database proof | F01–F02 | Trusted build/deploy foundation |
| 1 | Security, identity, telemetry, events | F03–F05, F37 | Auditable tenant-safe domain delivery |
| 2 | Organization and estate master data | F06–F11 | Valid actors, Authority, property, asset, taxonomy context |
| 3 | Intake and resident foundation | F12–F14, F40 | Safe separate Case creation and resident tracking |
| 4 | Investigation and verified Incidents | F16–F19 | Human-verified Incident identity and recurrence handling |
| 5 | Operations and technician work | F20–F23, F41 | Accountable work execution and verification submission |
| 6 | Offline and Evidence | F24–F27 | Field resilience and evidentiary integrity |
| 7 | Decisions and workflow | F28–F29 | Governed decisions, revisions, and orchestration |
| 8 | Communication, disputes, integrations | F15, F30–F31 | Durable participant communication and external boundaries |
| 9 | Governance, suppliers, safety | F32–F34 | Reserved decisions and life-safety operational control |
| 10 | Knowledge, memory, retention | F35–F36, F46 | Durable, context-bound institutional stewardship |
| 11 | Search, reporting, analytics | F38–F39 | Rebuildable discovery and governed measures |
| 12 | Manager and committee workspaces | F42–F43 | Integrated operational and oversight surfaces |
| 13 | Governed AI collaboration | F44–F45 | Advisory AI with citations, review, disablement, and evaluation |
| 14 | Resilience and continuity | F47 | Tested degraded/manual modes and disaster recovery |
| 15 | Production assurance and rollout | F48 | Controlled production launch and stewardship transfer |

Release gates are R0 after Sprint 2, R1 after Sprint 4, R2 after Sprint 8, R3 after Sprint 13, and R4 after Sprint 15. Details are in [04_release_plan.md](04_release_plan.md).

## Critical path

```mermaid
flowchart LR
  S0["S0 Bootstrap + database proof"] --> S1["S1 Identity, isolation, audit/events"]
  S1 --> S2["S2 Organization + estate"]
  S2 --> S3["S3 Report + Case"]
  S3 --> S4["S4 Investigation + Incident"]
  S4 --> S5["S5 Operations"]
  S5 --> S6["S6 Offline + Evidence"]
  S6 --> S7["S7 Decision + Workflow"]
  S7 --> S8["S8 Communication + integrations"]
  S8 --> S9["S9 Governance + safety"]
  S9 --> S10["S10 Knowledge + memory + retention"]
  S10 --> S11["S11 Search + analytics"]
  S11 --> S12["S12 Integrated workspaces"]
  S12 --> S13["S13 AI"]
  S13 --> S14["S14 Continuity"]
  S14 --> S15["S15 Production rollout"]
```

The strict critical path is intentional. It prevents screens from inventing business rules before Authority, history, and tenancy exist and prevents AI or analytics from becoming an accidental source of truth.

## Program controls

Each feature has one accountable product owner, domain owner, technical lead, security reviewer, and test owner. Each sprint begins with approved inputs and ends with traceable evidence: requirements/architecture references, contract changes, migration checksum, automated test results, security findings, accessibility results where applicable, operational runbook, telemetry, and a demonstration using representative scenarios.

Changes to Case/Incident meaning, immutable history, Responsibility/Authority separation, evidence provenance, AI limits, or tenant boundaries require an ADR and architecture review. Other changes still require impact analysis across schema, permissions, events, retention, reporting, offline behavior, and migration compatibility.

## Program completion

The roadmap is complete when all 48 features satisfy the shared Definition of Done, all 16 sprint gates pass, critical risks have implemented controls and accepted residual ownership, the clean and production-shaped migrations pass, RLS and Storage negative tests pass, the 31 validated operational scenarios pass end-to-end, Organizational Memory export/restore is demonstrated, manual continuity is drilled, and the Juristic Person accepts operational stewardship. See [06_definition_of_done.md](06_definition_of_done.md), [07_acceptance_criteria.md](07_acceptance_criteria.md), and [review/IMPLEMENTATION_PLAN_REVIEW.md](../review/IMPLEMENTATION_PLAN_REVIEW.md).
