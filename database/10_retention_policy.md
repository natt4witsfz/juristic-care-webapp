# Retention and Disposition Policy Architecture

Version: 1.0  
Status: Policy Framework — Jurisdictional Durations Required

## Purpose

This document defines retention classes and decision rules. Numeric durations must be approved under Thai law, condominium governance, privacy obligations, insurance, employment, safety, contract, and litigation needs before production configuration.

## Retention classes

| Class | Examples | Default treatment |
|---|---|---|
| Organizational Memory | Cases, Incidents, Decisions, Responsibility/Authority, ADRs, Knowledge, policy/resolution history | Long-term/permanent unless law requires minimization |
| Safety/Asset history | Operations, verification, Asset/Component lineage, critical Evidence | Asset life plus approved post-retirement period; legal holds override |
| Legal/Contract | Contracts, obligations, custody, formal Evidence packages | Statutory/contract limitation and hold rules |
| Personal communication | Case communications, recipient details, contact data | Purpose-limited; redact/restrict/archive according to policy |
| Security audit | access, denial, privileged action, authentication linkage | Risk-based security/legal period; protect from ordinary users |
| Integration staging | inbound envelopes, retry/outbox operational detail | Shorter operational period after reconciled outcome, with domain event retained |
| AI accountability | consequential interactions, sources, review/adoption | Use-case risk period; minimize unused raw context/content |
| Analytics | issued reports/KPI snapshots and lineage | Retain issued outputs; source data follows its own class |

## Disposition rules

Disposition requires eligibility evaluation, legal-hold check, dependencies, Authority/Decision, manifest, digest, and outcome audit. Content removal never changes a prior Decision to imply Evidence was never considered. Where lawful, a tombstone records identity, disposition type, Authority, time, and non-sensitive linkage; where law forbids metadata retention, the permitted minimum is used.

## Soft delete rules

Soft delete is allowed only for convenience records whose deleted state itself matters and is governed. Core history uses domain states: ended, revoked, closed, cancelled, superseded, withdrawn, restricted, disposed, disabled, or archived. Unreferenced drafts/staging may be physically removed through controlled cleanup with audit where appropriate.

## Holds and disputes

Legal, safety, insurance, audit, resident dispute, investigation, or security holds suspend destructive disposition. A hold is scoped, sourced, effective-dated, reviewed, and released by authorized Decision. Indefinite undocumented holds are prohibited.

## Review and evidence

Retention policies are versioned. Each record resolves the policy/version applied; changes apply prospectively unless a lawful Decision states otherwise. Disposal jobs reconcile database rows, Storage objects, archives, search indexes, analytics extracts, AI indexes/caches, and backups according to technically achievable approved rules.
