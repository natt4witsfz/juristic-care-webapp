# O83 Care Rollback Procedure

## Purpose

This procedure returns O83 Care to the last verified safe service state while preserving history, Evidence, Operational Truth, auditability and Organizational Memory. Rollback is an accountable incident Decision, not an informal developer action.

The currently verified frontend baseline is Vercel deployment `dpl_BXPtNazpHtkRrEkt2eHNpgDnnAws`, sourced from commit `4f318f07860dbe2399d5d3f9474facef15074436` and protected by Git tag `o83-care-rollback-20260718-103122-ict`.

## Non-negotiable safety rules

- Human safety and approved manual/emergency channels take priority over application availability.
- Never use `git reset --hard`, force-push, migration-ledger deletion, Production database reset, destructive schema reversal or broad RLS grants as rollback tools.
- Never edit a migration that has reached a shared environment.
- Never destroy the affected environment before evidence, logs, state, impact and the recovery point are preserved.
- Never assume a database restore recovers Supabase Storage object bytes.
- Never expose a service-role key, database password, access token or backup key in chat, documentation, Git, browser variables or command output.

## Roles required

| Role                         | Responsibility                                                                                 |
| ---------------------------- | ---------------------------------------------------------------------------------------------- |
| Incident commander           | Owns safety, scope, freeze, rollback/cutover Decision and communications                       |
| Application release operator | Executes Vercel rollback and application verification                                          |
| Database custodian           | Preserves database evidence and plans forward correction or isolated restore                   |
| Storage custodian            | Preserves/reconciles private object bytes and digests                                          |
| Security verifier            | Confirms Auth, RLS, Storage, secrets, redirects and tenant boundaries remain protected         |
| Business verifier            | Checks critical Cases, Incidents, Operations, Responsibility and communications after recovery |
| Recorder                     | Preserves timeline, commands, evidence, observations, decisions and revised understanding      |

No single technical operator should authorize and independently verify a high-impact Production rollback.

## Trigger classification

| Incident                                                         | Preferred response                                                                                                                  |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Static frontend defect with healthy compatible Supabase services | Vercel Instant Rollback                                                                                                             |
| Edge Function defect with compatible database/frontend           | Redeploy last approved function version or remove it from traffic under the incident plan                                           |
| Additive migration defect without corrupted data                 | Hold unsafe writes, use a compatible frontend, then apply an authorized forward correction                                          |
| Authorization or cross-tenant exposure                           | Immediately stop affected access, revoke/rotate exposed credentials, preserve logs, notify security authority, then correct forward |
| Logical data corruption                                          | Stop unsafe writes and restore or repair first in isolation                                                                         |
| Database/platform outage                                         | Invoke the approved Supabase restore/failover and manual-continuity plan                                                            |
| Storage object loss                                              | Restore bytes separately, verify SHA-256, reconcile metadata/custody and record the unavailability period                           |

## Phase 1 — Declare and preserve

1. Open a recovery Incident and record detection time, affected users/tenants, symptoms, suspected release, current deployment, current migration ledger and available Evidence.
2. Name the roles above and identify the Authority instrument for the rollback.
3. Activate approved manual or emergency channels when safety or essential service is affected.
4. Stop only unsafe writes or traffic using the least disruptive approved control. Do not reset or delete the source environment.
5. Preserve Vercel/Supabase logs, deployment identifiers, database recovery points, Storage inventory, configuration versions and relevant screenshots or exports.
6. Decide whether the fault is frontend-only, function, database, identity/security, Storage or multi-component.

## Phase 2 — Frontend-only rollback

Use this path only after confirming that the target frontend is compatible with the current database, Auth, Storage and function state.

1. In Vercel, select team `frostberg` and project `o83-care`.
2. Inspect the current and target deployment identities, environment, source commit and domain aliases.
3. Select **Instant Rollback** from the Production Deployment tile and choose the last verified eligible deployment. For rollback from a future candidate release, the known-good baseline is `dpl_BXPtNazpHtkRrEkt2eHNpgDnnAws`.
4. Confirm the listed domains. Vercel rollback reassigns domains to a prior build; it does not rebuild that deployment with newly changed environment variables.
5. If the approved operator uses the CLI, first inspect the installed command with `vercel rollback --help`; then target the approved deployment ID or URL. Do not place a Vercel token on the command line or in this document.
6. Record the resulting current deployment ID and rollback state. Vercel may suspend automatic Production-domain assignment after Instant Rollback; restore normal promotion behavior only through a later approved release.

Official operational reference: [Vercel Instant Rollback](https://vercel.com/docs/instant-rollback).

## Phase 3 — Database and Edge Function handling

### Candidate not yet migrated

As of this handover, hosted Supabase contains only migration `20260717153210` and no deployed Edge Functions. No database or function rollback is required for the local candidate because it has not reached the hosted project.

### Candidate migrated but database remains sound

1. Do not delete `20260718050844` or `20260718053532` from migration history.
2. Confirm whether the known-good frontend can operate safely with the additive schema. Do not assume compatibility; verify protected routing, reads, writes, RLS and Storage.
3. Keep the database at the latest applied state when safe and prepare a new timestamped forward-correction migration.
4. Exercise the correction on an isolated restored staging database, rerun lint and all Database/RLS/adversarial tests, and obtain change approval before Production.
5. Redeploy Edge Functions only from an identified approved source commit. If a function must be taken out of traffic, first ensure no live Evidence or Memory workflow depends on it and record the resulting service limitation.

### Corruption or unacceptable data change

1. Freeze unsafe writes and preserve the source project.
2. Select a database recovery point from before the harmful transaction.
3. Select an independent Storage recovery point; the two may differ.
4. Restore into an isolated project or approved recovery target first.
5. Apply the application/migration lineage matching that recovery point.
6. Reconcile Auth configuration, five private buckets, every relevant Evidence object, SHA-256 digest, custody record, Audit, Timeline and Organizational Memory manifest.
7. Run the complete release gate and independent human record verification.
8. Cut over only after an authorized recovery Decision and communication plan.

Official database reference: [Supabase Database Backups](https://supabase.com/docs/guides/platform/backups).

## Phase 4 — Verification after rollback

At minimum verify:

- Production `/` and `/system-status` return the expected release and environment;
- anonymous access to protected workspace routes redirects to sign-in;
- Auth Site URL and exact redirect allow-list remain correct;
- Data API exposure remains limited to the controlled `api` boundary;
- tenant, role, relationship, disabled-account, expired-role and Mandate checks deny inappropriate access;
- all authoritative tables retain forced RLS;
- all O83 buckets remain private and browser access to trusted/quarantined objects is denied;
- critical Case, Incident, Operation, Responsibility, Decision, Evidence, Audit and Timeline records are present and internally consistent;
- notification/offline queues are reconciled without duplicate domain actions;
- browser errors, server errors and security alerts are reviewed;
- no secret or source map was introduced in the served bundle.

## Phase 5 — Close and learn

1. Record the old and new deployment/function/migration state, start/end time, achieved RPO/RTO, service impact and any unrecovered data or Evidence.
2. Preserve observation, hypothesis, evidence, Decision and revised understanding separately.
3. Notify affected parties according to approved disclosure and incident policy.
4. Create forward actions with named Responsibility, Authority, due date and verification method.
5. Update this procedure, the risk register and Organizational Memory through versioned records; do not overwrite the incident history.

Rollback is complete only when safety, access control, database and Storage integrity, critical business traceability and the authorized human recovery Decision are all verified.
