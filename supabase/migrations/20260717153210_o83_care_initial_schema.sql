
-- ============================================================================
-- Source: sql/00_extensions.sql
-- ============================================================================

-- O83 Care database extensions.
-- Idempotent and safe to run in a Supabase PostgreSQL project.

create extension if not exists pgcrypto with schema extensions;
create extension if not exists btree_gist with schema extensions;
create extension if not exists pg_trgm with schema extensions;

comment on extension pgcrypto is 'Cryptographic UUID and digest support for O83 Care.';
comment on extension btree_gist is 'Exclusion constraints for effective-dated O83 relationships.';
comment on extension pg_trgm is 'Authorized similarity and search support; never automatic Case merging.';


-- ============================================================================
-- Source: sql/01_schemas.sql
-- ============================================================================

-- O83 Care bounded-context schemas.

create schema if not exists core;
create schema if not exists iam;
create schema if not exists org;
create schema if not exists property;
create schema if not exists taxonomy;
create schema if not exists intake;
create schema if not exists investigation;
create schema if not exists incident;
create schema if not exists work;
create schema if not exists evidence;
create schema if not exists decision;
create schema if not exists knowledge;
create schema if not exists workflow;
create schema if not exists notification;
create schema if not exists governance;
create schema if not exists ai;
create schema if not exists audit;
create schema if not exists analytics;
create schema if not exists memory;
create schema if not exists integration;
create schema if not exists api;

comment on schema core is 'Shared O83 database types and internal helpers; not a business write model.';
comment on schema iam is 'Application identity and authorization-decision records.';
comment on schema org is 'Juristic Person, party, role, Authority, Responsibility, Capability, and Availability.';
comment on schema property is 'Property, Building, Room, Location, Asset, Component, and maintenance planning.';
comment on schema taxonomy is 'Governed, versioned vocabularies.';
comment on schema intake is 'Immutable Reports and separately traceable Cases.';
comment on schema investigation is 'Observations, Hypotheses, and versioned Understanding Assessments.';
comment on schema incident is 'Human-verified Incidents and Case associations.';
comment on schema work is 'Operations, Work Steps, Commitments, verification, priority, sequence, and SLA.';
comment on schema evidence is 'Evidence provenance, renditions, packages, custody, integrity, and disposition.';
comment on schema decision is 'Human Decisions, Recommendations, and Decision Evolution.';
comment on schema knowledge is 'Context-bound Knowledge and learning outcomes.';
comment on schema workflow is 'Versioned workflow orchestration and immutable transitions.';
comment on schema notification is 'Notification intent, rendering, delivery, and acknowledgement.';
comment on schema governance is 'Policies, committees, resolutions, Contracts, obligations, and risks.';
comment on schema ai is 'Governed AI interactions and advisory Recommendations.';
comment on schema audit is 'Immutable domain events, transactional outbox, and security audit.';
comment on schema analytics is 'Versioned KPIs and reproducible report snapshots.';
comment on schema memory is 'Organizational Memory manifests and archive custody.';
comment on schema integration is 'External identity, inbound messages, and synchronization conflicts.';
comment on schema api is 'Intentionally exposed security-invoker projections; contains no authoritative tables.';

-- Prevent accidental Data API exposure through broad public-schema defaults.
revoke all on schema public from anon, authenticated;
revoke all on schema core, iam, org, property, taxonomy, intake, investigation,
  incident, work, evidence, decision, knowledge, workflow, notification,
  governance, ai, audit, analytics, memory, integration from anon, authenticated;

grant usage on schema api to authenticated;


-- ============================================================================
-- Source: sql/02_types.sql
-- ============================================================================

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


-- ============================================================================
-- Source: sql/03_tables.sql
-- ============================================================================

-- O83 Care production tables.
-- Foreign keys, advanced constraints, and indexes are added in later scripts.

create table if not exists iam.user_accounts (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  auth_user_id uuid not null,
  person_id uuid not null,
  account_state text not null default 'active',
  linked_at timestamptz not null default now(),
  disabled_at timestamptz,
  session_revocation_required boolean not null default false
);
comment on table iam.user_accounts is 'Maps Supabase Auth accounts to durable O83 Person identities.';

create table if not exists iam.service_principals (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  principal_code text not null,
  auth_user_id uuid,
  display_name text not null,
  purpose text not null,
  owner_relationship_id uuid,
  credential_rotated_at timestamptz,
  expires_at timestamptz
);
comment on table iam.service_principals is 'Technical principal with scoped purpose and accountable owner.';

create table if not exists iam.access_decisions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  principal_kind core.actor_kind not null,
  principal_id uuid,
  action_code text not null,
  resource_type text not null,
  resource_id uuid,
  purpose_code text,
  policy_version_id uuid,
  mandate_id uuid,
  result core.audit_result not null,
  denial_reason text,
  session_id uuid,
  request_context jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now(),
  correlation_id uuid not null default gen_random_uuid()
);
comment on table iam.access_decisions is 'Immutable consequential authorization decision.';

create table if not exists org.juristic_persons (
  id uuid primary key default extensions.gen_random_uuid(),
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  legal_name text not null,
  registration_number text,
  country_code char(2) not null default 'TH',
  timezone text not null default 'Asia/Bangkok',
  default_locale text not null default 'th',
  successor_juristic_person_id uuid
);
comment on table org.juristic_persons is 'Enduring legal tenant and owner of Organizational Memory.';

create table if not exists org.people (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  person_code text not null,
  display_name text not null,
  legal_name text,
  preferred_name text,
  contact_data jsonb not null default '{}'::jsonb,
  identity_state text not null default 'active',
  merged_into_person_id uuid,
  classification core.data_classification not null default 'confidential'
);
comment on table org.people is 'Durable human identity independent of role or account.';

create table if not exists org.external_organizations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  organization_code text not null,
  legal_name text not null,
  organization_type_term_id uuid,
  registration_number text,
  contact_data jsonb not null default '{}'::jsonb,
  successor_organization_id uuid
);
comment on table org.external_organizations is 'External organization such as vendor, utility, insurer, regulator, or management company.';

create table if not exists org.organization_relationships (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  person_id uuid,
  external_organization_id uuid,
  relationship_type_term_id uuid not null,
  source_policy_version_id uuid,
  relationship_state core.relationship_lifecycle not null default 'proposed',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid,
  contact_preferences jsonb not null default '{}'::jsonb
);
comment on table org.organization_relationships is 'Effective relationship between a party and the Juristic Person.';

create table if not exists org.role_definitions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  role_code text not null,
  name text not null,
  description text,
  deprecated_at timestamptz
);
comment on table org.role_definitions is 'Stable role definition used by effective role assignments.';

create table if not exists org.role_assignments (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  organization_relationship_id uuid not null,
  role_definition_id uuid not null,
  assignment_source_type text,
  assignment_source_id uuid,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid
);
comment on table org.role_assignments is 'Effective role held through an organization relationship.';

create table if not exists org.permission_definitions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  permission_code text not null,
  name text not null,
  description text,
  resource_type text not null,
  action_code text not null,
  deprecated_at timestamptz
);
comment on table org.permission_definitions is 'Tenant-owned permission vocabulary; a permission does not itself grant business Authority.';

create table if not exists org.role_permissions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  role_definition_id uuid not null,
  permission_definition_id uuid not null,
  effect text not null default 'allow',
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid
);
comment on table org.role_permissions is 'Effective data-driven Role-to-Permission relationship with history.';

create table if not exists org.mandates (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  mandate_code text not null,
  grantee_relationship_id uuid not null,
  grantee_role_assignment_id uuid,
  grantor_type text not null,
  grantor_id uuid not null,
  parent_mandate_id uuid,
  authority_actions text[] not null default '{}',
  scope_type text not null,
  scope_id uuid,
  delegation_allowed boolean not null default false,
  revoked_at timestamptz,
  source_type text not null,
  source_id uuid not null
);
comment on table org.mandates is 'Scoped, effective-dated Authority grant.';

create table if not exists org.responsibility_definitions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  responsibility_code text not null,
  name text not null,
  outcome_definition text not null,
  scope_type text not null
);
comment on table org.responsibility_definitions is 'Governed responsibility type and accountable outcome.';

create table if not exists org.responsibility_assignments (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  assignment_code text not null,
  responsibility_definition_id uuid not null,
  responsible_relationship_id uuid not null,
  responsible_role_assignment_id uuid,
  scope_type text not null,
  scope_id uuid not null,
  supervising_assignment_id uuid,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid
);
comment on table org.responsibility_assignments is 'Effective accountable duty for a defined scope.';

create table if not exists org.responsibility_ledger_entries (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  responsibility_assignment_id uuid not null,
  entry_type text not null,
  subject_type text not null,
  subject_id uuid,
  commitment_id uuid,
  mandate_id uuid,
  decision_id uuid,
  evidence_package_id uuid,
  state_after text,
  handover_id uuid,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now(),
  correlation_id uuid not null default gen_random_uuid(),
  reason text
);
comment on table org.responsibility_ledger_entries is 'Immutable Responsibility Chain entry.';

create table if not exists org.handovers (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  handover_code text not null,
  from_relationship_id uuid,
  to_relationship_id uuid not null,
  scope_type text not null,
  scope_id uuid not null,
  offered_at timestamptz,
  accepted_at timestamptz,
  authority_decision_id uuid,
  summary text
);
comment on table org.handovers is 'Transfer of future stewardship and current context.';

create table if not exists org.handover_items (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  handover_id uuid not null,
  item_sequence integer not null,
  subject_type text not null,
  subject_id uuid not null,
  context_summary text,
  risk_summary text,
  acknowledgement_state text not null default 'pending',
  acknowledged_at timestamptz,
  acknowledged_by_person_id uuid
);
comment on table org.handover_items is 'Item-level handover acknowledgement.';

create table if not exists org.capability_assertions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  assertion_code text not null,
  subject_relationship_id uuid not null,
  capability_term_id uuid not null,
  level_term_id uuid,
  issuer_type text not null,
  issuer_id uuid,
  evidence_item_id uuid,
  verification_state text not null default 'proposed',
  revoked_at timestamptz,
  classification core.data_classification not null default 'confidential'
);
comment on table org.capability_assertions is 'Evidence-backed capability or qualification assertion.';

create table if not exists org.availability_periods (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  subject_relationship_id uuid,
  resource_type text not null,
  resource_id uuid not null,
  availability_state text not null,
  source_type text not null,
  source_id uuid,
  confidence numeric(5,4),
  timezone text not null,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid
);
comment on table org.availability_periods is 'Effective availability assertion for a person or resource.';

create table if not exists property.properties (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  property_code text not null,
  name text not null,
  legal_description text,
  timezone text not null default 'Asia/Bangkok'
);
comment on table property.properties is 'Managed property or estate under a Juristic Person.';

create table if not exists property.buildings (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  building_code text not null,
  property_id uuid not null,
  name text not null,
  address jsonb not null default '{}'::jsonb,
  commissioned_on date,
  retired_on date
);
comment on table property.buildings is 'Durable Building identity within a property.';

create table if not exists property.locations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  location_code text not null,
  property_id uuid not null,
  building_id uuid,
  parent_location_id uuid,
  location_type_term_id uuid not null,
  name text not null,
  floor_label text,
  geometry jsonb,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid
);
comment on table property.locations is 'Effective hierarchical place identity.';

create table if not exists property.location_aliases (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  location_id uuid not null,
  alias_type text not null,
  alias_value text not null,
  locale text,
  external_system_id uuid,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table property.location_aliases is 'Historical, localized, or external Location label.';

create table if not exists property.rooms (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  room_code text not null,
  building_id uuid not null,
  location_id uuid not null,
  room_type_term_id uuid,
  display_label text not null,
  renumbered_from_room_id uuid
);
comment on table property.rooms is 'Durable private or common Unit identity.';

create table if not exists property.occupancy_relationships (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  room_id uuid,
  location_id uuid,
  organization_relationship_id uuid not null,
  occupancy_type_term_id uuid not null,
  consent_scope jsonb not null default '{}'::jsonb,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid
);
comment on table property.occupancy_relationships is 'Effective party relationship to a Room or Location.';

create table if not exists property.asset_types (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  asset_type_code text not null,
  name text not null,
  component_allowed boolean not null default true,
  required_context_schema jsonb not null default '{}'::jsonb,
  deprecated_at timestamptz
);
comment on table property.asset_types is 'Governed Asset or Component type.';

create table if not exists property.assets (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  asset_code text not null,
  asset_type_id uuid not null,
  primary_location_id uuid not null,
  manufacturer text,
  model text,
  version text,
  serial_number text,
  commissioned_on date,
  retired_on date,
  predecessor_asset_id uuid
);
comment on table property.assets is 'Durable managed Asset identity and lifecycle.';

create table if not exists property.asset_components (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  component_code text not null,
  asset_id uuid not null,
  parent_component_id uuid,
  asset_type_id uuid not null,
  manufacturer text,
  model text,
  version text,
  serial_number text,
  installed_at timestamptz,
  removed_at timestamptz,
  predecessor_component_id uuid
);
comment on table property.asset_components is 'Replaceable or diagnosable Asset component.';

create table if not exists property.asset_relationships (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  from_asset_id uuid,
  from_component_id uuid,
  to_asset_id uuid,
  to_component_id uuid,
  relationship_type_term_id uuid not null,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid
);
comment on table property.asset_relationships is 'Typed effective Asset topology or replacement relationship.';

create table if not exists property.asset_identifiers (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  asset_id uuid,
  component_id uuid,
  identifier_type text not null,
  identifier_value text not null,
  issuer text not null,
  external_system_id uuid,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table property.asset_identifiers is 'External, legacy, vendor, or serial identifier for Asset or Component.';

create table if not exists property.maintenance_plans (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  plan_code text not null,
  name text not null,
  policy_version_id uuid,
  workflow_version_id uuid,
  operation_type_term_id uuid not null,
  schedule_definition jsonb not null,
  criteria_definition jsonb not null default '{}'::jsonb,
  effective_from timestamptz,
  effective_to timestamptz
);
comment on table property.maintenance_plans is 'Versioned proactive maintenance intent, schedule, and criteria.';

create table if not exists property.maintenance_plan_assets (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  maintenance_plan_id uuid not null,
  asset_id uuid,
  component_id uuid,
  applicability_context jsonb not null default '{}'::jsonb,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table property.maintenance_plan_assets is 'Effective Maintenance Plan applicability to Asset or Component.';

create table if not exists taxonomy.taxonomies (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  taxonomy_code text not null,
  name text not null,
  purpose text not null,
  owner_responsibility_id uuid,
  governance_mode text not null default 'controlled'
);
comment on table taxonomy.taxonomies is 'Governed vocabulary identity and ownership.';

create table if not exists taxonomy.taxonomy_versions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  taxonomy_id uuid not null,
  version_number integer not null,
  status core.version_status not null default 'draft',
  change_summary text,
  effective_from timestamptz,
  effective_to timestamptz,
  supersedes_version_id uuid,
  content_digest text
);
comment on table taxonomy.taxonomy_versions is 'Immutable published vocabulary version.';

create table if not exists taxonomy.taxonomy_terms (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  taxonomy_id uuid not null,
  term_code text not null,
  canonical_label text not null,
  descriptions jsonb not null default '{}'::jsonb,
  introduced_version_id uuid not null,
  deprecated_version_id uuid
);
comment on table taxonomy.taxonomy_terms is 'Stable term code and localized labels.';

create table if not exists taxonomy.taxonomy_term_relationships (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  from_term_id uuid not null,
  to_term_id uuid not null,
  relationship_type text not null,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table taxonomy.taxonomy_term_relationships is 'Typed hierarchy, equivalence, or supersession edge between terms.';

create table if not exists intake.reports (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  report_number text not null,
  channel text not null,
  source_message_id text,
  source_relationship_id uuid,
  submitted_payload jsonb not null default '{}'::jsonb,
  submitted_text text,
  submitted_location_text text,
  safety_opinion text,
  impact_opinion text,
  language text,
  acceptance_state text not null default 'accepted',
  occurred_at timestamptz,
  recorded_at timestamptz not null default now(),
  classification core.data_classification not null default 'confidential'
);
comment on table intake.reports is 'Immutable original incoming Report.';

create table if not exists intake.cases (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  case_number text not null,
  report_id uuid not null,
  current_state text not null default 'open',
  opened_at timestamptz not null default now(),
  resolved_at timestamptz,
  closed_at timestamptz,
  current_summary text,
  current_priority_decision_id uuid
);
comment on table intake.cases is 'Separately traceable Case created for exactly one Report.';

create table if not exists intake.case_party_relationships (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  case_id uuid not null,
  organization_relationship_id uuid not null,
  party_role_term_id uuid not null,
  contact_permission text,
  visibility_scope jsonb not null default '{}'::jsonb,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid
);
comment on table intake.case_party_relationships is 'Effective Case relationship for reporter, affected party, contact, or representative.';

create table if not exists intake.case_context_assertions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  case_id uuid not null,
  assertion_type text not null,
  value_text text,
  location_id uuid,
  room_id uuid,
  asset_id uuid,
  component_id uuid,
  taxonomy_term_id uuid,
  source_type text not null,
  source_id uuid,
  confidence numeric(5,4),
  is_submitted_value boolean not null default false,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid,
  decision_id uuid
);
comment on table intake.case_context_assertions is 'Versioned submitted or corrected Case context assertion.';

create table if not exists intake.case_communications (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  case_id uuid not null,
  case_party_relationship_id uuid,
  direction text not null,
  channel text not null,
  subject text,
  content_digest text,
  content_reference text,
  notification_intent_id uuid,
  delivery_attempt_id uuid,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now(),
  correlation_id uuid not null default gen_random_uuid()
);
comment on table intake.case_communications is 'Immutable Case communication history.';

create table if not exists intake.case_reopens (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  case_id uuid not null,
  reopen_sequence integer not null,
  decision_id uuid not null,
  prior_close_transition_id uuid not null,
  reopen_reason_type text not null,
  new_evidence_item_id uuid,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table intake.case_reopens is 'Reasoned immutable Case Reopen event.';

create table if not exists intake.case_transfers (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  transfer_code text not null,
  source_case_id uuid not null,
  source_juristic_person_id uuid not null,
  destination_juristic_person_id uuid not null,
  destination_case_id uuid,
  requested_at timestamptz not null,
  accepted_at timestamptz,
  decision_id uuid not null,
  scope_manifest_id uuid,
  sla_treatment text
);
comment on table intake.case_transfers is 'Governed cross-building or cross-tenant Case transfer.';

create table if not exists investigation.investigations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  investigation_number text not null,
  question text not null,
  initiating_case_id uuid,
  responsibility_assignment_id uuid,
  workflow_instance_id uuid,
  current_state text not null default 'opened',
  opened_at timestamptz not null default now(),
  concluded_at timestamptz
);
comment on table investigation.investigations is 'Structured investigative question and lifecycle.';

create table if not exists investigation.investigation_cases (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  investigation_id uuid not null,
  case_id uuid not null,
  scope_role text not null,
  inclusion_reason text not null,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table investigation.investigation_cases is 'Effective Investigation scope membership for Cases.';

create table if not exists investigation.observations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  observation_number text not null,
  investigation_id uuid not null,
  observer_relationship_id uuid,
  observation_type text not null,
  narrative text,
  measured_value jsonb,
  location_id uuid,
  asset_id uuid,
  component_id uuid,
  source_device text,
  confidence numeric(5,4),
  correction_of_observation_id uuid,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table investigation.observations is 'Attributed immutable perception or measurement.';

create table if not exists investigation.hypotheses (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  hypothesis_number text not null,
  investigation_id uuid not null,
  statement text not null,
  author_person_id uuid not null,
  confidence numeric(5,4),
  hypothesis_state text not null default 'proposed',
  supersedes_hypothesis_id uuid
);
comment on table investigation.hypotheses is 'Proposed explanation that remains distinct from fact.';

create table if not exists investigation.hypothesis_evidence_links (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  hypothesis_id uuid not null,
  evidence_item_id uuid not null,
  link_role core.link_role not null,
  relevance text,
  reviewer_person_id uuid,
  supersedes_link_id uuid
);
comment on table investigation.hypothesis_evidence_links is 'Typed Evidence relationship to a Hypothesis.';

create table if not exists investigation.understanding_assessments (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  assessment_number text not null,
  investigation_id uuid not null,
  known_summary text not null,
  inferred_summary text,
  disputed_summary text,
  unknown_summary text,
  confidence numeric(5,4),
  recommendation_summary text,
  assessment_status core.version_status not null default 'draft',
  supersedes_assessment_id uuid,
  issued_at timestamptz
);
comment on table investigation.understanding_assessments is 'Versioned Operational Truth assessment for an Investigation.';

create table if not exists investigation.assessment_evidence_links (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  assessment_id uuid not null,
  evidence_item_id uuid not null,
  consideration_role core.link_role not null,
  relevance text,
  reliability_assessment text,
  omission_reason text,
  supersedes_link_id uuid
);
comment on table investigation.assessment_evidence_links is 'Evidence considered or omitted by an Understanding Assessment.';

create table if not exists incident.incidents (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  incident_number text not null,
  verification_decision_id uuid not null,
  verification_assessment_id uuid not null,
  verified_at timestamptz not null,
  current_state text not null default 'verified',
  current_summary text,
  activated_at timestamptz,
  monitoring_started_at timestamptz,
  closed_at timestamptz,
  verification_withdrawn_at timestamptz
);
comment on table incident.incidents is 'One human-verified operational event.';

create table if not exists incident.case_incident_associations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  association_code text not null,
  case_id uuid not null,
  incident_id uuid not null,
  relationship_type text not null,
  relevance text,
  decision_id uuid not null,
  mandate_id uuid not null,
  assessment_id uuid not null,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_association_id uuid
);
comment on table incident.case_incident_associations is 'Reasoned historical many-to-many Case and Incident relationship.';

create table if not exists incident.incident_assets (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  incident_id uuid not null,
  asset_id uuid,
  component_id uuid,
  location_id uuid,
  relationship_type text not null,
  confidence numeric(5,4),
  source_assessment_id uuid,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table incident.incident_assets is 'Effective Incident relationship to Asset, Component, or Location.';

create table if not exists incident.incident_reopens (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  incident_id uuid not null,
  reopen_sequence integer not null,
  decision_id uuid not null,
  prior_close_transition_id uuid not null,
  relationship_to_prior_repair text,
  reason_type text not null,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table incident.incident_reopens is 'Immutable human-authorized Incident Reopen event.';

create table if not exists incident.incident_classifications (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  incident_id uuid not null,
  classification_type text not null,
  taxonomy_term_id uuid not null,
  decision_id uuid not null,
  assessment_id uuid,
  confidence numeric(5,4),
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid
);
comment on table incident.incident_classifications is 'Effective governed Incident classification assertion.';

create table if not exists work.operations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  operation_number text not null,
  operation_type_term_id uuid not null,
  title text not null,
  scope text not null,
  desired_outcome text not null,
  hazards jsonb not null default '{}'::jsonb,
  responsibility_assignment_id uuid not null,
  workflow_instance_id uuid,
  current_state text not null default 'proposed',
  proposed_at timestamptz not null default now(),
  authorized_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz
);
comment on table work.operations is 'Bounded reactive or proactive work unit.';

create table if not exists work.incident_operations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  incident_id uuid not null,
  operation_id uuid not null,
  relationship_type text not null,
  scope_note text,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table work.incident_operations is 'Explicit Incident-to-Operation relationship.';

create table if not exists work.maintenance_plan_operations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  maintenance_plan_id uuid not null,
  operation_id uuid not null,
  planned_occurrence_key text not null,
  scheduled_for timestamptz,
  plan_version_reference text not null,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table work.maintenance_plan_operations is 'Maintenance Plan origin for an Operation.';

create table if not exists work.operation_assets (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  operation_id uuid not null,
  asset_id uuid,
  component_id uuid,
  location_id uuid,
  subject_role text not null,
  expected_effect text,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table work.operation_assets is 'Operation work subject relationship.';

create table if not exists work.work_steps (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  operation_id uuid not null,
  step_code text not null,
  parent_step_id uuid,
  sequence_hint integer,
  title text not null,
  instructions text,
  required_capability_term_id uuid,
  current_state text not null default 'planned',
  started_at timestamptz,
  completed_at timestamptz,
  skip_reason text
);
comment on table work.work_steps is 'Operation-owned executable Work Step.';

create table if not exists work.commitments (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  commitment_number text not null,
  operation_id uuid not null,
  work_step_id uuid,
  offered_by_person_id uuid not null,
  accepted_by_relationship_id uuid not null,
  scope text not null,
  due_at timestamptz,
  accepted_at timestamptz,
  current_state text not null default 'offered',
  replaces_commitment_id uuid,
  released_by_decision_id uuid
);
comment on table work.commitments is 'Explicit accepted obligation for work.';

create table if not exists work.operation_interruptions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  operation_id uuid not null,
  commitment_id uuid,
  interrupting_incident_id uuid,
  interrupting_operation_id uuid,
  priority_decision_id uuid,
  safe_stop_state text not null,
  schedule_impact text,
  recovery_plan text not null,
  resumed_at timestamptz,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table work.operation_interruptions is 'Immutable interruption, safe stop, impact, and recovery history.';

create table if not exists work.verification_records (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  verification_number text not null,
  operation_id uuid not null,
  attempt_number integer not null,
  verifier_relationship_id uuid not null,
  verifier_role_assignment_id uuid,
  criteria_policy_version_id uuid,
  method text not null,
  remote boolean not null default false,
  result text not null,
  limitations text,
  evidence_package_version_id uuid,
  decision_id uuid not null,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table work.verification_records is 'Immutable human verification attempt.';

create table if not exists work.priority_decisions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  decision_id uuid not null,
  target_type text not null,
  case_id uuid,
  incident_id uuid,
  operation_id uuid,
  priority_term_id uuid not null,
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_priority_id uuid,
  consequence_summary text
);
comment on table work.priority_decisions is 'Organizational Priority decision separated from sequence and SLA.';

create table if not exists work.execution_sequence_entries (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  technician_relationship_id uuid not null,
  operation_id uuid not null,
  commitment_id uuid,
  sequence_rank integer not null,
  constraint_summary text,
  previous_entry_id uuid,
  material_change boolean not null default true,
  decision_id uuid,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table work.execution_sequence_entries is 'Material technician Execution Sequence entry.';

create table if not exists work.sla_policies (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  sla_code text not null,
  name text not null,
  owner_responsibility_id uuid not null
);
comment on table work.sla_policies is 'Stable SLA identity and governance owner.';

create table if not exists work.sla_policy_versions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  sla_policy_id uuid not null,
  version_number integer not null,
  status core.version_status not null default 'draft',
  service_class_term_id uuid not null,
  calendar_definition jsonb not null,
  target_duration interval not null,
  start_rule text not null,
  satisfaction_rule text not null,
  pause_rules jsonb not null default '{}'::jsonb,
  breach_rules jsonb not null default '{}'::jsonb,
  source_policy_version_id uuid,
  contract_obligation_id uuid,
  effective_from timestamptz,
  effective_to timestamptz,
  supersedes_version_id uuid
);
comment on table work.sla_policy_versions is 'Immutable SLA service class, calendar, target, and clock rules.';

create table if not exists work.sla_applications (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  sla_application_number text not null,
  sla_policy_version_id uuid not null,
  case_id uuid,
  operation_id uuid,
  classification_decision_id uuid not null,
  clock_started_at timestamptz,
  current_clock_state text not null default 'pending',
  due_at timestamptz,
  satisfied_at timestamptz,
  breached_at timestamptz,
  supersedes_application_id uuid
);
comment on table work.sla_applications is 'SLA version applied to exactly one Case or Operation.';

create table if not exists work.sla_clock_events (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  sla_application_id uuid not null,
  clock_event_type text not null,
  duration_effect interval,
  source_type text not null,
  source_id uuid,
  blocking_party_type text,
  blocking_party_id uuid,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table work.sla_clock_events is 'Immutable SLA clock start, pause, resume, satisfy, breach, or cancel event.';

create table if not exists evidence.upload_attachments (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  upload_id text not null,
  storage_bucket text not null,
  storage_object_key text not null,
  original_filename text,
  media_type text,
  byte_size bigint,
  expected_digest text,
  observed_digest text,
  uploader_person_id uuid,
  upload_state text not null default 'initiated',
  scan_state text,
  quarantine_reason text,
  promoted_evidence_item_id uuid,
  disposed_at timestamptz,
  classification core.data_classification not null default 'confidential'
);
comment on table evidence.upload_attachments is 'Storage upload intent before evidentiary promotion.';

create table if not exists evidence.evidence_items (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  evidence_number text not null,
  evidence_type text not null,
  original_attachment_id uuid,
  original_storage_bucket text not null,
  original_storage_object_key text not null,
  content_digest text not null,
  byte_size bigint,
  capture_method text,
  captured_at timestamptz,
  source_person_id uuid,
  source_device text,
  custodian_relationship_id uuid,
  location_id uuid,
  retention_policy_version_id uuid,
  access_state text not null default 'captured',
  classification core.data_classification not null default 'confidential'
);
comment on table evidence.evidence_items is 'Immutable provenanced Evidence identity and original object reference.';

create table if not exists evidence.evidence_renditions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  evidence_item_id uuid not null,
  parent_rendition_id uuid,
  rendition_type text not null,
  version_number integer not null,
  storage_bucket text not null,
  storage_object_key text not null,
  content_digest text not null,
  transformation_method text not null,
  tool_version text,
  redaction_basis text,
  language text,
  classification core.data_classification not null default 'confidential'
);
comment on table evidence.evidence_renditions is 'Immutable derived, redacted, annotated, or transcribed Evidence rendition.';

create table if not exists evidence.evidence_links (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  evidence_item_id uuid not null,
  rendition_id uuid,
  target_type text not null,
  target_id uuid not null,
  claim_type text,
  claim_id uuid,
  link_role core.link_role not null,
  relevance text,
  reviewer_person_id uuid,
  relationship_state core.relationship_lifecycle not null default 'effective',
  supersedes_link_id uuid
);
comment on table evidence.evidence_links is 'Typed Evidence-to-claim or domain-record relationship.';

create table if not exists evidence.evidence_packages (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  package_code text not null,
  question text not null,
  owner_relationship_id uuid not null
);
comment on table evidence.evidence_packages is 'Stable Evidence Package identity for a defined question.';

create table if not exists evidence.evidence_package_versions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  evidence_package_id uuid not null,
  version_number integer not null,
  status core.version_status not null default 'draft',
  compiler_person_id uuid not null,
  selection_criteria text not null,
  omissions_summary text,
  issued_at timestamptz,
  supersedes_version_id uuid,
  content_digest text
);
comment on table evidence.evidence_package_versions is 'Immutable issued Evidence Package manifest version.';

create table if not exists evidence.evidence_package_members (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  package_version_id uuid not null,
  member_sequence integer not null,
  evidence_item_id uuid not null,
  rendition_id uuid,
  inclusion_role text not null,
  inclusion_reason text
);
comment on table evidence.evidence_package_members is 'Evidence Item or Rendition membership in a Package Version.';

create table if not exists evidence.evidence_custody_events (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  evidence_item_id uuid,
  package_version_id uuid,
  from_custodian_id uuid,
  to_custodian_id uuid,
  custody_action text not null,
  export_manifest_id uuid,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table evidence.evidence_custody_events is 'Immutable Evidence possession or control transfer.';

create table if not exists evidence.evidence_integrity_checks (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  evidence_item_id uuid,
  rendition_id uuid,
  memory_manifest_id uuid,
  check_type text not null,
  expected_digest text,
  observed_digest text,
  availability_result text not null,
  checker_principal_id uuid,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table evidence.evidence_integrity_checks is 'Immutable Evidence or manifest integrity and availability check.';

create table if not exists evidence.evidence_dispositions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  evidence_item_id uuid not null,
  rendition_id uuid,
  disposition_type text not null,
  policy_version_id uuid not null,
  decision_id uuid not null,
  legal_hold_state text,
  archive_batch_id uuid,
  content_removed boolean not null default false,
  tombstone_scope jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table evidence.evidence_dispositions is 'Governed Evidence restriction, hold, archive, or lawful disposal.';

create table if not exists decision.decision_records (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  decision_number text not null,
  decision_class text not null,
  question text not null,
  context_summary text not null,
  alternatives jsonb not null default '[]'::jsonb,
  outcome text not null,
  rationale text not null,
  responsible_person_id uuid not null,
  acting_role_assignment_id uuid not null,
  mandate_id uuid,
  authority_source_type text not null,
  authority_source_id uuid,
  decided_at timestamptz not null,
  effective_from timestamptz,
  effective_to timestamptz,
  expected_consequences text,
  affected_commitments jsonb not null default '[]'::jsonb,
  dissent_summary text,
  review_due_at timestamptz,
  decision_status core.version_status not null default 'issued'
);
comment on table decision.decision_records is 'Accountable human Decision and rationale.';

create table if not exists decision.decision_evidence_links (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  decision_id uuid not null,
  evidence_item_id uuid not null,
  consideration_role core.link_role not null,
  relevance text,
  reliability text,
  omission_reason text
);
comment on table decision.decision_evidence_links is 'Evidence considered, omitted, supporting, or challenging a Decision.';

create table if not exists decision.decision_assessment_links (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  decision_id uuid not null,
  assessment_id uuid not null,
  relationship_role text not null
);
comment on table decision.decision_assessment_links is 'Understanding Assessment used by a Decision.';

create table if not exists decision.decision_relationships (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  from_decision_id uuid not null,
  to_decision_id uuid not null,
  relationship_type core.decision_relationship_kind not null,
  effective_at timestamptz not null,
  reason text not null
);
comment on table decision.decision_relationships is 'Typed Decision Evolution relationship.';

create table if not exists decision.recommendations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  recommendation_number text not null,
  author_kind core.actor_kind not null,
  author_person_id uuid,
  author_service_principal_id uuid,
  question text not null,
  recommendation_text text not null,
  assumptions text,
  uncertainty text,
  limitations text,
  issued_at timestamptz,
  expires_at timestamptz,
  recommendation_status text not null default 'draft'
);
comment on table decision.recommendations is 'Attributed advisory option with no Authority.';

create table if not exists decision.recommendation_sources (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  recommendation_id uuid not null,
  source_type text not null,
  source_id uuid not null,
  source_role core.link_role not null,
  context_match numeric(5,4),
  citation_label text
);
comment on table decision.recommendation_sources is 'Durable source and context for a Recommendation.';

create table if not exists knowledge.knowledge_records (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  knowledge_number text not null,
  knowledge_type text not null,
  title text not null,
  steward_responsibility_id uuid not null,
  current_published_version_id uuid
);
comment on table knowledge.knowledge_records is 'Stable context-bound Knowledge or Lesson identity.';

create table if not exists knowledge.knowledge_versions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  knowledge_record_id uuid not null,
  version_number integer not null,
  status core.version_status not null default 'draft',
  content text not null,
  confidence numeric(5,4),
  assumptions text not null,
  limitations text not null,
  author_person_id uuid not null,
  last_verified_at timestamptz,
  supersedes_version_id uuid,
  content_digest text
);
comment on table knowledge.knowledge_versions is 'Immutable Knowledge content version.';

create table if not exists knowledge.validity_contexts (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  knowledge_version_id uuid not null,
  asset_id uuid,
  component_id uuid,
  asset_type_id uuid,
  manufacturer text,
  model text,
  version text,
  location_id uuid,
  environment jsonb not null default '{}'::jsonb,
  governance_policy_version_id uuid,
  workflow_version_id uuid,
  effective_from timestamptz,
  effective_to timestamptz,
  context_expression jsonb not null default '{}'::jsonb
);
comment on table knowledge.validity_contexts is 'Conditions under which a Knowledge version may apply.';

create table if not exists knowledge.knowledge_sources (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  knowledge_version_id uuid not null,
  source_type text not null,
  source_id uuid not null,
  source_role core.link_role not null,
  outcome_summary text
);
comment on table knowledge.knowledge_sources is 'Source lineage for a Knowledge version.';

create table if not exists knowledge.knowledge_reviews (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  knowledge_version_id uuid not null,
  reviewer_person_id uuid not null,
  review_type text not null,
  result text not null,
  decision_id uuid,
  findings text,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table knowledge.knowledge_reviews is 'Immutable human Knowledge review.';

create table if not exists knowledge.knowledge_usage_outcomes (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  knowledge_version_id uuid not null,
  case_id uuid,
  incident_id uuid,
  operation_id uuid,
  context_match numeric(5,4),
  used_by_person_id uuid not null,
  use_decision_id uuid,
  outcome_assessment_id uuid,
  result text,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table knowledge.knowledge_usage_outcomes is 'Immutable Knowledge use and evaluated outcome.';

create table if not exists workflow.workflow_definitions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  workflow_code text not null,
  name text not null,
  business_owner_responsibility_id uuid not null,
  policy_authority_id uuid
);
comment on table workflow.workflow_definitions is 'Stable workflow identity, owner, and policy authority.';

create table if not exists workflow.workflow_versions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  workflow_definition_id uuid not null,
  version_number integer not null,
  status core.version_status not null default 'draft',
  states jsonb not null,
  transitions jsonb not null,
  role_requirements jsonb not null default '{}'::jsonb,
  timers jsonb not null default '{}'::jsonb,
  exception_rules jsonb not null default '{}'::jsonb,
  supersedes_version_id uuid,
  content_digest text
);
comment on table workflow.workflow_versions is 'Immutable states, transitions, roles, timers, and exception rules.';

create table if not exists workflow.workflow_instances (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  instance_number text not null,
  workflow_version_id uuid not null,
  responsibility_assignment_id uuid not null,
  current_state text not null,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  migration_decision_id uuid,
  previous_instance_id uuid
);
comment on table workflow.workflow_instances is 'Orchestration instance bound to an exact workflow version.';

create table if not exists workflow.workflow_subjects (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  workflow_instance_id uuid not null,
  subject_type text not null,
  subject_id uuid not null,
  subject_role text not null,
  is_primary boolean not null default false,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table workflow.workflow_subjects is 'Typed workflow relationship to domain aggregates.';

create table if not exists workflow.state_transitions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  workflow_instance_id uuid,
  aggregate_type text not null,
  aggregate_id uuid not null,
  aggregate_version_before bigint not null,
  aggregate_version_after bigint not null,
  previous_state text,
  current_state text not null,
  decision_id uuid,
  mandate_id uuid,
  evidence_package_id uuid,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now(),
  correlation_id uuid not null default gen_random_uuid(),
  reason text not null
);
comment on table workflow.state_transitions is 'Immutable previous/current state transition.';

create table if not exists notification.notification_intents (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  source_event_id uuid not null,
  purpose_code text not null,
  urgency text not null,
  policy_version_id uuid,
  template_code text not null,
  required_acknowledgement boolean not null default false,
  expires_at timestamptz,
  responsibility_assignment_id uuid not null
);
comment on table notification.notification_intents is 'Governed requirement to communicate a source event and purpose.';

create table if not exists notification.notification_audiences (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  notification_intent_id uuid not null,
  case_party_relationship_id uuid,
  organization_relationship_id uuid,
  recipient_address_reference text,
  channel text not null,
  locale text,
  disclosure_scope jsonb not null default '{}'::jsonb,
  eligibility_state text not null default 'eligible',
  suppression_reason text,
  classification core.data_classification not null default 'confidential'
);
comment on table notification.notification_audiences is 'Authorized recipient, channel, and disclosure selection.';

create table if not exists notification.message_renditions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  notification_intent_id uuid not null,
  audience_id uuid not null,
  locale text not null,
  template_version text not null,
  subject text,
  content_reference text not null,
  content_digest text not null,
  corrects_rendition_id uuid,
  classification core.data_classification not null default 'confidential'
);
comment on table notification.message_renditions is 'Immutable rendered message content and correction lineage.';

create table if not exists notification.delivery_attempts (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  audience_id uuid not null,
  rendition_id uuid not null,
  provider_external_system_id uuid,
  attempt_number integer not null,
  idempotency_key text not null,
  provider_message_id text,
  result text not null,
  provider_status text,
  sent_at timestamptz,
  delivered_at timestamptz,
  failure_reason text,
  occurred_at timestamptz not null default now(),
  recorded_at timestamptz not null default now()
);
comment on table notification.delivery_attempts is 'Immutable provider/channel delivery attempt.';

create table if not exists notification.notification_acknowledgements (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  audience_id uuid not null,
  delivery_attempt_id uuid,
  acknowledging_relationship_id uuid not null,
  acknowledgement_method text not null,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table notification.notification_acknowledgements is 'Explicit recipient acknowledgement.';

create table if not exists notification.announcements (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'draft',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  announcement_number text not null,
  title text not null,
  body text not null,
  severity text not null default 'information',
  audience_roles text[] not null default array[]::text[],
  publication_state text not null default 'draft',
  published_at timestamptz,
  expires_at timestamptz,
  acknowledgement_required boolean not null default false
);
comment on table notification.announcements is 'Version-preserving operational announcement; publication does not create hidden Authority.';

create table if not exists governance.compliance_deadlines (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  deadline_number text not null,
  title text not null,
  description text,
  source_type text not null,
  source_reference text,
  due_at timestamptz not null,
  current_state text not null default 'open',
  responsibility_assignment_id uuid,
  completed_at timestamptz,
  completion_evidence_package_version_id uuid,
  supersedes_deadline_id uuid
);
comment on table governance.compliance_deadlines is 'Traceable compliance obligation date, Responsibility, completion, and supersession history.';

create table if not exists governance.policies (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  policy_code text not null,
  title text not null,
  owner_responsibility_id uuid not null
);
comment on table governance.policies is 'Stable governance policy identity.';

create table if not exists governance.policy_versions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  policy_id uuid not null,
  version_number integer not null,
  status core.version_status not null default 'draft',
  content_reference text not null,
  structured_rules jsonb not null default '{}'::jsonb,
  approved_by_resolution_id uuid,
  review_due_at timestamptz,
  effective_from timestamptz,
  effective_to timestamptz,
  supersedes_version_id uuid,
  content_digest text
);
comment on table governance.policy_versions is 'Immutable approved policy content and structured rules.';

create table if not exists governance.committees (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  committee_code text not null,
  name text not null,
  term_start date not null,
  term_end date,
  appointment_source text not null
);
comment on table governance.committees is 'Governing body and term identity.';

create table if not exists governance.committee_memberships (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  committee_id uuid not null,
  person_id uuid not null,
  organization_relationship_id uuid not null,
  office_term_id uuid,
  voting_rights boolean not null default true,
  conflict_declaration text,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz
);
comment on table governance.committee_memberships is 'Effective Committee membership, office, vote rights, and conflict state.';

create table if not exists governance.meetings (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  meeting_code text not null,
  committee_id uuid not null,
  scheduled_at timestamptz not null,
  held_at timestamptz,
  location text,
  chair_membership_id uuid,
  secretary_membership_id uuid,
  quorum_policy_version_id uuid,
  quorum_result text
);
comment on table governance.meetings is 'Committee meeting, agenda, quorum, and session record.';

create table if not exists governance.resolutions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  resolution_code text not null,
  meeting_id uuid not null,
  decision_id uuid not null,
  title text not null,
  outcome text not null,
  effective_at timestamptz,
  review_due_at timestamptz
);
comment on table governance.resolutions is 'Committee resolution backed by a human Decision.';

create table if not exists governance.resolution_votes (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  resolution_id uuid not null,
  committee_membership_id uuid not null,
  vote text not null,
  conflict_state text,
  dissent_text text,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table governance.resolution_votes is 'Immutable Committee member vote, abstention, conflict, or dissent.';

create table if not exists governance.contracts (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  contract_code text not null,
  vendor_organization_id uuid not null,
  title text not null,
  owner_responsibility_id uuid not null,
  started_on date,
  ended_on date
);
comment on table governance.contracts is 'Stable Vendor and Juristic Person agreement identity.';

create table if not exists governance.contract_versions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  contract_id uuid not null,
  version_number integer not null,
  status core.version_status not null default 'draft',
  executed_at timestamptz,
  terms_reference text not null,
  terms_digest text not null,
  approved_by_decision_id uuid,
  termination_terms jsonb not null default '{}'::jsonb,
  effective_from timestamptz,
  effective_to timestamptz,
  supersedes_version_id uuid
);
comment on table governance.contract_versions is 'Immutable executed or amended Contract terms.';

create table if not exists governance.contract_obligations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  contract_version_id uuid not null,
  obligation_code text not null,
  obligation_type text not null,
  service_scope jsonb not null,
  sla_policy_version_id uuid,
  responsible_party_id uuid not null,
  acceptance_criteria text,
  evidence_requirements text,
  remedy_rules jsonb not null default '{}'::jsonb,
  effective_from timestamptz,
  effective_to timestamptz
);
comment on table governance.contract_obligations is 'Scoped Contract obligation, SLA, acceptance, evidence, and remedy.';

create table if not exists governance.risks (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  risk_code text not null,
  title text not null,
  description text not null,
  risk_type_term_id uuid,
  likelihood numeric(5,4),
  impact numeric(5,4),
  owner_responsibility_id uuid not null,
  control_summary text,
  review_due_at timestamptz,
  acceptance_decision_id uuid
);
comment on table governance.risks is 'Governed risk statement, owner, controls, and acceptance.';

create table if not exists governance.risk_links (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  risk_id uuid not null,
  target_type text not null,
  target_id uuid not null,
  relationship_type text not null,
  control_policy_version_id uuid
);
comment on table governance.risk_links is 'Typed Risk relationship to Asset, Incident, policy, Contract, Decision, or control.';

create table if not exists ai.ai_use_cases (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  use_case_code text not null,
  purpose text not null,
  business_owner_responsibility_id uuid not null,
  risk_owner_responsibility_id uuid not null,
  technical_steward_relationship_id uuid not null,
  approved_data_scope jsonb not null,
  prohibited_actions text[] not null,
  evaluation_policy jsonb not null,
  approved_by_decision_id uuid
);
comment on table ai.ai_use_cases is 'Approved AI purpose, ownership, data scope, and evaluation.';

create table if not exists ai.ai_interactions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  ai_use_case_id uuid not null,
  requesting_person_id uuid,
  provider_external_system_id uuid not null,
  model_name text not null,
  model_version text not null,
  prompt_purpose text not null,
  context_manifest_id uuid,
  input_digest text not null,
  output_digest text not null,
  output_reference text,
  uncertainty text,
  safety_result text,
  occurred_at timestamptz not null default now(),
  recorded_at timestamptz not null default now(),
  classification core.data_classification not null default 'confidential'
);
comment on table ai.ai_interactions is 'Immutable governed AI interaction metadata and artifact digest.';

create table if not exists ai.ai_recommendations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  ai_interaction_id uuid not null,
  recommendation_id uuid,
  recommendation_text text not null,
  assumptions text,
  limitations text,
  uncertainty text not null,
  context_match numeric(5,4),
  generated_at timestamptz not null,
  review_state text not null default 'pending',
  classification core.data_classification not null default 'confidential'
);
comment on table ai.ai_recommendations is 'AI advisory output distinct from human Decision.';

create table if not exists ai.ai_recommendation_sources (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  ai_recommendation_id uuid not null,
  source_type text not null,
  source_id uuid not null,
  citation text not null,
  context_match numeric(5,4),
  mismatch_summary text
);
comment on table ai.ai_recommendation_sources is 'Durable AI citation and context match result.';

create table if not exists ai.ai_reviews (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  ai_interaction_id uuid,
  ai_recommendation_id uuid,
  reviewer_person_id uuid not null,
  review_result text not null,
  correction_summary text,
  adoption_decision_id uuid,
  harm_severity text,
  use_case_disabled boolean not null default false,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now()
);
comment on table ai.ai_reviews is 'Immutable human review of AI interaction or Recommendation.';

create table if not exists audit.domain_events (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  event_type text not null,
  schema_version integer not null,
  aggregate_type text not null,
  aggregate_id uuid not null,
  aggregate_version bigint not null,
  payload jsonb not null,
  classification core.data_classification not null default 'internal',
  producer text not null,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now(),
  actor_kind core.actor_kind not null,
  actor_id uuid,
  acting_role_assignment_id uuid,
  correlation_id uuid not null,
  causation_id uuid
);
comment on table audit.domain_events is 'Immutable accepted domain fact envelope.';

create table if not exists audit.outbox_messages (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  domain_event_id uuid not null,
  destination text not null,
  publication_state text not null default 'pending',
  attempt_count integer not null default 0,
  next_attempt_at timestamptz,
  published_at timestamptz,
  last_error text,
  quarantined_at timestamptz
);
comment on table audit.outbox_messages is 'Transactional publication state for a Domain Event.';

create table if not exists audit.audit_entries (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  principal_kind core.actor_kind not null,
  principal_id uuid,
  session_id uuid,
  action_code text not null,
  target_type text not null,
  target_id uuid,
  result core.audit_result not null,
  policy_version_id uuid,
  mandate_id uuid,
  access_decision_id uuid,
  request_metadata jsonb not null default '{}'::jsonb,
  before_reference text,
  after_reference text,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now(),
  correlation_id uuid not null default gen_random_uuid(),
  reason text,
  classification core.data_classification not null default 'confidential'
);
comment on table audit.audit_entries is 'Tamper-evident security and administrative action record.';

create table if not exists analytics.kpi_definitions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  kpi_code text not null,
  name text not null,
  purpose text not null,
  owner_responsibility_id uuid not null,
  guardrails text not null
);
comment on table analytics.kpi_definitions is 'Stable KPI identity, purpose, owner, and guardrails.';

create table if not exists analytics.kpi_versions (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  kpi_definition_id uuid not null,
  version_number integer not null,
  status core.version_status not null default 'draft',
  formula_definition jsonb not null,
  population_definition jsonb not null,
  exclusions jsonb not null default '{}'::jsonb,
  dimensions jsonb not null default '{}'::jsonb,
  freshness_target interval,
  supersedes_version_id uuid,
  content_digest text
);
comment on table analytics.kpi_versions is 'Immutable KPI formula, population, exclusions, and dimensions.';

create table if not exists analytics.kpi_observations (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  kpi_version_id uuid not null,
  period_start timestamptz not null,
  period_end timestamptz not null,
  as_of_at timestamptz not null,
  dimension_values jsonb not null default '{}'::jsonb,
  numerator numeric,
  denominator numeric,
  value numeric,
  suppression_state text,
  source_manifest_id uuid not null,
  restates_observation_id uuid
);
comment on table analytics.kpi_observations is 'Immutable reproducible KPI observation.';

create table if not exists analytics.report_snapshots (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  report_code text not null,
  report_version text not null,
  period_start timestamptz,
  period_end timestamptz,
  as_of_at timestamptz not null,
  source_manifest_id uuid not null,
  content_reference text not null,
  content_digest text not null,
  published_by_person_id uuid not null,
  restates_snapshot_id uuid
);
comment on table analytics.report_snapshots is 'Immutable issued or restated report snapshot.';

create table if not exists memory.memory_manifests (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  manifest_code text not null,
  manifest_type text not null,
  scope_definition jsonb not null,
  as_of_at timestamptz not null,
  schema_catalog_version text not null,
  manifest_state text not null default 'preparing',
  sealed_at timestamptz,
  verified_at timestamptz,
  content_digest text,
  custodian_relationship_id uuid not null
);
comment on table memory.memory_manifests is 'Organizational Memory, export, or integrity manifest.';

create table if not exists memory.memory_manifest_items (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  memory_manifest_id uuid not null,
  item_sequence bigint not null,
  source_type text not null,
  source_id uuid,
  source_version text,
  object_reference text,
  content_digest text not null,
  retention_state text,
  verification_result text
);
comment on table memory.memory_manifest_items is 'Source record, object, schema, policy, or taxonomy item in a sealed manifest.';

create table if not exists memory.archive_batches (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  archive_batch_code text not null,
  policy_version_id uuid not null,
  decision_id uuid not null,
  source_tier text not null,
  destination_tier text not null,
  batch_state text not null default 'preparing',
  started_at timestamptz,
  completed_at timestamptz,
  custodian_relationship_id uuid not null
);
comment on table memory.archive_batches is 'Governed archive, restore, or disposition custody operation.';

create table if not exists memory.archive_batch_items (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  archive_batch_id uuid not null,
  item_sequence bigint not null,
  source_type text not null,
  source_id uuid,
  object_reference text,
  result text not null,
  error text,
  reconciled_at timestamptz
);
comment on table memory.archive_batch_items is 'Per-record or object archive result and reconciliation.';

create table if not exists integration.external_systems (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  system_code text not null,
  name text not null,
  system_type text not null,
  owner_relationship_id uuid not null,
  contract_id uuid,
  trust_level text not null,
  data_classification core.data_classification not null,
  activated_at timestamptz,
  retired_at timestamptz
);
comment on table integration.external_systems is 'External system identity, trust, ownership, and lifecycle.';

create table if not exists integration.external_identifiers (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  external_system_id uuid not null,
  entity_type text not null,
  entity_id uuid not null,
  identifier_type text not null,
  identifier_value text not null,
  relationship_state core.relationship_lifecycle not null default 'effective',
  recorded_from timestamptz not null default now(),
  recorded_to timestamptz,
  supersedes_id uuid
);
comment on table integration.external_identifiers is 'Effective mapping from O83 identity to external identity.';

create table if not exists integration.inbound_messages (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  external_system_id uuid not null,
  external_message_id text not null,
  message_type text not null,
  schema_version text not null,
  payload_reference text,
  payload_digest text not null,
  validation_state text not null default 'received',
  processing_state text not null default 'pending',
  result_type text,
  result_id uuid,
  quarantine_reason text,
  occurred_at timestamptz,
  recorded_at timestamptz not null default now(),
  correlation_id uuid not null default gen_random_uuid()
);
comment on table integration.inbound_messages is 'Immutable inbound envelope, idempotency, validation, and quarantine history.';

create table if not exists integration.sync_conflicts (
  id uuid primary key default extensions.gen_random_uuid(),
  juristic_person_id uuid not null,
  business_key text not null,
  lifecycle core.record_lifecycle not null default 'active',
  row_version bigint not null default 1,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  created_by_person_id uuid,
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  conflict_number text not null,
  external_system_id uuid,
  inbound_message_id uuid,
  aggregate_type text not null,
  aggregate_id uuid not null,
  expected_version bigint,
  actual_version bigint,
  conflict_type text not null,
  alternatives jsonb not null default '[]'::jsonb,
  resolution text,
  resolved_by_person_id uuid,
  resolution_decision_id uuid,
  conflict_state text not null default 'open'
);
comment on table integration.sync_conflicts is 'Offline or integration conflict and accountable resolution.';


-- ============================================================================
-- Source: sql/04_constraints.sql
-- ============================================================================

-- O83 Care foreign keys, unique rules, and check constraints.
-- Helper functions are internal, idempotent, and not exposed to application roles.

create or replace function core.ensure_fk(p_table regclass, p_name text, p_column text, p_target regclass, p_target_column text default 'id')
returns void language plpgsql set search_path = pg_catalog, core as $$
begin
  if not exists (select 1 from pg_constraint where conrelid = p_table and conname = p_name) then
    execute format('alter table %s add constraint %I foreign key (%I) references %s(%I) on delete restrict', p_table, p_name, p_column, p_target, p_target_column);
  end if;
end $$;
comment on function core.ensure_fk(regclass,text,text,regclass,text) is 'Internal idempotent migration helper for O83 foreign keys.';
revoke all on function core.ensure_fk(regclass,text,text,regclass,text) from public, anon, authenticated;

do $$
declare r record; c_name text;
begin
  for r in
    select format('%I.%I', schemaname, tablename)::regclass as rel, schemaname, tablename
    from pg_tables
    where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
      and not (schemaname = 'org' and tablename = 'juristic_persons')
  loop
    c_name := left('fk_' || r.schemaname || '_' || r.tablename || '_juristic_person', 63);
    perform core.ensure_fk(r.rel, c_name, 'juristic_person_id', 'org.juristic_persons'::regclass, 'id');
  end loop;
end $$;

select core.ensure_fk('iam.user_accounts'::regclass, 'fk_iam_user_accounts_auth_user_id', 'auth_user_id', 'auth.users'::regclass, 'id');
select core.ensure_fk('iam.user_accounts'::regclass, 'fk_iam_user_accounts_person_id', 'person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('iam.service_principals'::regclass, 'fk_iam_service_principals_owner_relationship_id', 'owner_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('iam.service_principals'::regclass, 'fk_iam_service_principals_auth_user_id', 'auth_user_id', 'auth.users'::regclass, 'id');
select core.ensure_fk('iam.access_decisions'::regclass, 'fk_iam_access_decisions_policy_version_id', 'policy_version_id', 'governance.policy_versions'::regclass, 'id');
select core.ensure_fk('iam.access_decisions'::regclass, 'fk_iam_access_decisions_mandate_id', 'mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('org.juristic_persons'::regclass, 'fk_org_juristic_persons_successor_juristic_person_id', 'successor_juristic_person_id', 'org.juristic_persons'::regclass, 'id');
select core.ensure_fk('org.people'::regclass, 'fk_org_people_merged_into_person_id', 'merged_into_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('org.external_organizations'::regclass, 'fk_org_external_organizations_successor_organization_id', 'successor_organization_id', 'org.external_organizations'::regclass, 'id');
select core.ensure_fk('org.organization_relationships'::regclass, 'fk_org_organization_relationships_person_id', 'person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('org.organization_relationships'::regclass, 'fk_org_organization_relationships_external_organization_id', 'external_organization_id', 'org.external_organizations'::regclass, 'id');
select core.ensure_fk('org.organization_relationships'::regclass, 'fk_org_organization_relationships_relationship_type_term_id', 'relationship_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('org.role_assignments'::regclass, 'fk_org_role_assignments_organization_relationship_id', 'organization_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.role_assignments'::regclass, 'fk_org_role_assignments_role_definition_id', 'role_definition_id', 'org.role_definitions'::regclass, 'id');
select core.ensure_fk('org.role_permissions'::regclass, 'fk_org_role_permissions_role_definition_id', 'role_definition_id', 'org.role_definitions'::regclass, 'id');
select core.ensure_fk('org.role_permissions'::regclass, 'fk_org_role_permissions_permission_definition_id', 'permission_definition_id', 'org.permission_definitions'::regclass, 'id');
select core.ensure_fk('org.role_permissions'::regclass, 'fk_org_role_permissions_supersedes_id', 'supersedes_id', 'org.role_permissions'::regclass, 'id');
select core.ensure_fk('org.mandates'::regclass, 'fk_org_mandates_grantee_relationship_id', 'grantee_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.mandates'::regclass, 'fk_org_mandates_grantee_role_assignment_id', 'grantee_role_assignment_id', 'org.role_assignments'::regclass, 'id');
select core.ensure_fk('org.mandates'::regclass, 'fk_org_mandates_parent_mandate_id', 'parent_mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('org.responsibility_assignments'::regclass, 'fk_org_responsibility_assignments_responsibility_definition_id', 'responsibility_definition_id', 'org.responsibility_definitions'::regclass, 'id');
select core.ensure_fk('org.responsibility_assignments'::regclass, 'fk_org_responsibility_assignments_responsible_relationship_id', 'responsible_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.responsibility_assignments'::regclass, 'fk_org_responsibility_assignments_responsible_role_assignment_i', 'responsible_role_assignment_id', 'org.role_assignments'::regclass, 'id');
select core.ensure_fk('org.responsibility_assignments'::regclass, 'fk_org_responsibility_assignments_supervising_assignment_id', 'supervising_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('org.responsibility_ledger_entries'::regclass, 'fk_org_responsibility_ledger_entries_responsibility_assignment_', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('org.responsibility_ledger_entries'::regclass, 'fk_org_responsibility_ledger_entries_mandate_id', 'mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('org.responsibility_ledger_entries'::regclass, 'fk_org_responsibility_ledger_entries_handover_id', 'handover_id', 'org.handovers'::regclass, 'id');
select core.ensure_fk('org.handovers'::regclass, 'fk_org_handovers_from_relationship_id', 'from_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.handovers'::regclass, 'fk_org_handovers_to_relationship_id', 'to_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.handovers'::regclass, 'fk_org_handovers_authority_decision_id', 'authority_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('org.handover_items'::regclass, 'fk_org_handover_items_handover_id', 'handover_id', 'org.handovers'::regclass, 'id');
select core.ensure_fk('org.handover_items'::regclass, 'fk_org_handover_items_acknowledged_by_person_id', 'acknowledged_by_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('org.capability_assertions'::regclass, 'fk_org_capability_assertions_subject_relationship_id', 'subject_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('org.capability_assertions'::regclass, 'fk_org_capability_assertions_capability_term_id', 'capability_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('org.capability_assertions'::regclass, 'fk_org_capability_assertions_level_term_id', 'level_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('org.capability_assertions'::regclass, 'fk_org_capability_assertions_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('org.availability_periods'::regclass, 'fk_org_availability_periods_subject_relationship_id', 'subject_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('property.buildings'::regclass, 'fk_property_buildings_property_id', 'property_id', 'property.properties'::regclass, 'id');
select core.ensure_fk('property.locations'::regclass, 'fk_property_locations_property_id', 'property_id', 'property.properties'::regclass, 'id');
select core.ensure_fk('property.locations'::regclass, 'fk_property_locations_building_id', 'building_id', 'property.buildings'::regclass, 'id');
select core.ensure_fk('property.locations'::regclass, 'fk_property_locations_parent_location_id', 'parent_location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('property.locations'::regclass, 'fk_property_locations_location_type_term_id', 'location_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('property.location_aliases'::regclass, 'fk_property_location_aliases_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('property.location_aliases'::regclass, 'fk_property_location_aliases_external_system_id', 'external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('property.rooms'::regclass, 'fk_property_rooms_building_id', 'building_id', 'property.buildings'::regclass, 'id');
select core.ensure_fk('property.rooms'::regclass, 'fk_property_rooms_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('property.rooms'::regclass, 'fk_property_rooms_room_type_term_id', 'room_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('property.rooms'::regclass, 'fk_property_rooms_renumbered_from_room_id', 'renumbered_from_room_id', 'property.rooms'::regclass, 'id');
select core.ensure_fk('property.occupancy_relationships'::regclass, 'fk_property_occupancy_relationships_room_id', 'room_id', 'property.rooms'::regclass, 'id');
select core.ensure_fk('property.occupancy_relationships'::regclass, 'fk_property_occupancy_relationships_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('property.occupancy_relationships'::regclass, 'fk_property_occupancy_relationships_organization_relationship_i', 'organization_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('property.occupancy_relationships'::regclass, 'fk_property_occupancy_relationships_occupancy_type_term_id', 'occupancy_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('property.assets'::regclass, 'fk_property_assets_asset_type_id', 'asset_type_id', 'property.asset_types'::regclass, 'id');
select core.ensure_fk('property.assets'::regclass, 'fk_property_assets_primary_location_id', 'primary_location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('property.assets'::regclass, 'fk_property_assets_predecessor_asset_id', 'predecessor_asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.asset_components'::regclass, 'fk_property_asset_components_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.asset_components'::regclass, 'fk_property_asset_components_parent_component_id', 'parent_component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('property.asset_components'::regclass, 'fk_property_asset_components_asset_type_id', 'asset_type_id', 'property.asset_types'::regclass, 'id');
select core.ensure_fk('property.asset_components'::regclass, 'fk_property_asset_components_predecessor_component_id', 'predecessor_component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('property.asset_relationships'::regclass, 'fk_property_asset_relationships_from_asset_id', 'from_asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.asset_relationships'::regclass, 'fk_property_asset_relationships_from_component_id', 'from_component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('property.asset_relationships'::regclass, 'fk_property_asset_relationships_to_asset_id', 'to_asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.asset_relationships'::regclass, 'fk_property_asset_relationships_to_component_id', 'to_component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('property.asset_relationships'::regclass, 'fk_property_asset_relationships_relationship_type_term_id', 'relationship_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('property.asset_identifiers'::regclass, 'fk_property_asset_identifiers_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.asset_identifiers'::regclass, 'fk_property_asset_identifiers_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('property.asset_identifiers'::regclass, 'fk_property_asset_identifiers_external_system_id', 'external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('property.maintenance_plans'::regclass, 'fk_property_maintenance_plans_operation_type_term_id', 'operation_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('property.maintenance_plan_assets'::regclass, 'fk_property_maintenance_plan_assets_maintenance_plan_id', 'maintenance_plan_id', 'property.maintenance_plans'::regclass, 'id');
select core.ensure_fk('property.maintenance_plan_assets'::regclass, 'fk_property_maintenance_plan_assets_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('property.maintenance_plan_assets'::regclass, 'fk_property_maintenance_plan_assets_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_versions'::regclass, 'fk_taxonomy_taxonomy_versions_taxonomy_id', 'taxonomy_id', 'taxonomy.taxonomies'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_versions'::regclass, 'fk_taxonomy_taxonomy_versions_supersedes_version_id', 'supersedes_version_id', 'taxonomy.taxonomy_versions'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_terms'::regclass, 'fk_taxonomy_taxonomy_terms_taxonomy_id', 'taxonomy_id', 'taxonomy.taxonomies'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_terms'::regclass, 'fk_taxonomy_taxonomy_terms_introduced_version_id', 'introduced_version_id', 'taxonomy.taxonomy_versions'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_terms'::regclass, 'fk_taxonomy_taxonomy_terms_deprecated_version_id', 'deprecated_version_id', 'taxonomy.taxonomy_versions'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_term_relationships'::regclass, 'fk_taxonomy_taxonomy_term_relationships_from_term_id', 'from_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('taxonomy.taxonomy_term_relationships'::regclass, 'fk_taxonomy_taxonomy_term_relationships_to_term_id', 'to_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('intake.cases'::regclass, 'fk_intake_cases_report_id', 'report_id', 'intake.reports'::regclass, 'id');
select core.ensure_fk('intake.case_party_relationships'::regclass, 'fk_intake_case_party_relationships_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('intake.case_party_relationships'::regclass, 'fk_intake_case_party_relationships_organization_relationship_id', 'organization_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('intake.case_party_relationships'::regclass, 'fk_intake_case_party_relationships_party_role_term_id', 'party_role_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_room_id', 'room_id', 'property.rooms'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_taxonomy_term_id', 'taxonomy_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('intake.case_context_assertions'::regclass, 'fk_intake_case_context_assertions_supersedes_id', 'supersedes_id', 'intake.case_context_assertions'::regclass, 'id');
select core.ensure_fk('intake.case_communications'::regclass, 'fk_intake_case_communications_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('intake.case_communications'::regclass, 'fk_intake_case_communications_case_party_relationship_id', 'case_party_relationship_id', 'intake.case_party_relationships'::regclass, 'id');
select core.ensure_fk('intake.case_reopens'::regclass, 'fk_intake_case_reopens_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('intake.case_reopens'::regclass, 'fk_intake_case_reopens_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('intake.case_reopens'::regclass, 'fk_intake_case_reopens_new_evidence_item_id', 'new_evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('intake.case_transfers'::regclass, 'fk_intake_case_transfers_source_case_id', 'source_case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('intake.case_transfers'::regclass, 'fk_intake_case_transfers_source_juristic_person_id', 'source_juristic_person_id', 'org.juristic_persons'::regclass, 'id');
select core.ensure_fk('intake.case_transfers'::regclass, 'fk_intake_case_transfers_destination_juristic_person_id', 'destination_juristic_person_id', 'org.juristic_persons'::regclass, 'id');
select core.ensure_fk('intake.case_transfers'::regclass, 'fk_intake_case_transfers_destination_case_id', 'destination_case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('investigation.investigations'::regclass, 'fk_investigation_investigations_initiating_case_id', 'initiating_case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('investigation.investigations'::regclass, 'fk_investigation_investigations_responsibility_assignment_id', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('investigation.investigations'::regclass, 'fk_investigation_investigations_workflow_instance_id', 'workflow_instance_id', 'workflow.workflow_instances'::regclass, 'id');
select core.ensure_fk('investigation.investigation_cases'::regclass, 'fk_investigation_investigation_cases_investigation_id', 'investigation_id', 'investigation.investigations'::regclass, 'id');
select core.ensure_fk('investigation.investigation_cases'::regclass, 'fk_investigation_investigation_cases_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_investigation_id', 'investigation_id', 'investigation.investigations'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_observer_relationship_id', 'observer_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('investigation.observations'::regclass, 'fk_investigation_observations_correction_of_observation_id', 'correction_of_observation_id', 'investigation.observations'::regclass, 'id');
select core.ensure_fk('investigation.hypotheses'::regclass, 'fk_investigation_hypotheses_investigation_id', 'investigation_id', 'investigation.investigations'::regclass, 'id');
select core.ensure_fk('investigation.hypotheses'::regclass, 'fk_investigation_hypotheses_author_person_id', 'author_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('investigation.hypotheses'::regclass, 'fk_investigation_hypotheses_supersedes_hypothesis_id', 'supersedes_hypothesis_id', 'investigation.hypotheses'::regclass, 'id');
select core.ensure_fk('investigation.hypothesis_evidence_links'::regclass, 'fk_investigation_hypothesis_evidence_links_hypothesis_id', 'hypothesis_id', 'investigation.hypotheses'::regclass, 'id');
select core.ensure_fk('investigation.hypothesis_evidence_links'::regclass, 'fk_investigation_hypothesis_evidence_links_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('investigation.understanding_assessments'::regclass, 'fk_investigation_understanding_assessments_investigation_id', 'investigation_id', 'investigation.investigations'::regclass, 'id');
select core.ensure_fk('investigation.understanding_assessments'::regclass, 'fk_investigation_understanding_assessments_supersedes_assessmen', 'supersedes_assessment_id', 'investigation.understanding_assessments'::regclass, 'id');
select core.ensure_fk('investigation.assessment_evidence_links'::regclass, 'fk_investigation_assessment_evidence_links_assessment_id', 'assessment_id', 'investigation.understanding_assessments'::regclass, 'id');
select core.ensure_fk('investigation.assessment_evidence_links'::regclass, 'fk_investigation_assessment_evidence_links_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('incident.incidents'::regclass, 'fk_incident_incidents_verification_decision_id', 'verification_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('incident.incidents'::regclass, 'fk_incident_incidents_verification_assessment_id', 'verification_assessment_id', 'investigation.understanding_assessments'::regclass, 'id');
select core.ensure_fk('incident.case_incident_associations'::regclass, 'fk_incident_case_incident_associations_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('incident.case_incident_associations'::regclass, 'fk_incident_case_incident_associations_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('incident.case_incident_associations'::regclass, 'fk_incident_case_incident_associations_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('incident.case_incident_associations'::regclass, 'fk_incident_case_incident_associations_mandate_id', 'mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('incident.case_incident_associations'::regclass, 'fk_incident_case_incident_associations_assessment_id', 'assessment_id', 'investigation.understanding_assessments'::regclass, 'id');
select core.ensure_fk('incident.incident_assets'::regclass, 'fk_incident_incident_assets_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('incident.incident_assets'::regclass, 'fk_incident_incident_assets_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('incident.incident_assets'::regclass, 'fk_incident_incident_assets_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('incident.incident_assets'::regclass, 'fk_incident_incident_assets_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('incident.incident_reopens'::regclass, 'fk_incident_incident_reopens_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('incident.incident_reopens'::regclass, 'fk_incident_incident_reopens_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('incident.incident_classifications'::regclass, 'fk_incident_incident_classifications_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('incident.incident_classifications'::regclass, 'fk_incident_incident_classifications_taxonomy_term_id', 'taxonomy_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('incident.incident_classifications'::regclass, 'fk_incident_incident_classifications_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('work.operations'::regclass, 'fk_work_operations_operation_type_term_id', 'operation_type_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('work.operations'::regclass, 'fk_work_operations_responsibility_assignment_id', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('work.operations'::regclass, 'fk_work_operations_workflow_instance_id', 'workflow_instance_id', 'workflow.workflow_instances'::regclass, 'id');
select core.ensure_fk('work.incident_operations'::regclass, 'fk_work_incident_operations_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('work.incident_operations'::regclass, 'fk_work_incident_operations_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.maintenance_plan_operations'::regclass, 'fk_work_maintenance_plan_operations_maintenance_plan_id', 'maintenance_plan_id', 'property.maintenance_plans'::regclass, 'id');
select core.ensure_fk('work.maintenance_plan_operations'::regclass, 'fk_work_maintenance_plan_operations_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.operation_assets'::regclass, 'fk_work_operation_assets_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.operation_assets'::regclass, 'fk_work_operation_assets_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('work.operation_assets'::regclass, 'fk_work_operation_assets_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('work.operation_assets'::regclass, 'fk_work_operation_assets_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('work.work_steps'::regclass, 'fk_work_work_steps_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.work_steps'::regclass, 'fk_work_work_steps_parent_step_id', 'parent_step_id', 'work.work_steps'::regclass, 'id');
select core.ensure_fk('work.commitments'::regclass, 'fk_work_commitments_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.commitments'::regclass, 'fk_work_commitments_work_step_id', 'work_step_id', 'work.work_steps'::regclass, 'id');
select core.ensure_fk('work.commitments'::regclass, 'fk_work_commitments_offered_by_person_id', 'offered_by_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('work.commitments'::regclass, 'fk_work_commitments_accepted_by_relationship_id', 'accepted_by_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('work.commitments'::regclass, 'fk_work_commitments_replaces_commitment_id', 'replaces_commitment_id', 'work.commitments'::regclass, 'id');
select core.ensure_fk('work.operation_interruptions'::regclass, 'fk_work_operation_interruptions_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.operation_interruptions'::regclass, 'fk_work_operation_interruptions_commitment_id', 'commitment_id', 'work.commitments'::regclass, 'id');
select core.ensure_fk('work.operation_interruptions'::regclass, 'fk_work_operation_interruptions_interrupting_incident_id', 'interrupting_incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('work.operation_interruptions'::regclass, 'fk_work_operation_interruptions_interrupting_operation_id', 'interrupting_operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.verification_records'::regclass, 'fk_work_verification_records_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.verification_records'::regclass, 'fk_work_verification_records_verifier_relationship_id', 'verifier_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('work.verification_records'::regclass, 'fk_work_verification_records_verifier_role_assignment_id', 'verifier_role_assignment_id', 'org.role_assignments'::regclass, 'id');
select core.ensure_fk('work.verification_records'::regclass, 'fk_work_verification_records_evidence_package_version_id', 'evidence_package_version_id', 'evidence.evidence_package_versions'::regclass, 'id');
select core.ensure_fk('work.verification_records'::regclass, 'fk_work_verification_records_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('work.priority_decisions'::regclass, 'fk_work_priority_decisions_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('work.priority_decisions'::regclass, 'fk_work_priority_decisions_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('work.priority_decisions'::regclass, 'fk_work_priority_decisions_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('work.priority_decisions'::regclass, 'fk_work_priority_decisions_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.priority_decisions'::regclass, 'fk_work_priority_decisions_priority_term_id', 'priority_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('work.execution_sequence_entries'::regclass, 'fk_work_execution_sequence_entries_technician_relationship_id', 'technician_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('work.execution_sequence_entries'::regclass, 'fk_work_execution_sequence_entries_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.execution_sequence_entries'::regclass, 'fk_work_execution_sequence_entries_commitment_id', 'commitment_id', 'work.commitments'::regclass, 'id');
select core.ensure_fk('work.execution_sequence_entries'::regclass, 'fk_work_execution_sequence_entries_previous_entry_id', 'previous_entry_id', 'work.execution_sequence_entries'::regclass, 'id');
select core.ensure_fk('work.sla_policies'::regclass, 'fk_work_sla_policies_owner_responsibility_id', 'owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('work.sla_policy_versions'::regclass, 'fk_work_sla_policy_versions_sla_policy_id', 'sla_policy_id', 'work.sla_policies'::regclass, 'id');
select core.ensure_fk('work.sla_policy_versions'::regclass, 'fk_work_sla_policy_versions_service_class_term_id', 'service_class_term_id', 'taxonomy.taxonomy_terms'::regclass, 'id');
select core.ensure_fk('work.sla_policy_versions'::regclass, 'fk_work_sla_policy_versions_supersedes_version_id', 'supersedes_version_id', 'work.sla_policy_versions'::regclass, 'id');
select core.ensure_fk('work.sla_applications'::regclass, 'fk_work_sla_applications_sla_policy_version_id', 'sla_policy_version_id', 'work.sla_policy_versions'::regclass, 'id');
select core.ensure_fk('work.sla_applications'::regclass, 'fk_work_sla_applications_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('work.sla_applications'::regclass, 'fk_work_sla_applications_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('work.sla_applications'::regclass, 'fk_work_sla_applications_classification_decision_id', 'classification_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('work.sla_clock_events'::regclass, 'fk_work_sla_clock_events_sla_application_id', 'sla_application_id', 'work.sla_applications'::regclass, 'id');
select core.ensure_fk('evidence.upload_attachments'::regclass, 'fk_evidence_upload_attachments_uploader_person_id', 'uploader_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('evidence.upload_attachments'::regclass, 'fk_evidence_upload_attachments_promoted_evidence_item_id', 'promoted_evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_items'::regclass, 'fk_evidence_evidence_items_original_attachment_id', 'original_attachment_id', 'evidence.upload_attachments'::regclass, 'id');
select core.ensure_fk('evidence.evidence_items'::regclass, 'fk_evidence_evidence_items_source_person_id', 'source_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('evidence.evidence_items'::regclass, 'fk_evidence_evidence_items_custodian_relationship_id', 'custodian_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('evidence.evidence_items'::regclass, 'fk_evidence_evidence_items_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('evidence.evidence_renditions'::regclass, 'fk_evidence_evidence_renditions_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_renditions'::regclass, 'fk_evidence_evidence_renditions_parent_rendition_id', 'parent_rendition_id', 'evidence.evidence_renditions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_links'::regclass, 'fk_evidence_evidence_links_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_links'::regclass, 'fk_evidence_evidence_links_rendition_id', 'rendition_id', 'evidence.evidence_renditions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_packages'::regclass, 'fk_evidence_evidence_packages_owner_relationship_id', 'owner_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('evidence.evidence_package_versions'::regclass, 'fk_evidence_evidence_package_versions_evidence_package_id', 'evidence_package_id', 'evidence.evidence_packages'::regclass, 'id');
select core.ensure_fk('evidence.evidence_package_versions'::regclass, 'fk_evidence_evidence_package_versions_compiler_person_id', 'compiler_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('evidence.evidence_package_members'::regclass, 'fk_evidence_evidence_package_members_package_version_id', 'package_version_id', 'evidence.evidence_package_versions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_package_members'::regclass, 'fk_evidence_evidence_package_members_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_package_members'::regclass, 'fk_evidence_evidence_package_members_rendition_id', 'rendition_id', 'evidence.evidence_renditions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_custody_events'::regclass, 'fk_evidence_evidence_custody_events_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_custody_events'::regclass, 'fk_evidence_evidence_custody_events_package_version_id', 'package_version_id', 'evidence.evidence_package_versions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_integrity_checks'::regclass, 'fk_evidence_evidence_integrity_checks_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_integrity_checks'::regclass, 'fk_evidence_evidence_integrity_checks_rendition_id', 'rendition_id', 'evidence.evidence_renditions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_dispositions'::regclass, 'fk_evidence_evidence_dispositions_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('evidence.evidence_dispositions'::regclass, 'fk_evidence_evidence_dispositions_rendition_id', 'rendition_id', 'evidence.evidence_renditions'::regclass, 'id');
select core.ensure_fk('evidence.evidence_dispositions'::regclass, 'fk_evidence_evidence_dispositions_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('decision.decision_records'::regclass, 'fk_decision_decision_records_responsible_person_id', 'responsible_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('decision.decision_records'::regclass, 'fk_decision_decision_records_acting_role_assignment_id', 'acting_role_assignment_id', 'org.role_assignments'::regclass, 'id');
select core.ensure_fk('decision.decision_records'::regclass, 'fk_decision_decision_records_mandate_id', 'mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('decision.decision_evidence_links'::regclass, 'fk_decision_decision_evidence_links_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('decision.decision_evidence_links'::regclass, 'fk_decision_decision_evidence_links_evidence_item_id', 'evidence_item_id', 'evidence.evidence_items'::regclass, 'id');
select core.ensure_fk('decision.decision_assessment_links'::regclass, 'fk_decision_decision_assessment_links_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('decision.decision_assessment_links'::regclass, 'fk_decision_decision_assessment_links_assessment_id', 'assessment_id', 'investigation.understanding_assessments'::regclass, 'id');
select core.ensure_fk('decision.decision_relationships'::regclass, 'fk_decision_decision_relationships_from_decision_id', 'from_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('decision.decision_relationships'::regclass, 'fk_decision_decision_relationships_to_decision_id', 'to_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('decision.recommendations'::regclass, 'fk_decision_recommendations_author_person_id', 'author_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('decision.recommendations'::regclass, 'fk_decision_recommendations_author_service_principal_id', 'author_service_principal_id', 'iam.service_principals'::regclass, 'id');
select core.ensure_fk('decision.recommendation_sources'::regclass, 'fk_decision_recommendation_sources_recommendation_id', 'recommendation_id', 'decision.recommendations'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_records'::regclass, 'fk_knowledge_knowledge_records_steward_responsibility_id', 'steward_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_versions'::regclass, 'fk_knowledge_knowledge_versions_knowledge_record_id', 'knowledge_record_id', 'knowledge.knowledge_records'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_versions'::regclass, 'fk_knowledge_knowledge_versions_author_person_id', 'author_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_versions'::regclass, 'fk_knowledge_knowledge_versions_supersedes_version_id', 'supersedes_version_id', 'knowledge.knowledge_versions'::regclass, 'id');
select core.ensure_fk('knowledge.validity_contexts'::regclass, 'fk_knowledge_validity_contexts_knowledge_version_id', 'knowledge_version_id', 'knowledge.knowledge_versions'::regclass, 'id');
select core.ensure_fk('knowledge.validity_contexts'::regclass, 'fk_knowledge_validity_contexts_asset_id', 'asset_id', 'property.assets'::regclass, 'id');
select core.ensure_fk('knowledge.validity_contexts'::regclass, 'fk_knowledge_validity_contexts_component_id', 'component_id', 'property.asset_components'::regclass, 'id');
select core.ensure_fk('knowledge.validity_contexts'::regclass, 'fk_knowledge_validity_contexts_asset_type_id', 'asset_type_id', 'property.asset_types'::regclass, 'id');
select core.ensure_fk('knowledge.validity_contexts'::regclass, 'fk_knowledge_validity_contexts_location_id', 'location_id', 'property.locations'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_sources'::regclass, 'fk_knowledge_knowledge_sources_knowledge_version_id', 'knowledge_version_id', 'knowledge.knowledge_versions'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_reviews'::regclass, 'fk_knowledge_knowledge_reviews_knowledge_version_id', 'knowledge_version_id', 'knowledge.knowledge_versions'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_reviews'::regclass, 'fk_knowledge_knowledge_reviews_reviewer_person_id', 'reviewer_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_reviews'::regclass, 'fk_knowledge_knowledge_reviews_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_usage_outcomes'::regclass, 'fk_knowledge_knowledge_usage_outcomes_knowledge_version_id', 'knowledge_version_id', 'knowledge.knowledge_versions'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_usage_outcomes'::regclass, 'fk_knowledge_knowledge_usage_outcomes_case_id', 'case_id', 'intake.cases'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_usage_outcomes'::regclass, 'fk_knowledge_knowledge_usage_outcomes_incident_id', 'incident_id', 'incident.incidents'::regclass, 'id');
select core.ensure_fk('knowledge.knowledge_usage_outcomes'::regclass, 'fk_knowledge_knowledge_usage_outcomes_operation_id', 'operation_id', 'work.operations'::regclass, 'id');
select core.ensure_fk('workflow.workflow_definitions'::regclass, 'fk_workflow_workflow_definitions_business_owner_responsibility_', 'business_owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('workflow.workflow_versions'::regclass, 'fk_workflow_workflow_versions_workflow_definition_id', 'workflow_definition_id', 'workflow.workflow_definitions'::regclass, 'id');
select core.ensure_fk('workflow.workflow_versions'::regclass, 'fk_workflow_workflow_versions_supersedes_version_id', 'supersedes_version_id', 'workflow.workflow_versions'::regclass, 'id');
select core.ensure_fk('workflow.workflow_instances'::regclass, 'fk_workflow_workflow_instances_workflow_version_id', 'workflow_version_id', 'workflow.workflow_versions'::regclass, 'id');
select core.ensure_fk('workflow.workflow_instances'::regclass, 'fk_workflow_workflow_instances_responsibility_assignment_id', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('workflow.workflow_instances'::regclass, 'fk_workflow_workflow_instances_previous_instance_id', 'previous_instance_id', 'workflow.workflow_instances'::regclass, 'id');
select core.ensure_fk('workflow.workflow_subjects'::regclass, 'fk_workflow_workflow_subjects_workflow_instance_id', 'workflow_instance_id', 'workflow.workflow_instances'::regclass, 'id');
select core.ensure_fk('workflow.state_transitions'::regclass, 'fk_workflow_state_transitions_workflow_instance_id', 'workflow_instance_id', 'workflow.workflow_instances'::regclass, 'id');
select core.ensure_fk('workflow.state_transitions'::regclass, 'fk_workflow_state_transitions_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('workflow.state_transitions'::regclass, 'fk_workflow_state_transitions_mandate_id', 'mandate_id', 'org.mandates'::regclass, 'id');
select core.ensure_fk('notification.notification_intents'::regclass, 'fk_notification_notification_intents_source_event_id', 'source_event_id', 'audit.domain_events'::regclass, 'id');
select core.ensure_fk('notification.notification_intents'::regclass, 'fk_notification_notification_intents_responsibility_assignment_', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('notification.notification_audiences'::regclass, 'fk_notification_notification_audiences_notification_intent_id', 'notification_intent_id', 'notification.notification_intents'::regclass, 'id');
select core.ensure_fk('notification.notification_audiences'::regclass, 'fk_notification_notification_audiences_case_party_relationship_', 'case_party_relationship_id', 'intake.case_party_relationships'::regclass, 'id');
select core.ensure_fk('notification.notification_audiences'::regclass, 'fk_notification_notification_audiences_organization_relationshi', 'organization_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('notification.message_renditions'::regclass, 'fk_notification_message_renditions_notification_intent_id', 'notification_intent_id', 'notification.notification_intents'::regclass, 'id');
select core.ensure_fk('notification.message_renditions'::regclass, 'fk_notification_message_renditions_audience_id', 'audience_id', 'notification.notification_audiences'::regclass, 'id');
select core.ensure_fk('notification.message_renditions'::regclass, 'fk_notification_message_renditions_corrects_rendition_id', 'corrects_rendition_id', 'notification.message_renditions'::regclass, 'id');
select core.ensure_fk('notification.delivery_attempts'::regclass, 'fk_notification_delivery_attempts_audience_id', 'audience_id', 'notification.notification_audiences'::regclass, 'id');
select core.ensure_fk('notification.delivery_attempts'::regclass, 'fk_notification_delivery_attempts_rendition_id', 'rendition_id', 'notification.message_renditions'::regclass, 'id');
select core.ensure_fk('notification.delivery_attempts'::regclass, 'fk_notification_delivery_attempts_provider_external_system_id', 'provider_external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('notification.notification_acknowledgements'::regclass, 'fk_notification_notification_acknowledgements_audience_id', 'audience_id', 'notification.notification_audiences'::regclass, 'id');
select core.ensure_fk('notification.notification_acknowledgements'::regclass, 'fk_notification_notification_acknowledgements_delivery_attempt_', 'delivery_attempt_id', 'notification.delivery_attempts'::regclass, 'id');
select core.ensure_fk('notification.notification_acknowledgements'::regclass, 'fk_notification_notification_acknowledgements_acknowledging_rel', 'acknowledging_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('governance.compliance_deadlines'::regclass, 'fk_governance_compliance_deadlines_responsibility_assignment_id', 'responsibility_assignment_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('governance.compliance_deadlines'::regclass, 'fk_governance_compliance_deadlines_evidence_package_version_id', 'completion_evidence_package_version_id', 'evidence.evidence_package_versions'::regclass, 'id');
select core.ensure_fk('governance.compliance_deadlines'::regclass, 'fk_governance_compliance_deadlines_supersedes_deadline_id', 'supersedes_deadline_id', 'governance.compliance_deadlines'::regclass, 'id');
select core.ensure_fk('governance.policies'::regclass, 'fk_governance_policies_owner_responsibility_id', 'owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('governance.policy_versions'::regclass, 'fk_governance_policy_versions_policy_id', 'policy_id', 'governance.policies'::regclass, 'id');
select core.ensure_fk('governance.policy_versions'::regclass, 'fk_governance_policy_versions_supersedes_version_id', 'supersedes_version_id', 'governance.policy_versions'::regclass, 'id');
select core.ensure_fk('governance.committee_memberships'::regclass, 'fk_governance_committee_memberships_committee_id', 'committee_id', 'governance.committees'::regclass, 'id');
select core.ensure_fk('governance.committee_memberships'::regclass, 'fk_governance_committee_memberships_person_id', 'person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('governance.committee_memberships'::regclass, 'fk_governance_committee_memberships_organization_relationship_i', 'organization_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('governance.meetings'::regclass, 'fk_governance_meetings_committee_id', 'committee_id', 'governance.committees'::regclass, 'id');
select core.ensure_fk('governance.meetings'::regclass, 'fk_governance_meetings_chair_membership_id', 'chair_membership_id', 'governance.committee_memberships'::regclass, 'id');
select core.ensure_fk('governance.meetings'::regclass, 'fk_governance_meetings_secretary_membership_id', 'secretary_membership_id', 'governance.committee_memberships'::regclass, 'id');
select core.ensure_fk('governance.resolutions'::regclass, 'fk_governance_resolutions_meeting_id', 'meeting_id', 'governance.meetings'::regclass, 'id');
select core.ensure_fk('governance.resolutions'::regclass, 'fk_governance_resolutions_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('governance.resolution_votes'::regclass, 'fk_governance_resolution_votes_resolution_id', 'resolution_id', 'governance.resolutions'::regclass, 'id');
select core.ensure_fk('governance.resolution_votes'::regclass, 'fk_governance_resolution_votes_committee_membership_id', 'committee_membership_id', 'governance.committee_memberships'::regclass, 'id');
select core.ensure_fk('governance.contracts'::regclass, 'fk_governance_contracts_vendor_organization_id', 'vendor_organization_id', 'org.external_organizations'::regclass, 'id');
select core.ensure_fk('governance.contracts'::regclass, 'fk_governance_contracts_owner_responsibility_id', 'owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('governance.contract_versions'::regclass, 'fk_governance_contract_versions_contract_id', 'contract_id', 'governance.contracts'::regclass, 'id');
select core.ensure_fk('governance.contract_versions'::regclass, 'fk_governance_contract_versions_approved_by_decision_id', 'approved_by_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('governance.contract_versions'::regclass, 'fk_governance_contract_versions_supersedes_version_id', 'supersedes_version_id', 'governance.contract_versions'::regclass, 'id');
select core.ensure_fk('governance.contract_obligations'::regclass, 'fk_governance_contract_obligations_contract_version_id', 'contract_version_id', 'governance.contract_versions'::regclass, 'id');
select core.ensure_fk('governance.contract_obligations'::regclass, 'fk_governance_contract_obligations_sla_policy_version_id', 'sla_policy_version_id', 'work.sla_policy_versions'::regclass, 'id');
select core.ensure_fk('governance.risks'::regclass, 'fk_governance_risks_owner_responsibility_id', 'owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('governance.risks'::regclass, 'fk_governance_risks_acceptance_decision_id', 'acceptance_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('governance.risk_links'::regclass, 'fk_governance_risk_links_risk_id', 'risk_id', 'governance.risks'::regclass, 'id');
select core.ensure_fk('ai.ai_use_cases'::regclass, 'fk_ai_ai_use_cases_business_owner_responsibility_id', 'business_owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('ai.ai_use_cases'::regclass, 'fk_ai_ai_use_cases_risk_owner_responsibility_id', 'risk_owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('ai.ai_use_cases'::regclass, 'fk_ai_ai_use_cases_technical_steward_relationship_id', 'technical_steward_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('ai.ai_use_cases'::regclass, 'fk_ai_ai_use_cases_approved_by_decision_id', 'approved_by_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('ai.ai_interactions'::regclass, 'fk_ai_ai_interactions_ai_use_case_id', 'ai_use_case_id', 'ai.ai_use_cases'::regclass, 'id');
select core.ensure_fk('ai.ai_interactions'::regclass, 'fk_ai_ai_interactions_requesting_person_id', 'requesting_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('ai.ai_interactions'::regclass, 'fk_ai_ai_interactions_provider_external_system_id', 'provider_external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('ai.ai_recommendations'::regclass, 'fk_ai_ai_recommendations_ai_interaction_id', 'ai_interaction_id', 'ai.ai_interactions'::regclass, 'id');
select core.ensure_fk('ai.ai_recommendations'::regclass, 'fk_ai_ai_recommendations_recommendation_id', 'recommendation_id', 'decision.recommendations'::regclass, 'id');
select core.ensure_fk('ai.ai_recommendation_sources'::regclass, 'fk_ai_ai_recommendation_sources_ai_recommendation_id', 'ai_recommendation_id', 'ai.ai_recommendations'::regclass, 'id');
select core.ensure_fk('ai.ai_reviews'::regclass, 'fk_ai_ai_reviews_ai_interaction_id', 'ai_interaction_id', 'ai.ai_interactions'::regclass, 'id');
select core.ensure_fk('ai.ai_reviews'::regclass, 'fk_ai_ai_reviews_ai_recommendation_id', 'ai_recommendation_id', 'ai.ai_recommendations'::regclass, 'id');
select core.ensure_fk('ai.ai_reviews'::regclass, 'fk_ai_ai_reviews_reviewer_person_id', 'reviewer_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('ai.ai_reviews'::regclass, 'fk_ai_ai_reviews_adoption_decision_id', 'adoption_decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('audit.domain_events'::regclass, 'fk_audit_domain_events_acting_role_assignment_id', 'acting_role_assignment_id', 'org.role_assignments'::regclass, 'id');
select core.ensure_fk('audit.outbox_messages'::regclass, 'fk_audit_outbox_messages_domain_event_id', 'domain_event_id', 'audit.domain_events'::regclass, 'id');
select core.ensure_fk('audit.audit_entries'::regclass, 'fk_audit_audit_entries_access_decision_id', 'access_decision_id', 'iam.access_decisions'::regclass, 'id');
select core.ensure_fk('analytics.kpi_definitions'::regclass, 'fk_analytics_kpi_definitions_owner_responsibility_id', 'owner_responsibility_id', 'org.responsibility_assignments'::regclass, 'id');
select core.ensure_fk('analytics.kpi_versions'::regclass, 'fk_analytics_kpi_versions_kpi_definition_id', 'kpi_definition_id', 'analytics.kpi_definitions'::regclass, 'id');
select core.ensure_fk('analytics.kpi_versions'::regclass, 'fk_analytics_kpi_versions_supersedes_version_id', 'supersedes_version_id', 'analytics.kpi_versions'::regclass, 'id');
select core.ensure_fk('analytics.kpi_observations'::regclass, 'fk_analytics_kpi_observations_kpi_version_id', 'kpi_version_id', 'analytics.kpi_versions'::regclass, 'id');
select core.ensure_fk('analytics.kpi_observations'::regclass, 'fk_analytics_kpi_observations_source_manifest_id', 'source_manifest_id', 'memory.memory_manifests'::regclass, 'id');
select core.ensure_fk('analytics.report_snapshots'::regclass, 'fk_analytics_report_snapshots_source_manifest_id', 'source_manifest_id', 'memory.memory_manifests'::regclass, 'id');
select core.ensure_fk('analytics.report_snapshots'::regclass, 'fk_analytics_report_snapshots_published_by_person_id', 'published_by_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('memory.memory_manifests'::regclass, 'fk_memory_memory_manifests_custodian_relationship_id', 'custodian_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('memory.memory_manifest_items'::regclass, 'fk_memory_memory_manifest_items_memory_manifest_id', 'memory_manifest_id', 'memory.memory_manifests'::regclass, 'id');
select core.ensure_fk('memory.archive_batches'::regclass, 'fk_memory_archive_batches_decision_id', 'decision_id', 'decision.decision_records'::regclass, 'id');
select core.ensure_fk('memory.archive_batches'::regclass, 'fk_memory_archive_batches_custodian_relationship_id', 'custodian_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('memory.archive_batch_items'::regclass, 'fk_memory_archive_batch_items_archive_batch_id', 'archive_batch_id', 'memory.archive_batches'::regclass, 'id');
select core.ensure_fk('integration.external_systems'::regclass, 'fk_integration_external_systems_owner_relationship_id', 'owner_relationship_id', 'org.organization_relationships'::regclass, 'id');
select core.ensure_fk('integration.external_systems'::regclass, 'fk_integration_external_systems_contract_id', 'contract_id', 'governance.contracts'::regclass, 'id');
select core.ensure_fk('integration.external_identifiers'::regclass, 'fk_integration_external_identifiers_external_system_id', 'external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('integration.inbound_messages'::regclass, 'fk_integration_inbound_messages_external_system_id', 'external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('integration.sync_conflicts'::regclass, 'fk_integration_sync_conflicts_external_system_id', 'external_system_id', 'integration.external_systems'::regclass, 'id');
select core.ensure_fk('integration.sync_conflicts'::regclass, 'fk_integration_sync_conflicts_inbound_message_id', 'inbound_message_id', 'integration.inbound_messages'::regclass, 'id');
select core.ensure_fk('integration.sync_conflicts'::regclass, 'fk_integration_sync_conflicts_resolved_by_person_id', 'resolved_by_person_id', 'org.people'::regclass, 'id');
select core.ensure_fk('integration.sync_conflicts'::regclass, 'fk_integration_sync_conflicts_resolution_decision_id', 'resolution_decision_id', 'decision.decision_records'::regclass, 'id');

-- Universal business key and temporal checks.
do $$
declare r record; c_name text;
begin
  for r in
    select schemaname, tablename, format('%I.%I', schemaname, tablename)::regclass as rel
    from pg_tables
    where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
  loop
    c_name := left('uq_' || r.schemaname || '_' || r.tablename || '_business_key', 63);
    if not exists (select 1 from pg_constraint where conrelid = r.rel and conname = c_name) then
      if r.schemaname = 'org' and r.tablename = 'juristic_persons' then
        execute format('alter table %s add constraint %I unique (business_key)', r.rel, c_name);
      else
        execute format('alter table %s add constraint %I unique (juristic_person_id, business_key)', r.rel, c_name);
      end if;
    end if;
    c_name := left('ck_' || r.schemaname || '_' || r.tablename || '_row_version', 63);
    if not exists (select 1 from pg_constraint where conrelid = r.rel and conname = c_name) then
      execute format('alter table %s add constraint %I check (row_version > 0)', r.rel, c_name);
    end if;
    c_name := left('ck_' || r.schemaname || '_' || r.tablename || '_valid_period', 63);
    if not exists (select 1 from pg_constraint where conrelid = r.rel and conname = c_name) then
      execute format('alter table %s add constraint %I check (valid_to is null or valid_from is null or valid_to > valid_from)', r.rel, c_name);
    end if;
  end loop;
end $$;

-- Domain-specific cardinality and integrity checks.
do $$ begin
  alter table org.organization_relationships add constraint ck_org_relationship_party_xor check ((person_id is not null)::int + (external_organization_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table org.role_permissions add constraint ck_org_role_permissions_effect check (effect in ('allow','deny'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table org.role_permissions add constraint uq_org_role_permissions_effective unique nulls not distinct (role_definition_id, permission_definition_id, recorded_to);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table notification.announcements add constraint ck_announcement_publication check ((publication_state = 'published' and published_at is not null) or publication_state <> 'published');
exception when duplicate_object then null; end $$;
do $$ begin
  alter table governance.compliance_deadlines add constraint ck_compliance_completion check ((current_state = 'completed' and completed_at is not null) or current_state <> 'completed');
exception when duplicate_object then null; end $$;
do $$ begin
  alter table property.occupancy_relationships add constraint ck_occupancy_place_xor check ((room_id is not null)::int + (location_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table property.asset_relationships add constraint ck_asset_rel_from_one check ((from_asset_id is not null)::int + (from_component_id is not null)::int = 1), add constraint ck_asset_rel_to_one check ((to_asset_id is not null)::int + (to_component_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table property.asset_identifiers add constraint ck_asset_identifier_subject_xor check ((asset_id is not null)::int + (component_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table property.maintenance_plan_assets add constraint ck_plan_asset_subject_xor check ((asset_id is not null)::int + (component_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table intake.cases add constraint uq_cases_report unique (report_id);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table incident.incident_assets add constraint ck_incident_asset_subject check ((asset_id is not null)::int + (component_id is not null)::int + (location_id is not null)::int >= 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table work.operation_assets add constraint ck_operation_asset_subject check ((asset_id is not null)::int + (component_id is not null)::int + (location_id is not null)::int >= 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table work.sla_applications add constraint ck_sla_target_xor check ((case_id is not null)::int + (operation_id is not null)::int = 1);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table evidence.evidence_package_members add constraint ck_package_member_rendition check (rendition_id is null or evidence_item_id is not null);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table decision.recommendations add constraint ck_recommendation_author check ((author_kind = 'person' and author_person_id is not null and author_service_principal_id is null) or (author_kind <> 'person' and author_service_principal_id is not null));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table decision.decision_relationships add constraint ck_decision_relationship_not_self check (from_decision_id <> to_decision_id);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table taxonomy.taxonomy_term_relationships add constraint ck_taxonomy_relationship_not_self check (from_term_id <> to_term_id);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table workflow.workflow_subjects add constraint uq_workflow_primary_subject unique nulls not distinct (workflow_instance_id, is_primary) deferrable initially deferred;
exception when duplicate_object then null; end $$;
do $$ begin
  alter table governance.resolution_votes add constraint uq_resolution_member_vote unique (resolution_id, committee_membership_id);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table audit.outbox_messages add constraint uq_outbox_event_destination unique (domain_event_id, destination);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table integration.inbound_messages add constraint uq_inbound_external_message unique (external_system_id, external_message_id);
exception when duplicate_object then null; end $$;

comment on function core.ensure_fk(regclass,text,text,regclass,text) is 'Internal helper retained for future idempotent migrations; execute is revoked from application roles.';


-- ============================================================================
-- Source: sql/05_indexes.sql
-- ============================================================================

-- O83 Care index architecture.
-- Creates indexes for all foreign keys plus high-value operational, temporal,
-- traceability, RLS, search, and queue access paths.

do $$
declare
  r record;
  v_name text;
  v_cols text;
begin
  for r in
    select c.conrelid,
           n.nspname as schema_name,
           t.relname as table_name,
           c.conname,
           c.conkey
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where c.contype = 'f'
      and n.nspname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
  loop
    select string_agg(quote_ident(a.attname), ', ' order by u.ordinality)
      into v_cols
    from unnest(r.conkey) with ordinality u(attnum, ordinality)
    join pg_attribute a on a.attrelid = r.conrelid and a.attnum = u.attnum;
    v_name := left('ix_' || r.schema_name || '_' || r.table_name || '_' || replace(v_cols, ', ', '_'), 63);
    if not exists (
      select 1
      from pg_index i
      where i.indrelid = r.conrelid
        and i.indisvalid
        and i.indisready
        and i.indpred is null
        and (i.indkey::smallint[])[0:cardinality(r.conkey)-1] @> r.conkey
    ) then
      execute format('create index %I on %I.%I (%s)', v_name, r.schema_name, r.table_name, v_cols);
    end if;
  end loop;
end $$;

-- Effective/current relationship indexes.
create index if not exists ix_org_relationships_current_party on org.organization_relationships (juristic_person_id, person_id, external_organization_id, relationship_type_term_id) where recorded_to is null;
create index if not exists ix_org_roles_current on org.role_assignments (juristic_person_id, organization_relationship_id, role_definition_id) where recorded_to is null;
create index if not exists ix_org_role_permissions_current on org.role_permissions (juristic_person_id, role_definition_id, permission_definition_id) where recorded_to is null and relationship_state = 'effective';
create index if not exists ix_org_mandates_active_scope on org.mandates (juristic_person_id, grantee_relationship_id, scope_type, scope_id, valid_from, valid_to) where lifecycle = 'active' and revoked_at is null;
create index if not exists ix_org_responsibility_current_scope on org.responsibility_assignments (juristic_person_id, scope_type, scope_id, responsible_relationship_id) where recorded_to is null;
create index if not exists ix_property_occupancy_current on property.occupancy_relationships (juristic_person_id, room_id, location_id, organization_relationship_id) where recorded_to is null;
create index if not exists ix_property_locations_current_parent on property.locations (juristic_person_id, parent_location_id, location_type_term_id) where recorded_to is null;
create index if not exists ix_asset_relationships_current_from on property.asset_relationships (juristic_person_id, from_asset_id, from_component_id, relationship_type_term_id) where recorded_to is null;

-- Case, Investigation, Incident, and Operation queues.
create index if not exists ix_cases_opened_state on intake.cases (juristic_person_id, current_state, opened_at desc) where closed_at is null;
create index if not exists ix_case_party_current on intake.case_party_relationships (juristic_person_id, case_id, party_role_term_id, organization_relationship_id) where recorded_to is null;
create index if not exists ix_case_context_current on intake.case_context_assertions (juristic_person_id, case_id, assertion_type) where recorded_to is null;
create index if not exists ix_investigations_active on investigation.investigations (juristic_person_id, current_state, responsibility_assignment_id, opened_at) where concluded_at is null;
create index if not exists ix_assessments_current on investigation.understanding_assessments (juristic_person_id, investigation_id, issued_at desc) where assessment_status in ('issued','published');
create index if not exists ix_incidents_active on incident.incidents (juristic_person_id, current_state, verified_at desc) where closed_at is null;
create index if not exists ix_case_incident_case on incident.case_incident_associations (juristic_person_id, case_id, recorded_from desc);
create index if not exists ix_case_incident_incident on incident.case_incident_associations (juristic_person_id, incident_id, recorded_from desc);
create index if not exists ix_operations_active on work.operations (juristic_person_id, current_state, responsibility_assignment_id, proposed_at) where completed_at is null and cancelled_at is null;
create index if not exists ix_commitments_active_due on work.commitments (juristic_person_id, accepted_by_relationship_id, current_state, due_at) where current_state not in ('fulfilled','released','replaced');
create index if not exists ix_sla_active_due on work.sla_applications (juristic_person_id, current_clock_state, due_at) where satisfied_at is null and breached_at is null;

-- History and traceability.
create index if not exists ix_responsibility_ledger_timeline on org.responsibility_ledger_entries (juristic_person_id, responsibility_assignment_id, occurred_at, recorded_at);
create index if not exists ix_observations_timeline on investigation.observations (juristic_person_id, investigation_id, occurred_at, recorded_at);
create index if not exists ix_state_transitions_aggregate on workflow.state_transitions (juristic_person_id, aggregate_type, aggregate_id, aggregate_version_after);
create index if not exists ix_domain_events_aggregate on audit.domain_events (juristic_person_id, aggregate_type, aggregate_id, aggregate_version);
create index if not exists ix_domain_events_correlation on audit.domain_events (juristic_person_id, correlation_id, occurred_at);
create index if not exists ix_audit_target_time on audit.audit_entries (juristic_person_id, target_type, target_id, occurred_at desc);
create index if not exists ix_audit_principal_time on audit.audit_entries (juristic_person_id, principal_kind, principal_id, occurred_at desc);

-- Evidence, notification, integration, and AI queues.
create unique index if not exists ux_evidence_original_object on evidence.evidence_items (original_storage_bucket, original_storage_object_key);
create index if not exists ix_evidence_digest on evidence.evidence_items (juristic_person_id, content_digest);
create index if not exists ix_evidence_links_target on evidence.evidence_links (juristic_person_id, target_type, target_id, link_role);
create index if not exists ix_evidence_integrity_failures on evidence.evidence_integrity_checks (juristic_person_id, occurred_at desc) where availability_result <> 'available' or observed_digest is distinct from expected_digest;
create index if not exists ix_notification_pending on notification.notification_intents (juristic_person_id, lifecycle, expires_at) where lifecycle in ('active','draft');
create index if not exists ix_announcements_active on notification.announcements (juristic_person_id, published_at desc, expires_at) where publication_state = 'published';
create index if not exists ix_compliance_deadlines_open on governance.compliance_deadlines (juristic_person_id, due_at, current_state) where completed_at is null;
create index if not exists ix_delivery_retry on notification.delivery_attempts (juristic_person_id, result, occurred_at) where result not in ('delivered','suppressed');
create unique index if not exists ux_delivery_idempotency on notification.delivery_attempts (juristic_person_id, idempotency_key);
create index if not exists ix_outbox_pending on audit.outbox_messages (publication_state, next_attempt_at, created_at) where publication_state in ('pending','retry');
create index if not exists ix_inbound_pending on integration.inbound_messages (juristic_person_id, processing_state, recorded_at) where processing_state in ('pending','failed');
create index if not exists ix_sync_conflicts_open on integration.sync_conflicts (juristic_person_id, conflict_state, created_at) where conflict_state = 'open';
create index if not exists ix_ai_reviews_pending on ai.ai_recommendations (juristic_person_id, review_state, generated_at) where review_state = 'pending';

-- Authorized search support. Similarity is advisory only.
create index if not exists ix_people_display_name_trgm on org.people using gin (display_name extensions.gin_trgm_ops);
create index if not exists ix_external_org_name_trgm on org.external_organizations using gin (legal_name extensions.gin_trgm_ops);
create index if not exists ix_location_name_trgm on property.locations using gin (name extensions.gin_trgm_ops);
create index if not exists ix_asset_code_trgm on property.assets using gin (asset_code extensions.gin_trgm_ops);
create index if not exists ix_report_text_trgm on intake.reports using gin (submitted_text extensions.gin_trgm_ops);
create index if not exists ix_knowledge_content_fts on knowledge.knowledge_versions using gin (to_tsvector('simple', content));

comment on index intake.ix_report_text_trgm is 'Advisory Report similarity search; must never automatically merge Cases.';


-- ============================================================================
-- Source: sql/06_views.sql
-- ============================================================================

-- O83 Care security-invoker projections.
-- Views do not own truth and obey underlying RLS policies.

create or replace view api.current_cases
with (security_invoker = true) as
select c.id, c.juristic_person_id, c.case_number, c.report_id, c.current_state,
       c.opened_at, c.resolved_at, c.closed_at, c.current_summary,
       c.current_priority_decision_id, c.row_version
from intake.cases c
where c.lifecycle <> 'archived';
comment on view api.current_cases is 'Current Case projection; immutable Report and transition history remain authoritative.';

create or replace view api.current_incidents
with (security_invoker = true) as
select i.id, i.juristic_person_id, i.incident_number, i.current_state,
       i.current_summary, i.verified_at, i.activated_at,
       i.monitoring_started_at, i.closed_at, i.verification_decision_id,
       i.verification_assessment_id, i.row_version
from incident.incidents i
where i.lifecycle <> 'archived';
comment on view api.current_incidents is 'Current verified Incident projection; suspected events remain Investigations.';

create or replace view api.operation_queue
with (security_invoker = true) as
select o.id, o.juristic_person_id, o.operation_number, o.title, o.current_state,
       o.responsibility_assignment_id, o.proposed_at, o.authorized_at,
       o.started_at, o.completed_at, o.row_version
from work.operations o
where o.cancelled_at is null and o.completed_at is null;
comment on view api.operation_queue is 'Active Operation queue projection; Organizational Priority, SLA, and sequence remain separate records.';

create or replace view api.responsibility_chain
with (security_invoker = true) as
select ra.juristic_person_id, ra.id as responsibility_assignment_id,
       ra.assignment_code, ra.scope_type, ra.scope_id,
       ra.responsible_relationship_id, ra.responsible_role_assignment_id,
       le.id as ledger_entry_id, le.entry_type, le.occurred_at,
       le.recorded_at, le.subject_type, le.subject_id, le.commitment_id,
       le.mandate_id, le.decision_id, le.handover_id, le.state_after
from org.responsibility_assignments ra
left join org.responsibility_ledger_entries le
  on le.responsibility_assignment_id = ra.id
 and le.juristic_person_id = ra.juristic_person_id;
comment on view api.responsibility_chain is 'Rebuildable Responsibility Chain over assignments and immutable ledger entries.';

create or replace view api.decision_evolution
with (security_invoker = true) as
select d.juristic_person_id, d.id as decision_id, d.decision_number,
       d.decision_class, d.question, d.outcome, d.rationale, d.decided_at,
       d.decision_status, r.relationship_type,
       r.to_decision_id as related_decision_id, r.effective_at as relationship_effective_at
from decision.decision_records d
left join decision.decision_relationships r
  on r.from_decision_id = d.id and r.juristic_person_id = d.juristic_person_id;
comment on view api.decision_evolution is 'Decision history and typed evolution edges; previous Decisions remain visible.';

create or replace view api.operational_truth
with (security_invoker = true) as
select distinct on (a.investigation_id)
       a.juristic_person_id, a.investigation_id, a.id as assessment_id,
       a.assessment_number, a.known_summary, a.inferred_summary,
       a.disputed_summary, a.unknown_summary, a.confidence,
       a.recommendation_summary, a.issued_at
from investigation.understanding_assessments a
where a.assessment_status in ('issued','published')
order by a.investigation_id, a.issued_at desc nulls last, a.created_at desc;
comment on view api.operational_truth is 'Best current Understanding Assessment; never absolute truth or a mutable fact.';

create or replace view api.current_knowledge
with (security_invoker = true) as
select kr.id, kr.juristic_person_id, kr.knowledge_number, kr.knowledge_type,
       kr.title, kv.id as knowledge_version_id, kv.version_number,
       kv.content, kv.confidence, kv.assumptions, kv.limitations,
       kv.last_verified_at
from knowledge.knowledge_records kr
join knowledge.knowledge_versions kv on kv.id = kr.current_published_version_id
where kv.status = 'published';
comment on view api.current_knowledge is 'Published Knowledge projection; Validity Context must be checked before reuse.';

create or replace view api.resident_case_status
with (security_invoker = true) as
select c.id, c.juristic_person_id, c.case_number, c.current_state,
       c.opened_at, c.resolved_at, c.closed_at, c.current_summary,
       cp.organization_relationship_id, cp.party_role_term_id
from intake.cases c
join intake.case_party_relationships cp on cp.case_id = c.id
where cp.recorded_to is null;
comment on view api.resident_case_status is 'Privacy-limited Case status projection filtered by underlying RLS and party relationships.';

create or replace view api.active_announcements
with (security_invoker = true) as
select a.id, a.juristic_person_id, a.announcement_number, a.title, a.body,
       a.severity, a.audience_roles, a.published_at, a.expires_at,
       a.acknowledgement_required
from notification.announcements a
where a.publication_state = 'published'
  and a.published_at <= now()
  and (a.expires_at is null or a.expires_at > now());
comment on view api.active_announcements is 'Currently published announcements filtered by underlying tenant and role RLS.';

create or replace view api.open_compliance_deadlines
with (security_invoker = true) as
select d.id, d.juristic_person_id, d.deadline_number, d.title, d.description,
       d.source_type, d.source_reference, d.due_at, d.current_state,
       d.responsibility_assignment_id
from governance.compliance_deadlines d
where d.completed_at is null and d.lifecycle = 'active';
comment on view api.open_compliance_deadlines is 'Open compliance deadlines; underlying RLS controls governance visibility.';

create or replace view api.organization_chart
with (security_invoker = true) as
select rel.juristic_person_id, p.id as person_id, p.display_name,
       rel.id as organization_relationship_id, rd.role_code, rd.name as role_name,
       ra.recorded_from as role_started_at
from org.organization_relationships rel
join org.people p on p.id = rel.person_id
join org.role_assignments ra on ra.organization_relationship_id = rel.id
join org.role_definitions rd on rd.id = ra.role_definition_id
where rel.recorded_to is null and rel.relationship_state = 'effective'
  and ra.recorded_to is null and ra.relationship_state = 'effective';
comment on view api.organization_chart is 'Current role chart; historical assignments remain in source tables.';


-- ============================================================================
-- Source: sql/07_functions.sql
-- ============================================================================

-- O83 Care internal and RLS helper functions.

create or replace function core.current_person_id(p_juristic_person_id uuid)
returns uuid
language sql
stable
security definer
set search_path = pg_catalog, iam
as $$
  select ua.person_id
  from iam.user_accounts ua
  where ua.auth_user_id = (select auth.uid())
    and ua.juristic_person_id = p_juristic_person_id
    and ua.account_state = 'active'
    and ua.disabled_at is null
  order by ua.linked_at desc
  limit 1
$$;
comment on function core.current_person_id(uuid) is 'Resolves current Supabase Auth account to tenant-specific O83 Person identity.';

create or replace function core.current_service_principal_id(p_juristic_person_id uuid)
returns uuid
language sql
stable
security definer
set search_path = pg_catalog, iam
as $$
  select sp.id
  from iam.service_principals sp
  where sp.auth_user_id = (select auth.uid())
    and sp.juristic_person_id = p_juristic_person_id
    and sp.lifecycle = 'active'
    and (sp.expires_at is null or sp.expires_at > now())
  limit 1
$$;
comment on function core.current_service_principal_id(uuid) is 'Resolves a current Auth identity to an active scoped service principal.';

create or replace function core.has_role(p_juristic_person_id uuid, p_role_code text)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, iam, org
as $$
  select exists (
    select 1
    from iam.user_accounts ua
    join org.organization_relationships rel
      on rel.person_id = ua.person_id
     and rel.juristic_person_id = ua.juristic_person_id
     and rel.recorded_to is null
     and rel.relationship_state = 'effective'
    join org.role_assignments ra
      on ra.organization_relationship_id = rel.id
     and ra.recorded_to is null
     and ra.relationship_state = 'effective'
    join org.role_definitions rd on rd.id = ra.role_definition_id
    where ua.auth_user_id = (select auth.uid())
      and ua.juristic_person_id = p_juristic_person_id
      and ua.account_state = 'active'
      and ua.disabled_at is null
      and rd.role_code = p_role_code
  )
$$;
comment on function core.has_role(uuid,text) is 'Checks an effective database-owned role; JWT user metadata is not trusted.';

create or replace function core.has_any_role(p_juristic_person_id uuid, p_role_codes text[])
returns boolean
language sql
stable
security invoker
set search_path = pg_catalog, core
as $$
  select coalesce(bool_or(core.has_role(p_juristic_person_id, role_code)), false)
  from unnest(p_role_codes) role_code
$$;
comment on function core.has_any_role(uuid,text[]) is 'Checks whether the current Person has any listed effective tenant role.';

create or replace function core.is_case_party(p_case_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, core, intake, org
as $$
  select exists (
    select 1
    from intake.cases c
    join intake.case_party_relationships cp on cp.case_id = c.id and cp.recorded_to is null
    join org.organization_relationships rel on rel.id = cp.organization_relationship_id and rel.recorded_to is null
    where c.id = p_case_id
      and rel.person_id = core.current_person_id(c.juristic_person_id)
  )
$$;
comment on function core.is_case_party(uuid) is 'Checks whether current Person has an effective party relationship to a Case.';

create or replace function core.has_active_mandate(p_juristic_person_id uuid, p_action text, p_scope_type text, p_scope_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, core, iam, org
as $$
  select exists (
    select 1
    from org.mandates m
    join org.organization_relationships rel on rel.id = m.grantee_relationship_id
    where m.juristic_person_id = p_juristic_person_id
      and rel.person_id = core.current_person_id(p_juristic_person_id)
      and m.lifecycle = 'active'
      and m.revoked_at is null
      and (m.valid_from is null or m.valid_from <= now())
      and (m.valid_to is null or m.valid_to > now())
      and p_action = any(m.authority_actions)
      and (m.scope_type = 'juristic_person' or (m.scope_type = p_scope_type and m.scope_id = p_scope_id))
  )
$$;
comment on function core.has_active_mandate(uuid,text,text,uuid) is 'Checks effective database-owned Authority for action and scope.';

create or replace function core.current_change_reason()
returns text
language sql
stable
security invoker
set search_path = pg_catalog
as $$
  select nullif(current_setting('app.change_reason', true), '')
$$;
comment on function core.current_change_reason() is 'Returns transaction-local reason supplied by trusted workflow code, if any.';

revoke all on function core.current_person_id(uuid) from public, anon;
revoke all on function core.current_service_principal_id(uuid) from public, anon;
revoke all on function core.has_role(uuid,text) from public, anon;
revoke all on function core.has_any_role(uuid,text[]) from public, anon;
revoke all on function core.is_case_party(uuid) from public, anon;
revoke all on function core.has_active_mandate(uuid,text,text,uuid) from public, anon;
grant execute on function core.current_person_id(uuid), core.current_service_principal_id(uuid),
  core.has_role(uuid,text), core.has_any_role(uuid,text[]), core.is_case_party(uuid),
  core.has_active_mandate(uuid,text,text,uuid), core.current_change_reason() to authenticated;

create or replace function api.resolve_current_access()
returns table (
  juristic_person_id uuid,
  person_id uuid,
  display_name text,
  roles text[],
  permissions text[]
)
language sql
stable
security definer
set search_path = ''
as $$
  select ua.juristic_person_id,
         ua.person_id,
         p.display_name,
         coalesce((
           select array_agg(distinct rd.role_code order by rd.role_code)
           from org.organization_relationships rel
           join org.role_assignments ra on ra.organization_relationship_id = rel.id
             and ra.recorded_to is null and ra.relationship_state = 'effective'
           join org.role_definitions rd on rd.id = ra.role_definition_id
           where rel.juristic_person_id = ua.juristic_person_id
             and rel.person_id = ua.person_id
             and rel.recorded_to is null
             and rel.relationship_state = 'effective'
         ), array[]::text[]) as roles,
         coalesce((
           select array_agg(distinct pd.permission_code order by pd.permission_code)
           from org.organization_relationships rel
           join org.role_assignments ra on ra.organization_relationship_id = rel.id
             and ra.recorded_to is null and ra.relationship_state = 'effective'
           join org.role_permissions rp on rp.role_definition_id = ra.role_definition_id
             and rp.recorded_to is null and rp.relationship_state = 'effective' and rp.effect = 'allow'
           join org.permission_definitions pd on pd.id = rp.permission_definition_id
           where rel.juristic_person_id = ua.juristic_person_id
             and rel.person_id = ua.person_id
             and rel.recorded_to is null
             and rel.relationship_state = 'effective'
             and not exists (
               select 1
               from org.role_permissions denied
               where denied.role_definition_id = ra.role_definition_id
                 and denied.permission_definition_id = pd.id
                 and denied.recorded_to is null
                 and denied.relationship_state = 'effective'
                 and denied.effect = 'deny'
             )
         ), array[]::text[]) as permissions
  from iam.user_accounts ua
  join org.people p on p.id = ua.person_id
  where ua.auth_user_id = (select auth.uid())
    and ua.account_state = 'active'
    and ua.disabled_at is null
    and ua.lifecycle = 'active'
$$;
comment on function api.resolve_current_access() is 'Returns database-owned tenant identity, effective roles, and data-driven permissions for the current Auth user.';

create or replace function core.has_permission(p_juristic_person_id uuid, p_permission_code text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from iam.user_accounts ua
    join org.organization_relationships rel
      on rel.person_id = ua.person_id and rel.juristic_person_id = ua.juristic_person_id
    join org.role_assignments ra on ra.organization_relationship_id = rel.id
    join org.role_permissions rp on rp.role_definition_id = ra.role_definition_id
    join org.permission_definitions pd on pd.id = rp.permission_definition_id
    where ua.auth_user_id = (select auth.uid())
      and ua.juristic_person_id = p_juristic_person_id
      and ua.account_state = 'active' and ua.disabled_at is null and ua.lifecycle = 'active'
      and rel.recorded_to is null and rel.relationship_state = 'effective'
      and ra.recorded_to is null and ra.relationship_state = 'effective'
      and rp.recorded_to is null and rp.relationship_state = 'effective' and rp.effect = 'allow'
      and pd.permission_code = p_permission_code
      and not exists (
        select 1 from org.role_permissions denied
        where denied.role_definition_id = ra.role_definition_id
          and denied.permission_definition_id = pd.id
          and denied.recorded_to is null and denied.relationship_state = 'effective'
          and denied.effect = 'deny'
      )
  )
$$;
comment on function core.has_permission(uuid,text) is 'Checks an effective database-owned role-permission mapping for the current Auth identity.';
revoke all on function core.has_permission(uuid,text) from public, anon;
grant execute on function core.has_permission(uuid,text) to authenticated;

create or replace function api.create_case(
  p_juristic_person_id uuid,
  p_channel text,
  p_submitted_text text,
  p_submitted_location_text text default null,
  p_occurred_at timestamptz default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid;
  v_relationship_id uuid;
  v_reporter_term_id uuid;
  v_report_id uuid := extensions.gen_random_uuid();
  v_case_id uuid := extensions.gen_random_uuid();
  v_correlation_id uuid := extensions.gen_random_uuid();
  v_year text := to_char(timezone('Asia/Bangkok', now()), 'YYYY');
  v_sequence integer;
  v_case_number text;
  v_report_number text;
begin
  if (select auth.uid()) is null then
    raise exception using errcode = '42501', message = 'Authentication is required.';
  end if;
  if p_channel not in ('resident_form','juristic_staff_intake','technician_finding','security_report','external_authority','system_recommendation') then
    raise exception using errcode = '22023', message = 'Unsupported Case source.';
  end if;
  if nullif(btrim(p_submitted_text), '') is null then
    raise exception using errcode = '22023', message = 'Report description is required.';
  end if;

  v_person_id := core.current_person_id(p_juristic_person_id);
  if v_person_id is null or not core.has_any_role(
    p_juristic_person_id,
    array['admin','juristic_manager','juristic_staff','head_technician','technician','resident','security']
  ) then
    raise exception using errcode = '42501', message = 'No active membership may create a Case for this organization.';
  end if;
  if (p_channel = 'resident_form' and not core.has_role(p_juristic_person_id, 'resident'))
     or (p_channel in ('juristic_staff_intake','external_authority','system_recommendation')
         and not core.has_any_role(p_juristic_person_id, array['admin','juristic_manager','juristic_staff']))
     or (p_channel = 'technician_finding'
         and not core.has_any_role(p_juristic_person_id, array['head_technician','technician']))
     or (p_channel = 'security_report' and not core.has_role(p_juristic_person_id, 'security')) then
    raise exception using errcode = '42501', message = 'The selected Case source does not match the current effective role.';
  end if;

  select rel.id into v_relationship_id
  from org.organization_relationships rel
  where rel.juristic_person_id = p_juristic_person_id
    and rel.person_id = v_person_id
    and rel.recorded_to is null
    and rel.relationship_state = 'effective'
  order by rel.recorded_from desc
  limit 1;

  select tt.id into v_reporter_term_id
  from taxonomy.taxonomy_terms tt
  join taxonomy.taxonomies t on t.id = tt.taxonomy_id
  where tt.juristic_person_id = p_juristic_person_id
    and t.taxonomy_code = 'case_party_role'
    and tt.term_code = 'reporter'
    and tt.lifecycle = 'active'
  limit 1;

  if v_relationship_id is null or v_reporter_term_id is null then
    raise exception using errcode = '55000', message = 'Membership or Case party reference data is not provisioned.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_juristic_person_id::text || ':case:' || v_year, 0));
  select coalesce(max(right(c.case_number, 6)::integer), 0) + 1 into v_sequence
  from intake.cases c
  where c.juristic_person_id = p_juristic_person_id
    and c.case_number ~ ('^CASE-' || v_year || '-[0-9]{6}$');
  v_case_number := 'CASE-' || v_year || '-' || lpad(v_sequence::text, 6, '0');
  v_report_number := 'REPORT-' || v_year || '-' || lpad(v_sequence::text, 6, '0');

  insert into intake.reports (
    id, juristic_person_id, business_key, created_by_person_id, report_number,
    channel, source_relationship_id, submitted_text, submitted_location_text,
    occurred_at, recorded_at
  ) values (
    v_report_id, p_juristic_person_id, 'report:' || v_report_id::text, v_person_id,
    v_report_number, p_channel, v_relationship_id, btrim(p_submitted_text),
    nullif(btrim(p_submitted_location_text), ''), p_occurred_at, now()
  );

  insert into intake.cases (
    id, juristic_person_id, business_key, created_by_person_id, case_number,
    report_id, current_state, opened_at, current_summary
  ) values (
    v_case_id, p_juristic_person_id, 'case:' || v_case_id::text, v_person_id,
    v_case_number, v_report_id, 'open', now(), left(btrim(p_submitted_text), 500)
  );

  insert into intake.case_party_relationships (
    juristic_person_id, business_key, created_by_person_id, case_id,
    organization_relationship_id, party_role_term_id, contact_permission,
    relationship_state, recorded_from
  ) values (
    p_juristic_person_id, 'case-party:' || v_case_id::text || ':' || v_relationship_id::text,
    v_person_id, v_case_id, v_relationship_id, v_reporter_term_id, 'case_updates',
    'effective', now()
  );

  insert into audit.domain_events (
    juristic_person_id, business_key, created_by_person_id, event_type, schema_version,
    aggregate_type, aggregate_id, aggregate_version, payload, producer, occurred_at,
    actor_kind, actor_id, correlation_id
  ) values (
    p_juristic_person_id, 'event:' || v_correlation_id::text, v_person_id,
    'CaseCreated', 1, 'Case', v_case_id, 1,
    jsonb_build_object('case_number', v_case_number, 'report_id', v_report_id, 'channel', p_channel),
    'api.create_case', coalesce(p_occurred_at, now()), 'person', v_person_id, v_correlation_id
  );

  return jsonb_build_object('case_id', v_case_id, 'case_number', v_case_number, 'report_id', v_report_id);
end
$$;
comment on function api.create_case(uuid,text,text,text,timestamptz) is 'Atomically creates one immutable Report, exactly one separate Case, reporter relationship, and CaseCreated event.';

create or replace function api.create_investigation(
  p_juristic_person_id uuid,
  p_case_id uuid,
  p_question text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person_id uuid;
  v_investigation_id uuid := extensions.gen_random_uuid();
  v_year text := to_char(timezone('Asia/Bangkok', now()), 'YYYY');
  v_sequence integer;
  v_number text;
begin
  v_person_id := core.current_person_id(p_juristic_person_id);
  if v_person_id is null or not core.has_any_role(p_juristic_person_id, array['admin','juristic_manager','juristic_staff','head_technician']) then
    raise exception using errcode = '42501', message = 'Investigation permission is required.';
  end if;
  if not exists (select 1 from intake.cases c where c.id = p_case_id and c.juristic_person_id = p_juristic_person_id) then
    raise exception using errcode = 'P0002', message = 'Case was not found in this organization.';
  end if;
  if nullif(btrim(p_question), '') is null then
    raise exception using errcode = '22023', message = 'Investigation question is required.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_juristic_person_id::text || ':investigation:' || v_year, 0));
  select count(*) + 1 into v_sequence from investigation.investigations i
  where i.juristic_person_id = p_juristic_person_id and i.investigation_number like 'INV-' || v_year || '-%';
  v_number := 'INV-' || v_year || '-' || lpad(v_sequence::text, 6, '0');

  insert into investigation.investigations (
    id, juristic_person_id, business_key, created_by_person_id, investigation_number,
    question, initiating_case_id, current_state, opened_at
  ) values (
    v_investigation_id, p_juristic_person_id, 'investigation:' || v_investigation_id::text,
    v_person_id, v_number, btrim(p_question), p_case_id, 'opened', now()
  );
  insert into investigation.investigation_cases (
    juristic_person_id, business_key, created_by_person_id, investigation_id,
    case_id, scope_role, inclusion_reason, relationship_state, recorded_from
  ) values (
    p_juristic_person_id, 'investigation-case:' || v_investigation_id::text || ':' || p_case_id::text,
    v_person_id, v_investigation_id, p_case_id, 'initiating', 'Created from Case investigation action',
    'effective', now()
  );
  return jsonb_build_object('investigation_id', v_investigation_id, 'investigation_number', v_number);
end
$$;
comment on function api.create_investigation(uuid,uuid,text) is 'Creates an Investigation without creating an Incident; Incident verification remains a separate human Decision.';

revoke all on function api.resolve_current_access() from public, anon;
revoke all on function api.create_case(uuid,text,text,text,timestamptz) from public, anon;
revoke all on function api.create_investigation(uuid,uuid,text) from public, anon;
grant execute on function api.resolve_current_access(),
  api.create_case(uuid,text,text,text,timestamptz),
  api.create_investigation(uuid,uuid,text) to authenticated;


-- ============================================================================
-- Source: sql/08_triggers.sql
-- ============================================================================

-- O83 Care generic concurrency and updated-at triggers.

create or replace function core.touch_mutable_row()
returns trigger
language plpgsql
security invoker
set search_path = pg_catalog
as $$
begin
  if new.id <> old.id then
    raise exception 'O83 primary key is immutable';
  end if;
  if new.juristic_person_id is distinct from old.juristic_person_id then
    raise exception 'O83 tenant identity is immutable';
  end if;
  new.updated_at := now();
  new.row_version := old.row_version + 1;
  return new;
end $$;
comment on function core.touch_mutable_row() is 'Maintains optimistic row version and immutable tenant/primary identity.';

do $$
declare r record; v_name text;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
      and not (schemaname = 'org' and tablename = 'juristic_persons')
  loop
    v_name := left('trg_' || r.schemaname || '_' || r.tablename || '_touch', 63);
    if not exists (
      select 1 from pg_trigger t
      join pg_class c on c.oid = t.tgrelid
      join pg_namespace n on n.oid = c.relnamespace
      where not t.tgisinternal and n.nspname = r.schemaname and c.relname = r.tablename and t.tgname = v_name
    ) then
      execute format('create trigger %I before update on %I.%I for each row execute function core.touch_mutable_row()', v_name, r.schemaname, r.tablename);
    end if;
  end loop;
end $$;

comment on function core.touch_mutable_row() is 'Attached to mutable rows; immutable tables receive stricter triggers in 09_history.sql.';


-- ============================================================================
-- Source: sql/09_history.sql
-- ============================================================================

-- O83 Care immutable history and published-version protection.

create or replace function core.reject_history_change()
returns trigger
language plpgsql
security invoker
set search_path = pg_catalog
as $$
begin
  raise exception 'O83 immutable history cannot be updated or deleted: %.%', tg_table_schema, tg_table_name;
end $$;
comment on function core.reject_history_change() is 'Rejects update/delete on accepted immutable history.';

create or replace function core.protect_published_version()
returns trigger
language plpgsql
security invoker
set search_path = pg_catalog, core
as $$
begin
  if tg_op = 'DELETE' then
    if old.status in ('published','executed','issued') then
      raise exception 'Published, executed, or issued O83 version cannot be deleted';
    end if;
    return old;
  end if;
  if old.status in ('published','executed','issued') then
    if to_jsonb(new) - array['lifecycle','updated_at','row_version','archived_at']
       is distinct from
       to_jsonb(old) - array['lifecycle','updated_at','row_version','archived_at'] then
      raise exception 'Published, executed, or issued O83 version payload is immutable';
    end if;
  end if;
  return new;
end $$;
comment on function core.protect_published_version() is 'Allows archive metadata but prevents mutation of issued version payload.';

do $$
declare v_table regclass; v_name text;
begin
  foreach v_table in array array[
    'iam.access_decisions'::regclass,
    'org.responsibility_ledger_entries'::regclass,
    'intake.reports'::regclass, 'intake.case_communications'::regclass, 'intake.case_reopens'::regclass,
    'investigation.observations'::regclass,
    'incident.incident_reopens'::regclass,
    'work.operation_interruptions'::regclass, 'work.verification_records'::regclass,
    'work.execution_sequence_entries'::regclass, 'work.sla_clock_events'::regclass,
    'evidence.evidence_custody_events'::regclass, 'evidence.evidence_integrity_checks'::regclass,
    'evidence.evidence_dispositions'::regclass,
    'knowledge.knowledge_reviews'::regclass, 'knowledge.knowledge_usage_outcomes'::regclass,
    'workflow.state_transitions'::regclass,
    'notification.delivery_attempts'::regclass, 'notification.notification_acknowledgements'::regclass,
    'governance.resolution_votes'::regclass,
    'ai.ai_interactions'::regclass, 'ai.ai_recommendations'::regclass,
    'ai.ai_recommendation_sources'::regclass, 'ai.ai_reviews'::regclass,
    'audit.domain_events'::regclass, 'audit.audit_entries'::regclass,
    'integration.inbound_messages'::regclass
  ]
  loop
    v_name := left('trg_' || replace(v_table::text, '.', '_') || '_immutable', 63);
    if not exists (select 1 from pg_trigger where tgrelid = v_table and tgname = v_name and not tgisinternal) then
      execute format('create trigger %I before update or delete on %s for each row execute function core.reject_history_change()', v_name, v_table);
    end if;
  end loop;
end $$;

do $$
declare v_table regclass; v_name text;
begin
  foreach v_table in array array[
    'taxonomy.taxonomy_versions'::regclass,
    'work.sla_policy_versions'::regclass,
    'evidence.evidence_package_versions'::regclass,
    'knowledge.knowledge_versions'::regclass,
    'workflow.workflow_versions'::regclass,
    'governance.policy_versions'::regclass,
    'governance.contract_versions'::regclass,
    'analytics.kpi_versions'::regclass
  ]
  loop
    v_name := left('trg_' || replace(v_table::text, '.', '_') || '_protect_version', 63);
    if not exists (select 1 from pg_trigger where tgrelid = v_table and tgname = v_name and not tgisinternal) then
      execute format('create trigger %I before update or delete on %s for each row execute function core.protect_published_version()', v_name, v_table);
    end if;
  end loop;
end $$;

-- Prevent published Knowledge from existing without source and Validity Context.
create or replace function knowledge.validate_published_version()
returns trigger
language plpgsql
security invoker
set search_path = pg_catalog, knowledge
as $$
begin
  if new.status = 'published' and (tg_op = 'INSERT' or old.status is distinct from 'published') then
    if not exists (select 1 from knowledge.validity_contexts where knowledge_version_id = new.id) then
      raise exception 'Published Knowledge requires Validity Context';
    end if;
    if not exists (select 1 from knowledge.knowledge_sources where knowledge_version_id = new.id) then
      raise exception 'Published Knowledge requires at least one source';
    end if;
  end if;
  return new;
end $$;
comment on function knowledge.validate_published_version() is 'Enforces context and source requirements before Knowledge publication.';

drop trigger if exists trg_knowledge_versions_validate_publish on knowledge.knowledge_versions;
create constraint trigger trg_knowledge_versions_validate_publish
after insert or update of status on knowledge.knowledge_versions
deferrable initially deferred
for each row execute function knowledge.validate_published_version();


-- ============================================================================
-- Source: sql/10_audit.sql
-- ============================================================================

-- O83 Care row-change audit with actor, time, old/new values, and reason.

alter table audit.audit_entries add column if not exists old_value jsonb;
alter table audit.audit_entries add column if not exists new_value jsonb;
alter table audit.audit_entries add column if not exists database_role text;
comment on column audit.audit_entries.old_value is 'Prior row image for audited modification, classification and retention controlled.';
comment on column audit.audit_entries.new_value is 'New row image for audited modification, classification and retention controlled.';

create or replace function audit.capture_row_change()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, core, iam, audit
as $$
declare
  v_old jsonb := case when tg_op in ('UPDATE','DELETE') then to_jsonb(old) else null end;
  v_new jsonb := case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) else null end;
  v_tenant uuid := coalesce((v_new->>'juristic_person_id')::uuid, (v_old->>'juristic_person_id')::uuid);
  v_target uuid := coalesce((v_new->>'id')::uuid, (v_old->>'id')::uuid);
  v_person uuid;
  v_service uuid;
begin
  if v_tenant is null and tg_table_schema = 'org' and tg_table_name = 'juristic_persons' then
    v_tenant := v_target;
  end if;
  if v_tenant is not null then
    v_person := core.current_person_id(v_tenant);
    v_service := core.current_service_principal_id(v_tenant);
  end if;
  insert into audit.audit_entries (
    juristic_person_id, business_key, lifecycle, principal_kind, principal_id,
    action_code, target_type, target_id, result, old_value, new_value,
    database_role, occurred_at, recorded_at, correlation_id, reason,
    classification
  ) values (
    v_tenant, extensions.gen_random_uuid()::text, 'active',
    case when v_person is not null then 'person'::core.actor_kind
         when v_service is not null then 'service_principal'::core.actor_kind
         else 'system'::core.actor_kind end,
    coalesce(v_person, v_service), lower(tg_op), tg_table_schema || '.' || tg_table_name,
    v_target, 'succeeded', v_old, v_new, current_user, statement_timestamp(),
    clock_timestamp(), extensions.gen_random_uuid(), core.current_change_reason(), 'confidential'
  );
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end $$;
comment on function audit.capture_row_change() is 'Captures row modification with actor, time, old/new value, database role, and reason.';
revoke all on function audit.capture_row_change() from public, anon, authenticated;

do $$
declare r record; v_name text;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','analytics','memory','integration'])
  loop
    v_name := left('trg_' || r.schemaname || '_' || r.tablename || '_audit', 63);
    if not exists (
      select 1 from pg_trigger t
      join pg_class c on c.oid = t.tgrelid
      join pg_namespace n on n.oid = c.relnamespace
      where not t.tgisinternal and n.nspname = r.schemaname and c.relname = r.tablename and t.tgname = v_name
    ) then
      execute format('create trigger %I after insert or update or delete on %I.%I for each row execute function audit.capture_row_change()', v_name, r.schemaname, r.tablename);
    end if;
  end loop;
end $$;


-- ============================================================================
-- Source: sql/11_storage.sql
-- ============================================================================

-- O83 Care Supabase Storage buckets and RLS policies.
-- All buckets are private; database Evidence metadata remains authoritative.

insert into storage.buckets (id, name, public, file_size_limit)
values
  ('o83-evidence-intake', 'o83-evidence-intake', false, 1073741824),
  ('o83-evidence-originals', 'o83-evidence-originals', false, 1073741824),
  ('o83-evidence-renditions', 'o83-evidence-renditions', false, 1073741824),
  ('o83-artifacts', 'o83-artifacts', false, 1073741824),
  ('o83-memory-archive', 'o83-memory-archive', false, 5368709120)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit;

create or replace function core.storage_tenant_id(p_name text)
returns uuid
language plpgsql
immutable
security invoker
set search_path = pg_catalog
as $$
declare v_part text;
begin
  v_part := split_part(p_name, '/', 1);
  if v_part ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    return v_part::uuid;
  end if;
  return null;
end $$;
comment on function core.storage_tenant_id(text) is 'Safely extracts the tenant UUID from an O83 Storage object path.';

create or replace function core.can_read_evidence_object(p_bucket text, p_name text)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, core, evidence, intake, org
as $$
  with tenant as (select core.storage_tenant_id(p_name) as id),
  evidence_object as (
    select ei.id as evidence_id, ei.juristic_person_id
    from evidence.evidence_items ei, tenant t
    where ei.juristic_person_id = t.id
      and ei.original_storage_bucket = p_bucket
      and ei.original_storage_object_key = p_name
    union all
    select er.evidence_item_id, er.juristic_person_id
    from evidence.evidence_renditions er, tenant t
    where er.juristic_person_id = t.id
      and er.storage_bucket = p_bucket
      and er.storage_object_key = p_name
  )
  select exists (
    select 1 from evidence_object eo
    where core.has_any_role(eo.juristic_person_id, array['admin','juristic_manager','juristic_staff','head_technician','technician','auditor'])
       or exists (
         select 1 from evidence.evidence_links el
         where el.evidence_item_id = eo.evidence_id
           and el.target_type = 'case'
           and core.is_case_party(el.target_id)
       )
  )
$$;
comment on function core.can_read_evidence_object(text,text) is 'Authorizes an Evidence object using database Evidence and Case relationships, not path alone.';
revoke all on function core.can_read_evidence_object(text,text) from public, anon;
grant execute on function core.storage_tenant_id(text), core.can_read_evidence_object(text,text) to authenticated;

drop policy if exists o83_storage_intake_insert on storage.objects;
create policy o83_storage_intake_insert on storage.objects
for insert to authenticated
with check (
  bucket_id = 'o83-evidence-intake'
  and core.storage_tenant_id(name) is not null
  and (
    core.current_person_id(core.storage_tenant_id(name)) is not null
    or core.current_service_principal_id(core.storage_tenant_id(name)) is not null
  )
);

drop policy if exists o83_storage_intake_select on storage.objects;
create policy o83_storage_intake_select on storage.objects
for select to authenticated
using (
  bucket_id = 'o83-evidence-intake'
  and core.storage_tenant_id(name) is not null
  and (
    core.has_any_role(core.storage_tenant_id(name), array['admin','juristic_manager','juristic_staff','head_technician','technician'])
    or owner_id = (select auth.uid()::text)
  )
);

drop policy if exists o83_storage_evidence_select on storage.objects;
create policy o83_storage_evidence_select on storage.objects
for select to authenticated
using (
  bucket_id in ('o83-evidence-originals','o83-evidence-renditions')
  and core.can_read_evidence_object(bucket_id, name)
);

drop policy if exists o83_storage_trusted_insert on storage.objects;
create policy o83_storage_trusted_insert on storage.objects
for insert to authenticated
with check (
  bucket_id in ('o83-evidence-originals','o83-evidence-renditions','o83-artifacts')
  and core.storage_tenant_id(name) is not null
  and core.has_any_role(core.storage_tenant_id(name), array['admin','juristic_manager','juristic_staff','head_technician'])
);

drop policy if exists o83_storage_artifact_select on storage.objects;
create policy o83_storage_artifact_select on storage.objects
for select to authenticated
using (
  bucket_id = 'o83-artifacts'
  and core.storage_tenant_id(name) is not null
  and core.has_any_role(core.storage_tenant_id(name), array['admin','committee','juristic_manager','juristic_staff','auditor'])
);

-- No authenticated policy grants direct access to the memory archive bucket.
-- Trusted server-side service-role workflows remain subject to O83 audit and manifest rules.


-- ============================================================================
-- Source: sql/12_rls.sql
-- ============================================================================

-- O83 Care Row Level Security.
-- Authentication is not authorization; policies require tenant and role/relationship checks.

create or replace function core.is_ai_service(p_juristic_person_id uuid)
returns boolean
language sql
stable
security invoker
set search_path = pg_catalog, core
as $$
  select core.current_service_principal_id(p_juristic_person_id) is not null
$$;
comment on function core.is_ai_service(uuid) is 'Checks for an active tenant-scoped service principal mapped to the current Auth identity.';
grant execute on function core.is_ai_service(uuid) to authenticated;

-- Enable and force RLS across every O83 authoritative table.
do $$
declare r record;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
  loop
    execute format('alter table %I.%I enable row level security', r.schemaname, r.tablename);
    execute format('alter table %I.%I force row level security', r.schemaname, r.tablename);
  end loop;
end $$;

-- Admin has tenant-scoped access. Immutable triggers still prohibit history mutation.
do $$
declare r record; v_policy text; v_expr text;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
  loop
    v_policy := left('o83_admin_all_' || r.schemaname || '_' || r.tablename, 63);
    v_expr := case when r.schemaname = 'org' and r.tablename = 'juristic_persons'
      then 'core.has_role(id, ''admin'')'
      else 'core.has_role(juristic_person_id, ''admin'')' end;
    execute format('drop policy if exists %I on %I.%I', v_policy, r.schemaname, r.tablename);
    execute format('create policy %I on %I.%I for all to authenticated using (%s) with check (%s)', v_policy, r.schemaname, r.tablename, v_expr, v_expr);
  end loop;
end $$;

-- Committee read access is limited to governance, property, taxonomy, analytics, and approved memory metadata.
do $$
declare r record; v_policy text;
begin
  for r in select schemaname, tablename from pg_tables
    where schemaname = any (array['property','taxonomy','governance','analytics','memory'])
  loop
    v_policy := left('o83_committee_select_' || r.schemaname || '_' || r.tablename, 63);
    execute format('drop policy if exists %I on %I.%I', v_policy, r.schemaname, r.tablename);
    execute format('create policy %I on %I.%I for select to authenticated using (core.has_role(juristic_person_id, ''committee''))', v_policy, r.schemaname, r.tablename);
  end loop;
end $$;

-- Manager and staff operational access. Business Authority remains enforced by Mandate-aware commands/constraints.
do $$
declare r record; v_policy text;
begin
  for r in select schemaname, tablename from pg_tables
    where schemaname = any (array['org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','analytics','integration'])
      and not (schemaname = 'org' and tablename = 'juristic_persons')
  loop
    v_policy := left('o83_manager_all_' || r.schemaname || '_' || r.tablename, 63);
    execute format('drop policy if exists %I on %I.%I', v_policy, r.schemaname, r.tablename);
    execute format('create policy %I on %I.%I for all to authenticated using (core.has_any_role(juristic_person_id, array[''juristic_manager''])) with check (core.has_any_role(juristic_person_id, array[''juristic_manager'']))', v_policy, r.schemaname, r.tablename);
  end loop;
  for r in select schemaname, tablename from pg_tables
    where schemaname = any (array['property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification'])
  loop
    v_policy := left('o83_staff_select_' || r.schemaname || '_' || r.tablename, 63);
    execute format('drop policy if exists %I on %I.%I', v_policy, r.schemaname, r.tablename);
    execute format('create policy %I on %I.%I for select to authenticated using (core.has_any_role(juristic_person_id, array[''juristic_staff'']))', v_policy, r.schemaname, r.tablename);
  end loop;
end $$;

-- Residents can read only their own Case surface and add communications/context through their Case.
drop policy if exists o83_resident_case_select on intake.cases;
create policy o83_resident_case_select on intake.cases for select to authenticated using (core.is_case_party(id));
drop policy if exists o83_resident_case_party_select on intake.case_party_relationships;
create policy o83_resident_case_party_select on intake.case_party_relationships for select to authenticated using (core.is_case_party(case_id));
drop policy if exists o83_resident_case_context_select on intake.case_context_assertions;
create policy o83_resident_case_context_select on intake.case_context_assertions for select to authenticated using (core.is_case_party(case_id));
drop policy if exists o83_resident_case_comm_select on intake.case_communications;
create policy o83_resident_case_comm_select on intake.case_communications for select to authenticated using (core.is_case_party(case_id));
drop policy if exists o83_resident_case_comm_insert on intake.case_communications;
create policy o83_resident_case_comm_insert on intake.case_communications for insert to authenticated with check (core.is_case_party(case_id));
drop policy if exists o83_resident_report_select on intake.reports;
create policy o83_resident_report_select on intake.reports for select to authenticated using (exists (select 1 from intake.cases c where c.report_id = reports.id and core.is_case_party(c.id)));

drop policy if exists o83_member_announcement_select on notification.announcements;
create policy o83_member_announcement_select on notification.announcements
for select to authenticated
using (
  publication_state = 'published'
  and published_at <= now()
  and (expires_at is null or expires_at > now())
  and core.current_person_id(juristic_person_id) is not null
);

drop policy if exists o83_staff_compliance_select on governance.compliance_deadlines;
create policy o83_staff_compliance_select on governance.compliance_deadlines
for select to authenticated
using (core.has_any_role(juristic_person_id, array['juristic_manager','juristic_staff','committee']));

drop policy if exists o83_org_chart_people_select on org.people;
create policy o83_org_chart_people_select on org.people for select to authenticated
using (core.has_any_role(juristic_person_id, array['juristic_manager','juristic_staff','head_technician','committee']));
drop policy if exists o83_org_chart_relationship_select on org.organization_relationships;
create policy o83_org_chart_relationship_select on org.organization_relationships for select to authenticated
using (core.has_any_role(juristic_person_id, array['juristic_manager','juristic_staff','head_technician','committee']));
drop policy if exists o83_org_chart_role_assignment_select on org.role_assignments;
create policy o83_org_chart_role_assignment_select on org.role_assignments for select to authenticated
using (core.has_any_role(juristic_person_id, array['juristic_manager','juristic_staff','head_technician','committee']));
drop policy if exists o83_org_chart_role_definition_select on org.role_definitions;
create policy o83_org_chart_role_definition_select on org.role_definitions for select to authenticated
using (core.has_any_role(juristic_person_id, array['juristic_manager','juristic_staff','head_technician','committee']));

-- Technician and vendor access is driven by accepted Commitments, not a global tenant grant.
create or replace function core.can_access_operation(p_operation_id uuid)
returns boolean
language sql stable security definer
set search_path = pg_catalog, core, work, org
as $$
  select exists (
    select 1 from work.operations o
    where o.id = p_operation_id
      and (
        core.has_any_role(o.juristic_person_id, array['admin','juristic_manager','juristic_staff','head_technician'])
        or exists (
          select 1 from work.commitments c
          join org.organization_relationships rel on rel.id = c.accepted_by_relationship_id
          where c.operation_id = o.id
            and rel.person_id = core.current_person_id(o.juristic_person_id)
            and c.current_state in ('accepted','in_progress','renegotiation_requested')
        )
      )
  )
$$;
comment on function core.can_access_operation(uuid) is 'Checks Operation access through management role or accepted personal Commitment.';
revoke all on function core.can_access_operation(uuid) from public, anon;
grant execute on function core.can_access_operation(uuid) to authenticated;

drop policy if exists o83_worker_operations_select on work.operations;
create policy o83_worker_operations_select on work.operations for select to authenticated using (core.can_access_operation(id));
drop policy if exists o83_worker_steps_select on work.work_steps;
create policy o83_worker_steps_select on work.work_steps for select to authenticated using (core.can_access_operation(operation_id));
drop policy if exists o83_worker_steps_update on work.work_steps;
create policy o83_worker_steps_update on work.work_steps for update to authenticated using (core.can_access_operation(operation_id)) with check (core.can_access_operation(operation_id));
drop policy if exists o83_worker_commitments_select on work.commitments;
create policy o83_worker_commitments_select on work.commitments for select to authenticated using (core.can_access_operation(operation_id));
drop policy if exists o83_worker_verification_select on work.verification_records;
create policy o83_worker_verification_select on work.verification_records for select to authenticated using (core.can_access_operation(operation_id));

-- AI service receives no general domain-table policy and cannot create human reviews.
drop policy if exists o83_ai_service_use_case_select on ai.ai_use_cases;
create policy o83_ai_service_use_case_select on ai.ai_use_cases for select to authenticated
using (core.is_ai_service(juristic_person_id) and lifecycle = 'active');
drop policy if exists o83_ai_service_interaction_insert on ai.ai_interactions;
create policy o83_ai_service_interaction_insert on ai.ai_interactions for insert to authenticated
with check (core.is_ai_service(juristic_person_id));
drop policy if exists o83_ai_service_interaction_select on ai.ai_interactions;
create policy o83_ai_service_interaction_select on ai.ai_interactions for select to authenticated
using (core.is_ai_service(juristic_person_id));
drop policy if exists o83_ai_service_recommendation_insert on ai.ai_recommendations;
create policy o83_ai_service_recommendation_insert on ai.ai_recommendations for insert to authenticated
with check (core.is_ai_service(juristic_person_id) and review_state = 'pending');
drop policy if exists o83_ai_service_recommendation_select on ai.ai_recommendations;
create policy o83_ai_service_recommendation_select on ai.ai_recommendations for select to authenticated
using (core.is_ai_service(juristic_person_id));
drop policy if exists o83_ai_service_source_insert on ai.ai_recommendation_sources;
create policy o83_ai_service_source_insert on ai.ai_recommendation_sources for insert to authenticated
with check (core.is_ai_service(juristic_person_id));
drop policy if exists o83_ai_service_source_select on ai.ai_recommendation_sources;
create policy o83_ai_service_source_select on ai.ai_recommendation_sources for select to authenticated
using (core.is_ai_service(juristic_person_id));

-- Qualified humans may read AI context and append immutable review records.
drop policy if exists o83_ai_reviewer_use_case_select on ai.ai_use_cases;
create policy o83_ai_reviewer_use_case_select on ai.ai_use_cases for select to authenticated
using (core.has_permission(juristic_person_id, 'ai.review'));
drop policy if exists o83_ai_reviewer_interaction_select on ai.ai_interactions;
create policy o83_ai_reviewer_interaction_select on ai.ai_interactions for select to authenticated
using (core.has_permission(juristic_person_id, 'ai.review'));
drop policy if exists o83_ai_reviewer_recommendation_select on ai.ai_recommendations;
create policy o83_ai_reviewer_recommendation_select on ai.ai_recommendations for select to authenticated
using (core.has_permission(juristic_person_id, 'ai.review'));
drop policy if exists o83_ai_reviewer_source_select on ai.ai_recommendation_sources;
create policy o83_ai_reviewer_source_select on ai.ai_recommendation_sources for select to authenticated
using (core.has_permission(juristic_person_id, 'ai.review'));
drop policy if exists o83_ai_reviewer_review_select on ai.ai_reviews;
create policy o83_ai_reviewer_review_select on ai.ai_reviews for select to authenticated
using (core.has_permission(juristic_person_id, 'ai.review'));
drop policy if exists o83_ai_reviewer_review_insert on ai.ai_reviews;
create policy o83_ai_reviewer_review_insert on ai.ai_reviews for insert to authenticated
with check (
  core.has_permission(juristic_person_id, 'ai.review')
  and reviewer_person_id = core.current_person_id(juristic_person_id)
);

-- Service role is a Supabase BYPASSRLS role. It receives no end-user policy;
-- all use must remain server-side, least privileged, and audited by workflow code.


-- ============================================================================
-- Source: sql/13_permissions.sql
-- ============================================================================

-- O83 Care object privileges paired with RLS.

-- Start from deny-by-default for application roles.
revoke all on all tables in schema iam, org, property, taxonomy, intake,
  investigation, incident, work, evidence, decision, knowledge, workflow,
  notification, governance, ai, audit, analytics, memory, integration
from anon, authenticated;

revoke all on all functions in schema core, iam, org, property, taxonomy, intake,
  investigation, incident, work, evidence, decision, knowledge, workflow,
  notification, governance, ai, audit, analytics, memory, integration
from public, anon, authenticated;

-- Authenticated role can reach tables; RLS determines rows and operations.
grant usage on schema iam, org, property, taxonomy, intake, investigation,
  incident, work, evidence, decision, knowledge, workflow, notification,
  governance, ai, audit, analytics, memory, integration to authenticated;
grant usage on schema api to authenticated;

grant select, insert, update on all tables in schema iam, org, property, taxonomy,
  intake, investigation, incident, work, evidence, decision, knowledge,
  workflow, notification, governance, ai, analytics, memory, integration
to authenticated;

grant select on audit.domain_events, audit.audit_entries to authenticated;
grant select, insert, update on audit.outbox_messages to authenticated;

-- No authoritative table DELETE privilege is granted to authenticated users.
revoke delete on all tables in schema iam, org, property, taxonomy, intake,
  investigation, incident, work, evidence, decision, knowledge, workflow,
  notification, governance, ai, audit, analytics, memory, integration
from authenticated;

grant select on api.current_cases, api.current_incidents, api.operation_queue,
  api.responsibility_chain, api.decision_evolution, api.operational_truth,
  api.current_knowledge, api.resident_case_status, api.active_announcements,
  api.open_compliance_deadlines, api.organization_chart to authenticated;

-- Re-grant only reviewed helper functions after the blanket revoke.
grant execute on function core.current_person_id(uuid), core.current_service_principal_id(uuid),
  core.has_role(uuid,text), core.has_any_role(uuid,text[]), core.is_case_party(uuid),
  core.has_active_mandate(uuid,text,text,uuid), core.current_change_reason(),
  core.storage_tenant_id(text), core.can_read_evidence_object(text,text),
  core.is_ai_service(uuid), core.can_access_operation(uuid) to authenticated;

grant execute on function api.resolve_current_access(),
  api.create_case(uuid,text,text,text,timestamptz),
  api.create_investigation(uuid,uuid,text) to authenticated;

-- Harden future defaults in private schemas. SQL generators must still review every grant.
alter default privileges in schema iam, org, property, taxonomy, intake,
  investigation, incident, work, evidence, decision, knowledge, workflow,
  notification, governance, ai, audit, analytics, memory, integration
revoke all on tables from public, anon, authenticated;

alter default privileges in schema core, iam, org, property, taxonomy, intake,
  investigation, incident, work, evidence, decision, knowledge, workflow,
  notification, governance, ai, audit, analytics, memory, integration
revoke execute on functions from public, anon, authenticated;


-- ============================================================================
-- Source: sql/14_seed_reference_data.sql
-- ============================================================================

-- O83 Care tenant bootstrap reference data.
-- Set app.bootstrap_juristic_person_id transaction-locally before running to seed one tenant.

do $$
declare
  v_tenant uuid := nullif(current_setting('app.bootstrap_juristic_person_id', true), '')::uuid;
  v_party_taxonomy uuid;
  v_party_version uuid;
  v_relationship_taxonomy uuid;
  v_relationship_version uuid;
begin
  if v_tenant is null then
    raise notice 'O83 seed skipped: app.bootstrap_juristic_person_id is not set';
    return;
  end if;
  if not exists (select 1 from org.juristic_persons where id = v_tenant) then
    raise exception 'O83 seed tenant does not exist: %', v_tenant;
  end if;

  insert into org.role_definitions (juristic_person_id, business_key, role_code, name, description)
  values
    (v_tenant, 'role:admin', 'admin', 'Administrator', 'Tenant database and operational administrator; not automatic business Authority.'),
    (v_tenant, 'role:committee', 'committee', 'Committee Member', 'Governance role within effective committee mandate.'),
    (v_tenant, 'role:juristic_manager', 'juristic_manager', 'Juristic Manager', 'Juristic management role; business Authority still requires an effective Mandate.'),
    (v_tenant, 'role:juristic_staff', 'juristic_staff', 'Juristic Staff', 'Operational juristic staff role.'),
    (v_tenant, 'role:head_technician', 'head_technician', 'Head Technician', 'Technical coordination role; Capability and assignment remain separately recorded.'),
    (v_tenant, 'role:technician', 'technician', 'Technician', 'Field technician role; Capability remains separately asserted.'),
    (v_tenant, 'role:resident', 'resident', 'Resident', 'Resident role with Case relationship-scoped access.'),
    (v_tenant, 'role:vendor', 'vendor', 'Vendor Participant', 'Person acting through a contracted external organization.'),
    (v_tenant, 'role:security', 'security', 'Security', 'Security staff with explicitly scoped reporting and emergency duties.'),
    (v_tenant, 'role:housekeeping', 'housekeeping', 'Housekeeping', 'Housekeeping staff with explicitly scoped reporting duties.'),
    (v_tenant, 'role:auditor', 'auditor', 'Auditor', 'Scoped audit/review role.'),
    (v_tenant, 'role:ai_service', 'ai_service', 'AI Service', 'Technical advisory service with no human Authority.')
  on conflict (juristic_person_id, business_key) do update
  set name = excluded.name,
      description = excluded.description,
      updated_at = now();

  insert into org.permission_definitions (
    juristic_person_id, business_key, permission_code, name, description, resource_type, action_code
  ) values
    (v_tenant, 'permission:case.create', 'case.create', 'Create Case', 'Create one separate Case from one incoming Report.', 'case', 'create'),
    (v_tenant, 'permission:case.read', 'case.read', 'Read Case', 'Read Cases allowed by relationship and tenant policy.', 'case', 'read'),
    (v_tenant, 'permission:investigation.manage', 'investigation.manage', 'Manage Investigation', 'Create and contribute to an Investigation.', 'investigation', 'manage'),
    (v_tenant, 'permission:incident.manage', 'incident.manage', 'Manage Incident', 'Manage a human-verified Incident within Mandate.', 'incident', 'manage'),
    (v_tenant, 'permission:operation.manage', 'operation.manage', 'Manage Operation', 'Create and coordinate Operations within Mandate.', 'operation', 'manage'),
    (v_tenant, 'permission:operation.accept', 'operation.accept', 'Accept Work', 'Accept a suitable offered Commitment.', 'operation', 'accept'),
    (v_tenant, 'permission:evidence.create', 'evidence.create', 'Create Evidence', 'Create Evidence through the governed upload lifecycle.', 'evidence', 'create'),
    (v_tenant, 'permission:evidence.read', 'evidence.read', 'Read Evidence', 'Read authorized Evidence renditions.', 'evidence', 'read'),
    (v_tenant, 'permission:verification.perform', 'verification.perform', 'Perform Verification', 'Record qualified human verification when separation rules permit.', 'verification', 'perform'),
    (v_tenant, 'permission:announcement.manage', 'announcement.manage', 'Manage Announcements', 'Create and manage authorized announcements.', 'announcement', 'manage'),
    (v_tenant, 'permission:compliance.manage', 'compliance.manage', 'Manage Compliance', 'Manage compliance deadlines and evidence.', 'compliance', 'manage'),
    (v_tenant, 'permission:report.read', 'report.read', 'Read Reports', 'Read authorized operational reporting.', 'report', 'read'),
    (v_tenant, 'permission:permission.manage', 'permission.manage', 'Manage Permissions', 'Administer role-permission relationships without creating business Authority.', 'permission', 'manage'),
    (v_tenant, 'permission:ai.review', 'ai.review', 'Review AI Recommendations', 'Accept or reject AI advice as a human review action.', 'ai_recommendation', 'review')
  on conflict (juristic_person_id, business_key) do update
  set name = excluded.name,
      description = excluded.description,
      resource_type = excluded.resource_type,
      action_code = excluded.action_code,
      updated_at = now();

  insert into org.role_permissions (
    juristic_person_id, business_key, role_definition_id, permission_definition_id,
    effect, relationship_state, recorded_from
  )
  select v_tenant,
         'role-permission:' || rd.role_code || ':' || pd.permission_code,
         rd.id,
         pd.id,
         'allow',
         'effective',
         now()
  from org.role_definitions rd
  cross join org.permission_definitions pd
  where rd.juristic_person_id = v_tenant
    and pd.juristic_person_id = v_tenant
    and (
      rd.role_code = 'admin'
      or (rd.role_code = 'juristic_manager' and pd.permission_code = any(array['case.create','case.read','investigation.manage','incident.manage','operation.manage','evidence.create','evidence.read','verification.perform','announcement.manage','compliance.manage','report.read','permission.manage','ai.review']))
      or (rd.role_code = 'juristic_staff' and pd.permission_code = any(array['case.create','case.read','investigation.manage','operation.manage','evidence.create','evidence.read','announcement.manage','compliance.manage','report.read','ai.review']))
      or (rd.role_code = 'head_technician' and pd.permission_code = any(array['case.create','case.read','investigation.manage','operation.manage','operation.accept','evidence.create','evidence.read','verification.perform','report.read','ai.review']))
      or (rd.role_code = 'technician' and pd.permission_code = any(array['case.create','case.read','operation.accept','evidence.create','evidence.read']))
      or (rd.role_code = 'resident' and pd.permission_code = any(array['case.create','case.read','evidence.create','evidence.read']))
      or (rd.role_code = 'committee' and pd.permission_code = any(array['case.read','evidence.read','report.read','ai.review']))
      or (rd.role_code = 'vendor' and pd.permission_code = any(array['case.read','operation.accept','evidence.create','evidence.read']))
      or (rd.role_code = 'security' and pd.permission_code = any(array['case.create','case.read','evidence.create']))
      or (rd.role_code = 'housekeeping' and pd.permission_code = any(array['case.create','case.read','evidence.create']))
    )
  on conflict (juristic_person_id, business_key) do update
  set effect = excluded.effect,
      relationship_state = excluded.relationship_state,
      recorded_to = null,
      updated_at = now();

  insert into taxonomy.taxonomies (
    juristic_person_id, business_key, taxonomy_code, name, purpose, governance_mode
  ) values (
    v_tenant, 'taxonomy:case_party_role', 'case_party_role', 'Case Party Roles',
    'Identifies reporter, affected party, representative, and communication relationships.', 'controlled'
  )
  on conflict (juristic_person_id, business_key) do update set name = excluded.name, updated_at = now()
  returning id into v_party_taxonomy;

  insert into taxonomy.taxonomy_versions (
    juristic_person_id, business_key, taxonomy_id, version_number, status,
    change_summary, effective_from, content_digest
  ) values (
    v_tenant, 'taxonomy-version:case_party_role:1', v_party_taxonomy, 1, 'published',
    'Initial Case party role vocabulary.', now(), encode(extensions.digest('case_party_role:v1', 'sha256'), 'hex')
  )
  on conflict (juristic_person_id, business_key) do update set updated_at = now()
  returning id into v_party_version;

  insert into taxonomy.taxonomy_terms (
    juristic_person_id, business_key, taxonomy_id, term_code, canonical_label, introduced_version_id
  ) values
    (v_tenant, 'term:case_party_role:reporter', v_party_taxonomy, 'reporter', 'Reporter', v_party_version),
    (v_tenant, 'term:case_party_role:affected_party', v_party_taxonomy, 'affected_party', 'Affected Party', v_party_version),
    (v_tenant, 'term:case_party_role:representative', v_party_taxonomy, 'representative', 'Representative', v_party_version)
  on conflict (juristic_person_id, business_key) do update set canonical_label = excluded.canonical_label, updated_at = now();

  insert into taxonomy.taxonomies (
    juristic_person_id, business_key, taxonomy_code, name, purpose, governance_mode
  ) values (
    v_tenant, 'taxonomy:organization_relationship_type', 'organization_relationship_type',
    'Organization Relationship Types', 'Identifies how a person or external organization participates in the Juristic Person.', 'controlled'
  )
  on conflict (juristic_person_id, business_key) do update set name = excluded.name, updated_at = now()
  returning id into v_relationship_taxonomy;

  insert into taxonomy.taxonomy_versions (
    juristic_person_id, business_key, taxonomy_id, version_number, status,
    change_summary, effective_from, content_digest
  ) values (
    v_tenant, 'taxonomy-version:organization_relationship_type:1', v_relationship_taxonomy, 1, 'published',
    'Initial organization relationship vocabulary.', now(), encode(extensions.digest('organization_relationship_type:v1', 'sha256'), 'hex')
  )
  on conflict (juristic_person_id, business_key) do update set updated_at = now()
  returning id into v_relationship_version;

  insert into taxonomy.taxonomy_terms (
    juristic_person_id, business_key, taxonomy_id, term_code, canonical_label, introduced_version_id
  ) values
    (v_tenant, 'term:organization_relationship_type:resident', v_relationship_taxonomy, 'resident', 'Resident', v_relationship_version),
    (v_tenant, 'term:organization_relationship_type:staff', v_relationship_taxonomy, 'staff', 'Staff', v_relationship_version),
    (v_tenant, 'term:organization_relationship_type:technician', v_relationship_taxonomy, 'technician', 'Technician', v_relationship_version),
    (v_tenant, 'term:organization_relationship_type:vendor', v_relationship_taxonomy, 'vendor', 'Vendor', v_relationship_version),
    (v_tenant, 'term:organization_relationship_type:committee', v_relationship_taxonomy, 'committee', 'Committee', v_relationship_version)
  on conflict (juristic_person_id, business_key) do update set canonical_label = excluded.canonical_label, updated_at = now();
end $$;

comment on table org.role_definitions is 'Includes tenant-scoped bootstrap roles; roles do not replace Mandates or Capability.';
comment on table org.permission_definitions is 'Includes tenant-scoped permission vocabulary; permissions do not replace RLS or Mandates.';


-- ============================================================================
-- Source: sql/15_validation.sql
-- ============================================================================

-- O83 Care executable database validation.
-- Raises exceptions on critical structural, integrity, RLS, or history gaps.

do $$
declare v_count integer; v_details text;
begin
  select count(*) into v_count
  from pg_tables
  where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration']);
  if v_count <> 135 then
    raise exception 'Expected 135 O83 tables, found %', v_count;
  end if;

  select count(*) into v_count
  from pg_tables t
  where t.schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
    and not exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = t.schemaname and c.relname = t.tablename and c.relrowsecurity
    );
  if v_count <> 0 then
    raise exception 'Found % O83 tables without RLS', v_count;
  end if;

  if exists (select 1 from intake.cases c left join intake.reports r on r.id = c.report_id where r.id is null) then
    raise exception 'Orphan Case without Report';
  end if;
  if exists (select report_id from intake.cases group by report_id having count(*) > 1) then
    raise exception 'One Report is linked to multiple Cases';
  end if;
  if exists (select 1 from incident.incidents i left join decision.decision_records d on d.id = i.verification_decision_id where d.id is null) then
    raise exception 'Incident without verification Decision';
  end if;
  if exists (select 1 from incident.case_incident_associations a where a.decision_id is null or a.mandate_id is null or a.assessment_id is null) then
    raise exception 'Case-Incident Association missing Decision, Authority, or Assessment';
  end if;
  if exists (
    select 1 from work.operations o
    where o.current_state not in ('proposed','cancelled')
      and not exists (select 1 from work.incident_operations io where io.operation_id = o.id)
      and not exists (select 1 from work.maintenance_plan_operations mo where mo.operation_id = o.id)
  ) then raise exception 'Authorized Operation without Incident or Maintenance Plan origin'; end if;
  if exists (
    select 1 from work.operations o
    where o.current_state not in ('proposed','cancelled')
      and not exists (select 1 from work.operation_assets oa where oa.operation_id = o.id)
  ) then raise exception 'Authorized Operation without work subject'; end if;

  if exists (select 1 from evidence.evidence_items where content_digest is null or original_storage_object_key is null) then
    raise exception 'Evidence without digest or original object identity';
  end if;
  if exists (select 1 from decision.decision_records where responsible_person_id is null or rationale is null) then
    raise exception 'Decision without responsible human or rationale';
  end if;
  if exists (select 1 from knowledge.knowledge_versions kv where kv.status = 'published' and not exists (select 1 from knowledge.validity_contexts vc where vc.knowledge_version_id = kv.id)) then
    raise exception 'Published Knowledge without Validity Context';
  end if;

  select string_agg(
           format('%s: %s', duplicate_table::regclass, duplicate_indexes),
           E'\n'
         )
    into v_details
  from (
    select i.indrelid as duplicate_table,
           string_agg(idx.relname, ', ' order by idx.relname) as duplicate_indexes
    from pg_index i
    join pg_class idx on idx.oid = i.indexrelid
    join pg_class c on c.oid = i.indrelid
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration'])
    group by i.indrelid, i.indkey, i.indclass, i.indcollation, i.indoption,
             pg_get_expr(i.indexprs, i.indrelid), pg_get_expr(i.indpred, i.indrelid)
    having count(*) > 1
  ) duplicates;
  if v_details is not null then
    raise exception 'Duplicated index definition detected:%', E'\n' || v_details;
  end if;

  raise notice 'O83 structural and domain validation passed';
end $$;

-- Diagnostic result sets for migration review.
select count(*) as table_count
from pg_tables
where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration']);

select count(*) as constraint_count
from pg_constraint c join pg_namespace n on n.oid = c.connamespace
where n.nspname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration']);

select count(*) as index_count
from pg_indexes
where schemaname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration']);

select count(*) as trigger_count
from pg_trigger t join pg_class c on c.oid = t.tgrelid join pg_namespace n on n.oid = c.relnamespace
where not t.tgisinternal and n.nspname = any (array['iam','org','property','taxonomy','intake','investigation','incident','work','evidence','decision','knowledge','workflow','notification','governance','ai','audit','analytics','memory','integration']);


-- ============================================================================
-- Source: sql/16_migration.sql
-- ============================================================================

-- O83 Care migration assembly guard.
-- The 00-15 scripts are the readable source set. Production migration files must
-- be created by the installed Supabase CLI and must preserve this ordering.

do $$
begin
  if current_setting('server_version_num')::integer < 150000 then
    raise exception 'O83 requires PostgreSQL 15 or newer for reviewed view/RLS behavior';
  end if;
  if not exists (select 1 from pg_extension where extname = 'pgcrypto') then
    raise exception 'O83 pgcrypto extension is missing';
  end if;
  if not exists (select 1 from pg_namespace where nspname = 'api') then
    raise exception 'O83 API boundary schema is missing';
  end if;
  if exists (
    select 1 from pg_tables
    where schemaname = 'public'
      and tablename like 'o83%'
  ) then
    raise exception 'O83 authoritative tables must not be created in public schema';
  end if;
  raise notice 'O83 migration assembly preconditions passed; run 15_validation.sql and Supabase advisors after migration';
end $$;

-- Reload PostgREST schema metadata after the complete migration is committed.
notify pgrst, 'reload schema';
