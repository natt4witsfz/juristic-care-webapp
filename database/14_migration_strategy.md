# Database Migration Strategy

Version: 1.0  
Status: Production Change Architecture

## Purpose

Migrations evolve structure and data without erasing history, changing meaning silently, breaking RLS, or making Organizational Memory dependent on one developer.

## Migration lifecycle

1. Architecture/ADR and business semantic impact review.
2. Compatibility classification: additive, behavior change, backfill, contract version, destructive/disposition.
3. Migration artifact created through the approved Supabase CLI workflow when implementation begins; filenames are tool-generated, not invented.
4. Test on production-shaped data with RLS, constraints, events, Storage links, and rollback/forward-correction plan.
5. Deploy expand phase, dual-read/write or backfill where required, validate/reconcile, then contract only after consumers and archives are safe.
6. Run database/security/performance advisors and migration-state verification before acceptance.
7. Seal migration result, schema catalog version, validation evidence, and ADR into Organizational Memory.

## Expand-and-contract

Semantic changes add new columns/tables/contracts first. Existing consumers continue safely. Backfills are idempotent, restartable, tenant-bounded, rate-limited, observable, and preserve source lineage. Constraints move from validation to enforcement only after reconciliation. Old structure is removed only when no event, report, archive, AI index, integration, or historical interpretation depends on it.

## Historical data rules

Backfills never invent unknown event time, Authority, actor, Evidence, or Decision. Unknown remains explicit. A derived value records derivation/migration source. Corrections append or create version/relationship records. Business keys and IDs are not regenerated. Published version payloads and Evidence originals are never rewritten.

## RLS and access migration

Every new exposed object has RLS, policies, and explicit grants reviewed together. Tests prove positive and negative access, update `USING`/result checks, cross-tenant denial, stale claims, disabled accounts, and view/function behavior. Migration roles are separated from runtime roles; privileged bypass is temporary, audited, and scoped.

## Large-table migrations

Avoid long blocking operations. Use staged nullable/additive fields, batched backfill, concurrent-safe index strategy, validated constraints, partition-by-partition work, and short metadata transitions appropriate to the supported PostgreSQL version. Lock/statement timeouts and recovery steps are documented.

## Supabase components

Database, Auth mappings, Storage metadata/objects, Realtime publications, Edge Function assumptions, and Data API exposure are migrated as one change set with separate rollback/verification. Auth users are never recreated to migrate domain Person identity. Storage paths are not bulk-renamed without manifest and digest reconciliation.

## Disaster and rollback

Rollback is used only when it preserves accepted data; otherwise forward correction is safer. Before high-risk change, verify restore point, export/manifest, recovery objective, and rollback compatibility. A failed migration cannot leave event schema, RLS, or Storage metadata half-switched; partial state is detected and reconciled.

## Long-term continuity

Migration history is immutable and reproducible. Each migration records purpose, author/reviewer, ADR, dependencies, checksum, applied time/result, Supabase/PostgreSQL version, data backfill outcome, advisor findings, and later supersession. A new developer can rebuild and validate the database from documented artifacts and sealed baselines.
