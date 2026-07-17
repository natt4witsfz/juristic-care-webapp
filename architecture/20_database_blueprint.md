# Database Blueprint

Version: 2.0  
Status: Logical Architecture Baseline

## Purpose

This blueprint defines persistence responsibilities and integrity rules without prescribing database code or a vendor.

## Logical stores

| Store                 | Contents                                                | Key properties                              |
| --------------------- | ------------------------------------------------------- | ------------------------------------------- |
| Transactional store   | Aggregate records, relationships, mandates, commitments | Strong local transactions, tenant isolation |
| Event/outbox store    | Domain event envelopes and publication state            | Append-only, ordered per aggregate          |
| Evidence object store | Originals and derived renditions                        | Immutable objects, digest verification      |
| Search index          | Authorized searchable projections                       | Rebuildable, access-filtered                |
| Analytics store       | Governed historical facts/dimensions                    | Lineage, snapshot reproducibility           |
| Audit store           | Security and administrative audit                       | Tamper-evident, restricted                  |

## Core logical entities

Separate identities exist for Report, Case, Investigation, Understanding Assessment, Incident, Case-Incident Association, Operation, Commitment, Responsibility Entry, Mandate, Capability Assertion, Availability Period, Priority Decision, Sequence Decision, SLA Policy, Evidence Item/Rendition/Package, Observation, Hypothesis, Decision Record, Knowledge Record/Validity Context, Notification Intent/Attempt, Asset Reference, Policy Version, Memory Manifest, and Audit Entry.

## Integrity rules

Each Report references exactly one Case; a Case never shares identity with another Case. Case-Incident associations are effective-dated records with human decision references. Incident and Operation state changes are appended and version-checked. Foreign relationships never cross tenant boundaries. Material record deletion is denied except through governed retention disposition.

No Incident row is created for suspicion alone. An authorized verification Decision and its Understanding Assessment are required before Incident creation. Responsibility Chain and Decision Evolution are reproducible relationship views over authoritative records, not denormalized fields that overwrite history.

## Concurrency and identifiers

Opaque globally unique identifiers support offline creation and import. Optimistic aggregate versions prevent lost updates. Idempotency keys protect intake, synchronization, and integration commands without conflating distinct intentional reports.

## Resilience and evolution

Backups, point-in-time recovery, object-version protection, integrity scans, and restore tests are mandatory. Migrations are versioned, observable, validated against invariants, and reversible or forward-correctable. Historical fields are not repurposed with new meanings.

## Explicit exclusions

This document defines logical architecture only. It contains no SQL, physical indexes, vendor configuration, or generated schema. Those require implementation design approved against [18_data_architecture.md](18_data_architecture.md).
