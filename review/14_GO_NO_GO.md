# O83 Care Readiness Decisions

**Decision date:** 2026-07-18  
**Evidence cut-off:** Final local gate recorded in `review/16_FINAL_LOCAL_READINESS_20260718.md`

## Decisions

| Scope             | Decision  | Verified basis                                                                                                                                                                                                                                                      |
| ----------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Local development | **GO**    | Frozen dependency installation, formatting, lint, strict type-check, 14 unit/component tests, 22 database/RLS tests, production build, two Playwright tests, database lint, static SQL validation, and dependency audit passed. Core Supabase services are healthy. |
| Hosted staging    | **NO GO** | No Git repository/history is present, and no hosted Supabase or Vercel project authorization/configuration is available. Hosted Auth, Storage, redirect, email, real-identity RLS, and deployment behavior are unproven.                                            |
| Production        | **NO GO** | Required operational vertical slices, adversarial identity/Storage tests, continuity/restore proof, production controls, and Juristic Person policy approvals remain incomplete.                                                                                    |

## Verified local evidence

- PostgreSQL is accepting connections; Auth, Storage, Data API, Studio, local mail, Realtime, gateway, metadata, and related core containers are running.
- The repaired timestamped migration has already passed local startup and a clean reset.
- Supabase database lint returned no schema errors across the O83, `api`, and `core` schemas.
- Both pgTAP files passed: 22 database/RLS assertions.
- Backend and frontend lint and strict TypeScript checks passed.
- Backend tests passed 2/2; frontend tests passed 12/12.
- The production build completed, and both Chromium Playwright tests passed.
- The frozen lockfile installation was already up to date, and the registry audit found no known vulnerabilities.
- Environment-template and repository-pattern scans found no real credential, private key, token, or password-bearing database URL.
- Local backup, environment, dependency, build, coverage, Playwright, Supabase temporary, and Vercel state paths have explicit ignore coverage.

## Hosted staging blockers

1. This directory is not a Git repository. Consequently, no authoritative status, diff, tracked-file inventory, commit, branch protection, or remote CI evidence exists.
2. No staging Supabase project reference, CLI authorization, database migration credential, project URL, or browser-safe publishable key is configured.
3. No staging Vercel project/team authorization, project linkage, deployment origin, or environment configuration is available.
4. Auth Site URL, redirect allow-list, SMTP/sender settings, invitation/recovery delivery, and hosted session behavior are not validated.
5. Real Auth identities have not exercised cross-tenant, disabled-account, expired-role/Mandate, resident, technician, committee, administrator, vendor, or AI denial paths.
6. Hosted Storage upload, quarantine, digest, signed read, loss/recovery, and object/database reconciliation are not implemented and validated end to end.

## Production blockers

1. Incident association, Operations/tasks, Responsibility transfer, Evidence workflow, completion, verification, reopen/recurrence, follow-up, administration, notification, and governed reporting vertical slices remain incomplete.
2. Production-shaped load, accessibility, penetration, resilience, offline/manual continuity, Storage recovery, complete backup restore, and Organizational Memory export/import have not passed.
3. Critical and High program risks do not yet have complete control evidence and authorized residual-risk Decisions.
4. Juristic Person approvals remain outstanding for privacy/retention, emergency Authority and succession, committee governance, SLA rules, evidence standards, dispute/access handling, vendor abandonment, notifications, RPO/RTO/archive custody, and governed AI use.

## Non-blocking local warnings

- The optional Supabase Vector log collector restarts because it cannot reach the Docker log API while insecure TCP exposure remains disabled. The application has no runtime dependency on this local Analytics/log-collection path. Core database, Auth, Storage, API, and tests are unaffected.
- Vite reports a 614.55 kB minified main JavaScript chunk. Route-level code splitting and a performance budget remain pre-production work.
- Playwright reports a harmless `NO_COLOR`/`FORCE_COLOR` warning.
- Several historical review/planning/architecture artifacts are exact duplicates or contain superseded pre-Docker statements. They were identified in the dated readiness report and intentionally not deleted.

## Conditions to reconsider hosted staging

- Restore the intended Git history and remote, review the complete diff, and obtain a clean reviewed baseline commit with CI evidence.
- Provision and link isolated staging Supabase and Vercel projects using secrets stored only in the relevant platforms.
- Configure and verify hosted Auth, redirects, email, Storage, least-privileged identity fixtures, migration, lint, tests, headers, and rollback evidence.

## Conditions to reconsider production

- Complete dependency-ordered operational vertical slices through controlled commands without weakening RLS, history, audit, Evidence, or Storage controls.
- Pass the full real-identity RLS/Storage/service-role matrix, all 31 operational scenarios, accessibility/performance/security validation, restore and continuity exercises, and production-shaped load tests.
- Obtain the outstanding Juristic Person policy approvals and close or formally treat every applicable Critical/High risk.
- Record a human release Decision with accountable business, security, privacy, operations, data, and technical acceptance.

No repository artifact authorizes production use or replacement of current safety and operational processes.
