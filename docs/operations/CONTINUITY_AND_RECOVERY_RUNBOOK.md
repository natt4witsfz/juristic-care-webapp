# O83 Care Continuity and Recovery Runbook

## Purpose and safety boundary

This runbook verifies that O83 Care records and private object bytes can be recovered without treating a backup as proof of business correctness. Database records, Supabase Storage objects, Auth configuration, external provider configuration, and deployment configuration are separate recovery assets.

The automated commands in this repository operate only against the local Supabase stack. A hosted restore requires an approved incident commander, change record, target project, recovery point, communication plan, and rollback Decision. Never run local validation commands with hosted credentials.

## Local database restore validation

Prerequisites are a healthy local Supabase database container and Docker. Run:

```text
pnpm restore:validate
```

The script creates a custom-format dump inside the local database container, creates the isolated database `o83_restore_validation`, and restores the full Supabase database with the local bootstrap administrator required for managed Auth/Realtime objects. It then verifies all 136 authoritative tables and five private bucket records, drops only that fixed validation database, and removes only the fixed temporary dump. It does not stop, reset, or modify the primary local database, and it does not grant the application database role any additional privilege.

## Private Storage byte recovery validation

Run:

```text
pnpm storage:recovery
```

The wrapper reads local-only service credentials from `supabase status` into process memory, uploads unique known bytes to the private Memory bucket, downloads and validates SHA-256, removes the object, repeats upload and verification as a recovery simulation, and cleans up. It never prints or writes the credential and never uses hosted credentials.

## Hosted recovery sequence

1. Declare the recovery Incident and name the incident commander, record custodian, Storage custodian, communications lead, and verifier.
2. Stop unsafe writes using an approved maintenance boundary; do not destroy the source project.
3. Select a database recovery point and independently select a Storage-object recovery point.
4. Restore into an isolated hosted recovery project or approved staging target.
5. Apply the exact application release and migration lineage associated with the recovery point.
6. Reconcile database Evidence metadata against original and rendition object existence and SHA-256.
7. Verify Auth settings, redirect allowlists, SMTP, Edge Function secrets, RLS, Storage policies, service principals, and external integrations.
8. Run database, adversarial identity, Storage, unit, component, build, accessibility, performance, load, and Playwright gates.
9. Have an independent authorized human verify critical Cases, active Incidents, Operations, Responsibility Chain, Decisions, Evidence, notifications, and Organizational Memory manifests.
10. Record the restore Decision, evidence, limitations, gaps, selected cutover time, notifications, and revised understanding.
11. Cut over only under the approved Production change procedure. Preserve the old environment and recovery evidence according to policy.

## Offline continuity

When connectivity fails, authorized users can queue immutable command envelopes on their device. Each envelope preserves a unique identifier, occurred time, aggregate identity, expected version, and payload. On reconnection the server calculates the payload digest and either accepts the envelope for governed processing or records an explicit conflict. Users must never resolve a conflict by changing the historical occurred time or overwriting the current aggregate.

If a device is lost or damaged, treat unsynchronized work as a continuity incident. Recover from human notes and other verifiable Evidence; never fabricate a missing digital envelope. Retrospective records must identify their actual occurred time, later recorded time, source, limitations, and approving human.

## Exit criteria

Recovery is complete only when database and Storage restoration are both verified, security controls are unchanged or stronger, traceability is reconciled, remaining loss is explicitly documented, and the authorized human recovery Decision is recorded. A technically successful restore alone is not Production approval.
