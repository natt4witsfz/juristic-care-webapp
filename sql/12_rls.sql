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
