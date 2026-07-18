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
