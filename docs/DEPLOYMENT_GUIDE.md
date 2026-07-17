# Deployment Guide

## Release order

1. Approve the reviewed architecture and migration change.
2. Confirm a recent recoverable database backup.
3. Apply Supabase migrations to staging and run database/RLS validation.
4. Build and smoke-test the frontend against staging.
5. Apply the database migration to production during the approved window.
6. Deploy the immutable frontend build to Vercel.
7. Run read, create-Case, authorization-denial, recovery, and audit smoke tests.
8. Record outcome, operator, approver, timestamps, digests, and any rollback.

Database changes must remain backward compatible for the application version active during rollout. Destructive transformations use expand–migrate–verify–contract across separate releases. A failed validation stops promotion; it must not be bypassed to meet a date.

## Rollback

Frontend rollback selects the last known-good immutable deployment. Database rollback is normally a forward corrective migration. Restore is reserved for data loss or corruption and follows `BACKUP_AND_RECOVERY.md`; it requires reconciliation of events created after the restore point.

## Evidence

Attach CI results, migration output, database lint/test output, dependency audit, smoke-test evidence, and the go/no-go approval to the release record. Secrets and resident personal data must not appear in screenshots or logs.
