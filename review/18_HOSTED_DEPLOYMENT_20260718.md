# O83 Care Hosted Deployment Evidence

**Date:** 2026-07-18

**Deployment window:** 09:50–10:35 Asia/Bangkok

**Scope:** GitHub recovery publication, hosted Supabase baseline, Vercel Preview, Vercel Production, and live verification

**Technical deployment result:** **VERIFIED**

**Operational production-use decision:** **NO GO** pending the product, governance, continuity, and real-identity conditions in `review/14_GO_NO_GO.md`

## Executive outcome

The approved recovery commit was published without rewriting history, migrated into the verified empty O83 Supabase project, deployed through an explicit Vercel Preview, and deliberately deployed to the stable Vercel Production alias. The live Production application identifies the exact approved commit and passes desktop/mobile browser smoke tests, hosted database/RLS tests, Storage denial tests, security-header checks, deployed-bundle secret scans, and platform log review.

This evidence verifies the hosted technical foundation. It does not assert that O83 Care is complete or authorized to replace existing operational and safety processes. The hosted database intentionally contains no production tenant, invited user, resident, staff member, or operational record. Positive real-identity workflows and the incomplete operational modules therefore remain outside this deployment proof.

## Deployment identity

| Item | Verified value |
| --- | --- |
| Recovery repository | `C:\Users\natta\source\repos\O83_Care_recovery_20260718` |
| Original protected working directory | `C:\Users\natta\OneDrive\Desktop\Codex` — not modified by this workflow |
| GitHub repository | `https://github.com/natt4witsfz/juristic-care-webapp.git` |
| Recovery branch | `recovery-o83-verified-tree-20260718` |
| Approved and deployed commit | `4f318f07860dbe2399d5d3f9474facef15074436` |
| Pull Request | [#1](https://github.com/natt4witsfz/juristic-care-webapp/pull/1) into `feature/routine-daily-task`; open, unmerged |
| Rollback tag | `o83-care-rollback-20260718-103122-ict` |
| Supabase organization | `O83 Juristic MD Version` (`puvnfotquuiumdezvghy`) |
| Supabase project | `O83 Juristic MD Version` (`uqzfptxbtzufijjxfbut`) |
| Supabase region/runtime | `ap-southeast-1`; PostgreSQL `17.6.1.147`; status `ACTIVE_HEALTHY` |
| Vercel team/project | `frostberg/o83-care` (`prj_LlYhokTvFJ6lAzIXXS6FLbyv8rFD`) |
| Preview deployment | `dpl_AunvumKM9TriNtKkmUdWXm6kiaWg` |
| Preview URL | `https://o83-care-fpks7s0ne-frostberg.vercel.app` |
| Production deployment | `dpl_BXPtNazpHtkRrEkt2eHNpgDnnAws` |
| Production URL | `https://o83-care.vercel.app` |

## Commands and operations executed

Credential values were held only in process memory or platform-managed stores. The command record below intentionally names variables and targets without secret values.

### Git and source verification

- `git status --short --branch`
- `git rev-parse HEAD`
- `git ls-remote origin refs/heads/recovery-o83-verified-tree-20260718`
- normal, non-force branch push and remote hash comparison
- annotated rollback tag creation and `git push origin refs/tags/o83-care-rollback-20260718-103122-ict`
- GitHub browser creation of Pull Request #1; no merge performed

### Supabase authentication, discovery, and preflight

- `pnpm supabase login` using browser/device authorization; no access token pasted or printed
- `pnpm supabase orgs list --output json`
- `pnpm supabase projects list --output json`
- `pnpm supabase link --project-ref uqzfptxbtzufijjxfbut --agent no`
- `pnpm supabase migration list --linked`
- `pnpm supabase functions list --project-ref uqzfptxbtzufijjxfbut --output json`
- read-only hosted queries for Auth-user count, O83 schemas/table estimates, Storage buckets, and Storage policies
- targeted migration scan for destructive DDL, Supabase-managed ownership operations, policy removal, and broad grants
- `pnpm supabase db push --linked --dry-run`

### Supabase deployment and validation

- `pnpm supabase db push --linked`
- `pnpm supabase db lint --linked --level warning`
- `pnpm supabase db query --linked --file supabase/tests/database_validation.sql`
- `pnpm supabase db query --linked --file supabase/tests/rls_validation.sql`
- post-migration catalog queries for table/RLS/policy/bucket/function state
- browser configuration of Auth Site URL and four exact redirect URLs
- browser configuration of Data API exposed schemas and automatic-exposure hardening
- sanitized Auth, anonymous RPC, and Storage denial probes
- Supabase Security Advisor and unified log review

### Vercel configuration and deployment

- Vercel CLI `56.3.1` installed outside the repository through `pnpm dlx`
- browser/GitHub Vercel authorization as `natt4witsfz`
- `vercel teams list` and `vercel project list`
- project creation/linking for `frostberg/o83-care`
- project settings: Vite; `pnpm install --frozen-lockfile`; `pnpm --filter @o83/frontend build`; `frontend/dist`
- Preview and Production environment-variable creation using values retrieved directly from Supabase/platform state
- explicit Preview deployment with `vercel deploy --target preview --force --logs`
- deliberate Production deployment with `vercel deploy --prod --force --logs`
- `vercel inspect`, authenticated `vercel curl`, and `vercel logs --level error`
- live HTTP, bundle, browser, and Playwright checks against the stable Production URL

## Hosted Supabase result

### Preflight and migration

The hosted project was unambiguously the only accessible O83 Supabase project. Before migration it contained:

- zero Auth users;
- no O83 application schemas or tables;
- no Storage buckets;
- no O83 policies on `storage.objects`;
- no Edge Functions;
- no remote record for migration `20260717153210`.

The migration dry run listed only `20260717153210_o83_care_initial_schema.sql`. The targeted scan found no `DROP TABLE`, `DROP SCHEMA`, `DROP COLUMN`, `TRUNCATE`, ownership transfer, Supabase-managed table/column comments, or broad anonymous/public grants. Its `DROP POLICY IF EXISTS` and `DROP TRIGGER IF EXISTS` statements are idempotent replacement guards. Because the hosted database was empty and the migration was non-destructive, it was applied automatically as authorized.

The migration completed and recorded version `20260717153210`. Its own structural/domain validation passed. A post-commit Supabase CLI cache warning reported a missing temporary pg-delta certificate file; direct migration-ledger and catalog checks proved that this affected only local catalog caching, not the hosted transaction.

### Database, RLS, and Storage validation

| Check | Result |
| --- | --- |
| Authoritative application tables | 135 |
| RLS enabled | 135/135 |
| RLS forced | 135/135 |
| Application RLS policies | 405 |
| Database lint | PASS; no schema errors |
| Database pgTAP suite | PASS; 7 planned assertions completed |
| RLS pgTAP suite | PASS; 15 planned assertions completed |
| O83 Storage buckets | 5/5, all private |
| O83 `storage.objects` policies | 5/5 |
| Browser Storage update/delete/all policies | 0 |
| Edge Functions in repository/deployed | 0/0; not applicable |

Verified private buckets:

- `o83-artifacts`
- `o83-evidence-intake`
- `o83-evidence-originals`
- `o83-evidence-renditions`
- `o83-memory-archive`

Verified Storage policies:

- `o83_storage_artifact_select`
- `o83_storage_evidence_select`
- `o83_storage_intake_insert`
- `o83_storage_intake_select`
- `o83_storage_trusted_insert`

An anonymous upload to a synthetic path returned HTTP 400, anonymous listing disclosed zero objects, and a direct database query confirmed that no probe object was created. Anonymous invocation of `api.resolve_current_access` reached the exposed schema and returned HTTP 401 / PostgreSQL `42501` as intended.

### Auth and Data API configuration

Supabase Auth is configured with:

- Site URL: `https://o83-care.vercel.app`
- exact allow-listed origins/routes:
  - `https://o83-care.vercel.app`
  - `https://o83-care.vercel.app/reset-password`
  - `https://o83-care-fpks7s0ne-frostberg.vercel.app`
  - `https://o83-care-fpks7s0ne-frostberg.vercel.app/reset-password`

No wildcard redirect was added. A synthetic invalid-password request reached hosted Auth and returned HTTP 400 without creating a user.

The Data API exposes its two platform defaults plus only the controlled `api` schema. Automatic exposure/granting for future tables is disabled. The migration separately grants the reviewed API views/functions to `authenticated` and revokes the three RPCs from `public` and `anon`.

### Supabase advisor and logs

The Security Advisor reported zero errors and three warnings. All three warnings identify the intentionally callable `SECURITY DEFINER` functions `api.resolve_current_access`, `api.create_case`, and `api.create_investigation`. They remain warnings, not ignored defects: each has an empty fixed `search_path`; anonymous/public execution is revoked; authenticated execution is explicit; identity comes from `auth.uid()` through database-owned account records; and Case/Investigation commands enforce tenant membership and role/channel authority before mutation.

Unified logs showed the expected 400/401/406 validation probes and the denied Storage/RPC calls. No application-generated HTTP 5xx path was identified. A transient PostgreSQL `08006` entry occurred while the Data API configuration reloaded; subsequent API probes, database lint, pgTAP tests, and live application checks passed.

## Vercel result

### Project and environment

The linked project uses:

- framework: Vite;
- install: `pnpm install --frozen-lockfile`;
- build: `pnpm --filter @o83/frontend build`;
- output: `frontend/dist`;
- SPA rewrite and security headers from `frontend/vercel.json`;
- Node `24.x` selected by Vercel from the repository's `>=22.12.0` engine range.

Exactly these browser-safe variable names are configured in Preview and Production:

- `VITE_APP_ENV`
- `VITE_APP_VERSION`
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`

No service-role key, Supabase secret key, database password, database URL, Vercel token, or Supabase access token is configured in a browser-exposed variable or committed file.

### Preview validation

The explicit Preview deployment is `READY` and protected by Vercel Authentication. Owner-browser and authenticated Vercel HTTP validation confirmed:

- HTTPS load and application boot;
- correct `staging` environment and exact approved commit on `/system-status`;
- `/workspace` redirects an application-anonymous visitor to `/sign-in`;
- SPA fallback works for direct routes;
- Supabase Auth is reachable;
- anonymous RPC and Storage write access remain denied;
- no runtime error logs;
- required HSTS, anti-framing, MIME, referrer, and browser-capability headers;
- no complete secret key, service-role string, legacy JWT, database connection string, or source-map reference in the deployed bundle.

The repository Playwright configuration always starts a local Vite server and does not accept an external base URL. Vercel Authentication also protects the Preview. Live external Playwright was therefore not forced through a new bypass secret; equivalent browser and authenticated Vercel checks were used, and the exact artifact was then exercised by desktop/mobile Playwright at the public Production alias.

### Production validation

The stable alias resolves to deliberate deployment `dpl_BXPtNazpHtkRrEkt2eHNpgDnnAws`, target `production`, state `READY`. Live validation proved:

- `https://o83-care.vercel.app` returns HTTPS 200 and boots O83 Care;
- `/system-status` identifies environment `production` and commit `4f318f07860dbe2399d5d3f9474facef15074436`;
- direct SPA routes return the built application;
- `/workspace` redirects an application-anonymous browser to `/sign-in`;
- the sign-in and password-recovery UI is present;
- hosted Auth connectivity and anonymous denial probes pass;
- all five private Storage buckets/policies remain effective;
- desktop 1440×900 and mobile 390×844 Playwright checks pass;
- both Playwright profiles report zero console errors, page errors, and failed requests;
- no Vercel runtime error logs were found;
- no source map or complete secret-shaped token is deployed.

Verified response headers:

- `Strict-Transport-Security: max-age=63072000; includeSubDomains; preload`
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy: camera=(), geolocation=(), microphone=(), payment=(), usb=()`

The production bundle contains exactly one browser-safe `sb_publishable_` token, as required by the Supabase browser client, and zero complete `sb_secret_` tokens, legacy JWTs, service-role strings, or PostgreSQL connection strings.

## Failures encountered and resolved

| Event | Classification | Resolution |
| --- | --- | --- |
| Bundled `pnpm` initially could not locate bundled Node | Local execution-path issue | Added the bundled Node directory to the process PATH and reran unchanged checks |
| First Vercel deployment without `--prod` was assigned to Production because it was the new project's first deployment | Deployment sequencing warning | Did not accept it as the Production gate; created and validated an explicit `--target preview`, then deliberately replaced the stable alias using `--prod` after rollback tagging |
| Vercel `curl` forwarded global scope flags to underlying curl | CLI beta-command issue | Used the already linked project context; protected Preview header checks passed |
| First live Playwright assertion compared `Production` case-sensitively | Test assertion defect | Made the assertion case-insensitive and reran; desktop/mobile passed |
| Chrome extension UI interrupted a synthetic form submission | Browser tooling limitation | Verified the same Auth endpoint with a sanitized direct request; no account was created |
| Supabase migration catalog cache could not read a temporary pg-delta certificate after push | Non-blocking CLI cache warning | Verified remote migration ledger, catalog, lint, RLS, Storage, and both hosted test suites directly |

No application, architecture, RLS, Auth, audit, Evidence, Storage, role, or property control was weakened to resolve these events.

## Rollback and recovery position

The immutable Git rollback tag `o83-care-rollback-20260718-103122-ict` points to the exact deployed commit and is present on GitHub. Vercel retains the deployment history and the inspected deployment IDs above. If the static frontend must be withdrawn, use Vercel's prior-deployment promotion/rollback controls while preserving this report.

The hosted database baseline was applied to an empty project and contains no operational data. Do not reset, drop, or reverse migration history. Any future database correction must be an authorized forward migration with evidence and recovery planning.

## Repository and generated-file hygiene

The source tree was clean and matched the approved commit at every Preview/Production deployment. Vercel's generated root `.env.local` OIDC file was removed immediately, and its temporary `.gitignore` additions were restored before deployment. `.vercel/`, Supabase temporary state, dependency trees, builds, test output, local environments, and backups remain ignored and untracked. No hosted credential value is recorded in this report.

## Files created or modified by final documentation

- `review/18_HOSTED_DEPLOYMENT_20260718.md` — created as this evidence record.
- `review/14_GO_NO_GO.md` — reconciled to distinguish verified hosted deployment from operational production authorization.

The documentation checkpoint is intentionally not the deployed application commit; the deployed code remains the independently verified commit `4f318f07860dbe2399d5d3f9474facef15074436`.

## Remaining warnings and limits

- The application is still a reviewed engineering foundation, not a complete condominium operations system.
- No production tenant, real user, invited identity, SMTP sender, or positive role/property fixture exists. No fabricated production data was introduced merely to claim a successful workflow.
- Real-identity positive/negative tests for resident, technician, manager, committee, vendor, administrator, disabled account, expired role/Mandate, and cross-property access remain required before operational use.
- Incident association, Operations/tasks, Responsibility transfer, Evidence workflow, completion/verification, recurrence, notifications, administration, governance, reporting, continuity, and AI stewardship remain incomplete or unproven end to end.
- Production policy approvals, privacy/retention decisions, emergency authority, SLA rules, evidence standards, dispute handling, RPO/RTO, restore exercises, accessibility, performance, penetration testing, support/on-call, training, pilot, and residual-risk acceptance remain outstanding.
- Supabase Security Advisor retains three justified `SECURITY DEFINER` warnings. Re-evaluate them whenever an API function or its grants change.
- The Vercel Node engine range can advance to future majors automatically; pin and qualify an approved major before operational release.
- The pre-existing main bundle remains large and lacks a production Content Security Policy. Route splitting, a performance budget, and an approved CSP are pre-operational requirements.
- Pull Request #1 must pass normal review/checks before any merge. No branch protection was bypassed and no merge was performed.

## Next maintainer instructions

1. Treat `4f318f07860dbe2399d5d3f9474facef15074436` as the deployed application source and this report's follow-up commit as documentation only.
2. Review Pull Request #1 and its CI checks normally; do not force merge or rewrite history.
3. Do not create operational users or tenant data until the Juristic Person has approved the required production policies and the next implementation/release gate supplies governed fixtures.
4. Preserve the exact Supabase Auth redirects, controlled `api` exposure, disabled automatic Data API table exposure, forced RLS, private buckets, and five Storage policies.
5. For database changes, use non-destructive forward migrations and rerun hosted lint plus both Database/RLS suites.
6. For frontend changes, deploy a protected Preview, repeat live denial/secret/header/browser checks, create a new rollback point, and then promote deliberately.

## Final decisions

| Scope | Decision | Meaning |
| --- | --- | --- |
| Local development | **GO** | Existing verified local engineering gate remains valid |
| Hosted technical deployment | **GO / VERIFIED** | GitHub, Supabase, Preview, Production alias, and technical security boundaries are deployed and evidenced |
| Operational Production use | **NO GO** | Product completeness, real-identity proof, continuity, governance, and accountable human release approval remain incomplete |

## One exact next action

Review Pull Request [#1](https://github.com/natt4witsfz/juristic-care-webapp/pull/1) after its CI checks complete, while keeping the deployed site out of operational use until `review/14_GO_NO_GO.md` records an authorized Production **GO**.
