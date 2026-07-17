# Developer Guide

## Daily workflow

Work from an approved feature and sprint. Read its architecture/database/permission references before design. Create a short-lived branch, define acceptance and negative paths, update contracts before consumers, and keep each change reviewable. Run `pnpm validate` before opening a pull request.

Use the repository/service/validation folders as boundaries, not mandatory abstraction layers. Repositories isolate persistence for one aggregate/use case. Services coordinate authorized use cases. Validation protects transport shape; database constraints and domain rules remain authoritative. UI code queries purpose-specific projections and invokes explicit commands; it must not construct generic table mutations.

## Frontend conventions

Routes are declared in `frontend/src/routes/router.tsx`. Cross-cutting providers live under `app/providers`; reusable interface components under `components`; route-level screens under `pages`; environment parsing under `config`; global theme tokens under `styles`. Feature work should use `frontend/src/features/<feature-name>/` with colocated components, queries, schemas, and tests. Loading, empty, denied, offline, conflict, error, and recovery states are part of the feature.

TanStack Query owns remote server-state caching. Local UI state stays local. Query keys must include tenant and relevant scope. Mutations invalidate or update only owned projections and rely on idempotent server commands. Never use cached data as proof of current Authority.

## Supabase conventions

The frontend receives only the project URL and publishable key. The service-role/secret key is never browser configuration. Database schemas are private by default; exposed views use invoker security and explicit grants. RLS is tested with positive and negative cases and never relies on user-editable metadata. Storage paths do not prove authorization.

Use `pnpm supabase --help` and subcommand help before CLI work. Generate migrations with `pnpm supabase migration new <name>`. Local development uses Docker and `pnpm db:start`; `pnpm db:reset` is destructive and local-only unless an explicit safe environment is selected. Production changes use the approved expand-and-contract migration plan.

## Testing pyramid

Write fast unit tests for pure rules, database tests for constraints/RLS, contract tests for commands/events, integration tests for Supabase/Storage/providers, and focused end-to-end tests for role journeys. Critical invariants require direct negative tests. Use synthetic data only. Every failure report identifies environment, build/schema/config version, correlation identifier, and expected/actual outcome.

## Observability and errors

Unexpected errors reach the error boundary and, when telemetry is added, an approved redacted sink. User-facing messages explain recovery without exposing internal details. Do not log credentials, tokens, raw Evidence, resident details, AI prompts containing restricted data, or authorization payloads. Preserve correlation identifiers across calls.

## Definition of Done

The governing Definition of Done is [`planning/06_definition_of_done.md`](../planning/06_definition_of_done.md). A merged change is not done until applicable security, accessibility, migration, operational, and acceptance evidence passes.
