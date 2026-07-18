# Sprint 00 Risk Register

Version: 1.0  
Date: 2026-07-17  
Status: Accepted foundation risks recorded

| ID | Risk | Probability | Impact | Control | Status |
| --- | --- | --- | --- | --- | --- |
| S00-R01 | A developer lacks Node.js, pnpm, or Git on `PATH` | Medium | Medium | Pinned engines, setup guide, setup script, CI verification | Open operational prerequisite |
| S00-R02 | Playwright browser CDN is temporarily unavailable | Medium | Low | Local installed Chrome fallback; CI retry and pinned Chromium install | Mitigated |
| S00-R03 | Public environment values are confused with secrets | Medium | Critical | Explicit variable names, `.env.example` warning, startup validation, security guide, no value logging | Controlled; continuous review |
| S00-R04 | Placeholder sign-in is mistaken for authentication | Low | High | Explicit copy and tests prove there is no form or auth behavior | Controlled |
| S00-R05 | Future features bypass route, error, or query foundations | Medium | Medium | Documented ownership boundaries, CI, review template, coding standard | Open governance risk |
| S00-R06 | Production CSP is omitted or made overly permissive | Medium | High | Baseline headers now; CSP requires approved deployment domains before production | Deferred production gate |
| S00-R07 | Database SQL is executed before its authorized sprint | Low | Critical | Sprint report and docs explicitly defer migrations; no migration created | Controlled |
| S00-R08 | Local Supabase cannot run without Docker | High on current host | Low for Sprint 00 | Docker documented as later database prerequisite | Accepted out of scope |
| S00-R09 | Browser smoke command leaves a child process open in some Windows automation hosts | Low | Low | Tests complete and servers release their ports; CI runs Linux; monitor local tooling behavior | Monitor |

No critical risk is uncontrolled. S00-R06 must close before production release, not before the next implementation sprint.
