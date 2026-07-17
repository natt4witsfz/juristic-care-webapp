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
