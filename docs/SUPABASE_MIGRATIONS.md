# Supabase Migrations

## Purpose

`supabase/migrations/` is the canonical executable migration directory. It contains timestamped SQL migration files only. Generate a new file with `pnpm supabase migration new <descriptive_name>`; never invent a migration timestamp or edit a migration that has already been applied to a shared environment.

The approved SQL baseline must first be validated on a disposable local project and then captured as a reviewed migration according to `review/MIGRATION_PLAN.md`.

## Supabase-managed schemas

O83 migrations do not own Supabase-managed tables in schemas such as `auth` and `storage`. They must not add table or column comments, change ownership, or make structural alterations to those managed tables.

The O83 baseline intentionally performs only these managed-schema interactions:

- foreign keys from application-owned identity tables to `auth.users`;
- idempotent private bucket records in `storage.buckets`;
- narrowly scoped RLS policies on `storage.objects`.

The storage policies enforce O83 tenant, role, Case-party, and evidence relationships. They must not be weakened to work around ownership or privilege errors. Descriptions of managed objects belong in architecture or operational documentation, not PostgreSQL object comments.
