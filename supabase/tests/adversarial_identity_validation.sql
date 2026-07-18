-- O83 Care adversarial real-JWT identity, cross-tenant, account, role, Mandate,
-- Commitment, Evidence-intake, and command-boundary tests.
begin;

create extension if not exists pgtap with schema extensions;
select extensions.plan(29);

insert into auth.users (id) values
  ('20000000-0000-4000-8000-000000000001'),
  ('20000000-0000-4000-8000-000000000002'),
  ('20000000-0000-4000-8000-000000000003'),
  ('20000000-0000-4000-8000-000000000004'),
  ('20000000-0000-4000-8000-000000000005'),
  ('20000000-0000-4000-8000-000000000006');

insert into org.juristic_persons (id, business_key, legal_name, country_code, timezone, default_locale) values
  ('10000000-0000-4000-8000-000000000001', 'test-tenant-a', 'Adversarial Tenant A', 'TH', 'Asia/Bangkok', 'en'),
  ('10000000-0000-4000-8000-000000000002', 'test-tenant-b', 'Adversarial Tenant B', 'TH', 'Asia/Bangkok', 'en');

insert into taxonomy.taxonomies (id, juristic_person_id, business_key, taxonomy_code, name, purpose, governance_mode) values
  ('50000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'taxonomy-a', 'fixture', 'Fixture taxonomy A', 'Adversarial fixtures', 'controlled'),
  ('50000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000002', 'taxonomy-b', 'fixture', 'Fixture taxonomy B', 'Adversarial fixtures', 'controlled');
insert into taxonomy.taxonomy_versions (id, juristic_person_id, business_key, taxonomy_id, version_number, status) values
  ('51000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'taxonomy-version-a', '50000000-0000-4000-8000-000000000001', 1, 'published'),
  ('51000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000002', 'taxonomy-version-b', '50000000-0000-4000-8000-000000000002', 1, 'published');
insert into taxonomy.taxonomy_terms (id, juristic_person_id, business_key, taxonomy_id, term_code, canonical_label, descriptions, introduced_version_id) values
  ('52000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'term-a-relationship', '50000000-0000-4000-8000-000000000001', 'relationship', 'Relationship', '{}'::jsonb, '51000000-0000-4000-8000-000000000001'),
  ('52000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'term-a-reporter', '50000000-0000-4000-8000-000000000001', 'reporter', 'Reporter', '{}'::jsonb, '51000000-0000-4000-8000-000000000001'),
  ('52000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001', 'term-a-operation', '50000000-0000-4000-8000-000000000001', 'repair', 'Repair', '{}'::jsonb, '51000000-0000-4000-8000-000000000001'),
  ('52000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', 'term-b-relationship', '50000000-0000-4000-8000-000000000002', 'relationship', 'Relationship', '{}'::jsonb, '51000000-0000-4000-8000-000000000002'),
  ('52000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000002', 'term-b-operation', '50000000-0000-4000-8000-000000000002', 'repair', 'Repair', '{}'::jsonb, '51000000-0000-4000-8000-000000000002');

insert into org.people (id, juristic_person_id, business_key, person_code, display_name) values
  ('30000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'person-manager-a', 'MGR-A', 'Manager A'),
  ('30000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'person-resident-a', 'RES-A', 'Resident A'),
  ('30000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001', 'person-technician-a', 'TECH-A', 'Technician A'),
  ('30000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', 'person-admin-b', 'ADM-B', 'Admin B'),
  ('30000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000001', 'person-disabled-a', 'DIS-A', 'Disabled A'),
  ('30000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000001', 'person-expired-a', 'EXP-A', 'Expired Role A');

insert into org.organization_relationships (id, juristic_person_id, business_key, person_id, relationship_type_term_id, relationship_state) values
  ('40000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'relationship-manager-a', '30000000-0000-4000-8000-000000000001', '52000000-0000-4000-8000-000000000001', 'effective'),
  ('40000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'relationship-resident-a', '30000000-0000-4000-8000-000000000002', '52000000-0000-4000-8000-000000000001', 'effective'),
  ('40000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001', 'relationship-technician-a', '30000000-0000-4000-8000-000000000003', '52000000-0000-4000-8000-000000000001', 'effective'),
  ('40000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', 'relationship-admin-b', '30000000-0000-4000-8000-000000000004', '52000000-0000-4000-8000-000000000004', 'effective'),
  ('40000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000001', 'relationship-disabled-a', '30000000-0000-4000-8000-000000000005', '52000000-0000-4000-8000-000000000001', 'effective'),
  ('40000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000001', 'relationship-expired-a', '30000000-0000-4000-8000-000000000006', '52000000-0000-4000-8000-000000000001', 'effective');

insert into iam.user_accounts (id, juristic_person_id, business_key, auth_user_id, person_id, account_state, disabled_at) values
  ('41000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'account-manager-a', '20000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', 'active', null),
  ('41000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'account-resident-a', '20000000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-000000000002', 'active', null),
  ('41000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001', 'account-technician-a', '20000000-0000-4000-8000-000000000003', '30000000-0000-4000-8000-000000000003', 'active', null),
  ('41000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', 'account-admin-b', '20000000-0000-4000-8000-000000000004', '30000000-0000-4000-8000-000000000004', 'active', null),
  ('41000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000001', 'account-disabled-a', '20000000-0000-4000-8000-000000000005', '30000000-0000-4000-8000-000000000005', 'disabled', now()),
  ('41000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000001', 'account-expired-a', '20000000-0000-4000-8000-000000000006', '30000000-0000-4000-8000-000000000006', 'active', null);

insert into org.role_definitions (id, juristic_person_id, business_key, role_code, name) values
  ('60000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'role-manager-a', 'juristic_manager', 'Manager'),
  ('60000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'role-resident-a', 'resident', 'Resident'),
  ('60000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001', 'role-technician-a', 'technician', 'Technician'),
  ('60000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', 'role-admin-b', 'admin', 'Administrator');
insert into org.permission_definitions (id, juristic_person_id, business_key, permission_code, name, resource_type, action_code) values
  ('61000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'permission-case-create-a', 'case.create', 'Create Case', 'case', 'create'),
  ('61000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'permission-case-read-a', 'case.read', 'Read Case', 'case', 'read'),
  ('61000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001', 'permission-evidence-create-a', 'evidence.create', 'Create Evidence', 'evidence', 'create'),
  ('61000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000001', 'permission-operation-accept-a', 'operation.accept', 'Accept Operation', 'operation', 'accept'),
  ('61000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000002', 'permission-case-create-b', 'case.create', 'Create Case', 'case', 'create'),
  ('61000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000001', 'permission-operation-manage-a', 'operation.manage', 'Manage Operation', 'operation', 'manage'),
  ('61000000-0000-4000-8000-000000000007', '10000000-0000-4000-8000-000000000001', 'permission-report-read-a', 'report.read', 'Read Governed Reports', 'report', 'read');
insert into org.role_assignments (id, juristic_person_id, business_key, organization_relationship_id, role_definition_id, recorded_to) values
  ('62000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'role-assignment-manager-a', '40000000-0000-4000-8000-000000000001', '60000000-0000-4000-8000-000000000001', null),
  ('62000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'role-assignment-resident-a', '40000000-0000-4000-8000-000000000002', '60000000-0000-4000-8000-000000000002', null),
  ('62000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001', 'role-assignment-technician-a', '40000000-0000-4000-8000-000000000003', '60000000-0000-4000-8000-000000000003', null),
  ('62000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', 'role-assignment-admin-b', '40000000-0000-4000-8000-000000000004', '60000000-0000-4000-8000-000000000004', null),
  ('62000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000001', 'role-assignment-expired-a', '40000000-0000-4000-8000-000000000006', '60000000-0000-4000-8000-000000000001', now() - interval '1 day');
insert into org.role_permissions (juristic_person_id, business_key, role_definition_id, permission_definition_id, effect) values
  ('10000000-0000-4000-8000-000000000001', 'role-permission-manager-case-create', '60000000-0000-4000-8000-000000000001', '61000000-0000-4000-8000-000000000001', 'allow'),
  ('10000000-0000-4000-8000-000000000001', 'role-permission-manager-case-read', '60000000-0000-4000-8000-000000000001', '61000000-0000-4000-8000-000000000002', 'allow'),
  ('10000000-0000-4000-8000-000000000001', 'role-permission-manager-evidence', '60000000-0000-4000-8000-000000000001', '61000000-0000-4000-8000-000000000003', 'allow'),
  ('10000000-0000-4000-8000-000000000001', 'role-permission-resident-read', '60000000-0000-4000-8000-000000000002', '61000000-0000-4000-8000-000000000002', 'allow'),
  ('10000000-0000-4000-8000-000000000001', 'role-permission-resident-evidence', '60000000-0000-4000-8000-000000000002', '61000000-0000-4000-8000-000000000003', 'allow'),
  ('10000000-0000-4000-8000-000000000001', 'role-permission-technician-accept', '60000000-0000-4000-8000-000000000003', '61000000-0000-4000-8000-000000000004', 'allow'),
  ('10000000-0000-4000-8000-000000000002', 'role-permission-admin-case-create', '60000000-0000-4000-8000-000000000004', '61000000-0000-4000-8000-000000000005', 'allow'),
  ('10000000-0000-4000-8000-000000000001', 'role-permission-manager-operation-manage', '60000000-0000-4000-8000-000000000001', '61000000-0000-4000-8000-000000000006', 'allow'),
  ('10000000-0000-4000-8000-000000000001', 'role-permission-manager-report-read', '60000000-0000-4000-8000-000000000001', '61000000-0000-4000-8000-000000000007', 'allow');

insert into intake.reports (id, juristic_person_id, business_key, report_number, channel, submitted_payload, submitted_text, acceptance_state, classification) values
  ('70000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'report-a-1', 'RPT-A-1', 'resident_form', '{}'::jsonb, 'Resident A Case', 'accepted', 'confidential'),
  ('70000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'report-a-2', 'RPT-A-2', 'resident_form', '{}'::jsonb, 'Other A Case', 'accepted', 'confidential'),
  ('70000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', 'report-b-1', 'RPT-B-1', 'resident_form', '{}'::jsonb, 'Tenant B Case', 'accepted', 'confidential');
insert into intake.cases (id, juristic_person_id, business_key, case_number, report_id, current_summary) values
  ('71000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'case-a-1', 'CASE-A-1', '70000000-0000-4000-8000-000000000001', 'Resident A Case'),
  ('71000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'case-a-2', 'CASE-A-2', '70000000-0000-4000-8000-000000000002', 'Other A Case'),
  ('71000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', 'case-b-1', 'CASE-B-1', '70000000-0000-4000-8000-000000000003', 'Tenant B Case');
insert into intake.case_party_relationships (juristic_person_id, business_key, case_id, organization_relationship_id, party_role_term_id, visibility_scope) values
  ('10000000-0000-4000-8000-000000000001', 'case-party-a-1', '71000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000002', '52000000-0000-4000-8000-000000000002', '{"case_status":true}'::jsonb);

insert into org.responsibility_definitions (id, juristic_person_id, business_key, responsibility_code, name, outcome_definition, scope_type) values
  ('73000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'responsibility-a', 'RESP-A', 'Tenant A work', 'Responsible for test work', 'juristic_person'),
  ('73000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000002', 'responsibility-b', 'RESP-B', 'Tenant B work', 'Responsible for test work', 'juristic_person');
insert into org.responsibility_assignments (id, juristic_person_id, business_key, assignment_code, responsibility_definition_id, responsible_relationship_id, scope_type, scope_id) values
  ('73100000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'responsibility-assignment-a', 'RA-A', '73000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000001', 'juristic_person', '10000000-0000-4000-8000-000000000001'),
  ('73100000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000002', 'responsibility-assignment-b', 'RA-B', '73000000-0000-4000-8000-000000000002', '40000000-0000-4000-8000-000000000004', 'juristic_person', '10000000-0000-4000-8000-000000000002');
insert into work.operations (id, juristic_person_id, business_key, operation_number, operation_type_term_id, title, scope, desired_outcome, responsibility_assignment_id, current_state) values
  ('72000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'operation-a', 'OP-A', '52000000-0000-4000-8000-000000000003', 'Repair A', 'Test scope A', 'Test outcome A', '73100000-0000-4000-8000-000000000001', 'authorized'),
  ('72000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000002', 'operation-b', 'OP-B', '52000000-0000-4000-8000-000000000005', 'Repair B', 'Test scope B', 'Test outcome B', '73100000-0000-4000-8000-000000000002', 'authorized');

insert into org.mandates (id, juristic_person_id, business_key, mandate_code, grantee_relationship_id, grantor_type, grantor_id, authority_actions, scope_type, delegation_allowed, source_type, source_id, valid_from, valid_to) values
  ('63000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'expired-mandate-a', 'MAN-EXPIRED-A', '40000000-0000-4000-8000-000000000001', 'person', '30000000-0000-4000-8000-000000000001', array['incident.verify'], 'juristic_person', false, 'test', '30000000-0000-4000-8000-000000000001', now() - interval '2 days', now() - interval '1 day'),
  ('63000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'operation-mandate-a', 'MAN-OP-A', '40000000-0000-4000-8000-000000000001', 'person', '30000000-0000-4000-8000-000000000001', array['operation.transition'], 'juristic_person', false, 'test', '30000000-0000-4000-8000-000000000001', now() - interval '1 day', now() + interval '1 day');

set local role authenticated;
select set_config('request.jwt.claim.role', 'authenticated', true);

select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000001', true);
select extensions.is((select count(*) from intake.cases), 2::bigint, 'Tenant A manager sees both own-tenant Cases');
select extensions.is((select count(*) from intake.cases where juristic_person_id = '10000000-0000-4000-8000-000000000002'), 0::bigint, 'Tenant A manager cannot read Tenant B Case');
select extensions.throws_ok(
  $$select api.create_case('10000000-0000-4000-8000-000000000002','resident_form','cross tenant attempt',null,null)$$,
  '42501', 'No active membership may create a Case for this organization.', 'controlled command rejects cross-tenant identity substitution'
);
select extensions.is((select count(*) from api.current_authority_context where mandate_id = '63000000-0000-4000-8000-000000000001'), 0::bigint, 'expired Mandate is absent from the current Authority boundary');
select extensions.is(api.transition_operation('10000000-0000-4000-8000-000000000001','72000000-0000-4000-8000-000000000001',1,'scheduled','Scheduled by the accountable manager for the fixture window.','62000000-0000-4000-8000-000000000001','63000000-0000-4000-8000-000000000002',now())->>'current_state', 'scheduled', 'authorized manager and exact Mandate execute a valid Operation transition');
select extensions.is((select count(*) from workflow.state_transitions where aggregate_type = 'Operation' and aggregate_id = '72000000-0000-4000-8000-000000000001' and current_state = 'scheduled' and mandate_id = '63000000-0000-4000-8000-000000000002'), 1::bigint, 'Operation command appends the exact Mandate-bound immutable Timeline transition');
select extensions.is((select count(*) from notification.notification_audiences a join notification.notification_intents i on i.id = a.notification_intent_id where i.responsibility_assignment_id = '73100000-0000-4000-8000-000000000001' and a.organization_relationship_id = '40000000-0000-4000-8000-000000000001'), 1::bigint, 'Operation event routes one notification to the explicitly responsible relationship');
reset role;
select extensions.is((select count(*) from audit.audit_entries where target_type = 'work.operations' and target_id = '72000000-0000-4000-8000-000000000001' and action_code = 'update' and reason = 'Scheduled by the accountable manager for the fixture window.' and old_value->>'current_state' = 'authorized' and new_value->>'current_state' = 'scheduled'), 1::bigint, 'Operation command audit preserves actor context, reason, and before/after state');
set local role authenticated;
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000001', true);
select set_config('test.memory_intent', api.begin_memory_transfer('10000000-0000-4000-8000-000000000001','report_snapshot','{"scope":"operational"}'::jsonb,'40000000-0000-4000-8000-000000000001')::text, true);
select extensions.is(current_setting('test.memory_intent')::jsonb->>'state', 'preparing', 'authorized custodian begins a governed private Organizational Memory transfer');
reset role;
insert into storage.objects (bucket_id, name, owner_id, metadata) values ('o83-memory-archive', current_setting('test.memory_intent')::jsonb->>'object_key', '20000000-0000-4000-8000-000000000001', '{}'::jsonb);
select set_config('test.memory_result', api.finalize_memory_transfer('10000000-0000-4000-8000-000000000001',(current_setting('test.memory_intent')::jsonb->>'manifest_id')::uuid,current_setting('test.memory_intent')::jsonb->>'object_key',repeat('b',64),jsonb_build_array(jsonb_build_object('source_type','projection','source_version','1','object_reference','api.operation_workspace','content_digest',repeat('c',64),'retention_state','active','verification_result','passed')),'passed','TEST-REPORT',now() - interval '1 day',now())::text, true);
select extensions.ok(current_setting('test.memory_result')::jsonb->>'state' = 'sealed' and nullif(current_setting('test.memory_result')::jsonb->>'report_snapshot_id','') is not null, 'trusted finalizer seals a digest-verified Memory manifest and reproducible report snapshot');
select extensions.throws_ok(format('update memory.memory_manifests set content_digest = %L where id = %L', repeat('f',64), current_setting('test.memory_intent')::jsonb->>'manifest_id'), 'P0001', 'Completed Organizational Memory manifests are immutable', 'sealed Organizational Memory cannot be overwritten');
set local role authenticated;
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000001', true);
select set_config('test.offline_result', api.submit_offline_envelope('10000000-0000-4000-8000-000000000001','offline-fixture-1','operation_note','1','{"observation":"scheduled while disconnected"}'::jsonb,null,'operation','72000000-0000-4000-8000-000000000001',1,now() - interval '1 hour')::text, true);
select extensions.ok(current_setting('test.offline_result')::jsonb->>'state' = 'conflict' and (current_setting('test.offline_result')::jsonb->>'actual_version')::bigint = 2, 'offline stale version records an explicit conflict without overwriting the Operation');
select extensions.is(api.submit_offline_envelope('10000000-0000-4000-8000-000000000001','offline-fixture-1','operation_note','1','{"observation":"scheduled while disconnected"}'::jsonb,null,'operation','72000000-0000-4000-8000-000000000001',1,now() - interval '1 hour')->>'state', 'duplicate', 'offline envelope identity is idempotent on retry');
select extensions.throws_ok($$select api.submit_offline_envelope('10000000-0000-4000-8000-000000000001','offline-fixture-2','operation_note','1','{"observation":"tampered"}'::jsonb,repeat('f',64),'operation','72000000-0000-4000-8000-000000000001',2,now())$$, '23514', 'Offline payload digest does not match the submitted bytes.', 'offline envelope rejects a caller-supplied digest mismatch');
select extensions.throws_ok(
  $$select api.begin_evidence_upload('10000000-0000-4000-8000-000000000001','case','71000000-0000-4000-8000-000000000003','cross.txt','text/plain',4,repeat('a',64))$$,
  '42501', 'The Evidence target is not accessible.', 'Evidence intent rejects cross-tenant target'
);

select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000002', true);
select extensions.is((select count(*) from intake.cases), 1::bigint, 'resident sees only the Case carrying their effective party relationship');
select extensions.is((select count(*) from intake.cases where id = '71000000-0000-4000-8000-000000000002'), 0::bigint, 'resident cannot read another Case in the same tenant');
select set_config('test.evidence_intent', api.begin_evidence_upload('10000000-0000-4000-8000-000000000001','case','71000000-0000-4000-8000-000000000001','resident.txt','text/plain',4,repeat('a',64))::text, true);
select extensions.ok(current_setting('test.evidence_intent')::jsonb->>'object_key' like '10000000-0000-4000-8000-000000000001/%', 'resident receives only an own-tenant intent path for an authorized Case');
select extensions.lives_ok($$insert into storage.objects (bucket_id, name, owner_id, metadata) values ('o83-evidence-intake', current_setting('test.evidence_intent')::jsonb->>'object_key', auth.uid()::text, '{}'::jsonb)$$, 'issued Evidence intent authorizes its exact uploader and object path through Storage RLS');
reset role;
select set_config('test.quarantine_result', api.quarantine_evidence_upload('10000000-0000-4000-8000-000000000001',(current_setting('test.evidence_intent')::jsonb->>'upload_id')::uuid,repeat('d',64),'File signature does not match declared type.')::text, true);
select extensions.is(current_setting('test.quarantine_result')::jsonb->>'state', 'quarantined', 'trusted processor records the Evidence quarantine outcome');
select extensions.is((select count(*) from evidence.upload_attachments where upload_id = current_setting('test.evidence_intent')::jsonb->>'upload_id' and scan_state = 'quarantined' and observed_digest = repeat('d',64)), 1::bigint, 'Evidence quarantine preserves the observed digest and rejected intake state');
set local role authenticated;
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000002', true);
select extensions.is((select count(*) from storage.objects where bucket_id = 'o83-evidence-intake' and name = current_setting('test.evidence_intent')::jsonb->>'object_key'), 0::bigint, 'quarantined intake bytes are no longer browser-readable');

select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000003', true);
select extensions.is((select count(*) from work.operations), 0::bigint, 'technician without accepted Commitment cannot read Operation');

reset role;
insert into work.commitments (id, juristic_person_id, business_key, commitment_number, operation_id, offered_by_person_id, accepted_by_relationship_id, scope, accepted_at, current_state) values
  ('74000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'commitment-a', 'COM-A', '72000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000003', 'Perform test work', now(), 'accepted');
set local role authenticated;
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000003', true);
select extensions.is((select count(*) from work.operations), 1::bigint, 'accepted Commitment grants technician access to exactly the committed Operation');
select extensions.is((select count(*) from work.operations where juristic_person_id = '10000000-0000-4000-8000-000000000002'), 0::bigint, 'Commitment never grants cross-tenant Operation access');

select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000004', true);
select extensions.is((select count(*) from intake.cases), 1::bigint, 'Tenant B admin sees only Tenant B Case');

select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000005', true);
select extensions.is((select count(*) from api.resolve_current_access()), 0::bigint, 'disabled account cannot resolve an O83 access context');

select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000006', true);
select extensions.ok(not ('juristic_manager' = any(coalesce((select roles from api.resolve_current_access() limit 1), '{}'::text[]))), 'expired role assignment grants no effective role');

select extensions.ok(not has_table_privilege('anon', 'intake.cases', 'SELECT'), 'anon retains no direct Case access under adversarial fixtures');

select * from extensions.finish();
rollback;
