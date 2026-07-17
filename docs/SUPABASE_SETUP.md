# Supabase Setup

## Purpose

This guide provisions the O83 Care PostgreSQL, Auth, Storage, and Data API boundaries. It does not create production users or fabricate a tenant.

## Prerequisites

- A Supabase project using PostgreSQL 17, matching `supabase/config.toml`.
- Supabase CLI 2.109.1 and the pinned workspace dependencies.
- A reviewed backup and a change window before applying migrations to a shared environment.

## Local database

From the project root run `pnpm db:start`, then `pnpm db:reset`. The reset applies the timestamped migration and safe seed entry point. Run `pnpm supabase test db` and `pnpm supabase db lint --local --level warning`. Docker or another supported container runtime is required.

The canonical SQL sources are in `sql/`; the deployment artifact is the timestamped file under `supabase/migrations/`. When canonical SQL changes, create a new forward migration. Never edit a migration already applied to a shared environment.

## Tenant provisioning

1. Insert the Juristic Person through a reviewed administrative migration or a controlled provisioning command.
2. In the same transaction set `app.bootstrap_juristic_person_id` to that tenant UUID.
3. Execute `sql/14_seed_reference_data.sql` to install tenant-scoped roles, permissions, and taxonomies.
4. Create a person, organization relationship, user account linked to `auth.users`, and an effective role assignment.
5. Verify `api.resolve_current_access()` as that user before inviting operational users.

The repository intentionally contains no fake production tenant, user, or credential.

## Auth

Configure the Site URL and redirect allow-list for `/reset-password` on every deployed origin. Keep email confirmation and rate limits enabled. Invitation administration must run server-side; never expose a service-role key to Vite.

## Data API and RLS

Only the `api` schema is exposed. Domain schemas remain behind security-invoker views and controlled functions. Every authoritative table has RLS enabled and forced. Validate policies with real tenant fixtures before launch; frontend navigation is not authorization.

## Storage

Create the buckets and policies defined by `sql/11_storage.sql`. Object paths must use the documented tenant and evidence identifiers. Upload completion is not proof of evidence verification; metadata, integrity digest, custody, and human review remain separate records.

## Production checks

- Apply migrations first to a restored staging copy.
- Run SQL, RLS, restore, and application smoke tests.
- Inspect migration and Postgres logs.
- Confirm PITR and retention settings.
- Record approver, change reason, migration digest, start/end time, and rollback decision.
