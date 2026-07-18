# O83 Care Definition of Done

Version: 1.0  
Status: Normative Delivery Gate

## Purpose

“Done” means a feature is safe, understandable, operable, testable, and accepted in its target environment. Merge, deployment, demonstration, or document completion alone is insufficient. Feature-specific criteria in [01_feature_catalog.md](01_feature_catalog.md) add to—not replace—this definition.

## Feature Definition of Done

A feature is done only when all applicable statements are true.

### Business and domain

- Business goal, scope, actors, responsibilities, Authority, workflow, exceptions, and non-goals are approved.
- Case, Investigation, Incident, Operation, Evidence, Decision, Knowledge, and Organizational Memory meanings conform to the glossary.
- Safety action is not blocked by administrative completeness.
- Responsibility, Authority, Commitment, Capability, Availability, Organizational Priority, Execution Sequence, and SLA are not collapsed.
- Corrections append, relate, or supersede; accepted history is not overwritten.

### Contracts and data

- Commands, queries, events, error semantics, idempotency, versioning, and compatibility are documented and contract-tested.
- Required tables, constraints, indexes, policies, Storage objects, projections, retention classes, and migrations are identified and implemented.
- Every material action preserves who, acting role, when, why, evidence basis, Authority where needed, previous state, current state, correlation, and source.
- Tenant ownership, cardinality, orphan prevention, concurrency, offline conflict, and as-of behavior are tested.
- Migration and backfill are restartable, observable, reconciled, and do not invent unknown history.

### Security, privacy, and AI

- Least-privilege grants and RLS/Storage policies pass positive and negative role/tenant/state/classification tests.
- Secrets, privileged credentials, logs, exports, renditions, support access, and provider boundaries are reviewed.
- Data minimization, consent/purpose, retention, legal hold, redaction, and disposition effects are documented.
- AI features prove mediated context, citations, uncertainty, human adoption, manual fallback, prohibition enforcement, evaluation, and disablement.

### Experience and accessibility

- Role journeys, empty/loading/offline/error/conflict/denied/expired states, destructive-looking confirmation, and recovery paths are implemented.
- Accessibility acceptance meets the program standard; safety instructions are plain, localized as configured, and usable at low bandwidth.
- UI labels distinguish observation, hypothesis, Assessment, Decision, recommendation, and current projection.
- Status changes explain what changed and how to challenge, rather than showing an opaque label alone.

### Quality and test evidence

- Unit/domain, database constraint, contract, integration, end-to-end, security, accessibility, performance, migration, resilience, and observability tests are complete as applicable.
- Tests include happy path, denied path, duplicate/retry, concurrency, delayed evidence, provider failure, stale Authority, human error, and recovery.
- Defects have triage and no open severity-one or unaccepted Critical control failure remains.
- Coverage is risk-based; critical invariants are proved directly rather than inferred from line coverage.

### Operations and stewardship

- Metrics, logs, traces, dashboards, alerts, SLOs, on-call ownership, runbook, support escalation, capacity expectation, backup/restore impact, and kill switch are ready.
- Data/API/event/schema/config versions and deployment evidence are recorded.
- Business owner, technical steward, security reviewer, test owner, and operational owner accept the feature.
- Knowledge transfer and exit/continuity implications are included in Organizational Memory.

## Sprint Definition of Done

A sprint is done when every scoped feature meets the Feature DoD; sprint objectives are demonstrated through deployed vertical journeys; predecessor contracts remain compatible; integration and regression suites pass; sprint risks are updated; runbooks and telemetry are exercised; and the sprint completion criteria in [03_sprint_plan.md](03_sprint_plan.md) are signed.

Incomplete work returns to the backlog with an explicit dependency. It is not counted done through a feature flag if its enabled path lacks required controls. A temporary test stub may exist during development but cannot satisfy release acceptance.

## Release Definition of Done

A release is done when the environment manifest is reproducible, migration and reconciliation pass, security/advisor findings are dispositioned, acceptance scenarios pass, operational and continuity procedures are exercised, training is complete for the release audience, risks have named owners and accepted residual Decisions, and the authorized release Decision is sealed with evidence.

## Production Definition of Done

Production is done only after the full RLS/Storage/service-role matrix, 31 operational scenarios, load and longevity plans, penetration and accessibility tests, Evidence integrity/restore, Organizational Memory export/import, provider failure, power/internet/manual continuity, and full backup restore pass. No unaccepted critical risk remains, and the Juristic Person—not the vendor or development team—accepts stewardship.
