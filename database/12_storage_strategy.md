# Supabase Storage and Evidence Object Strategy

Version: 1.0  
Status: Production Storage Architecture

## Purpose

Supabase Storage holds binary objects while O83 PostgreSQL tables preserve authoritative identity, provenance, classification, retention, relationships, and integrity. Storage paths are implementation locators, not business keys.

## Bucket classes

| Bucket class | Visibility | Content |
|---|---|---|
| Evidence intake | private | temporary uploads pending scan, digest, classification, promotion/quarantine |
| Evidence originals | private, immutable-by-policy | original Evidence bytes |
| Evidence renditions | private | redacted, annotated, transcribed, translated, compressed derivatives |
| Notification/report artifacts | private or narrowly time-limited delivery | rendered messages, issued reports, export artifacts |
| Organizational Memory archive | private, restricted custody | sealed manifests/export bundles and cold Evidence copies |

No public bucket stores Case, Evidence, resident, audit, AI, contract, or governance content.

## Object naming

Paths use opaque tenant/entity/object/version components and contain no resident name, Room label, diagnosis, or secret. Database rows store bucket, object key, digest, size, media type, Evidence identity, and rendition lineage. Signed access is short-lived and purpose-bound.

## Upload lifecycle

1. Create `upload_attachments` intent with tenant, actor, expected type/size/digest, Case/Operation context.
2. Upload to private intake location.
3. Validate size/media, malware/security policy, observed digest, and tenant ownership.
4. Promote by creating immutable Evidence Item and moving/copying to original object identity, or quarantine/reject with reason.
5. Generate Renditions as new objects with transformation provenance.
6. Reconcile object and database metadata; orphan objects/rows enter controlled exception handling.

Evidence originals are never overwritten. Client-side upsert is not used for original Evidence. Resumable upload retains one logical upload intent and reconciles parts/provider state.

## Integrity and loss prevention

Cryptographic digests are calculated at trusted boundaries and periodically rechecked. Memory Manifests include object identity/digest. Object-version protection, backups/replication as available, legal holds, custody events, and restore exercises address loss. Missing/corrupt objects trigger Evidence integrity events and affected-Decision tracing; no replacement object is presented as the original.

## Access and redaction

Users normally receive an authorized Rendition, not original bytes. Access evaluation checks tenant, Case/Operation relationship, acting role, purpose, classification, Evidence restriction, legal hold, and disposition. Downloads/exports of sensitive Evidence are audited. Redaction produces a new Rendition; it does not edit the original.

## Retention and archive

Storage lifecycle rules cannot independently delete governed content. Database disposition/Archive Batch drives object tiering/removal and verifies outcome. Backups and derived caches/search/AI indexes follow the approved retention policy to the extent technically supported and documented.

## Edge Functions

Trusted Edge Functions may coordinate signed upload/download, scanning, digest confirmation, rendition generation, and webhook validation. They must use least privilege, validate tenant/actor/purpose, never expose service credentials, preserve idempotency, and write domain/audit outcomes. Database invariants remain authoritative.
