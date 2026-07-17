# Archive Strategy

Version: 1.0  
Status: Production Logical Model

## Purpose

Archiving reduces operational cost without severing identity, history, traceability, or Organizational Memory.

## Archive tiers

1. **Hot:** active and recently closed records, full operational indexing.
2. **Warm:** older closed records in PostgreSQL partitions/read-optimized storage with full relational identity and authorized retrieval.
3. **Cold:** sealed export bundles and Evidence objects in durable lower-cost storage, with searchable manifest metadata online.
4. **Legal hold:** protected independently of ordinary tiering or disposal schedule.

## Archive eligibility

A root is eligible only when active workflows, commitments, disputes, legal holds, evidence review, notification acknowledgements, integrations, and retention dependencies are resolved. Parent and child may tier separately only if online manifest/relationship resolution remains valid. Archive is a lifecycle state, not soft deletion.

## Archive batch

Every batch records policy/Decision, scope, source/destination tier, custodian, start/end, per-item result, digest, reconciliation, failures, and restore test. Partial results are explicit. Evidence bytes and database metadata are reconciled before source-tier removal.

## Retrieval and restore

Durable IDs resolve archived records. Authorized users receive a retrieval state and provenance; the system does not pretend cold data is absent. Restore produces a new batch/event, verifies digests, re-establishes indexes/projections, and does not alter original timestamps.

## Organizational Memory export

Exports include records, version history, relationship edges, Evidence manifests/objects as authorized, event/audit chronology, schemas, taxonomy/policy/workflow versions, Decision/Responsibility chains, retention/disposition states, and integrity digests. A new developer/vendor can interpret the bundle without private founder knowledge.

## Supabase Storage archive

Bucket/object movement or lifecycle policy cannot be the only archive record. Database manifests remain authoritative. Storage paths are opaque and non-authoritative; object metadata, digest, tenant, Evidence identity, retention, and access are preserved in O83 tables.
