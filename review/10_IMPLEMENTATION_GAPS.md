# Implementation Gaps

## Vertical-slice status

| Slice | Current implementation | Gap before production |
|---|---|---|
| Property/building/room/resident/occupancy | Relational model and policies | Controlled commands, forms, validation, RLS fixtures, history UI |
| Staff/technician/organization | Model, access resolution, organization-chart projection | Provisioning, effective-date commands, transfer/disable tests |
| Case intake | Controlled `api.create_case`, browser form, query invalidation | Runtime DB/RLS and resident/staff integration proof |
| Case list/details | RLS-backed current list | Details, communications, corrections, attachments, pagination |
| Investigation | Controlled creation from a Case | Findings, evidence, disagreement, conclusions, multi-Case association |
| Incident association | Model only | Verification decision command and Case-link workflow |
| Operation creation | Model/read projection | Authorized creation command and Incident linkage UI |
| Task assignment/acceptance | Model only | Separate assignment, offer, acceptance, refusal, pool, expiry |
| Responsibility ledger | Immutable model and view | Commands, no-gap transfer enforcement, timeline UI |
| Status transitions | Model/history design | Per-transition commands, preconditions, reason/evidence tests |
| Evidence upload/viewing | Storage/database design | Quarantine, registration, digest, custody, signed view, recovery |
| Before/after evidence | Model/policy | Completion rules and emergency exception command |
| Completion submission | Model only | Submission command, evidence package, separation rules |
| Juristic verification | Model only | Qualified verifier command, remote verification constraints |
| Reopen/recurrence | Immutable tables | New-Case-first workflow, investigation decision, loop controls |
| Follow-up scheduling | Model only | Configurable rule evaluation and responsible notification |
| Timeline/audit display | Immutable event/audit model | Unified permission-filtered UI and export |
| Announcements | Table, RLS, active read view, Home display | Create/publish/acknowledge/expire commands |
| Compliance deadlines | Table, RLS, open read view, Home display | Create/assign/complete/escalate commands |
| Organization chart | Effective-role read view and Home display | Administration, vacancies, acting roles, history drill-down |
| Basic reporting | Home operational counts | Governed definitions, snapshots, exports, reconciliation |
| Permission administration | Data-driven read foundation | Audited server-side mutation and invitation boundary |

Authentication supports sign-in, local sign-out, persisted/refreshing Supabase sessions, recovery request, password update, access resolution, protected routes, and unauthorized handling. Hosted delivery, invitation administration, and end-to-end identity provisioning remain conditional.

The implementation must progress in the dependency-safe order in `planning/03_sprint_plan.md`. Missing commands must not be replaced with direct browser writes to authoritative tables.

