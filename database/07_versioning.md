# Versioning and Temporal Strategy

Version: 1.0  
Status: Production Logical Model

## Purpose

Versioning preserves what was known, effective, decided, and recorded at each time without turning every update into destructive mutation.

## Versioning patterns

| Pattern | Used for | Rule |
|---|---|---|
| Stable root + immutable versions | Policy, Workflow, SLA, KPI, Knowledge, Contract, Evidence Package | Root identity remains; numbered versions append; published version payload immutable |
| Immutable events | State, audit, responsibility ledger, custody, clock, delivery, interruption | Append in causal sequence; corrections are new events |
| Effective-dated relationships | roles, occupancy, locations, classifications, Mandates, Responsibility | Preserve valid and recorded periods; prohibit unintended overlap |
| Supersession graph | Decisions, Assessments, Hypotheses, Knowledge, taxonomy terms | Typed acyclic relationship; previous node remains discoverable |
| Current projection | Operational Truth, current state, Responsibility Chain, timeline, search | Rebuildable; stores source watermark/version; never authoritative alone |
| Issued snapshot/restatement | Reports and KPI observations | Original remains; restatement links replacement and reason |

## Optimistic concurrency

Mutable roots carry `row_version`. Commands state expected version; mismatch creates a retry or `integration.sync_conflicts` outcome rather than last-write-wins. Append-only children use immutable sequence/business keys. Offline actions preserve local identifiers and times, then reconcile against current Authority and aggregate version.

## Bitemporal scope

Valid time and recorded time are mandatory for organization relationships, roles, Mandates, Responsibility, occupancy, Location/Asset relationships, classifications, Contract/SLA applicability, policy versions, and Case corrections/transfers. Event/action/upload times remain separate where delayed entry matters. As-of queries specify whether they ask “effective then,” “recorded by then,” or both.

## Decision Evolution

Observation, Hypothesis, Evidence link, Assessment, Decision, later Evidence, new Assessment, and affirming/superseding Decision retain separate IDs. A “current Decision” view chooses the latest effective non-withdrawn node under typed graph rules; it never edits the earlier outcome.

## Schema and event versions

Database migrations have ordered immutable identifiers, purpose, compatibility class, preconditions, validation, rollback/forward-correction strategy, and ADR. Domain Event schemas are immutable after publication. Additive compatible fields use the existing major contract only when semantics remain unchanged; otherwise a new event version and consumer migration are required.

## Taxonomy versions

Stable codes are never repurposed. Label corrections may be localized/versioned without changing meaning; semantic change creates a new term linked by supersession/equivalence. Historical records continue to resolve the term/version applicable at action time.

## Retention of versions

Published/executed/issued versions, Decisions, Assessments, Responsibility/Authority history, Evidence provenance, and used taxonomy/workflow versions remain in Organizational Memory for their governed lifetime. Draft versions may be removed only if unreferenced and never externally acknowledged.
