# Audit Strategy

Version: 1.0  
Status: Production Logical Model

## Purpose

Audit proves important business actions and security activity without conflating Audit Entries, Domain Events, or current state.

## Three records of accountability

- **Domain record/event:** what business fact was accepted.
- **Decision/Responsibility record:** why, under whose Authority, and with what Evidence.
- **Audit Entry:** which principal attempted/performed which database or administrative action, including denied reads/exports.

## Required audit envelope

Actor principal, Person when known, acting role, tenant, session, action, target type/id, event/action/record time, result, reason, policy version, Mandate/Authority, correlation, causation, evidence/Decision references, previous/new aggregate version or state reference, client/integration provenance, and classification.

## Audited action classes

Authentication linkage/revocation; role/Mandate/Responsibility changes; Case correction/transfer; Incident verification/association/reopen/closure; priority/override; emergency reconstruction; commitment/verification; Evidence view/download/export/redaction/disposition; policy/contract/SLA/taxonomy/workflow publication; AI context/generation/adoption/disablement; RLS/admin denial; bulk actions; report issue/restatement; archive/export/restore; migration and backfill.

## Tamper evidence

Audit Entries are append-only, written through a restricted path, denied to ordinary mutation roles, and periodically sealed into Memory Manifests with ordered digests. Audit access is audited. Database owners remain technically powerful, so separation of operational credentials, external log forwarding, backup custody, and independent integrity verification are governance controls.

## Privacy and secrets

Audit logs never store credentials, secret keys, raw tokens, full sensitive Evidence, or unnecessary message/AI content. They store digests and references. IP/device/request metadata is classified and retained only for justified security purpose.

## Supabase considerations

Supabase platform/Auth logs complement but do not replace O83 audit records. Service-role/secret-key use is restricted to trusted server environments. Privileged functions, if later approved, reside outside exposed schemas, have explicit execution grants, validate caller/tenant/purpose, and are separately audited. Views exposed to users must preserve invoker security behavior and RLS intent.

## Verification

Tests prove denied actions leave evidence where required, all material transitions correlate to Domain Events, audit partitions remain immutable, sealed digests detect alteration, archive/restore preserves sequence, and a departing account cannot be used to rewrite attribution.
