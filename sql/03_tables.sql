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
