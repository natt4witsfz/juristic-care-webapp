# Database Readiness Assessment

Version: 1.0  
Status: Conditional — Not Ready for Physical Design

## Purpose

This assessment determines whether engineers can translate the architecture into a production-grade logical and later physical database without losing business meaning. It intentionally contains no SQL, API, or vendor-specific design.

## Readiness conclusion

The core operational spine is implementable: Report → Case → Investigation → Understanding Assessment → human Decision → Incident → Case-Incident Association → Operation → Verification, with Evidence, Responsibility, Authority, Commitment, events, and immutable history. The architecture is **not yet ready for irreversible physical schema design** because several business concepts are referenced but not normatively modeled.

## Critical database risks before implementation

| ID | Critical risk | Why a database designer cannot safely infer it | Required architecture decision |
|---|---|---|---|
| CDB-01 | Property, Building, Room/Unit, Location, Asset, Component, and topology model is absent | Identity, hierarchy, moves, replacement, shared/common areas, cross-building corrections, and Knowledge validity would be guessed | Define a property/asset bounded context, durable identities, effective-dated location, component replacement, aliases, and dependency relationships |
| CDB-02 | Proactive preventive maintenance conflicts with the rule that Operations address Incidents | Creating fake Incidents corrupts Incident metrics; forbidding PM loses a required operation type | Define whether Operation may target an Asset/Maintenance Plan without an Incident, or introduce a compatible Work Subject abstraction |
| CDB-03 | Task/Work Step is requested but not defined | Treating Task as Operation duplicates lifecycle; omitting it may prevent execution templates and partial progress | Decide if Work Step is an Operation-owned entity, its identity/history threshold, and its relationship to Commitment and Execution Sequence |
| CDB-04 | Case party/context correction and cross-Juristic-Person transfer are not modeled | Overwriting resident/building loses submitted truth; copying can breach tenant isolation; moving can orphan responsibility | Define immutable submitted assertions, effective corrections, party roles, transfer acceptance, scoped evidence sharing, and SLA treatment |
| CDB-05 | Vendor, Contract, obligation, and SLA applicability/clock semantics are incomplete | A generic deadline cannot represent policy, contract, pause, calendar, transfer, renegotiation, or breach | Define Contract aggregate, service scope, obligation, SLA classification, calendars, pause/resume, due commitment, and version precedence |
| CDB-06 | Attachment versus Evidence Item identity is ambiguous | Conflating them treats every upload as evidence; separating without promotion lineage breaks provenance | Define upload/attachment lifecycle, quarantine, promotion to Evidence, rejection/disposition, original-object identity, and duplicate handling |
| CDB-07 | Taxonomy, Tag, Category, Capability, Risk, and policy code governance is missing | Free text destroys reports and rules; mutable lookup labels rewrite history | Define stable codes, hierarchy, versions, effective periods, localization, ownership, deprecation, and assignment history |
| CDB-08 | Temporal and graph constraints are not complete | Supersession, delegation, asset topology, category hierarchy, and workflow migration can form cycles or multiple “current” records | Define bitemporal scope, non-overlap rules, acyclic relationship types, precedence, and deterministic as-of selection |

## Aggregate and transaction boundaries

| Boundary | Required atomic invariant | Cross-boundary behavior |
|---|---|---|
| Intake / Case | One accepted Report creates exactly one Case and durable acknowledgement intent | Evidence upload and notifications may complete asynchronously; failures remain visible |
| Investigation | Observation/Hypothesis/Assessment version consistency within an Investigation | Incident verification is a separate authorized Decision/use case |
| Incident Management | Incident creation requires verified Decision; association record requires Decision, Authority, Case, Incident | Work and notifications consume events; no distributed transaction assumed |
| Work Management | Operation transition and outbox event share one transaction; Commitment transition version-checked | Evidence objects and external vendors reconcile asynchronously |
| Evidence | Evidence metadata, immutable object reference, digest, and rendition lineage agree | Object upload may be staged; unavailable/integrity failure is explicit |
| Decision | Decision outcome, actor/role, Authority source, considered evidence links, and supersession are complete | Consequences propagate via events; prior decisions remain |
| Organization | Mandate, Responsibility, Capability, Availability, and relationship periods preserve effective history | Authorization projections may cache but must be invalidated/audited |
| Notification | Intent and Delivery Attempts are idempotent and independently historical | Provider result cannot change source domain state |
| Organizational Memory | Manifest/export is internally consistent for one declared scope/as-of point | It references context-owned records; no write-back Authority |

## Logical data requirements

- Durable opaque identifiers must be globally collision-resistant and safe for offline creation.
- Every tenant-bound record must carry unambiguous Juristic Person scope; shared records require an explicit governed sharing relationship.
- Material records need actor, acting role, effective/event time, recorded time, upload time when applicable, source, reason, correlation, causation, and version.
- Versioned relationships need stable relationship identity plus effective and recorded intervals; a changing foreign key is insufficient.
- Evidence content, metadata, renditions, packages, and custody require separate identities and integrity relationships.
- Current state, Operational Truth, Responsibility Chain, timelines, search, and KPI results are projections with source lineage.
- Domain events and outbox publication status must be distinguishable from security Audit Entries.
- All external identifiers require issuer/system, value, validity, and alias/merge history without changing O83 identifiers.

## Delete, archive, and retention readiness

Soft delete must not be a universal flag. Domain-specific outcomes are required: close, cancel, end, revoke, withdraw verification, deprecate, supersede, restrict, dispose, disable, and archive. Core identity/history records are not normally deleted. Personal data minimization and lawful evidence disposition need category-specific retention rules and a legal decision about permitted tombstone metadata.

Archive cannot make Organizational Memory unusable. Archived records must remain addressable by durable ID, exportable with relationships, interpretable with historical policy/taxonomy/schema versions, and recoverable within approved service objectives.

## Search and reporting readiness

Search must enforce tenant and purpose authorization before ranking or AI retrieval. Full text should index renditions approved for search, not restricted originals by default. Reporting needs effective-dated dimensions for organization, property, asset, policy, SLA, taxonomy, and responsibility; several are currently undefined. Issued reports/KPI observations require reproducible snapshots and restatement lineage.

## Scalability readiness

High-volume objects include Domain Events, Audit Entries, Timeline projections, Delivery Attempts, Evidence metadata/objects, State Transitions, AI interactions, and KPI observations. Their retention and partition strategy can vary independently from core aggregates, provided lineage and tenant isolation remain intact. Large media must not be assumed to reside in the same transactional persistence mechanism as aggregate records.

## Readiness gates

Logical database modeling may proceed for the core operational spine as an exploratory model, but no production schema should be approved until CDB-01 through CDB-08 have binding ADRs or architecture extensions. Physical design additionally requires jurisdictional retention, volume estimates, recovery objectives, data residency, access-policy evaluation, and migration strategy.

## Score

Database readiness: **72/100**. The score reflects a strong history/audit foundation but material missing business semantics around property/assets, work decomposition, proactive maintenance, supplier contracts, corrections/transfers, evidence intake, and governed vocabularies.

## Consolidated scores

| Dimension | Score | Meaning |
|---|---:|---|
| Domain Model | 84/100 | Core operational meaning is strong; thirteen catalog objects need binding definition |
| Database Readiness | 72/100 | Logical exploration may begin, but physical design approval is blocked by CDB-01 through CDB-08 |
| History | 96/100 | Append/supersede, chronology, and previous-understanding preservation are excellent |
| Auditability | 92/100 | Required action envelope is strong; missing domains cannot yet be fully audited |
| Traceability | 88/100 | Core chain is complete; property, party, contract, taxonomy, and attachment links are weak |
| Future Scalability | 86/100 | Vendor-neutral direction is sound; delayed semantic decisions would cause expensive migrations |

Architecture readiness for database translation is **86/100**. This differs from operational scenario scoring because it penalizes undefined persistence semantics even when human workflow intent is clear.
