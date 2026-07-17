-- O83 Care database structure and integrity validation.
-- Executed by `supabase test db`; all test artifacts roll back.
begin;

create extension if not exists pgtap with schema extensions;
select extensions.plan(7);

select extensions.is(
  (
    select count(*)
    from pg_tables
    where schemaname = any (array[
      'iam','org','property','taxonomy','intake','investigation','incident','work','evidence',
      'decision','knowledge','workflow','notification','governance','ai','audit','analytics',
      'memory','integration'
    ])
  ),
  135::bigint,
  'all 135 authoritative O83 tables exist'
);

select extensions.is(
  (
    select count(*)
    from pg_attribute a
    join pg_class c on c.oid = a.attrelid and c.relkind in ('r','p')
    join pg_namespace n on n.oid = c.relnamespace
    where a.attname = 'juristic_person_id'
      and not a.attisdropped
      and n.nspname = any (array[
        'iam','org','property','taxonomy','intake','investigation','incident','work','evidence',
        'decision','knowledge','workflow','notification','governance','ai','audit','analytics',
        'memory','integration'
      ])
      and not exists (
        select 1
        from pg_constraint fk
        where fk.conrelid = c.oid
          and fk.contype = 'f'
          and a.attnum = any (fk.conkey)
          and fk.confrelid = 'org.juristic_persons'::regclass
      )
  ),
  0::bigint,
  'every tenant column has a foreign key to the Juristic Person'
);

select extensions.is(
  (
    select count(*)
    from pg_constraint fk
    join pg_class tbl on tbl.oid = fk.conrelid
    join pg_namespace ns on ns.oid = tbl.relnamespace
    where fk.contype = 'f'
      and ns.nspname = any (array[
        'iam','org','property','taxonomy','intake','investigation','incident','work','evidence',
        'decision','knowledge','workflow','notification','governance','ai','audit','analytics',
        'memory','integration'
      ])
      and not exists (
        select 1
        from pg_index i
        where i.indrelid = fk.conrelid
          and i.indisvalid
          and i.indisready
          and i.indpred is null
          and (i.indkey::smallint[])[0:cardinality(fk.conkey)-1] @> fk.conkey
      )
  ),
  0::bigint,
  'every foreign key has a valid non-partial covering index'
);

select extensions.ok(
  exists (
    select 1
    from pg_constraint
    where conrelid = 'intake.cases'::regclass
      and conname = 'uq_cases_report'
      and contype = 'u'
  ),
  'one Report can be linked to at most one Case'
);

select extensions.is(
  (
    select count(*)
    from (
      select i.indrelid
      from pg_index i
      join pg_class c on c.oid = i.indrelid
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = any (array[
        'iam','org','property','taxonomy','intake','investigation','incident','work','evidence',
        'decision','knowledge','workflow','notification','governance','ai','audit','analytics',
        'memory','integration'
      ])
      group by i.indrelid, i.indkey, i.indclass, i.indcollation, i.indoption,
               pg_get_expr(i.indexprs, i.indrelid), pg_get_expr(i.indpred, i.indrelid)
      having count(*) > 1
    ) duplicated
  ),
  0::bigint,
  'authoritative tables have no duplicate index definitions'
);

select extensions.is(
  (
    select count(*)
    from storage.buckets
    where id = any (array[
      'o83-evidence-intake','o83-evidence-originals','o83-evidence-renditions',
      'o83-artifacts','o83-memory-archive'
    ])
      and public is false
  ),
  5::bigint,
  'all five O83 Storage buckets exist and are private'
);

select extensions.ok(
  exists (
    select 1
    from supabase_migrations.schema_migrations
    where version = '20260717153210'
  ),
  'the O83 baseline migration is recorded'
);

select * from extensions.finish();
rollback;
