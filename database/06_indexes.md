# Index Architecture

Version: 1.0  
Status: Production Logical Model

## Purpose

Indexes support tenant isolation, foreign-key maintenance, operational queues, as-of history, search, reporting, and RLS without creating unsustainable write amplification over decades. Exact physical indexes require workload validation and query plans before SQL generation.

## Mandatory index families

1. Every primary and unique business key.
2. Every foreign-key child column or composite tenant/parent key used for joins and deletion checks.
3. Every RLS predicate path beginning with `juristic_person_id`, subject identity, relationship/role, and active effective period.
4. Aggregate history on `(juristic_person_id, aggregate_id, occurred_at/sequence)`.
5. Effective relationships on `(juristic_person_id, subject, valid_from, valid_to)` and current-row partial predicates.
6. Operational queues on state plus next-action/due time, restricted to active rows.
7. Idempotency on external system/message key, notification attempt key, planned maintenance occurrence, and command key.
8. Correlation/causation IDs for traceability and event replay.

## Domain access indexes

| Area | Leading access paths |
|---|---|
| Cases | tenant + Case number; Report; current state/opened time; current Location/Asset/category projection; party relationship |
| Investigations | tenant + state/responsible assignment; Case membership; Assessment by Investigation/version |
| Incidents | tenant + Incident number; state/verified time; Case association both directions; Asset/Location; reopen chronology |
| Operations | tenant + state/priority/due; Incident; Maintenance Plan occurrence; Asset/Component; responsible assignment |
| Responsibility | assignment scope/effective period; party/role; ledger chronology; uncovered/overlap review queries |
| Authority | grantee/role/effective period; scope/action; parent delegation; revocation/expiry queues |
| Evidence | Evidence number; digest; Storage object identity; link target; package membership; custody/integrity chronology |
| Decisions | target scope; responsible person; Authority; decision time; supersession both directions; evidence/assessment links |
| Knowledge | published state; Validity Context dimensions; source link; full-text approved content; supersession |
| Notifications | pending Intent; Audience/channel; retry time; provider message ID; acknowledgement required/outstanding |
| Contracts/SLA | vendor/effective Contract; Obligation scope; SLA target/current clock; due/breach time |

## Search indexes

Full-text search uses approved text columns or search projections, not raw restricted evidence/AI prompt content by default. Trigram or similarity indexes are reserved for name/alias lookup and Case similarity support; they never drive automatic Case merging. JSONB indexes are permitted only for documented queryable keys with a governed schema. Highly selective JSON paths should use expression indexes after plan evidence rather than a blanket index.

## Partial and covering indexes

Partial indexes target active/open/pending/unpublished/outbox-retry/current-version rows and should exclude long-term closed history from operational scans. Covering indexes may include display/status fields for stable high-frequency queries, but sensitive columns and large text/JSON are excluded. Every extra index must have a named query/RLS/report consumer and review owner.

## Partition-aware indexes

Partitioned event/audit tables use local indexes on tenant plus time/aggregate/correlation. Global uniqueness not natively supported across partitions is enforced by stable non-time-partitioned identity registries or UUID uniqueness guarantees plus ingestion validation, never by assuming time partitions cannot collide.

## RLS performance

RLS policies should filter with indexed tenant and identity columns. Stable authentication lookups should be evaluated once per statement where supported by PostgreSQL planning behavior. Policy joins use compact, indexed membership/Mandate projections; complex recursive Authority evaluation must not run per row in unbounded scans. Policy performance is validated with representative tenant sizes and authenticated plans.

## Index lifecycle

Index candidates pass query-plan evidence, write-cost assessment, storage forecast, and duplicate-index review. Unused index monitoring spans representative seasonal workloads before removal. Reindex/maintenance strategy must respect availability and partition independence.
