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
