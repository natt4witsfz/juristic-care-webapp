# Data Architecture

Version: 2.0  
Status: Architecture Baseline

## Purpose

The data architecture preserves trustworthy operational records, supports current views, and keeps Organizational Memory portable.

## Data categories

Authoritative transactional records represent aggregates and decisions. Immutable domain events represent accepted changes. Evidence objects preserve original content and renditions. Projections support search and current workflows. Analytical datasets support governed reporting. Audit records prove access and administrative activity.

## Ownership and access

The Juristic Person is the data owner; bounded contexts are data stewards for their write models. Other contexts access data through defined contracts, events, or governed read views rather than shared writes. Organizational Memory holds lineage, manifests, and historical projections over those records; it is not a master-data copy with competing write Authority. Every record is tenant-bound and classified.

## Temporal model

Records distinguish occurrence/event time, action time, effective time, recorded time, and upload/ingestion time. Effective-dated relationships support roles, authority, responsibility, assets, and policy. Bitemporal treatment is used where the organization must know both what was believed effective and when it was recorded.

## Immutability and correction

Material records are appended. Mutable convenience fields are rebuildable projections. Corrections cite the original, reason, actor, and authority. Deletion follows lawful retention policy and creates auditable disposition metadata where permitted.

## Quality and lineage

Data contracts define identifiers, meaning, requiredness, provenance, classification, allowed values, chronology, and version. Lineage connects Reports to Cases, Investigations, Understanding Assessments, Case-Incident Associations, Incidents, Operations, Responsibility Chains, Evidence, Decisions, events, projections, and KPIs. Reconciliation detects missing or duplicate transfers.

## Portability and continuity

Exports include schemas, code lists, event versions, relationships, evidence manifests, authority history, and integrity checks in documented durable formats. Restore and full-exit exercises verify independence from current developers and vendors.

## Evolution

Schema changes are additive where possible. Breaking changes use explicit versions, migration decisions, validation, coexistence, and rollback strategy. The storage-level blueprint is in [20_database_blueprint.md](20_database_blueprint.md).

A migration that changes meaning must create a new semantic version and preserve the old interpretation. Derived `current` values are rebuilt from authoritative records; migration tools may not manufacture missing Authority, chronology, or evidence.
