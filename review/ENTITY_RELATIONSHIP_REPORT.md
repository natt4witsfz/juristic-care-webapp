# Entity Relationship Validation Report

Version: 1.0  
Status: Database Translation Review

## Purpose

This report validates logical relationships, cardinality, ownership, temporal behavior, and traceability. It is a domain relationship model, not SQL or a physical schema.

## Relationship rules

1. Cross-aggregate relationships use durable identifiers and explicit relationship records when the link has business meaning, time, Authority, evidence, or history.
2. Many-to-many relationships are never hidden in arrays or overwritten foreign keys.
3. A projection may join across contexts but cannot own or change source truth.
4. Effective-dated relationships preserve both business-effective and recorded time where later correction matters.
5. Cross-Juristic-Person relationships are denied unless a governed transfer or sharing decision explicitly authorizes them.

## Validated relationships

| ID | Relationship and cardinality | Owning context / history | Validation |
|---|---|---|---|
| REL-01 | Juristic Person 1 → many Buildings | Property context; effective identity history | Missing normative owner/model; critical |
| REL-02 | Juristic Person 1 → many organizational relationships | Organization; effective-dated | Sound |
| REL-03 | Person many ↔ many Juristic Persons through Organization Relationship | Organization; never infer from account | Sound |
| REL-04 | Person 1 → many User Accounts | Identity/Security; disable rather than reuse | Conceptual only |
| REL-05 | Person 1 → many Resident/Staff/Technician role periods | Organization; effective-dated role history | Sound |
| REL-06 | Committee 1 → many Committee Memberships; Person 1 → many memberships | Governance; term/vote history | Sound, local quorum rules pending |
| REL-07 | Vendor 1 → many Contracts | Contract/procurement context not defined | Missing |
| REL-08 | Contract many ↔ many SLA Policies/service scopes through effective terms | Contract/policy; executed versions immutable | Missing |
| REL-09 | Mandate many → 1 grantor and many → 1 grantee party/role | Organization/Governance; delegation chain retained | Sound conceptually |
| REL-10 | Mandate 0..many → 0..1 parent Mandate | Organization; acyclic delegation graph | Constraint not explicit |
| REL-11 | Responsibility Assignment many → 1 responsible party/role | Organization; effective-dated | Sound |
| REL-12 | Responsibility Assignment 0..many → Mandates | Organization; Authority required only for governed actions | Sound conceptually |
| REL-13 | Responsibility Assignment 1 → many Ledger Entries | Organization; append-only | Sound |
| REL-14 | Handover many ↔ many Responsibilities/Commitments through handover items | Organization/Work; item acknowledgement retained | Cardinality not explicit |
| REL-15 | Person 1 → many Capability Assertions | Organization; issuer/effective status retained | Sound; taxonomy missing |
| REL-16 | Person/resource 1 → many Availability Periods | Organization/Scheduling; source precedence needed | Partial |
| REL-17 | Operation 1 → many Commitments | Work; lifecycle independent from Operation state | Sound |
| REL-18 | Commitment many → 1 accepting party and 1 defined scope | Work/Organization; substitution creates new Commitment | Replacement workflow missing |
| REL-19 | SLA Policy 1 → many classified Cases/Operations through applicability records | Policy/Workflow; version effective at classification | Applicability/clock rules missing |
| REL-20 | Priority Decision many → 1 governed scope | Decision context; supersession chain | Sound |
| REL-21 | Execution Sequence Decision many → 1 technician/work queue and many commitments | Work; material changes historical | Persistence threshold missing |
| REL-22 | Report exactly 1 ↔ exactly 1 Case | Intake owns atomic creation; immutable | Normative and sound |
| REL-23 | Case 1 → many Case Party Relationships | Intake/Case; effective-dated/consent history | Missing explicit entity |
| REL-24 | Case 1 → many Context Assertions | Intake/Case; submitted values preserved, corrections supersede | Missing explicit entity |
| REL-25 | Building 1 → many Rooms/Locations | Property context; renumber/history required | Missing |
| REL-26 | Room many ↔ many Residents through occupancy relationships | Property/Organization; effective-dated | Missing |
| REL-27 | Location 1 → many Cases/Observations/Operations by assertion/reference | Owning records retain source/time | Partial; hierarchy absent |
| REL-28 | Building/Location 1 → many Assets | Asset context; effective location history | Missing |
| REL-29 | Asset 1 → many Asset Components | Asset; replacement/predecessor history | Missing |
| REL-30 | Asset many ↔ many Assets through typed Asset Relationships | Asset; effective graph and cycle rules | Missing |
| REL-31 | Asset/Component 1 → many Operations/Evidence/Knowledge links | Source contexts own relationship records | Conceptual only |
| REL-32 | Case 1 → many Investigations | Investigation owns inquiry; Case remains Intake-owned | Sound |
| REL-33 | Investigation many ↔ many Cases through explicit scope membership | Investigation; membership/time/source retained | Cardinality implied, not formalized |
| REL-34 | Investigation 1 → many Observations | Investigation; append/correction history | Sound |
| REL-35 | Investigation 1 → many Hypotheses | Investigation; support/challenge history | Sound |
| REL-36 | Investigation 1 → many Understanding Assessments | Investigation; ordered supersession | Sound |
| REL-37 | Assessment many ↔ many Evidence Items through claim/evidence links | Evidence relationships own provenance and relevance | Sound conceptually |
| REL-38 | Assessment 0..many → Decisions | Decision owns adoption/action; assessment remains independent | Sound |
| REL-39 | Case many ↔ many Incidents through Case-Incident Association | Incident Management; human Decision/Authority/evidence mandatory | Normative and sound |
| REL-40 | Incident 1 → many Operations | Work; Operation owns work lifecycle | Sound for reactive work |
| REL-41 | Proactive Maintenance Plan 1 → many Operations without Incident | Asset/Work boundary | Unsupported by current Incident-required Operation model; critical |
| REL-42 | Operation 1 → many Work Steps/Tasks if adopted | Operation aggregate owns; no independent cross-root mutation | Undefined semantic decision |
| REL-43 | Operation 1 → many Interruption records | Work; append-only | Sound conceptually |
| REL-44 | Operation 1 → many Verification Records | Work/Decision/Evidence; every attempt retained | Sound |
| REL-45 | Evidence Item 1 → many Renditions | Evidence aggregate owns transformations | Sound |
| REL-46 | Evidence Item many ↔ many domain claims/records through Evidence Links | Evidence/domain contexts; relevance and claim type historical | Logical link entity not explicitly cataloged in architecture |
| REL-47 | Evidence Package many ↔ many Evidence Items through package membership | Evidence; issued package version immutable | Sound |
| REL-48 | Evidence Item 1 → many Chain-of-Custody Events | Evidence; append-only | Sound |
| REL-49 | Attachment 0..1 → Evidence Item or quarantine outcome | Intake/Evidence boundary; original upload identity retained | Undefined |
| REL-50 | Decision many ↔ many Evidence Items/Assessments/Recommendations | Decision owns consideration links and omission statement | Sound conceptually |
| REL-51 | Decision 0..many → prior Decisions through affirm/withdraw/supersede links | Decision; directed acyclic semantic graph | Cycle/current-selection rules incomplete |
| REL-52 | Recommendation many → 1 question/scope and many source records | Originating context; no Authority | Generic lifecycle incomplete |
| REL-53 | AI Recommendation many → 1 AI Interaction Record | AI governance; immutable generation metadata | Sound conceptually |
| REL-54 | AI Interaction many ↔ many authorized source records | AI adapter/audit; purpose/access snapshot required | Retention and link granularity partial |
| REL-55 | Knowledge Record many ↔ many source records | Knowledge; derivation lineage retained | Sound |
| REL-56 | Knowledge Record 1 → many versions/Validity Context snapshots | Knowledge; supersession, not overwrite | Sound |
| REL-57 | Lesson Learned is-a Knowledge Record subtype | Knowledge; same identity/lifecycle | Sound; avoid duplicate root |
| REL-58 | Workflow Definition 1 → many versions and many Instances | Workflow; instance binds exact version | Sound |
| REL-59 | Workflow Instance many ↔ many domain aggregates by correlation | Workflow owns orchestration only | Process inventory/cardinality missing |
| REL-60 | Aggregate 1 → many State Transitions | Source context; optimistic version order | Sound |
| REL-61 | Aggregate 1 → many Domain Events | Source context/outbox; at-least-once distribution | Sound |
| REL-62 | Domain Event 1 → many consumer-processing results | Infrastructure audit; idempotent | Processing record entity implicit |
| REL-63 | Source event 1 → many Notification Intents | Notification; policy-derived audiences | Sound |
| REL-64 | Notification Intent 1 → many Delivery Attempts | Notification; append-only outcomes | Sound |
| REL-65 | Actor/target 1 → many Audit Entries | Security/Audit; append-only and tenant-scoped | Sound |
| REL-66 | Policy 1 → many immutable Policy Versions | Governance; effective dates | Sound |
| REL-67 | KPI Definition 1 → many versions and observations | Analytics; result binds formula version/as-of snapshot | Sound conceptually |
| REL-68 | Tag/Category many ↔ many domain objects through typed assignments | Taxonomy owner; effective/versioned | Missing governance and polymorphic-link strategy |
| REL-69 | Memory Manifest many ↔ many source records/evidence digests/schema versions | Organizational Memory; immutable export/integrity scope | Sound conceptually |
| REL-70 | Historical Projection many ← many source records/events | Memory/Reporting; rebuildable, never source-owned | Sound |
| REL-71 | Timeline Event many ← many domain/audit/notification/sync events | Projection; deterministic source references | Sound; cross-clock ordering uncertainty must be represented |
| REL-72 | Operational Truth projection many ← Assessments + Decisions + Evidence state | Investigation/Decision sources; reproducible as-of view | Sound only if never independently edited |
| REL-73 | Risk Record many ↔ many Assets/Incidents/Policies/Decisions/Controls | Governance/Risk context | Entity and relationships missing |
| REL-74 | Architecture Decision Record is-a Decision Record subtype | Architecture governance; supersession retained | Sound |

## Circular dependency review

No required aggregate write cycle is inherent if contexts follow command ownership: Investigation proposes; Decision records authorized choice; Incident Management creates or associates; Work reacts through events. A dangerous cycle would arise if Incident creation required an Operation while Operation required an Incident. The current model avoids that for reactive work but fails to represent proactive preventive maintenance; this needs a deliberate `Work Subject` or Maintenance Plan relationship rather than a fake Incident.

Decision supersession, Mandate delegation, Asset topology, Category hierarchy, and workflow migration are graph structures. Each needs explicit cycle constraints and current-node selection rules. Responsibility Chain and Organizational Memory are projections and must not write back into their sources.

## Relationship readiness

Of 74 reviewed relationships, 43 are sound or sound conceptually, 16 are partial, and 15 are missing or require a binding semantic decision. Production logical modeling should not start until critical relationships for property/assets, proactive maintenance, Contract/SLA, Case correction/transfer, Task semantics, and evidence attachment are resolved.
