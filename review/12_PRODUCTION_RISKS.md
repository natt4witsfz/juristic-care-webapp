# Production Risks

| ID | Likelihood | Impact | Risk | Treatment / release gate |
|---|---|---|---|---|
| PR-01 | High | Critical | Untested migration or RLS permits outage or cross-tenant exposure | Execute clean reset, database/RLS suites, adversarial identities, staging soak |
| PR-02 | High | Critical | Incomplete operational commands force side channels or direct-table work | Complete required vertical slices and acceptance tests |
| PR-03 | Medium | Critical | Evidence object loss or unauthorized access breaks safety/audit proof | Implement quarantine, digest, custody, private access, restore test |
| PR-04 | Medium | High | Role termination leaves stale sessions or access | Revoke/disable tests, token refresh policy, monitoring, access reviews |
| PR-05 | Medium | High | Responsibility gap during transfer leaves work unaccountable | Atomic transfer command and no-gap ledger invariant |
| PR-06 | Medium | High | Incorrect Incident association hides independent Cases | Human verification command, unlink/revision history, traceability tests |
| PR-07 | Medium | High | Emergency workflow delays safety or loses post-event record | Approved authority, offline procedure, retrospective deadline and audit |
| PR-08 | Medium | High | Privacy/retention conflicts with immutable history | Legal/privacy assessment and designed restriction/anonymization process |
| PR-09 | Medium | High | Service-role or admin escalation bypasses tenant policy | Server-only secrets, narrow functions, monitoring, break-glass review |
| PR-10 | Medium | Medium | 614.55 kB minified main bundle degrades low-end/mobile access | Route-level code splitting and performance budget |
| PR-11 | Medium | Medium | Offline/connectivity failure interrupts technicians | Offline evidence/action queue with conflict and time semantics |
| PR-12 | Low | High | AI output is mistaken for a decision | Immutable labels/sources/limitations, human review, no domain mutation policy |
| PR-13 | Medium | High | Hosted Auth/email/redirect configuration causes account takeover or lockout | Staging tests for invite, recovery, redirect allow-list, MFA decision |
| PR-14 | Medium | High | Backup exists but cannot restore database plus Storage coherently | Quarterly isolated restore and object reconciliation exercise |

Critical risks PR-01 through PR-03 block production. Risk acceptance must name the accountable authority and cannot be inferred from a development build.

