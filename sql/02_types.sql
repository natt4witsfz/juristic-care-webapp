-- O83 Care stable PostgreSQL enum types.
-- Business vocabularies that evolve are stored in taxonomy tables, not enums.

do $$ begin
  create type core.actor_kind as enum ('person', 'service_principal', 'system', 'external');
exception when duplicate_object then null; end $$;

do $$ begin
  create type core.record_lifecycle as enum ('draft', 'active', 'inactive', 'closed', 'cancelled', 'superseded', 'withdrawn', 'restricted', 'archived');
exception when duplicate_object then null; end $$;

do $$ begin
  create type core.relationship_lifecycle as enum ('proposed', 'effective', 'ended', 'revoked', 'superseded', 'contested');
exception when duplicate_object then null; end $$;

do $$ begin
  create type core.version_status as enum ('draft', 'in_review', 'published', 'executed', 'issued', 'deprecated', 'superseded', 'withdrawn');
exception when duplicate_object then null; end $$;

do $$ begin
  create type core.link_role as enum ('supports', 'challenges', 'neutral', 'considered', 'omitted', 'derived_from', 'applies_to', 'related');
exception when duplicate_object then null; end $$;

do $$ begin
  create type core.decision_relationship_kind as enum ('affirms', 'withdraws', 'supersedes', 'appeals', 'corrects', 'implements');
exception when duplicate_object then null; end $$;

do $$ begin
  create type core.audit_result as enum ('allowed', 'denied', 'succeeded', 'failed', 'partial');
exception when duplicate_object then null; end $$;

do $$ begin
  create type core.data_classification as enum ('public', 'internal', 'confidential', 'highly_restricted');
exception when duplicate_object then null; end $$;

comment on type core.actor_kind is 'Principal categories; only a person can own consequential human Decisions.';
comment on type core.record_lifecycle is 'Shared coarse lifecycle; domain state remains in governed state columns and transitions.';
comment on type core.relationship_lifecycle is 'Lifecycle of effective-dated relationship assertions.';
comment on type core.version_status is 'Publication lifecycle for immutable version rows.';
comment on type core.link_role is 'How a source or Evidence item relates to a claim or record.';
comment on type core.decision_relationship_kind is 'Typed, historical Decision Evolution edge.';
comment on type core.audit_result is 'Outcome of an audited action.';
comment on type core.data_classification is 'Minimum O83 information classification.';
