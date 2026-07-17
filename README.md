# O83 Care Engineering Workspace

O83 Care is an operational coordination and organizational-memory system for residential Juristic Persons. This repository contains the reviewed architecture, database/SQL baseline, implementation roadmap, Supabase/Auth foundation, controlled Case and Investigation commands, and a runnable React workspace. It is a development foundation, not a production-complete system.

## Start here

1. Read [`architecture/00_foundation.md`](architecture/00_foundation.md), [`architecture/16_project_glossary.md`](architecture/16_project_glossary.md), and [`planning/00_master_roadmap.md`](planning/00_master_roadmap.md).
2. Install Node.js 22.12+, pnpm 11.9 through Corepack, Git, and a Docker-compatible runtime.
3. Copy `frontend/.env.example` to `frontend/.env.local` and insert the local or development Supabase URL and publishable key. Never use a secret/service-role key in a `VITE_` variable.
4. Run `pnpm install --frozen-lockfile`, `pnpm db:validate:static`, `pnpm validate`, and then `pnpm dev`.
5. Open `http://localhost:5173`; `/system-status` confirms public configuration without exposing values.

Local Supabase requires Docker. Run `pnpm db:start`, `pnpm db:reset`, `pnpm supabase db lint --local --level warning`, and `pnpm supabase test db` before exercising authenticated features.

## Workspace

- `frontend/` — React application, Auth/access provider, protected workspace, Case/Investigation foundation, operational projections, tests
- `backend/` — browser-safe Supabase client and generic application boundaries
- `supabase/` — CLI configuration, canonical executable migrations, and local seed entry point
- `database/`, `sql/` — approved database design and generated SQL baseline
- `architecture/` — normative reviewed architecture; `architecture_v2/` is retained historical generation input
- `planning/` — approved roadmap, feature catalog, sprints, release gates, risks, and acceptance
- `docs/`, `bootstrap/` — developer and workspace guidance
- `.github/`, `scripts/` — CI, dependency updates, task templates, setup, and verification

## Quality commands

| Command                   | Purpose                                                            |
| ------------------------- | ------------------------------------------------------------------ |
| `pnpm dev`                | Start the Vite development server                                  |
| `pnpm format:check`       | Verify formatting                                                  |
| `pnpm lint`               | Run ESLint across workspace packages                               |
| `pnpm typecheck`          | Run strict TypeScript checks                                       |
| `pnpm test`               | Run Vitest suites                                                  |
| `pnpm test:coverage`      | Run unit and component tests with coverage                         |
| `pnpm test:e2e`           | Run Playwright smoke tests                                         |
| `pnpm build`              | Create production frontend and backend type artifacts              |
| `pnpm validate`           | Run every required local quality gate                              |
| `pnpm db:validate:static` | Check canonical SQL, migration, RLS, and browser secret boundaries |

## Engineering boundary

Every incoming Report creates a separate Case. Only an authorized human investigation verifies an Incident. History is immutable; corrections supersede. Responsibility, Authority, Commitment, Capability, Availability, Organizational Priority, Execution Sequence, and SLA remain separate. Human safety precedes workflow. AI is advisory. These invariants are implementation constraints, not product copy.

See [`docs/DEVELOPMENT_SETUP.md`](docs/DEVELOPMENT_SETUP.md) for setup, [`docs/SUPABASE_SETUP.md`](docs/SUPABASE_SETUP.md) for database provisioning, [`docs/KNOWN_LIMITATIONS.md`](docs/KNOWN_LIMITATIONS.md) for the implementation boundary, and [`review/14_GO_NO_GO.md`](review/14_GO_NO_GO.md) for the production decision.
