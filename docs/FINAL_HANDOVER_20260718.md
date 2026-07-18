# O83 Care Final Engineering Handover

**Handover date:** 2026-07-18

**Repository:** `https://github.com/natt4witsfz/juristic-care-webapp.git`

**Technical release candidate:** local commit `9d06858` on branch `production-go-technical-20260718`

**Currently deployed baseline:** commit `4f318f07860dbe2399d5d3f9474facef15074436`

**Operational Production decision:** **NO GO pending accountable business approvals and controlled hosted acceptance**

## Purpose and scope

This is the final technical handover for the O83 Care release candidate. It identifies what is implemented, what is live, what remains governed by human approval, and how the next operator should provision, release, back up, and recover the system.

The handover does not grant business Authority, approve policy, create users, expose credentials, apply migrations, deploy Edge Functions, or promote a new Vercel build. Operational Truth remains the Juristic Person's best current understanding based on verifiable evidence; this record must be revised by adding later evidence, never by erasing the prior state.

## 1. Feature completion summary

The status below distinguishes the locally verified candidate from the older live baseline.

| Capability                                                                         | Candidate `9d06858`                                                                               | Current live baseline                                 | Handover evidence                                                          |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ----------------------------------------------------- | -------------------------------------------------------------------------- |
| React/TypeScript/Vite workspace, routing, query layer, security headers, CI        | Implemented and locally verified                                                                  | Deployed                                              | `review/14_GO_NO_GO.md`                                                    |
| Supabase Auth client, session lifecycle, protected routing, password recovery      | Implemented and locally verified                                                                  | Deployed foundation; no users                         | `review/18_HOSTED_DEPLOYMENT_20260718.md`                                  |
| Tenant isolation, forced RLS, database-owned access resolution, Audit and Timeline | Implemented; 58 Database/RLS/security assertions pass                                             | Baseline RLS deployed                                 | `review/14_GO_NO_GO.md`                                                    |
| Report-to-Case intake invariant                                                    | Implemented in the database/application foundation                                                | Baseline command deployed; no operational data        | `architecture_v2/00_foundation.md` and database tests                      |
| Investigation and Case association                                                 | Candidate UI, validation, commands, RLS projections, Audit and Timeline complete                  | Not deployed                                          | Candidate migrations and frontend workspace                                |
| Human Incident verification and Case-to-Incident association                       | Candidate slice complete; Cases remain separate                                                   | Not deployed                                          | `api.verify_incident_from_investigation`, `api.associate_case_to_incident` |
| Operations, Operational Tasks, Commitment, completion and verification             | Candidate slice complete                                                                          | Not deployed                                          | Operations workspace and lifecycle tests                                   |
| Responsibility transfer                                                            | Atomic candidate command preserves predecessor/successor history and Authority evidence           | Not deployed                                          | Candidate operational migration and adversarial tests                      |
| Close, reopen, recurrence and follow-up support                                    | Candidate command/UI paths preserve prior closure and revised understanding                       | Not deployed                                          | Incident and Operation lifecycle tests                                     |
| Evidence intake, quarantine, digest, private access and trusted promotion          | Candidate database, Storage policies, UI and Edge processor complete locally                      | Baseline private buckets only; processor not deployed | Evidence tests and Storage recovery exercise                               |
| In-app Responsibility-routed notifications                                         | Candidate slice complete                                                                          | Not deployed                                          | Notification projection/acknowledgement tests                              |
| Administration of account state and role lifecycle                                 | Candidate commands/UI complete and Mandate-bound                                                  | Not deployed; no initial account                      | Administration tests and First Administrator Guide                         |
| Governed reports and Organizational Memory transfer                                | Candidate projections, manifest lifecycle, UI and Edge transfer function complete locally         | Not deployed                                          | Memory immutability, digest and transfer tests                             |
| Offline continuity                                                                 | Candidate IndexedDB queue, immutable envelope, idempotency and conflict handling complete locally | Not deployed                                          | Offline tests and continuity runbook                                       |
| Accessibility, route splitting, performance and load gates                         | Locally verified                                                                                  | Live baseline smoke-tested only                       | 27 unit/component tests, seven Playwright tests, gzip budget and load test |
| Database and private Storage recovery                                              | Locally verified                                                                                  | Hosted recovery policy not approved                   | Restore and Storage recovery scripts/runbook                               |

The candidate closes the known technical blockers identified as PR-01 through PR-03. Completion means executable technical evidence exists; it does not mean the Juristic Person has accepted the workflow, policy, service level, legal basis, or operational release.

## 2. Remaining limitations

| Limitation                                                                                                                                         | Classification                   | Required closure                                                                                                                             |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Candidate commit `9d06858` has not been pushed, staged, or deployed                                                                                | Release-state limitation         | Normal review, CI, protected Preview/staging acceptance, authorized change window, and deliberate promotion                                  |
| Hosted Supabase has only the baseline migration; two candidate migrations are pending                                                              | Release-state limitation         | Apply to an isolated staging project first, run the full hosted gate, then apply under approved Production change control                    |
| The two candidate Edge Functions are not deployed                                                                                                  | Release-state limitation         | Configure server-only secrets and exact allowed origin, deploy to staging, run Evidence/Memory acceptance, then release under change control |
| Hosted project has zero Juristic Persons, Auth users, application accounts, and Storage objects                                                    | Intentional safety state         | Approved tenant and first-administrator bootstrap followed by governed role fixtures                                                         |
| No automated, approved first-tenant/first-admin bootstrap command exists                                                                           | Technical-operational limitation | Use a reviewed one-time provisioning migration/controlled service and make the workflow repeatable in the recommended next sprint            |
| Required privacy, retention, emergency Authority, SLA, Evidence, recovery, security, AI, accessibility, capacity and release policies are unsigned | Business blocker                 | Accountable authorities sign `docs/policies/PRODUCTION_POLICY_APPROVAL_PACK.md`                                                              |
| SMTP/sender, invitation/recovery operations, MFA/session policy and abuse support are not production-accepted                                      | Business/configuration blocker   | Approve providers/settings, configure them in hosted control planes, and pass real-identity acceptance                                       |
| External email/SMS/voice notifications are not configured                                                                                          | Product/configuration limitation | Approve channels, disclosure, templates, quiet hours, retries and providers before adding credentials                                        |
| Hosted backup plan, RPO/RTO, independent Storage-byte backup and archive custody are not approved                                                  | Business/continuity blocker      | Approve the recovery policy and execute a hosted isolated restore plus object reconciliation                                                 |
| No governed staging identities have exercised the complete role, tenant, property, disabled-account, expired-role and expired-Mandate matrix       | Acceptance limitation            | Provision non-production fixtures and execute the adversarial acceptance matrix before inviting Production users                             |
| The load test is a reproducible local baseline, not an approved Production traffic model                                                           | Capacity limitation              | Approve traffic/service-level targets and execute a staging load exercise within an authorized scope                                         |
| No authorized external penetration test has been performed                                                                                         | Assurance limitation             | Approve target, data handling, scope and test window; close or accept findings                                                               |
| AI remains an Organizational Mirror boundary with no approved provider/use case                                                                    | Intentional limitation           | Keep disabled until AI policy, provider, data classification, evaluation, kill switch and human review are approved                          |
| `AGENTS.md` references `docs/PROJECT_CONTEXT.md`, `docs/DESIGN_SYSTEM.md`, `docs/UX_RULES.md`, and `docs/ACCEPTANCE_CRITERIA.md`, which are absent | Documentation limitation         | Reconcile the agent instructions with the actual architecture/planning sources in a documentation-only maintenance task                      |

## 3. Test accounts

There are **no test accounts or administrator accounts** in the hosted project. A count-only hosted check on 2026-07-18 returned:

| Record                        | Count |
| ----------------------------- | ----: |
| Supabase Auth users           |     0 |
| O83 application user accounts |     0 |
| Juristic Persons              |     0 |
| Storage objects               |     0 |

The automated suites use synthetic UUIDs, claims, fixtures, and `example.test` addresses. They do not create reusable credentials. No username, password, access token, service-role key, database password, or recovery code is included in the repository or this handover.

Before hosted acceptance, create governed **staging-only** identities for administrator, manager, staff, technician, resident, committee, vendor and AI-service boundaries, plus disabled, expired-role and expired-Mandate cases. Deliver invitations through the approved provider; store credentials in the organization's approved password/identity system, never in Git, Markdown, tickets, or chat.

See [FIRST_ADMINISTRATOR_GUIDE.md](FIRST_ADMINISTRATOR_GUIDE.md).

## 4. Database migration status

Read-only `supabase migration list --linked` verification on 2026-07-18 returned:

| Migration                                                 | Local candidate | Hosted Production | Status                                        |
| --------------------------------------------------------- | --------------- | ----------------- | --------------------------------------------- |
| `20260717153210_o83_care_initial_schema.sql`              | Present         | Applied           | Live baseline                                 |
| `20260718050844_production_go_operational_commands.sql`   | Present         | Not applied       | Pending controlled staging/Production release |
| `20260718053532_production_go_continuity_projections.sql` | Present         | Not applied       | Pending after the operational migration       |

Local clean reset applies all three migrations and validates 136 authoritative tables, five private bucket records, database lint, and 58 Database/RLS/adversarial/lifecycle assertions. The hosted baseline contains 135 authoritative tables. Migration history must remain forward-only: never edit an applied migration, delete its ledger entry, reset Production, or use destructive rollback merely to align environments.

The local repository contains two Edge Functions:

- `evidence-process`
- `memory-transfer`

A read-only hosted function listing returned an empty collection on 2026-07-18. Neither function is currently live.

## 5. Production deployment information

| Item                        | Verified value                                                                              |
| --------------------------- | ------------------------------------------------------------------------------------------- |
| Production URL              | `https://o83-care.vercel.app`                                                               |
| Public verification         | `/` and `/system-status` returned HTTP 200 on 2026-07-18                                    |
| Vercel team/project         | `frostberg/o83-care` (`prj_LlYhokTvFJ6lAzIXXS6FLbyv8rFD`)                                   |
| Current verified deployment | `dpl_BXPtNazpHtkRrEkt2eHNpgDnnAws`                                                          |
| Current deployed source     | `4f318f07860dbe2399d5d3f9474facef15074436`                                                  |
| Verified Preview            | `https://o83-care-fpks7s0ne-frostberg.vercel.app` (`dpl_AunvumKM9TriNtKkmUdWXm6kiaWg`)      |
| Supabase organization       | `O83 Juristic MD Version` (`puvnfotquuiumdezvghy`)                                          |
| Supabase project            | `O83 Juristic MD Version` (`uqzfptxbtzufijjxfbut`)                                          |
| Supabase region/runtime     | `ap-southeast-1`; PostgreSQL `17.6.1.147` at the verified deployment gate                   |
| Auth Site URL               | `https://o83-care.vercel.app`                                                               |
| Data API exposure           | controlled `api` schema plus platform defaults; automatic future-table exposure disabled    |
| Storage                     | five private O83 buckets; current object count 0                                            |
| Operational use             | **NO GO** until the approvals and hosted acceptance in `review/14_GO_NO_GO.md` are recorded |

Only browser-safe `VITE_` configuration belongs in Vercel frontend environments. Database passwords, Supabase access tokens, service-role/secret keys, SMTP credentials, backup keys and provider secrets remain server-side and are not recorded here.

## 6. Repository commit

| Purpose                             | Branch/ref                              | Commit                                                            |
| ----------------------------------- | --------------------------------------- | ----------------------------------------------------------------- |
| Current technical release candidate | `production-go-technical-20260718`      | `9d06858` (`feat: close production technical readiness blockers`) |
| Current remote integration branch   | `origin/feature/routine-daily-task`     | `11d2b7f`                                                         |
| Current deployed application source | rollback-tagged baseline                | `4f318f07860dbe2399d5d3f9474facef15074436`                        |
| Deployed rollback tag               | `o83-care-rollback-20260718-103122-ict` | Points to the deployed baseline                                   |

At handover preparation time, the candidate branch was one local commit ahead of `origin/feature/routine-daily-task`; it was not pushed. This documentation is committed separately as a descendant of `9d06858`. The receiving engineer must use `git rev-parse HEAD` to record the complete documentation checkpoint and must not force-push or rewrite the rollback tag.

## 7. Rollback procedure

The safe rollback sequence is documented in [ROLLBACK_PROCEDURE.md](ROLLBACK_PROCEDURE.md).

Key rules:

1. Human safety and continuity channels take priority over software recovery.
2. Name an incident commander and record the rollback Decision, evidence and scope.
3. For a frontend-only incident, use Vercel Instant Rollback to the last verified deployment. Do not rebuild from an arbitrary working tree.
4. A database migration is never rolled back by deleting history or editing an applied file. Prefer a compatible frontend rollback and an authorized forward correction.
5. For data corruption, restore to isolation first; Production restore requires approved downtime, recovery point, communication, verification and cutover.
6. Database restoration does not restore deleted Storage bytes. Reconcile private objects and their SHA-256 digests separately.

## 8. Backup procedure

The full procedure is documented in [BACKUP_PROCEDURE.md](BACKUP_PROCEDURE.md).

The minimum recovery set consists of:

- PostgreSQL backup and migration ledger;
- private Storage object bytes plus an O83 manifest and digest reconciliation;
- Auth, redirect, Data API, RLS, bucket and Edge Function configuration inventory;
- server-side secret names, owners and rotation metadata, but never secret values in the export;
- Vercel project/environment configuration and deployment identifiers;
- Git commit, protected release branch and immutable rollback tag;
- Organizational Memory manifests and archive artifacts.

The current local restore test verifies 136 tables and five private buckets. The local Storage recovery test verifies byte-for-byte SHA-256 recovery. Those tests do not prove a hosted Production backup policy; RPO/RTO, cadence, custody and off-site Storage copy require human approval.

## 9. First administrator guide

The governed bootstrap guide is [FIRST_ADMINISTRATOR_GUIDE.md](FIRST_ADMINISTRATOR_GUIDE.md).

The critical distinction is that an `admin` role grants technical administration permissions; it does not create committee power, emergency Authority, Responsibility, Commitment, Capability or approval rights. The initial administrator requires an approved organization relationship and an effective Mandate for `permission.manage`. Subsequent changes must use the audited administration commands.

No one can become the first administrator merely by signing up or editing browser metadata. Authorization is derived from Supabase Auth linkage to database-owned Person, relationship, role, permission and Mandate records.

## 10. Recommended next sprint

### Sprint 16 — Governed Staging Acceptance and Production Stewardship

**Goal:** Convert the locally verified candidate into an accountable, recoverable and human-approved hosted release without adding unrelated product scope.

**Priority:** P0 release gate

**Scope:**

1. Reconcile the branch through normal review and CI; do not rewrite history.
2. Create or designate an isolated Supabase staging project and protected Vercel Preview/staging environment.
3. Apply the two pending migrations to staging and deploy both Edge Functions with server-only secrets and exact origin policy.
4. Implement or package a repeatable, two-person-controlled first-tenant/first-admin provisioning workflow; do not embed a default administrator.
5. Provision governed staging identities for every role and negative lifecycle case.
6. Execute end-to-end Auth, RLS, Storage, Evidence, Incident, Operation, Responsibility, notification, offline, report and Memory scenarios using real JWTs.
7. Approve and configure SMTP, MFA/session, notification, backup, RPO/RTO, monitoring/on-call, accessibility, performance, emergency Authority, privacy/retention, Evidence and AI policy.
8. Run hosted database lint/tests, private object recovery, isolated restore, accessibility, approved load profile, security/penetration scope and operational rehearsal.
9. Train the first administrator and operational stewards; record pilot, support, rollback and hypercare ownership.
10. Record the accountable Production GO Decision, then deploy only in the authorized change window and verify live behavior.

**Definition of Done:**

- candidate commit and migration/function versions are identical across source, staging evidence and approved release artifact;
- every required policy group has a named approver, effective version and Decision evidence;
- the first administrator and role matrix work without broad grants or browser-held secrets;
- database, RLS, Storage, Evidence, restore, continuity, accessibility, performance, security and real-identity acceptance pass in hosted staging;
- rollback and recovery are rehearsed and owners can execute them;
- the Juristic Person records an explicit Production GO or NO GO.

## Handover decision

The software release candidate is technically ready for governed hosted acceptance. The currently live baseline remains available and empty. The next team must not treat technical completion, an HTTP 200 response, an administrator role, or deployment access as business authorization.
