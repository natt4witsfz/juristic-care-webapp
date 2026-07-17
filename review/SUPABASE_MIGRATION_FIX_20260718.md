# Supabase Migration Ownership Fix

**Date:** 2026-07-18  
**Migration:** `supabase/migrations/20260717153210_o83_care_initial_schema.sql`  
**Result:** PASS

## Exact cause

The baseline migration attempted to execute this statement against a Supabase-managed table:

```sql
comment on table storage.objects is
'Supabase-managed object metadata protected by O83 bucket and relationship RLS policies.';
```

PostgreSQL permits a table comment to be changed only by an owner-capable role. The local migration role may create supported RLS policies on `storage.objects`, but it does not own that Supabase-managed table. PostgreSQL therefore stopped the migration with SQLSTATE `42501` before the O83 schema could finish.

## Complete managed-schema review

The complete 5,428-line migration was inspected before modification. All references to `auth` and `storage`, and all ownership-sensitive DDL patterns, were reviewed.

- One ownership-restricted operation was found: the `COMMENT ON TABLE storage.objects` statement shown above.
- No `COMMENT ON TABLE storage.buckets` statement existed.
- No `COMMENT ON TABLE` or `COMMENT ON COLUMN` statement targeted an Auth-managed table.
- No `ALTER ... OWNER` operation targeted a Supabase-managed object.
- No table, column, schema, constraint, or other structural DDL targeted `auth` or `storage` objects.
- The two application-owned foreign keys to `auth.users` were retained.
- The idempotent five-bucket upsert into `storage.buckets` was retained.
- All five narrow O83 RLS policies on `storage.objects` were retained unchanged.
- No grant to `anon`, `authenticated`, or `public` was added or broadened to bypass ownership checks.

## Statements removed or relocated

The `COMMENT ON TABLE storage.objects` statement was removed from both the canonical storage source and the assembled timestamped migration. Its explanatory meaning was relocated to `docs/SUPABASE_MIGRATIONS.md`, where the distinction between Supabase-managed objects and application-owned objects is now explicit.

The content previously stored in `supabase/migrations/README.md` was moved, without deletion of meaning, to `docs/SUPABASE_MIGRATIONS.md`. The executable migration directory now contains timestamp-formatted `.sql` files only.

## Follow-on migration defect found during verification

After the ownership failure was removed, the migration reached O83's own duplicate-index validator and exposed two indexes with the same definition on `intake.cases(report_id)`:

- `uq_cases_report`, the required unique constraint index enforcing one Case per Report;
- `ix_intake_cases_report_id`, a redundant index created by the generic foreign-key index generator.

The uniqueness constraint was preserved. The generator was corrected to recognize an existing valid, ready, non-partial index whose leading columns cover a foreign key, regardless of index name. The migration validator was also improved to report the affected table and index names when a future duplicate is detected.

## Files changed

- `sql/11_storage.sql` — removed the managed-table comment only.
- `supabase/migrations/20260717153210_o83_care_initial_schema.sql` — applied the same ownership fix and the two verified application-owned validation corrections.
- `docs/SUPABASE_MIGRATIONS.md` — relocated the migrations documentation and recorded managed-schema boundaries.
- `supabase/migrations/README.md` — moved out of the executable migration directory.
- `sql/05_indexes.sql` — made foreign-key index generation definition-aware.
- `sql/15_validation.sql` — added exact duplicate-index diagnostics.
- `supabase/tests/database_validation.sql` — converted the structural checks into an executable seven-test pgTAP suite.
- `supabase/tests/rls_validation.sql` — converted the security checks into an executable fifteen-test pgTAP suite.
- `review/BLOCKERS.md`, `review/07_RLS_VALIDATION.md`, `review/09_FINAL_VALIDATION.md`, and `review/14_GO_NO_GO.md` — reconciled validation status with the successful local run.

## Backups

Pre-change copies are preserved under:

- `backup/20260718_storage_comment_fix/`
- `backup/20260718_duplicate_index_diagnostic/`
- `backup/20260718_fk_index_fix/`

## Verification results

| Verification | Result | Evidence |
|---|---|---|
| `pnpm db:start` | PASS | Local Supabase started and the migration completed. |
| `pnpm db:reset` | PASS | A fresh database was recreated and the full migration replayed successfully. |
| Supabase database lint across all O83, `api`, and `core` schemas | PASS | `No schema errors found`. |
| `pnpm supabase test db --local supabase/tests` | PASS | 2 files, 22 tests, all successful. |
| `scripts/validate-sql.ps1` | PASS | 16 canonical SQL files and one migration passed static validation. |
| Storage RLS catalog assertions | PASS | Five O83 policies exist; two are insert-only; no O83 update, delete, or all-object policy exists. |

## Remaining warnings and limitations

- Supabase Analytics is not available in this Windows local stack unless the Docker daemon is exposed on unauthenticated TCP port 2375. That exposure was not enabled because it would weaken host security; the database, Auth, Storage, API, migration, lint, and pgTAP verification are unaffected.
- Clean-bootstrap `DROP POLICY IF EXISTS` notices are expected and non-failing.
- The pgTAP RLS suite proves catalog structure and policy boundaries. Multi-identity behavioral tests using real Auth JWT fixtures remain a separate production-readiness activity.
- Hosted Supabase and Vercel verification remain blocked by absent project credentials; no hosted deployment success is claimed.

