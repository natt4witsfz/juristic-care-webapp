# O83 Care Backup and Restore Procedure

## Purpose

O83 Care backups protect Operational Truth, immutable history, Evidence, Responsibility, Authority, Decisions and Organizational Memory. A backup is not accepted until an isolated restore and reconciliation have demonstrated that the records remain usable and interpretable.

This procedure separates PostgreSQL records from Supabase Storage bytes. Supabase database backups include Storage metadata but do not restore deleted Storage objects. The Juristic Person must therefore approve and operate both a database backup and an independent private-object recovery process.

Official platform reference: [Supabase Database Backups](https://supabase.com/docs/guides/platform/backups).

## Current verified position

- The hosted project contains zero tenants, Auth users, application accounts and Storage objects as of 2026-07-18.
- The current hosted migration ledger contains only `20260717153210`.
- The local candidate cleanly restores 136 authoritative tables and five private bucket records.
- `pnpm restore:validate` passed against an isolated local validation database.
- `pnpm storage:recovery` passed a private object loss/recovery simulation with matching SHA-256.
- Hosted plan, RPO, RTO, backup frequency, object-copy destination, encryption/key custody, archive custody and exercise cadence remain pending human approval.

Do not describe the local exercises as proof that hosted backups are enabled or sufficient.

## Required backup assets

| Asset                       | Minimum preserved information                                                                                                                                             |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PostgreSQL                  | schema, data, migration ledger, extensions, constraints, RLS/policies, functions, triggers, Audit and Timeline                                                            |
| Supabase Storage            | original private bytes, bucket/path, tenant/aggregate linkage, size, media type, classification, SHA-256, custody and retention/hold state                                |
| Supabase Auth/configuration | user linkage records, Site URL, exact redirects, provider/MFA/session/rate settings and configuration evidence; never export passwords or token values into documentation |
| Edge Functions              | exact source commit, deployed function version, allowed origins, secret names, accountable owners and rotation times; secret values remain in the secret manager          |
| Vercel                      | project ID, deployment IDs, domains, framework/build/output settings, environment variable names and release source commit                                                |
| Git                         | protected release branch, full commit IDs, migration files, lockfile and immutable rollback tag                                                                           |
| Organizational Memory       | sealed manifests, manifest items, schema catalog version, content digests, archive object and custody/verification evidence                                               |
| Operating records           | recovery policy version, RPO/RTO, backup job evidence, exceptions, restore results, approver and next review date                                                         |

## Policy gate before operational data

The accountable authorities must approve:

- RPO and RTO by service/data criticality;
- managed backup/PITR plan and retention window;
- independent logical export cadence;
- private Storage object copy and version-retention cadence;
- encryption, geographic location, processor and key custody;
- legal hold, privacy restriction, disposition and backup expiry;
- backup operator, restore authority, independent verifier and emergency succession;
- restore exercise frequency and acceptance thresholds;
- incident notification and provider-exit process.

Record these decisions in `docs/policies/PRODUCTION_POLICY_APPROVAL_PACK.md`. Until approved, no default interval or retention period may be presented as organizational policy.

## Database backup procedure

### Managed backup

1. In the Supabase Dashboard, verify the project plan and the Database Backups page.
2. Record whether the project uses daily physical backups or Point-in-Time Recovery, the earliest/latest recovery point and the applicable retention window.
3. Confirm the named restore authority can access the control without sharing credentials.
4. Record backup health evidence without copying access tokens, database passwords or connection strings.
5. Treat project deletion as destructive and irreversible; it is never a backup or rollback action.

### Independent logical export

Use an approved encrypted destination outside the Git repository, synchronized project folders and ordinary user Downloads/Desktop paths. From a clean linked checkout, the authorized custodian may run:

```text
pnpm supabase db dump --linked --file "<approved-encrypted-path>/o83-care-<UTC-timestamp>-schema.sql"
pnpm supabase db dump --linked --data-only --use-copy --file "<approved-encrypted-path>/o83-care-<UTC-timestamp>-data.sql"
```

Before execution, run `pnpm supabase db dump --help` and confirm the pinned CLI options. Allow the CLI or approved secret store to obtain authentication; never paste a database password or access token into a ticket, script, Markdown file or chat.

After export:

1. Compute a cryptographic digest using the approved organizational algorithm.
2. Record file name, byte length, digest, source project, migration versions, backup start/end, operator, tool versions and classification.
3. Encrypt under approved key custody.
4. Copy to the approved independent/off-site destination.
5. Verify the copied digest.
6. Apply retention/legal-hold controls; do not rely on a workstation recycle bin.

The dump command does not export private Storage bytes.

## Private Storage backup procedure

Before storing Production Evidence, establish an approved server-side object-copy process for all five private buckets:

- `o83-artifacts`
- `o83-evidence-intake`
- `o83-evidence-originals`
- `o83-evidence-renditions`
- `o83-memory-archive`

Requirements:

1. Enumerate objects using a server-only identity with narrow, logged purpose; never expose service credentials to a browser.
2. Copy bytes to an encrypted, access-controlled and independently retained object store.
3. Preserve bucket, path, object version where supported, size, media type, classification, source modification time and backup time.
4. Reconcile each trusted Evidence/Memory object against the authoritative database metadata and O83 SHA-256 digest. Do not treat provider ETag values as O83 evidence digests.
5. Record missing metadata, missing bytes, digest mismatch, quarantine state, legal hold and copy failure as explicit exceptions.
6. Do not release quarantined files into normal backup-consumer access.
7. Verify restoration to an isolated private bucket and re-check the SHA-256 before accepting the backup.
8. Preserve the period of unavailability and every recovery/custody event; never fabricate a lost original.

The repository currently has only a **local** Storage recovery script. It must never be pointed at hosted Production credentials. A hosted object backup service or approved provider-native process is a required operational configuration in the next sprint.

## Configuration and release backup

At each approved release, record:

- full Git commit and immutable rollback tag;
- local/remote migration ledger comparison;
- deployed Edge Function names and source commit;
- Vercel deployment ID, environment and domains;
- Supabase project ref and region;
- Auth Site URL and exact redirect allow-list;
- Data API exposed schemas and automatic-exposure setting;
- bucket privacy and Storage policy names;
- environment/secret **names**, owner and last rotation time, never values;
- validation results and accountable release Decision.

This configuration evidence allows reconstruction without turning documentation into a credential store.

## Restore validation

### Local rehearsal

With the local Supabase stack healthy, run:

```text
pnpm restore:validate
pnpm storage:recovery
```

The first command creates and removes only the fixed isolated local validation database. The second uses local-only credentials in process memory and cleans its private test object. Review `docs/operations/CONTINUITY_AND_RECOVERY_RUNBOOK.md` before execution.

### Hosted isolated restore

1. Declare the exercise/Incident and name the incident commander, database custodian, Storage custodian, security verifier, business verifier and recorder.
2. Select an approved database recovery point and an independent Storage recovery point.
3. Restore into a separate hosted recovery/staging project; do not overwrite Production for a test.
4. Apply the exact application and migration lineage associated with the recovery point.
5. Restore private object bytes into isolated private buckets.
6. Reconcile every relevant object against database metadata and SHA-256.
7. Verify Auth/configuration, 136-table expectation for the candidate, forced RLS, policies, five private buckets, functions, triggers and migration ledger.
8. Run Database/RLS/adversarial, Storage, application, browser, accessibility, performance and approved load gates.
9. Have an authorized human verify critical Cases, Incidents, Operations, Responsibility, Decisions, Evidence, notifications, reports and Organizational Memory.
10. Record achieved RPO/RTO, gaps, limitations, exceptions and the accept/reject Decision.
11. Destroy the exercise environment only under its retention/disposal policy and after evidence has been retained.

## Backup acceptance criteria

A backup set is accepted only when:

- its source, time, scope, version and custodian are known;
- database and Storage are both covered;
- digests match after independent copy;
- encryption and access controls are verified;
- migration, Auth, RLS, Storage and release configuration can be reconstructed;
- an isolated restore passes technical and human record checks;
- achieved RPO/RTO are measured rather than assumed;
- exceptions and unrecovered records are explicit;
- the accountable recovery authority signs the result.

Failed or partial backups remain immutable evidence of the attempt and must trigger corrective Responsibility; they are never silently relabeled as successful.
