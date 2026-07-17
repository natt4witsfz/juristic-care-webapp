-- O83 Care database extensions.
-- Idempotent and safe to run in a Supabase PostgreSQL project.

create extension if not exists pgcrypto with schema extensions;
create extension if not exists btree_gist with schema extensions;
create extension if not exists pg_trgm with schema extensions;

comment on extension pgcrypto is 'Cryptographic UUID and digest support for O83 Care.';
comment on extension btree_gist is 'Exclusion constraints for effective-dated O83 relationships.';
comment on extension pg_trgm is 'Authorized similarity and search support; never automatic Case merging.';
