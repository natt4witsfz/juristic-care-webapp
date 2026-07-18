# O83 Care SQL Validation

Version: 1.0  
Status: Static Validation Passed; Supabase Execution Gate Required

## Scope

Validated all 17 SQL files for ordering, object coverage, duplicate table columns, table comments, foreign-key references, idempotent creation patterns, immutable-history protections, RLS activation, Storage isolation, and executable post-migration checks.

## Static results

| Check | Result |
|---|---|
| Required SQL files | 17 of 17 |
| Approved tables created | 131 |
| Table comments | 131 |
| Duplicate columns within a table | 0 |
| Explicit foreign-key mappings with missing source/target columns | 0 |
| SQL placeholders/TODO markers | 0 |
| Authoritative tables in `public` schema | 0 by design |
| Generic DELETE grants to authenticated | 0 |
| Use of deprecated `auth.role()` | 0 |
| Use of user-editable metadata for authorization | 0 |

## Expected deployed object counts

- Tables: 131 O83 authoritative/support tables
- Constraints: 984 expected, including 131 primary keys, 130 universal tenant foreign keys, 312 explicit foreign keys, 131 tenant business-key unique rules, 262 universal checks, and 18 domain-specific constraints
- Indexes: 751 expected before platform-managed Storage/Auth indexes, including primary/unique indexes, one index per foreign key, and 42 explicit operational/search indexes
- Triggers: 292 expected, comprising 130 mutable-row concurrency triggers, 128 row-audit triggers, 25 immutable-history triggers, 8 published-version protection triggers, and 1 Knowledge-publication constraint trigger

Counts are verified after deployment by `15_validation.sql`; platform-managed objects are excluded.

## Domain integrity

The scripts enforce one Case per Report, verified-only Incident creation, reasoned Case-Incident Associations, reactive or proactive Operation origin, Operation work subject, Work Step ownership, separate SLA target, immutable Evidence originals/packages, human Decision accountability, Knowledge Validity Context, and append-only history.

## Circular dependency strategy

All tables are created before foreign keys. Constraints are added in a separate idempotent phase, eliminating DDL creation cycles. Typed polymorphic references are limited to governed link tables and validated by domain checks; concrete relationships use foreign keys. Event/outbox and projections do not own parent lifecycle.

## Runtime validation gate

The local workspace did not provide `psql`, Supabase CLI, Docker PostgreSQL, or a connected Supabase MCP project, so the migration was not executed against a live PostgreSQL parser. Before acceptance, run files 00–16 in order on a clean current Supabase project, run `15_validation.sql`, execute Supabase database/security/performance advisors, inspect every warning, and repeat on a production-shaped restored dataset. This is a deployment gate, not missing SQL content.
