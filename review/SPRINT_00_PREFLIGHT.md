# Sprint 00 Preflight Review

Version: 1.0  
Date: 2026-07-17  
Status: Complete before implementation

## Purpose

This review records the repository state and the implementation boundary before Sprint 00 changes. It prevents the bootstrap from silently replacing approved architecture, database artifacts, planning history, or prior review evidence.

## Material reviewed

The preflight read the project instructions and the relevant architecture, planning, database, documentation, package, source, test, automation, and Supabase configuration files. The authoritative planning sequence remains the source for later feature work. The database architecture and SQL repository are historical implementation inputs and are not executed or changed by this sprint.

The repository currently contains:

- approved architecture and architecture history;
- planning documents for the full delivery sequence;
- database architecture, SQL scripts, and prior validation reports;
- an initial pnpm workspace with React, TypeScript, Vite, Tailwind CSS, React Router, TanStack Query, Supabase JavaScript, Vitest, ESLint, and Prettier;
- a neutral React shell, a generic Supabase client factory, local Supabase configuration, scripts, and a baseline CI workflow;
- no implemented O83 business module in the application workspace.

## Existing assets to preserve

The following areas are preserved without semantic alteration in Sprint 00:

- `architecture/` and `architecture_v2/`;
- `planning/`;
- `database/` and `sql/`;
- existing historical files in `review/`;
- `source_architecture/`, `rewritten_architecture/`, and `backup/` in the delivery directory;
- the generic backend boundaries under `backend/`, except for narrowly required infrastructure corrections;
- the existing Supabase CLI structure, with no schema migration or seed data introduced.

## Conflicts and resolutions

### Sprint boundary

Earlier planning associates database deployment with early implementation. The current Sprint 00 instruction explicitly prohibits database tables, schema implementation, APIs, authentication workflows, and business logic. The current instruction governs this execution. Database execution is therefore deferred and no production migration is invented.

### Supabase key terminology

The existing scaffold uses a browser-safe Supabase publishable key. Supabase currently documents publishable keys for client initialization, while legacy anonymous keys may still be encountered. Sprint 00 keeps one browser-safe publishable-key boundary and documents the terminology; service-role and secret keys are forbidden in the frontend.

### Package manager

The repository already has a pinned pnpm workspace and lockfile. Sprint 00 retains pnpm as the single supported package manager to avoid lockfile drift.

### Runtime availability

The host shell does not expose Node.js or Git on its normal `PATH`, and a container runtime is not currently available. A managed Node.js runtime is available for deterministic validation. Docker is not required for this infrastructure-only sprint because no local database or migration is authorized.

## Gaps to close

The initial scaffold does not yet satisfy all Sprint 00 acceptance criteria. The implementation must add or complete:

- the required source-directory boundaries and explanatory boundary files;
- sign-in placeholder, unauthorized, system-status, route-error, configuration-error, and not-found routes;
- environment validation with a safe startup failure and non-secret development diagnostics;
- reusable page, error, empty, loading, and header foundations;
- unit, component, route, environment, status, and Playwright smoke tests;
- explicit preview, lint-fix, formatting, coverage, end-to-end, and full-validation scripts;
- a Playwright configuration and an end-to-end CI job using non-production local test values;
- the exact Sprint 00 documentation and review evidence set;
- validation of install, development startup, build, lint, typecheck, unit tests, coverage, and end-to-end tests.

## Implementation constraints

Sprint 00 will not add resident, case, investigation, incident, operation, evidence, notification, AI, authentication, or database behavior. Placeholder routes will describe future ownership boundaries without simulating production workflows. The Supabase client will be a controlled, lazy infrastructure dependency and will make no network call during startup or tests.

No existing application feature is deleted because none exists. All changed files will be complete and runnable. Secrets, real credentials, and production data are excluded.

## Preflight decision

Proceed with incremental Sprint 00 implementation. Preserve all approved architecture and historical evidence, keep database execution deferred, and require every automated validation to pass before the go/no-go decision.
