# O83 Care Production Database Architecture

Version: 1.0  
Status: Ready for SQL Design Review  
Target: PostgreSQL on Supabase  
Design horizon: 20+ years

## Purpose

This database architecture translates the approved O83 Care business architecture into a relational model while preserving Operational Truth, Organizational Memory, immutable history, responsibility, Authority, Decisions, Evidence, and end-to-end traceability. It specifies database structure only; it contains no SQL, backend code, frontend code, or API design.

## Resolved design decisions

1. **Property and Asset context:** Building, Room, Location, Asset, Component, topology, and Maintenance Plan have durable, effective-dated identities.
2. **Reactive and proactive work:** An Operation may be linked to one or more Incidents, a Maintenance Plan, or both. It must have at least one governed work origin and at least one work subject. Preventive maintenance never requires a fake Incident.
3. **Task semantics:** `work.work_steps` is an Operation-owned entity. A Work Step is not an Operation, Commitment, or Workflow State.
4. **Submitted versus corrected context:** original Report data is immutable. Case party/location/category corrections are appended assertions. Cross-tenant transfer requires acceptance; records are never moved silently.
5. **Contract and SLA:** Contracts have immutable versions and obligations. SLA Policy is separate from due Commitment and uses versioned applicability and clock events.
6. **Attachment versus Evidence:** an upload attachment is intake/storage metadata. Promotion creates an Evidence Item with provenance; quarantine or rejection remains historical.
7. **Taxonomy:** governed codes are versioned and never repurposed. Optional Tags are taxonomy terms with non-authoritative vocabulary policy.
8. **Temporal graphs:** Mandate delegation, Decision supersession, Asset topology, taxonomy hierarchy, and version lineage are typed, effective-dated, and cycle-constrained.

## Database schemas

| Schema | Ownership |
|---|---|
| `iam` | application identities, service principals, recorded authorization decisions |
| `org` | Juristic Persons, people/organizations, roles, Mandates, Responsibility, Capability, Availability |
| `property` | properties, Buildings, Rooms, Locations, Assets, Components, topology, maintenance plans |
| `taxonomy` | governed vocabularies, versions, terms, hierarchies |
| `intake` | Reports, Cases, parties, context corrections, communications, transfers |
| `investigation` | Investigations, Observations, Hypotheses, Understanding Assessments |
| `incident` | verified Incidents, Case associations, recurrence, classification |
| `work` | Operations, Work Steps, Commitments, verification, priority, sequence, SLA |
| `evidence` | attachment intake, Evidence Items, renditions, packages, custody, integrity, disposition |
| `decision` | human Decisions, evidence/assessment links, supersession, Recommendations |
| `knowledge` | Knowledge versions, Validity Context, sources, reviews, outcomes |
| `workflow` | versioned workflow definitions, instances, subjects, transitions |
| `notification` | intents, audiences, message renditions, attempts, acknowledgements |
| `governance` | policies, committees, resolutions, Contracts, obligations, risks |
| `ai` | governed AI use cases, interactions, Recommendations, sources, reviews |
| `audit` | domain events, transactional outbox, tamper-evident Audit Entries |
| `analytics` | KPI definitions/observations and reproducible report snapshots |
| `memory` | Organizational Memory manifests and archive custody |
| `integration` | external systems/identifiers, inbound envelopes, sync conflicts |
| `api` | intentionally exposed security-invoker views or narrowly governed database entry points; no authoritative tables |

Only schemas explicitly configured for Supabase Data API exposure are exposed. Domain schemas remain private by default. If any table is exposed later, RLS and explicit grants are both required; authentication alone is not authorization.

## Identity, tenancy, and keys

- Every durable entity uses a UUID primary key generated independently of business meaning and safe for offline creation.
- Human-readable business keys are unique within the Juristic Person and entity namespace, remain stable, and are never recycled.
- `juristic_person_id` is mandatory on tenant-owned tables, including relationship and event records, even when derivable, so RLS and partition pruning do not depend on joins.
- Supabase `auth.users.id` is referenced only through `iam.user_accounts.auth_user_id`; domain Person identity survives account deletion or replacement.
- External identifiers include system/issuer, identifier type, value, effective period, and alias/supersession history.

## Immutability model

Material facts are append-only. Mutable columns are limited to concurrency/version metadata and operational pointers whose history is independently preserved. Corrections use new assertions; lifecycle changes use State Transitions; revisions create new versions; Decisions use typed relationships; current views are projections. Soft delete is never used to hide history.

## Transaction and consistency model

Aggregate-local invariants use one PostgreSQL transaction. Each accepted domain mutation and its outbox event commit atomically. Cross-aggregate workflows are eventually consistent through at-least-once events, idempotent consumers, and reconciliation. No distributed transaction is assumed. A process cannot silently compensate a human Decision; compensation is a new authorized Decision or domain action.

## Supabase compatibility

- **Auth:** accounts map to durable Person/service identities; authorization data is database-owned and may be mirrored in trusted app metadata only as a cache.
- **Storage:** private buckets hold Evidence originals/renditions and message/report exports; database metadata remains authoritative for provenance and access.
- **Realtime:** restricted to explicitly approved operational projections and tenant-scoped topics; audit/evidence/AI secrets are not broadcast.
- **RLS:** enabled on exposed tables and used as defense in depth elsewhere. Policies evaluate tenant membership, acting role, Mandate, relationship, purpose, classification, and state.
- **Edge Functions:** may orchestrate trusted workflows but do not bypass domain rules; service credentials are never exposed to clients.

## Acceptance criteria

The design is acceptable only if a future SQL implementation can prove: one Report/one Case; verified-only Incident creation; immutable chronology; complete Decision Evolution and Responsibility Chain; evidence integrity and disposition; cross-tenant isolation; RLS coverage; no orphan business relationships; rebuildable projections; versioned vocabularies/policies/workflows; export/restore of Organizational Memory; and migration without semantic overwrite.
