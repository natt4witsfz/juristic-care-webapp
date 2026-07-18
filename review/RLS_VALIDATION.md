# O83 Care RLS Validation

Version: 1.0  
Status: Design and Static SQL Passed; Runtime Matrix Required

## Security boundary

All O83 authoritative tables are in private bounded-context schemas. RLS is enabled and forced on all 131 tables. Data API reachability and row authorization are separated: grants are paired with policies, and the `api` schema exposes only security-invoker views. Service credentials remain server-side.

## Role validation

| Role | Implemented access boundary | Negative boundary |
|---|---|---|
| Admin | Tenant-scoped all-table policy | No cross-tenant access; immutable triggers still apply |
| Committee | Governance/property/taxonomy/analytics/memory read plus authorized governance actions through reviewed paths | No automatic raw personal Evidence or operational mutation |
| Manager | Tenant operational read/write, subject to domain constraints and Mandates | No history deletion or cross-tenant transfer without records |
| Staff | Operational select; mutation only where explicit policies/commands permit | No governance/admin/audit blanket access |
| Technician | Operations, Work Steps, Commitments, and verification context through accepted Commitment | No global tenant work or priority/closure Authority |
| Resident | Own/represented Case surface via effective Case party relationship | No access to other Cases, internal Incident history, or priority/verification mutation |
| Vendor | Person access through accepted Commitment and effective organization relationship | No unrestricted vendor-wide tenant access |
| AI Service | Governed `ai` schema records through active service-principal identity | No general domain read, Decision, Evidence verification, or Authority |
| Service Role | Supabase server-side BYPASSRLS capability | Never client-exposed; every workflow use must be scoped/audited |

## Supabase-specific checks

- RLS uses `TO authenticated`, never deprecated `auth.role()`.
- Policies combine authentication with tenant/relationship/role checks.
- Update access uses policies with both existing-row and resulting-row predicates where direct updates are allowed.
- Authorization is database-owned; user-editable metadata is never trusted.
- Security-invoker views preserve underlying RLS behavior on PostgreSQL 15+.
- Privileged helpers fix `search_path`, revoke public execution, and validate current Auth identity/tenant.
- Storage buckets are private; upload and read policies are operation-specific.
- Evidence originals are not upserted; Storage path is never the sole authorization proof.
- Realtime receives no blanket publication grant in these scripts.

## Required runtime matrix

Test every role against own tenant, foreign tenant, active/expired relationship, active/revoked Mandate, open/closed/archived record, restricted Evidence, legal hold, stale JWT, disabled account, anonymous user, malformed Storage path, direct table access, security-invoker view, bulk mutation, and service-role workflow. Confirm denied operations do not silently succeed and approved updates satisfy both visibility and resulting-row checks.

## Result

RLS implementation is structurally complete and follows current Supabase guidance. Production approval requires execution of the negative matrix and production-scale policy query plans.
