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
