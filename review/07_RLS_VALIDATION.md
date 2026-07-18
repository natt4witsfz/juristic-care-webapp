# RLS Validation

## Static result

`scripts/validate-sql.ps1` passed on 2026-07-17. It verified the 16 canonical SQL files, a timestamped migration, forced-RLS declaration, resident Case policy, narrowed AI policy, and absence of browser service-role references.

## Policy coverage reviewed

- Admin: tenant-scoped policy, still subject to immutable-history triggers.
- Committee: governance/property/taxonomy/analytics/memory read scope and explicit organization-chart visibility.
- Juristic manager: broad tenant operational access; business Authority remains a Mandate/command concern.
- Juristic staff: operational read scope plus controlled commands/grants.
- Technician/vendor: Operation visibility through accepted Commitment or explicit technical role scope.
- Resident: own Case relationship, related report/context/communication, and published announcements.
- AI service: approved AI use-case read and append-only interaction/recommendation/source access; no review, approval, verification, closure, or domain-table policy.
- Service role: no end-user RLS policy; Supabase bypass behavior requires server-only governance.

## Runtime validation result

On 2026-07-18, a clean local Supabase migration and reset completed successfully. `supabase/tests/database_validation.sql` and `supabase/tests/rls_validation.sql` then passed through `pnpm supabase test db --local supabase/tests`: 2 files and 22 pgTAP tests, all successful.

The fifteen RLS/security assertions prove that RLS is enabled and forced across all 135 authoritative tables, `anon` has no authoritative-table grants or policies, the five O83 Storage policies are present without update/delete/all-object access, resident and worker policies remain relationship-scoped, AI cannot mutate authoritative decisions or human reviews, and immutable audit/domain-event triggers exist.

## Behavioral matrix still required

Create two tenants and at least two residents, staff, manager, committee, technician, vendor, AI-service, and disabled-user identities. For each identity, assert allowed reads/writes and denial of cross-tenant, unrelated-resident, uncommitted-worker, expired-role, AI-review, immutable-update, and direct-table mutation paths. Include JWT refresh after role termination.

The catalog-level RLS suite is runtime proven. The multi-identity behavior matrix remains required before production because it needs representative Auth JWT fixtures and cross-tenant data; this is an additional acceptance layer, not a failure of the executed catalog suite.
