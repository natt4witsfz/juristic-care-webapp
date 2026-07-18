# Production Risks

**Assessment date:** 2026-07-18

**Technical evidence cut-off:** clean local reset and full release-candidate gate on 2026-07-18

**Assessment rule:** a technical control is closed only by executable evidence. A policy-dependent residual risk remains open until an accountable human authority records approval.

## Risk status

| ID | Inherent impact | Risk | Verified technical treatment | Current status | Remaining release condition |
| --- | --- | --- | --- | --- | --- |
| PR-01 | Critical | Migration, RLS, or identity-boundary failure permits outage or cross-tenant exposure | Clean reset from zero; database lint; 58 database, RLS, adversarial-identity, and lifecycle assertions; forced RLS across all 136 authoritative tables; anonymous, cross-tenant, disabled-account, expired-role, expired-Mandate, resident, technician, manager, administrator, and service boundaries exercised | **Technical control closed** | Accountable security owner accepts residual risk and approves the production identity/test-data plan |
| PR-02 | Critical | Missing operational commands force side channels or direct-table work | Investigation association, Incident verification/association, Operation/task execution, Commitment, Responsibility transfer, Evidence, completion, verification, close, reopen, recurrence/follow-up support, notifications, administration, reporting, Timeline, and Organizational Memory transfer implemented through validated commands and RLS-backed projections; Audit and Timeline assertions passed | **Technical control closed** | Operations owner accepts workflows, terminology, forms, SLA behavior, and operating procedures |
| PR-03 | Critical | Evidence loss, tampering, or unauthorized access breaks safety and audit proof | Private intent-bound intake; service-only quarantine/promotion; byte-size, magic-signature, malware-test-signature, and SHA-256 checks; browser denial for trusted objects; private recovery exercise with digest equality; database plus five-bucket restore exercise | **Technical control closed** | Evidence, privacy, retention, custody, disclosure, and backup authorities approve policy and operating cadence |
| PR-04 | High | Role termination leaves stale access | Disabled-account and expired-role adversarial tests pass; role administration is command-bound and audited | **Technical control closed; policy pending** | Approve session/MFA, token refresh, access-review, emergency revocation, and recertification policy |
| PR-05 | High | Responsibility transfer creates an unaccountable gap | Atomic transfer command closes the current ledger interval and opens the successor; authority and exact Timeline evidence are preserved | **Technical control closed; policy pending** | Approve transfer acceptance, escalation, after-hours succession, and unresolved-transfer ownership |
| PR-06 | High | Incorrect Incident association hides independent Cases | Association requires human authority and a recorded Decision; every Case remains independent; association and Incident history remain traceable | **Technical control closed; policy pending** | Approve review, dispute, correction, unlink/revision, and committee escalation rules |
| PR-07 | High | Emergency workflow delays safety or loses the post-event record | Offline envelopes preserve observed/recorded time, digest, idempotency, and explicit conflicts; emergency work remains possible before recording; continuity runbook exists | **Technical control closed; policy pending** | Approve emergency Authority, manual channels, retrospective deadline, break-glass review, and drills |
| PR-08 | High | Privacy or retention rules conflict with immutable history | Restriction, archive, and immutable-history boundaries are separated; approval pack identifies required lawful decisions | **Design control closed; legal approval pending** | Qualified privacy/legal authorities approve lawful basis, notices, rights, restriction/anonymization, legal hold, and disposition |
| PR-09 | High | Service-role or administrative escalation bypasses tenant policy | Trusted functions authenticate the user, enforce exact origin, keep service credentials server-side, use narrow grants and empty search paths, and preserve Audit; source and environment secret scans pass | **Technical control closed; policy pending** | Approve privileged-access, secret custody/rotation, monitoring, break-glass, and vendor access policy |
| PR-10 | Medium | Large client payload degrades mobile or low-end access | All workspace routes are lazy-loaded; the automated budget measured 17 route-split scripts and 193,250 total gzip bytes; 100-request local production-preview load test completed with zero failures and 69.7 ms p95 | **Technical control closed; target approval pending** | Product owner approves supported devices/networks and production service-level/performance targets |
| PR-11 | Medium | Connectivity failure interrupts technicians | IndexedDB-backed offline envelope queue, retry, idempotency, server digest, optimistic-conflict handling, manual continuity procedure, and error-visible UI implemented and tested | **Technical control closed; policy pending** | Approve offline data-handling, device loss, maximum outage, reconciliation, and drill procedures |
| PR-12 | High | AI output is mistaken for a Decision | AI remains advisory, cannot mutate authoritative domain state, and is separated from human Decisions and their evidence | **Architecture control closed; policy pending** | Approve AI use cases, prohibited data, provider/residency, evaluation, model-change review, incident response, kill switch, and manual fallback |
| PR-13 | High | Hosted Auth, email, redirect, or MFA configuration causes takeover or lockout | Application/Auth boundary and redirect constraints are implemented; hosted baseline was previously verified | **Configuration and approval pending** | Approve and configure SMTP/sender, invitation/recovery, abuse limits, MFA/session policy, support ownership, and live real-identity acceptance |
| PR-14 | High | A backup exists but database and private Storage cannot be restored coherently | Isolated database restore verified 136 tables and five private buckets; private Storage loss/recovery reproduced the original SHA-256 digest; runbook and automated validation exist | **Technical control closed; policy pending** | Approve RPO/RTO, backup frequency, key custody, archive custody, exercise cadence, evidence retention, and restore authority |

## Technical blocker conclusion

PR-01 through PR-03, the former Critical Production blockers, now have repeatable technical evidence. No known software, database, RLS, Storage, build, test, accessibility, performance-budget, load-harness, backup-restore, or Organizational Memory transfer defect remains classified as a Production blocker in this release candidate.

The remaining gates are accountable human Decisions: policy approval, operational acceptance, hosted configuration under those approved policies, residual-risk acceptance, and authorization of the change window. They must not be inferred from passing tests.

## Non-blocking warnings

- Supabase's optional local `imgproxy` and pooler services are stopped; tested O83 workflows do not depend on them.
- The local Supabase Vector log-forwarder cannot read Docker logs because insecure Docker TCP exposure is disabled. Database, Auth, REST, Realtime, Storage, Studio, Analytics, and Edge runtime services remain available; Docker security was not weakened.
- Vite reports a 593.83 kB raw main chunk. The governed gzip budget passes, route-level splitting is present, and the production-preview load test passes. Further library-level splitting is an optimization, not a release blocker under the current provisional budget.
- The load harness proves a reproducible local baseline, not an unapproved business capacity target. Production traffic shape and service-level targets require owner approval.
- External penetration testing and production-scale resilience exercises require an authorized scope and test environment. The approval pack makes that governance gate explicit.
- This technical candidate has not been deployed by this workstream. Deployment was explicitly out of scope and remains a controlled action after approval.

## Required risk Decisions

The accountable authorities must approve, version, and retain the policy pack in `docs/policies/PRODUCTION_POLICY_APPROVAL_PACK.md`. Each approval must identify the Juristic Person, scope, authority, effective date, evidence reviewed, exceptions, review date, and acceptance or treatment of residual risk.
