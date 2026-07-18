# O83 Care SQL Migration Plan

Version: 1.0  
Status: Ready for Controlled Execution

## Execution order

1. `00_extensions.sql`
2. `01_schema.sql`
3. `02_enum.sql`
4. `03_tables.sql`
5. `04_constraints.sql`
6. `05_indexes.sql`
7. `06_views.sql`
8. `07_functions.sql`
9. `08_triggers.sql`
10. `09_history.sql`
11. `10_audit.sql`
12. `11_storage.sql`
13. `12_rls.sql`
14. `13_permissions.sql`
15. `14_seed_data.sql`
16. `15_validation.sql`
17. `16_migration.sql`

## Supabase migration workflow

Use the installed Supabase CLI help to confirm current commands and version. Create the actual timestamped migration through the CLI rather than inventing a filename. Apply this source set to a disposable local/branch database first, iterate there, run advisors, generate/pull the clean migration artifact, and verify migration history. Do not apply iterative drafts directly to production migration history.

## Environments

1. Clean development project: execute, validate object counts, seed a test tenant, run role/RLS/Storage tests.
2. Production-shaped staging: restore sanitized scale data, rehearse backfill and archive behavior, obtain query plans, test rollback/forward correction.
3. Production: verified backup/restore point, change window, monitoring, controlled migration role, post-deploy validation, advisor review, and sign-off.

## Preflight

Confirm PostgreSQL 15+, Supabase project configuration, exposed schemas, Auth/Storage availability, extensions, migration role, backup/restore, Data API grants, Realtime publication intent, legal retention configuration, tenant bootstrap ID, and no conflicting bucket/policy names.

## Postflight

Run `15_validation.sql`; compare actual tables, constraints, indexes, triggers, and policies; run database/security/performance advisors; execute negative cross-tenant tests; verify Evidence upload/promotion/read/disposition; verify event/outbox/audit; test one Report→Case→Investigation→Decision→Incident→Operation→Verification chain; seal schema and validation results into Organizational Memory.

## Failure handling

Do not destroy accepted data to roll back. Before data exists, a failed clean deployment can be discarded and recreated. After data exists, use expand-and-contract or forward correction, preserving IDs, chronology, Evidence, Decisions, and audit. Quarantine partial integration/outbox work and reconcile explicitly.
