# O83 Care Sprint Plan

Version: 1.0  
Status: Execution Baseline

## Planning conventions

There are 16 dependency-ordered sprints numbered 0–15. Estimates use capacity units defined in [09_estimation.md](09_estimation.md), not elapsed-time promises. Each sprint includes design clarification, implementation, tests, security and accessibility review where relevant, operational documentation, and acceptance evidence. A sprint is not complete when code is merged; it is complete when its business outcome works through the deployed development environment and its negative paths are proven.

## Sprint 0 — Project bootstrap and database execution proof

**Objectives:** Establish reproducible delivery and prove that the approved SQL executes on the selected Supabase/PostgreSQL versions.  
**Scope:** F01–F02; repository conventions, environments, secrets, CI quality gates, migration packaging, clean deployment, validation query, advisor baseline, seed fixture strategy, and rollback/forward-correction rehearsal.  
**Required inputs:** Approved SQL 00–16, migration plan, target Supabase versions, environment ownership, initial RTO/RPO assumptions.  
**Deliverables:** Development and test environments; protected delivery workflow; migration artifact/checksum; live object-count evidence; first schema catalog; database, security, and performance advisor reports.  
**Blocked by:** Nothing.  
**Risks:** SQL parser/version incompatibility, generated constraints with poor deployment characteristics, unsafe secrets, unmanaged environment drift.  
**Completion criteria:** Clean build succeeds twice; migration is repeatable; 131 tables and expected objects validate; no unreviewed critical advisor finding; failure procedure is rehearsed.  
**Definition of Done:** Shared DoD plus evidence attached to R0 readiness record.

## Sprint 1 — Identity, tenant isolation, telemetry, and durable events

**Objectives:** Establish who is acting, for which Juristic Person and purpose, with complete denial/change traceability.  
**Scope:** F03–F05 and F37; Auth-to-Person mapping, service principals, acting context, tenant selection, RLS/grants, audit envelope, domain events/outbox, correlation, logs/metrics/traces, security alerting.  
**Required inputs:** Sprint 0 environment and schema; role archetypes; data classifications.  
**Deliverables:** Login/session lifecycle; tenant-safe access layer; audit/event publication path; observability dashboards; policy-test harness.  
**Blocked by:** Sprint 0.  
**Risks:** Cross-tenant exposure, stale JWT access, service-role misuse, audit secrets, outbox duplication.  
**Completion criteria:** Full initial role × tenant negative matrix passes; disabled/revoked identity is denied; at-least-once events deduplicate; actor/reason/correlation are visible end-to-end.  
**Definition of Done:** No broad client table grants; privileged actions are server-side, scoped, and audited.

## Sprint 2 — Organization, Authority, property, assets, and taxonomy

**Objectives:** Create durable organizational and managed-estate context without collapsing Responsibility, Authority, Commitment, Capability, Availability, Priority, Sequence, or SLA.  
**Scope:** F06–F11; parties, roles, relationships, Mandates/delegation/revocation, Responsibility Ledger, capability/availability, handover, buildings/rooms/locations/occupancy, assets/components/topology, maintenance plans, governed vocabulary.  
**Required inputs:** Sprint 1 security; approved initial role/taxonomy codes; property import data and source lineage.  
**Deliverables:** Administrative master-data workflows; effective-dated views; import/reconciliation tools; succession and authority-expiry alerts.  
**Blocked by:** Sprint 1.  
**Risks:** Identity duplication, inferred Authority, graph cycles, invalid overlaps, destructive import correction.  
**Completion criteria:** Temporal overlap/cycle tests pass; role loss immediately affects access; historical labels/mandates remain resolvable; property and asset changes supersede rather than rewrite.  
**Definition of Done:** R0 gate passes and master data is ready for safe operational reference.

## Sprint 3 — Resident intake, safety triage, and Case service

**Objectives:** Accept every incoming report safely and create exactly one independently traceable Case.  
**Scope:** F12–F14 and F40; digital/assisted intake, acknowledgement, safety diversion, emergency reconstruction, Case parties, submitted/corrected context, wrong-building transfer, resident Case timeline and evidence submission entry.  
**Required inputs:** Organization/property/taxonomy data; accessibility/language baseline; emergency guidance approved by governance.  
**Deliverables:** Resident/assisted Report flow; Case service; acknowledgement and exception queue; immutable correction/transfer history; resident projection.  
**Blocked by:** Sprint 2.  
**Risks:** accidental deduplication, unsafe form delay, privacy leakage, wrong resident/building, transfer responsibility gap.  
**Completion criteria:** Five similar submissions create five Cases; offline/assisted entries reconcile without merge; destination must accept transfer; residents see only permitted Case information.  
**Definition of Done:** R1 intake scenarios and accessibility tests pass.

## Sprint 4 — Investigation, Operational Truth, and verified Incidents

**Objectives:** Support evidence-aware inquiry and human verification without converting suspicion into Incident identity.  
**Scope:** F16–F19; investigation scope, observations, hypotheses, Assessment versions, known/inferred/disputed/unknown presentation, human Incident verification, per-Case associations, classification, recurrence, reopen, bulk preview/per-item result.  
**Required inputs:** Sprint 3 Cases; Authority and capability context; state and classification catalogs.  
**Deliverables:** Investigator workspace slice; Assessment history; Incident verification command; association/disassociation trail; recurrence review.  
**Blocked by:** Sprint 3.  
**Risks:** premature Incident creation, hidden contradictory evidence, partial batch association, false recurrence automation.  
**Completion criteria:** Incident cannot exist without authorized human verification; Cases remain separate; contradictory assessments coexist; reopen preserves closure; batch outcomes reconcile item by item.  
**Definition of Done:** Required leak, wrong-cause, disagreement, and recurrence scenarios pass.

## Sprint 5 — Operations, commitments, SLA, and technician field work

**Objectives:** Coordinate accountable reactive and preventive work while preserving independent organizational concepts.  
**Scope:** F20–F23 and F41; Operation origins/subjects, Work Steps, offers/acceptance/decline, capability and availability checks, priority decisions, execution sequence, interruptions, SLA clocks, technician field workflow, verification request.  
**Required inputs:** Verified Incidents and Maintenance Plans; responsibility/authority model; SLA policy inputs.  
**Deliverables:** Operation planning and field execution slices; commitment queue; priority and SLA projections; interruption/recovery trail.  
**Blocked by:** Sprint 4.  
**Risks:** owner-field collapse, unsafe assignment, SLA treated as personal promise, hidden reprioritization, self-verification.  
**Completion criteria:** Preventive work needs no fake Incident; commitments are explicit; sequence differs from priority; blocked/access time follows policy; high-risk self-verification is denied.  
**Definition of Done:** Operation lifecycle and midnight emergency reconstruction scenarios pass.

## Sprint 6 — Offline field resilience and Evidence

**Objectives:** Preserve safe field work and trustworthy evidence across connectivity/device failures.  
**Scope:** F24–F27; durable local command queue, clock uncertainty, idempotency/conflict taxonomy, upload intents, private buckets, scanning/quarantine, immutable originals, renditions, provenance, custody, integrity, packages, verification attempts, evidence-loss response.  
**Required inputs:** Technician workflow, Case/Operation security, Storage provider configuration, evidence standards.  
**Deliverables:** Offline synchronization; signed upload/download boundary; reconciliation jobs; Evidence and package views; verifier slice.  
**Blocked by:** Sprint 5.  
**Risks:** device compromise, duplicate actions, metadata/object divergence, malware, evidence overwrite or silent loss.  
**Completion criteria:** Device loss revokes access; sync never uses last-write-wins for material conflict; original bytes cannot be overwritten; orphan/digest scans work; lost Evidence traces affected Decisions.  
**Definition of Done:** Offline, delayed upload, damaged phone, contradictory/lost evidence scenarios pass.

## Sprint 7 — Accountable decisions and workflow orchestration

**Objectives:** Make consequential choices and lifecycle transitions explainable, revisable, and policy-controlled.  
**Scope:** F28–F29; Decision records, evidence/assessment links, alternatives, dissent, appeals/supersession, versioned workflow definitions, instances, subjects, immutable transitions, timers and exceptions.  
**Required inputs:** Authority, Assessments, Evidence, Operations, state catalog.  
**Deliverables:** Decision composer/history; workflow engine boundary; transition validation; exception queues; as-of Decision Evolution view.  
**Blocked by:** Sprint 6.  
**Risks:** workflow becomes source of truth, silent decision overwrite, timer loops, Authority inferred from state.  
**Completion criteria:** Revision creates a new Decision; workflows cannot mutate another aggregate directly; invalid transitions fail; every material transition identifies actor, reason, previous/current state, and Authority where required.  
**Definition of Done:** Decision Evolution and workflow replay tests pass.

## Sprint 8 — Case disputes, notifications, and integrations

**Objectives:** Communicate durably, handle resident challenge fairly, and isolate external semantics.  
**Scope:** F15 and F30–F31; dispute classification/review/appeal, notification intent/audience/rendition/attempt/acknowledgement, retries/escalation, provider adapters, inbound message idempotency, external identifiers, synchronization conflicts.  
**Required inputs:** Case, workflow, Decision, domain events, provider selections.  
**Deliverables:** Communication center; resident dispute flow; delivery reconciliation; anti-corruption adapters; provider outage queues.  
**Blocked by:** Sprint 7.  
**Risks:** duplicate or over-disclosed messages, provider receipt treated as human acknowledgement, infinite dispute loop, external IDs replacing O83 IDs.  
**Completion criteria:** Content is purpose-minimized; delivery attempts are immutable; new Evidence is distinguished from disagreement; independent review and appeal finality work; replay cannot duplicate domain actions.  
**Definition of Done:** R2 operational release gate passes.

## Sprint 9 — Governance, suppliers, major incidents, and safety-critical control

**Objectives:** Implement lawful oversight and resolve life-safety and supplier-failure gaps before broad rollout.  
**Scope:** F32–F34; policies, committee terms/meetings/quorum/resolutions/votes, contracts/obligations, contractor abandonment and substitution, risk register, external emergency command handoff, safety-critical isolation/lockout/custody/certification/return-to-service, protected dissent and stop-work.  
**Required inputs:** Decisions/workflow, Evidence, notifications, asset and Authority models, local governance rules.  
**Deliverables:** Governance workspace slices; supplier controls; major-incident command record; critical-asset isolation board; independent return-to-service path.  
**Blocked by:** Sprint 8.  
**Risks:** unlawful electronic governance, local/external command conflict, unsafe return to service, retaliation for dissent, orphaned contractor access.  
**Completion criteria:** Fire/lift scenarios follow external command; critical assets remain isolated until qualified independent acceptance and authorized Decision; contractor access/custody are revoked/transferred; dissent cannot be erased.  
**Definition of Done:** All critical architecture-gap controls have executable acceptance evidence.

## Sprint 10 — Knowledge, Organizational Memory, privacy, and retention

**Objectives:** Preserve context-bound learning and long-term stewardship without creating a duplicate source of truth.  
**Scope:** F35–F36 and F46; Knowledge versions/validity/source/review/outcome, memory manifests/archive batches, export/import verification, retention classes, holds, restriction/redaction, disposition approval, archive retrieval.  
**Required inputs:** Operational outcomes, Evidence, Decisions, governance policies, jurisdictional retention decisions.  
**Deliverables:** Knowledge review/reuse flow; sealed manifest/export; retention and legal-hold operations; lineage and archive retrieval tools.  
**Blocked by:** Sprint 9.  
**Risks:** universalized lessons, mutable memory copy, premature deletion, archive traceability loss, vendor lock-in.  
**Completion criteria:** Published Knowledge requires validity context; conflicting versions remain visible; manifests verify; holds block disposition; successor organization/developer can interpret and restore exported records.  
**Definition of Done:** Steward-replacement and long-horizon retrieval tests pass.

## Sprint 11 — Search, reporting, and governed analytics

**Objectives:** Make records discoverable and measures reproducible without promoting projections to Operational Truth.  
**Scope:** F38–F39; tenant/role-aware search, rebuildable projections, KPI versions, observations, report snapshots, restatements, lineage, suppression, as-of reporting, recurrence and cycle escalation metrics.  
**Required inputs:** Complete operational domains, event stream, Knowledge/Memory, KPI governance inputs.  
**Deliverables:** Search service and index rebuild; reporting catalog; operational dashboards; reproducibility and data-quality checks.  
**Blocked by:** Sprint 10.  
**Risks:** stale projection, restricted-data leakage, KPI gaming, person ranking, irreproducible restatement.  
**Completion criteria:** Index can be destroyed/rebuilt; permissions are identical to source access; each report resolves formula/source/as-of/version; suppressed populations cannot be inferred.  
**Definition of Done:** KPI guardrail and historical-reproduction tests pass.

## Sprint 12 — Manager and committee workspaces

**Objectives:** Integrate role-specific operational and oversight work without bypassing domain commands or least privilege.  
**Scope:** F42–F43; manager queues, capacity/priority/SLA/exception views, remote verification controls, handover; committee packs, reserved decisions, conflicts, votes/dissent, drill-through boundaries, stewardship transition.  
**Required inputs:** Search/reporting, governance, operational domains, permissions.  
**Deliverables:** Integrated manager and committee experiences; role-specific dashboards; decision drill-through; transition packs.  
**Blocked by:** Sprint 11.  
**Risks:** dashboard authority, committee micromanagement, excessive personal-data access, misleading aggregate status.  
**Completion criteria:** Every action invokes an authorized use case; restricted Evidence remains restricted; metrics link to definition/source; remote verification enforces qualification and separation.  
**Definition of Done:** Manager/committee replacement scenarios pass.

## Sprint 13 — Governed AI collaboration

**Objectives:** Add an Organizational Mirror that helps people compare, summarize, and question without deciding.  
**Scope:** F44–F45; use-case approval/suspension, mediated context retrieval, prompt-injection defenses, citations, model/provider versions, recommendation/uncertainty/validity match, human review/adoption, disable switch, evaluation and change control.  
**Required inputs:** Governed Knowledge/search, human workspaces, privacy/retention rules, AI provider decision.  
**Deliverables:** AI context broker; advisory panel; review log; evaluation suite; operational disablement and provider-change runbook.  
**Blocked by:** Sprint 12.  
**Risks:** automation bias, hallucination, prompt injection, privacy leakage, outdated context, provider lock-in.  
**Completion criteria:** AI cannot directly mutate Incident, priority, responsibility, verification, closure, or governance; citations resolve; outdated/conflicting context is visible; manual path and disable switch work.  
**Definition of Done:** Wrong/outdated AI and historical-practice conflict scenarios pass.

## Sprint 14 — Resilience, disaster recovery, and manual continuity

**Objectives:** Prove decades-long operational survivability through service, provider, power, staffing, and data failures.  
**Scope:** F47; backup/restore, regional/provider failure, manual/voice/paper intake, emergency contact trees, offline authority cache limits, recovery sequencing, reconciliation, archive restore, observability incident response, game days.  
**Required inputs:** Entire functional system except final production rollout; approved RTO/RPO and continuity owners.  
**Deliverables:** Tested disaster-recovery and continuity plans; manual kits; reconciliation tooling; recovery evidence and improvement backlog.  
**Blocked by:** Sprint 13.  
**Risks:** paper records lost, split-brain chronology, stale Authority, untested restore, provider dependency.  
**Completion criteria:** Power/internet/provider outage drills preserve Report/Case identity and emergency work; full restore meets objectives; reconciliation records uncertainty and does not invent chronology.  
**Definition of Done:** R3 resilience gate passes with accountable business sign-off.

## Sprint 15 — Production assurance, pilot, and controlled rollout

**Objectives:** Demonstrate system, people, process, and stewardship readiness for production operation.  
**Scope:** F48; production-shaped load/performance, complete RLS/Storage matrix, penetration and accessibility testing, 31 scenario regression, migration rehearsal, data import, training, support, pilot, rollback/forward correction, go/no-go and post-launch review.  
**Required inputs:** All prior sprint evidence; named risk owners; production configuration and providers.  
**Deliverables:** Signed readiness dossier; production migration; runbooks/on-call; training and stewardship transfer; pilot results; launch and hypercare plan.  
**Blocked by:** Sprints 0–14.  
**Risks:** configuration drift, incomplete training, scale surprises, unresolved critical findings, false confidence from happy-path testing.  
**Completion criteria:** All mandatory criteria in [07_acceptance_criteria.md](07_acceptance_criteria.md) pass; no open unaccepted critical risk; recovery and exit work; Juristic Person authorizes launch.  
**Definition of Done:** R4 production gate is signed by business, security, operations, privacy, data, and technical authorities.
