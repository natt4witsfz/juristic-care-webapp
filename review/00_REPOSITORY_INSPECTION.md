# Repository Inspection

Version: 1.0  
Date: 2026-07-17  
Status: Complete

## Purpose

This inspection establishes the implementation baseline before the continuous O83 Care build. It distinguishes reusable approved work from missing executable behavior and protects historical material from accidental replacement.

## Repository inventory

| Area | Files found | Assessment |
| --- | ---: | --- |
| `architecture/` | 1 Markdown file | Navigation stub only; requires normalization |
| `architecture_v2/` | 32 Markdown files, about 90 KB | Complete Version 2 architecture; primary reusable source |
| `database/` | 18 files, about 120 KB | Complete database architecture and folder guidance |
| `sql/` | 17 SQL files, about 240 KB | Extensive generated schema, constraints, indexes, functions, history, audit, Storage, RLS, permissions, seed, validation, and migration guidance |
| `supabase/` | CLI config, seed entry point, migration/readme folders | Initialized but contains no executable timestamped migration |
| `planning/` | 10 Markdown files, about 110 KB | Mature roadmap, dependency graph, sprints, releases, risk, acceptance, milestones, and estimation |
| `frontend/` | 47 source/configuration files | Validated Sprint 00 React shell with routing, query provider, environment validation, diagnostics, accessibility foundations, Vitest, and Playwright |
| `backend/` | 15 source/configuration files | Generic TypeScript Supabase, repository, service, validation, and result boundaries; not a deployed API |
| `docs/` | 12 Markdown files | Strong developer foundation; role and production-operation guides remain missing |
| `review/` | 35 historical reports before this report | Architecture, domain, database, SQL, and Sprint 00 evidence preserved |
| `.github/`, `scripts/` | CI, templates, dependency automation, setup and checks | Reusable CI foundation |
| `source_architecture/` | Empty | Not a blocker; Version 2 exists elsewhere |
| `backup/` | Empty | Must receive materially replaced files before normalization |

## Existing architecture

The documents in `architecture_v2/` express the required O83 invariants: every Report creates a separate Case; Investigation associates Cases with a verified Incident; Operations resolve Incidents; Operational Truth is versioned and evidence-bound; organizational history is immutable; accountability dimensions remain separate; AI is advisory; safety overrides recording order; and Organizational Memory belongs to the Juristic Person. They are substantially stronger than the `architecture/README.md` stub and are suitable for normalization after status and cross-reference review.

The database documentation and SQL use bounded schemas and preserve evidence, decision, responsibility, operational-truth, knowledge, timeline, and audit histories. Before execution, SQL naming, migration order, RLS grants, Storage policies, Supabase Auth mappings, and current Supabase behavior require validation.

## Existing application code

The frontend is runnable and contains no business module. Reusable work includes React 19, strict TypeScript, Vite, Tailwind CSS, React Router, TanStack Query, a lazy browser-safe Supabase client, typed environment validation, a system-status page, safe error boundaries, semantic layout, tests, Vercel configuration, and a frozen pnpm lockfile. The sign-in route is intentionally a placeholder and must become a real Supabase Auth flow.

The backend package is a shared infrastructure library rather than a network service. It can host domain-neutral schemas and contracts, but browser-facing business authorization must remain enforced by PostgreSQL grants, RLS, and controlled database functions.

## Reusable work

- all Version 2 architecture documents;
- all database architecture documents;
- the generated SQL baseline after executable-order validation;
- the approved roadmap and prior review evidence;
- the complete Sprint 00 workspace, toolchain, tests, CI, and developer documentation;
- existing environment and Supabase client boundaries;
- Vercel SPA routing and baseline security headers.

## Conflicts and resolutions

1. The current `architecture/` path is incomplete while `architecture_v2/` is complete. The Version 2 documents will be copied into `architecture/`; the original stub will be backed up and history retained in `architecture_v2/`.
2. Required SQL filenames use plural `schemas`, `types`, and `seed_reference_data`; existing complete files use singular legacy names. Required canonical copies will be created without deleting the legacy history.
3. Earlier Sprint 00 deliberately prohibited schema and feature work. The current continuous-workflow instruction explicitly authorizes those later phases and supersedes that implementation boundary without invalidating its evidence.
4. The database architecture favors private bounded schemas while a browser application needs a practical Data API surface. The implementation will expose only explicitly granted, RLS-protected tables/functions and will retain tenant predicates.
5. The project has one initial property but the existing tenant key is retained to preserve the Juristic Person’s memory and future portability.

## Missing inputs

No hosted Supabase project reference, real Supabase URL/key, SMTP configuration, Vercel account, legal retention schedule, Thai privacy/legal sign-off, production committee mandates, or production identities were supplied. Safe local configuration and synthetic reference data can be implemented; hosted deployment, email delivery, and jurisdictional approval cannot be claimed.

## Migration and delivery risks

- the SQL baseline is large and must be applied in deterministic order;
- Docker is not available on the inspected host, so local Supabase execution may be blocked;
- timestamped migrations must be generated by the pinned Supabase CLI rather than invented;
- existing SQL may contain generated relationships that require PostgreSQL execution to reveal ordering or syntax defects;
- RLS must avoid trusting user metadata and must combine grants with tenant, relationship, and role predicates;
- Storage objects are not covered by database-only backups;
- live Auth and email recovery cannot be proven without a configured Supabase project;
- the requested scope exceeds one conventional sprint, so final readiness must distinguish implemented foundations from production-complete operations.

## Planned actions

1. Back up and normalize Version 2 architecture into `architecture/`, validate scenarios, and correct contradictions.
2. Preserve and normalize database documentation and SQL naming.
3. Generate a timestamped Supabase migration through the pinned CLI, then add database and RLS validation artifacts.
4. Update roadmap documents to the required canonical names without deleting historical planning.
5. Implement Supabase Auth, data-driven role/permission resolution, protected routes, and safe recovery flows.
6. Implement dependency-safe vertical slices for organization/property, Case/Investigation/Incident, Operation/responsibility, Evidence/completion/follow-up, announcements/deadlines, reporting, and permission administration.
7. Add a mock-only AI recommendation boundary with immutable human review.
8. Run all locally supported validation, perform security/privacy review, complete deployment and operations documentation, and issue a truthful final readiness decision.
