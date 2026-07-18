# O83 Care Readiness Decisions

**Decision date:** 2026-07-18  
**Evidence cut-off:** Hosted deployment evidence in `review/18_HOSTED_DEPLOYMENT_20260718.md`

## Decisions

| Scope | Decision | Verified basis |
| --- | --- | --- |
| Local development | **GO** | Frozen installation, formatting, lint, strict type-check, 14 unit/component tests, 22 Database/RLS tests, production build, local Playwright, database lint, static SQL validation, audit, and secret scans passed. |
| Hosted technical deployment | **GO / VERIFIED** | Approved Git commit published; hosted migration/lint/22 pgTAP assertions passed; 135/135 tables have forced RLS; five private buckets and five Storage policies passed; Auth/Data API redirects and exposure are hardened; Vercel Preview and Production live checks passed. |
| Operational Production use | **NO GO** | The deployed application remains an incomplete engineering foundation without governed production tenant/users, complete operational vertical slices, real-identity authorization proof, continuity exercises, policy approvals, or accountable human release acceptance. |

## Important distinction

`https://o83-care.vercel.app` is a technically verified Vercel Production deployment of commit `4f318f07860dbe2399d5d3f9474facef15074436`. That fact does not authorize the system to become the Juristic Person's operational system of record. Deployment verification and operational production acceptance are separate decisions.

The current site may be used for controlled technical demonstration and further engineering. It must not be relied upon as the sole channel for emergencies, resident reporting, work authorization, evidence custody, committee decisions, notifications, or organizational memory.

## Verified hosted evidence

- GitHub branch `recovery-o83-verified-tree-20260718` matches the approved deployed commit and is open as Pull Request #1 into `feature/routine-daily-task`; it has not been merged.
- Rollback tag `o83-care-rollback-20260718-103122-ict` is published and points to the deployed commit.
- Supabase project `uqzfptxbtzufijjxfbut` in `ap-southeast-1` was empty before the non-destructive baseline migration.
- Migration `20260717153210` is recorded remotely; database lint reports no schema errors.
- All 135 authoritative tables have enabled and forced RLS; 405 application policies exist.
- The two hosted pgTAP files completed 7 Database and 15 RLS assertions.
- All five Storage buckets are private; five narrow O83 object policies exist; no O83 browser update/delete/all-object policy exists.
- Anonymous RPC and Storage upload probes are denied, and no synthetic object was created.
- Data API exposure is limited to its two platform defaults plus the controlled `api` schema; automatic future-table exposure is disabled.
- Auth uses the stable Production Site URL and four exact Production/Preview origin and reset-password redirects; no wildcard was added.
- No Edge Functions exist in the repository, so no function deployment or secret is required.
- Vercel Production deployment `dpl_BXPtNazpHtkRrEkt2eHNpgDnnAws` is `READY` at `https://o83-care.vercel.app`.
- Live desktop and mobile Playwright checks passed with zero console errors, page errors, or failed requests.
- The live site reports `production` and the exact deployed commit, redirects anonymous protected-route access to sign-in, applies the reviewed headers, and exposes no complete secret-shaped token or database connection string.
- Vercel reported no runtime error logs. Supabase logs showed the expected validation denials and no application-generated HTTP 5xx path.
- Supabase Security Advisor reports zero errors. Its three warnings are the reviewed authenticated-only `SECURITY DEFINER` API boundaries with fixed empty search paths and tenant/role checks.

## Remaining Production blockers

1. No governed production Juristic Person, tenant configuration, invited identity, resident, staff member, technician, vendor, committee member, or AI service identity has been provisioned.
2. Real-JWT positive and negative authorization tests remain incomplete for role, tenant/property, disabled account, expired assignment/Mandate, resident relationship, worker Commitment, committee, vendor, administrator, and AI boundaries.
3. Incident association, Operations/tasks, Responsibility transfer, Evidence upload/custody/verification, recurrence/reopen, notifications, administration, governance, reporting, and Organizational Memory workflows are not complete and accepted end to end.
4. Auth invitation/recovery email delivery, approved SMTP/sender configuration, rate/abuse operations, MFA/privileged access, and support procedures are not production-proven.
5. Production-shaped load, accessibility, penetration, resilience, offline/manual continuity, backup restore, Storage recovery, archive custody, and Organizational Memory export/import have not passed.
6. Critical and High program risks lack complete control evidence and authorized residual-risk Decisions.
7. A production Content Security Policy, approved observability/on-call routing, performance budget, pinned/qualified Node major, support model, training, pilot, and hypercare plan remain outstanding.
8. The Juristic Person has not recorded accountable business, security, privacy, operations, data, and technical acceptance of an operational release.

## Required policy approvals

The Juristic Person and qualified legal, privacy, safety, and operational authorities must approve and version:

- privacy, lawful basis, notices, processors, data-subject rights, breach response, and cross-border handling;
- retention, legal hold, restriction, anonymization/erasure, Evidence/CCTV, audit, archive, cache, and backup disposition;
- emergency Authority, after-hours succession, responder handoff, break-glass use, and retrospective recording;
- committee powers, Mandates, quorum, voting, conflicts, delegation, and acknowledgement/approval boundaries;
- SLA calendars/pauses/escalations and their independence from Priority, Commitment, and sequence;
- Evidence, verification, calibration, custody, disclosure, and permitted-unavailability standards;
- resident refusal, lawful access, dispute, appeal, and communication rules;
- vendor disappearance/substitution, access revocation, custody transfer, liability, and residual Responsibility;
- notification channels, emergency overrides, quiet hours, language, disclosure, delivery, and acknowledgement rules;
- RPO/RTO, backups, restore frequency, Storage recovery, archive custody, Organizational Memory export, and provider/developer exit;
- AI use cases, prohibited data, provider/residency, evaluation, human adoption, model-change review, incident response, kill switch, and manual fallback;
- production session/MFA, privileged access recertification, CSP domains, monitoring/on-call, security response, accessibility, performance, training, pilot, and residual-risk acceptance.

## Non-blocking technical warnings

- Supabase CLI could not cache a temporary pg-delta catalog after the successful migration because a generated certificate file was unavailable; remote ledger/catalog/lint/test verification passed.
- Supabase Security Advisor retains three justified API-function warnings that require re-review whenever function bodies or grants change.
- Vercel selected Node `24.x` from an open-ended engine range and warned that future majors may be selected automatically.
- The existing main bundle remains large, and the baseline headers do not yet include a production CSP.
- The protected Preview required owner authentication; authenticated Vercel HTTP/browser checks were used, followed by public Production desktop/mobile Playwright against the same approved source.
- The first Vercel deployment was auto-assigned to the new project's Production alias; it used the same clean approved commit. The workflow then created/validated an explicit Preview, published the rollback tag, and deliberately replaced the alias with the verified Production deployment.

## Conditions for an operational Production GO

- Complete and accept the dependency-ordered operational vertical slices without weakening history, audit, RLS, Evidence, Storage, role, or property isolation.
- Provision governed non-production identities/fixtures and pass the full real-identity RLS, Storage, Auth, service, role, tenant/property, and lifecycle matrix before any production identity is invited.
- Pass the 31 operational scenarios, production-shaped performance, accessibility, security, resilience, restore, manual continuity, Storage recovery, and Organizational Memory transfer exercises.
- Approve and configure the required legal, privacy, safety, governance, SLA, Evidence, notification, recovery, AI, security, support, and stewardship policies.
- Close or formally treat every applicable Critical/High risk and record a human release Decision with named accountable authorities.

## Current hosted endpoints and rollback point

- Production: `https://o83-care.vercel.app`
- Verified Preview: `https://o83-care-fpks7s0ne-frostberg.vercel.app`
- Supabase project: `uqzfptxbtzufijjxfbut`
- Deployed commit: `4f318f07860dbe2399d5d3f9474facef15074436`
- Rollback tag: `o83-care-rollback-20260718-103122-ict`
- Pull Request: `https://github.com/natt4witsfz/juristic-care-webapp/pull/1`

## One exact next action

Review Pull Request #1 after CI completes, but keep the deployed site out of operational use until the blockers above are closed and an accountable human Production **GO** is recorded.
