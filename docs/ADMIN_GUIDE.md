# Administrator Guide

Administrators maintain identity linkage, tenant roles, permission mappings, and platform configuration. Administration does not confer unlimited business Authority.

Before inviting a user, create or verify their person and effective organization relationship, then link the Auth account and assign only the required role. Test the resulting `api.resolve_current_access()` output. Invitations require a deployed server-side function; the browser intentionally contains no service-role secret.

When access changes, record who requested and authorized the change, its reason and effective time, then end the old assignment and create the new one. Disable departing users without deleting history. Review admin, manager, committee, AI-service, auditor, and service-principal access at a documented cadence.

For schema releases, follow the migration, backup, validation, and rollback guides. Never edit an applied migration, disable RLS for convenience, or delete embarrassing history. Investigate unexpected denials as missing or expired relationships before broadening a policy.
