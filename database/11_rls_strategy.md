# Supabase Row-Level Security Strategy

Version: 1.0  
Status: Production Security Architecture

## Purpose

RLS enforces tenant, relationship, purpose, role, Authority, and data-classification boundaries for Supabase Data API and Realtime access. It is defense in depth for private schemas and mandatory for every table in any exposed schema.

## Exposure strategy

Domain tables reside in non-exposed schemas. The `api` schema is the only candidate for Data API exposure and contains no authoritative tables. Exposed views must run with invoker security behavior on supported PostgreSQL versions, or remain unexposed/revoked. Data API grants and RLS are separate: a role needs both explicit object privilege and an allowing RLS policy.

## Identity source

`auth.uid()` identifies the Supabase account, then `iam.user_accounts` resolves tenant-specific Person identity. Authorization does not trust user-editable metadata. Trusted app metadata may cache coarse information, but stale JWT claims never override database Mandates, revocation, session restrictions, or relationship end dates. Sensitive operations may require current session validation and fresh database authorization.

## Policy decision model

Every policy answers:

1. Is the account/service principal active?
2. Is it a member of this `juristic_person_id`?
3. Does the acting role/relationship permit the operation?
4. Is required Mandate active for action, scope, and time?
5. Does resource relationship permit access (own Case, assigned Operation, governance scope, audit role)?
6. Does purpose permit this classification and rendition?
7. Is the record restricted, on legal hold, archived, or in a state requiring stronger review?

Authentication alone never grants all tenant rows.

## Access archetypes

| Archetype | Read scope | Write scope |
|---|---|---|
| Resident | own/represented Case projections, permitted communications/evidence renditions | submit Report, add authorized Case communication/evidence; no Incident/priority/verification mutation |
| Technician | accepted/assigned Operations, necessary Case/Incident/Asset context | observations, work actions, evidence uploads, sequence, completion recommendation within Capability/Commitment |
| Dispatcher/Manager | managed tenant/scope, exception queues, appropriate Evidence | authorized association, priority, assignment, Operations, Decisions within Mandate |
| Verifier/Supervisor | review scope and evidence package | Verification Records/Decision within qualification and separation rule |
| Committee | governed aggregate views and reserved records | resolutions/policies/risks within term, quorum, and Mandate; no unrestricted personal Evidence |
| Auditor | approved time/scope, normally read-only | audit findings/acknowledgement only; no domain rewriting |
| Integration principal | explicit tenant, message type, and resource scope | inbound envelope and approved commands only |
| AI service | no general table access; mediated approved context only | AI Interaction/Recommendation records; no human Decision or verification |

## Mutation policy rules

Insert validates tenant and parent ownership. Update requires both visibility of the existing row and validity of the resulting row; ownership/tenant/immutable identity cannot be reassigned. Delete is denied for authoritative/history tables. Relationship/version/event creation uses governed entry points when cross-row invariant checks are required; ordinary clients do not receive broad table mutation privileges.

## Storage RLS

Storage object policies align bucket/path metadata with `evidence.upload_attachments`, Evidence classification, Case/Operation relationship, and tenant access. Object path alone never proves authorization. Upload replacement/upsert is discouraged for Evidence originals; originals use new object identity. Where Storage upsert is used for non-evidence staging, the required insert, select, and update permissions are treated separately.

## Realtime

Realtime is enabled only for explicitly approved operational projections/tables with RLS-compatible tenant filters. Audit Entries, restricted Evidence metadata, AI raw context, Mandates, credentials, and legal-hold data are excluded. Presence/broadcast topic authorization is tenant- and workflow-scoped. Realtime delivery is convenience, not durable notification or event processing.

## Privileged execution

Service-role/secret credentials remain server-side and are not a substitute for business Authority. Any privileged database function later approved is outside exposed schemas, has explicit execute grants rather than public defaults, fixes its search path, validates caller/tenant/purpose/Authority, minimizes bypass, and writes Audit Entries. `SECURITY DEFINER` is never used merely to fix a permission error.

## RLS verification

Automated policy tests cover every role × action × state × tenant × relationship × classification combination, including cross-tenant IDs, stale JWT claims, disabled accounts, expired Mandates, anonymous users, archived/restricted rows, update re-parenting, bulk operations, views, Storage, and Realtime. Query plans are tested at production-scale tenant sizes.
