# O83 Care Production Readiness Decision

**Decision date:** 2026-07-18

**Evidence cut-off:** clean local release-candidate validation completed on 2026-07-18

**Deployed baseline:** commit `4f318f07860dbe2399d5d3f9474facef15074436` remains the previously verified live baseline

**Current candidate:** branch `production-go-technical-20260718`; deployment was expressly out of scope

## Decision summary

| Scope | Decision | Verified basis |
| --- | --- | --- |
| Local development | **GO** | Frozen dependency graph, formatting, lint, strict type-check, 27 unit/component tests, production build, seven Playwright tests, accessibility checks, performance budget, load test, dependency audit, clean database reset, database lint, 58 Database/RLS/security assertions, Edge Function boot/authentication probes, database restore, and private Storage recovery passed |
| Technical release candidate | **GO** | All known Critical technical blockers PR-01 through PR-03 are closed; operational slices, tenant isolation, Audit, Timeline, Evidence custody, continuity, restore, and Organizational Memory controls have executable evidence |
| Hosted staging of this candidate | **NO GO — NOT REQUESTED** | The candidate has not been deployed or exercised with governed hosted identities; no credentials were invented and no hosted state was changed |
| Operational Production use | **NO GO — BUSINESS APPROVALS ONLY** | Technical blockers are zero, but the Juristic Person has not approved the policy pack, hosted configuration values, operational acceptance, residual risk, or the release/change Decision |

Passing technical gates does not authorize operational use. Operational Truth remains the organization's best current understanding based on verifiable evidence; only accountable human authorities may decide that the Juristic Person will rely on this release as its system of record.

## Resolved Production blockers

### Complete operational vertical slices

- Investigation associates Cases without merging or overwriting them.
- Human-authorized Incident verification and Case-to-Incident association preserve Decisions, evidence, Audit, and Timeline.
- Operations and Operational Tasks support creation, Commitment, execution, completion, verification, closure, reopen, recurrence, and follow-up without erasing prior state.
- Responsibility transfer is atomic and preserves the predecessor/successor ledger and exact Authority evidence.
- Evidence intake is intent-bound and private; quarantine and trusted promotion are service-only; actual bytes determine size, media signature, malware-test detection, and SHA-256 digest.
- Notification delivery derives recipients from current Responsibility and is tenant-isolated and acknowledgeable.
- Administration supports governed account state and role-assignment lifecycle changes with Audit.
- Governed reporting and Organizational Memory export/import preserve scope, version, manifest, per-projection digest, artifact digest, and human-controlled import acceptance.
- All operational workspaces use RLS-backed projections and validated commands; no workflow requires direct browser mutation of authoritative tables.

### Critical risks PR-01 through PR-03

- **PR-01 migration and authorization:** clean reset, lint, forced RLS, cross-tenant, anonymous, disabled-account, expired-role, expired-Mandate, resident, technician, manager, administrator, and service-boundary checks pass.
- **PR-02 incomplete workflows:** the operational UI/database/RLS/Audit/Timeline/traceability slices are implemented and acceptance-tested at the release-candidate level.
- **PR-03 Evidence custody:** quarantine, observed digest, private access, trusted-object browser denial, database/bucket restore, and byte-for-byte private Storage recovery pass.

### Continuity and engineering quality

- Offline envelopes preserve idempotency, occurred and recorded time, server digest, and explicit optimistic conflicts.
- The continuity runbook covers power, internet, device loss, emergency work, Evidence recovery, database restore, provider/developer exit, and drill evidence.
- All workspace routes are lazy-loaded.
- Component accessibility checks cover every new authenticated workspace; public-route Axe checks run in Playwright.
- The performance gate measures route splitting and gzip budgets; the load harness starts an isolated production preview and asserts failures and latency.
- Node and direct accessibility dependencies are pinned to qualified versions; CI reproduces database, restore, Storage recovery, application, browser, performance, and load gates.

## Commands executed and verified results

| Command | Result |
| --- | --- |
| `pnpm install --frozen-lockfile` | **PASS** — existing lockfile accepted without mutation |
| `pnpm format:check` | **PASS** |
| `pnpm lint` | **PASS** |
| `pnpm typecheck` | **PASS** — strict TypeScript checks |
| `pnpm test` | **PASS** — 2 backend and 25 frontend tests, 27 total |
| `pnpm build` | **PASS** — production build generated |
| `pnpm test:e2e` | **PASS** — seven Playwright tests, including five public-route Axe checks |
| Authenticated route component accessibility suite | **PASS** — all nine operational workspace routes exercised through the frontend suite |
| `pnpm performance:budget` | **PASS** — 17 route-split scripts, 193,250 total gzip bytes, 169,665 main gzip bytes |
| `pnpm load:test` | **PASS** — 100 requests at concurrency 20, zero failures, 69.7 ms p95 |
| `pnpm audit --audit-level high` | **PASS** — no vulnerabilities reported |
| Static SQL validation | **PASS** |
| Clean local Supabase reset from zero | **PASS** after one transient Docker initialization retry |
| Database lint | **PASS** — no schema errors |
| Database/RLS/adversarial/lifecycle pgTAP | **PASS** — 58 assertions |
| `pnpm restore:validate` | **PASS** — isolated restore verified 136 tables and five private buckets |
| `pnpm storage:recovery` | **PASS** — recovered private object matched original SHA-256 |
| Local Edge Function serve and unauthenticated probes | **PASS** — both functions booted and returned HTTP 401 without Authorization |
| Environment, source-control, generated-output, backup, temporary-file, and secret scans | **PASS** — only placeholder application environment template; generated/sensitive outputs ignored |

## Database, RLS, Storage, Audit, and traceability evidence

- All 136 authoritative tables are forced through RLS.
- Database reset applies the approved baseline plus the two forward-only Production GO migrations.
- Browser users cannot insert trusted Evidence originals, renditions, or artifacts.
- Intake insert/read policies require an unexpired user-bound upload intent and the authorized Evidence target relationship.
- Quarantine and promotion commands are service-only, retain observed facts, and preserve the server-computed digest.
- Cross-tenant command, projection, Evidence-target, resident-Case, worker-Commitment, administrator, and anonymous privilege boundaries are tested.
- Operational transitions require current relationships, Authority or accepted Commitment as applicable, valid state-machine transitions, a human Decision, and a durable Timeline event.
- Responsibility-routed notifications, old/new Audit values, reason for change, exact Mandate, prior/current state, and Memory manifest immutability are asserted.

## Files created or modified

The candidate changes are intentionally limited to implementation, tests, recovery operations, policy templates, CI, and these readiness records:

- `.github/workflows/ci.yml`
- root and frontend package manifests plus `pnpm-lock.yaml`
- frontend routing, navigation, domain gateway/hooks/types, command/projection components, operational workspace pages, offline queue, tests, and Vercel security headers
- `supabase/migrations/20260718050844_production_go_operational_commands.sql`
- `supabase/migrations/20260718053532_production_go_continuity_projections.sql`
- Supabase database/RLS/adversarial validation suites
- Edge Functions for Evidence processing and Organizational Memory transfer plus their shared HTTP security helper
- performance, load, restore, Storage recovery, and SQL validation scripts
- `docs/operations/CONTINUITY_AND_RECOVERY_RUNBOOK.md`
- `docs/policies/PRODUCTION_POLICY_APPROVAL_PACK.md`
- `review/12_PRODUCTION_RISKS.md` and `review/14_GO_NO_GO.md`

No architecture document, established RLS principle, authentication control, audit rule, Evidence rule, Storage rule, or historical record was weakened. Existing duplicate or legacy review artifacts were identified but not deleted because deletion was not authorized.

## Warnings

### Blocking warnings

There are **no known technical blocking warnings** in the local release candidate.

### Non-blocking technical warnings

- Supabase's optional local `imgproxy` and pooler containers are stopped and are not used by the validated workflows.
- The Supabase Vector log-forwarder restarts because Docker's insecure TCP log endpoint is disabled. Enabling that endpoint would weaken host security, so it remains disabled. The application does not depend on the log-forwarder; core database, Auth, REST, Realtime, Storage, Analytics, Studio, and Edge services remain available.
- Vite reports a 593.83 kB raw main chunk. The approved provisional gzip budget, route-splitting gate, and load test pass.
- A local 100-request load run is a technical baseline, not a substitute for a human-approved production traffic model.
- External penetration testing requires an authorized target, scope, data-handling agreement, and test window.
- The new candidate is not the currently deployed baseline. This is intentional: deployment was excluded and must follow the approved release/change process.

## Remaining business and policy approvals

Only accountable human Decisions remain:

1. **Operational release acceptance:** the Juristic Person's accountable business owner approves the supported scope, operating model, known limitations, training, pilot, hypercare, support, and go-live change window.
2. **Privacy and legal:** lawful basis, notices, processors, data-subject rights, breach response, cross-border handling, retention, legal hold, restriction, anonymization/erasure, Evidence/CCTV, archive, cache, and backup disposition.
3. **Safety and Authority:** emergency Authority, after-hours succession, responder handoff, break-glass, retrospective recording deadlines, committee powers, Mandates, quorum, voting, conflicts, and delegation.
4. **Operations:** Responsibility acceptance/transfer, resident refusal/access/dispute, vendor disappearance/substitution, verification standards, recurrence/follow-up, SLA calendars/pauses/escalations, Priority, notification channels, quiet hours, language, and acknowledgement.
5. **Evidence and records:** capture standards, permitted unavailability, calibration, custody, disclosure, access, archive custody, restriction, and retention.
6. **Recovery and continuity:** RPO/RTO, backup frequency, restore authority, key custody, Storage recovery, exercise cadence, manual/offline procedures, provider exit, developer exit, and Organizational Memory stewardship.
7. **Security and identity:** invitation/recovery, SMTP/sender, rate and abuse response, session/MFA, privileged-access recertification, secret rotation, monitoring/on-call, incident response, penetration-test scope, and residual-risk acceptance.
8. **AI:** approved use cases, prohibited data, provider/residency, evaluation, human adoption, model-change review, incident response, kill switch, and manual fallback.
9. **Experience and capacity:** supported devices/browsers/networks/languages, accessibility acceptance, production traffic model, performance targets, resilience scope, and service-level objectives.

The ready-for-signature templates are in `docs/policies/PRODUCTION_POLICY_APPROVAL_PACK.md`. No approval is implied by this report.

## Hosted configuration and credentials still required after approval

The approved operator must supply these values directly in the relevant hosted control plane; none belongs in chat, source control, or browser environment files:

- approved SMTP provider credentials, verified sender/domain, invitation and recovery templates, and rate/abuse thresholds;
- approved MFA/session settings and governed initial user/role/tenant provisioning data;
- Edge Function `SUPABASE_URL`, server-only `SUPABASE_SERVICE_ROLE_KEY`, and exact approved `ALLOWED_ORIGIN` in the hosted function environment;
- backup/archive destination, encryption and key-custody configuration, retention schedule, monitoring destinations, and on-call routing;
- approved production traffic and alert thresholds;
- release authority, change-window authorization, rollback authority, and accountable acceptance record.

Browser-delivered application templates contain placeholders only and must never receive service-role, database, SMTP, backup, or vendor secrets.

## Production readiness score

- **Technical readiness:** 100% of known technical blockers closed.
- **Overall Production readiness:** **92%**. The remaining eight percentage points represent human governance, policy approval, approved hosted configuration, operational acceptance, and release authorization—not missing implementation.

## Go-live decision and estimate

**Operational Production decision: NO GO until approvals are recorded.** Once the nine approval groups above are signed and the approved hosted configuration is verified, the candidate is technically eligible for the next authorized change window.

**Earliest estimated go-live:** **2026-07-20**, conditional on approvals and hosted acceptance being completed before that change window. This is not a committed date; if approval is later, go-live moves to the next approved window.

## One exact next action

The Juristic Person's accountable release authority must review and sign `docs/policies/PRODUCTION_POLICY_APPROVAL_PACK.md`, recording approval or rejection for every policy group and naming the authorized hosted acceptance/change window.
