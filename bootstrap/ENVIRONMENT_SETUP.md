# Environment Setup

## Machine prerequisites

- Node.js 22.12 or later
- Corepack and pnpm 11.9.0
- Git
- Docker Desktop or a compatible container runtime for local Supabase
- A Supabase development project for remote integration work
- A Vercel account/project for preview and production deployment

The local Supabase stack is development-only and must not be exposed to external traffic.

## Setup

1. Clone the repository and open its root.
2. Run `corepack enable` and `corepack prepare pnpm@11.9.0 --activate`.
3. Run `pnpm install --frozen-lockfile`.
4. Copy `frontend/.env.example` to `frontend/.env.local`.
5. Start Docker and run `pnpm db:start`; copy the local API URL and publishable key into `frontend/.env.local`.
6. Run `pnpm check`.
7. Run `pnpm dev` and open `http://localhost:5173`.

Windows users may run `powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1` after installing prerequisites when the local execution policy does not already permit signed workspace scripts.

## Environment variables

| Variable                        | Scope   | Rule                                              |
| ------------------------------- | ------- | ------------------------------------------------- |
| `VITE_SUPABASE_URL`             | Browser | Local/development project URL                     |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | Browser | Publishable key only; never secret/service role   |
| `VITE_APP_ENV`                  | Browser | `development`, `test`, `staging`, or `production` |

Vite variables are public by design. Server/provider secrets belong in environment-specific secret stores and are never prefixed `VITE_`, committed, logged, or placed in client bundles.

## Supabase workflow

Use `pnpm supabase --help` before commands. `pnpm db:reset` destroys the local database and reapplies migrations/seeds. The generated SQL baseline is not automatically copied into migrations: Sprint 0 validates it on a disposable stack, captures a reviewed canonical migration, and records advisor/RLS/Storage evidence.

## Vercel

Create a Vercel project with Root Directory `frontend`, install command `pnpm install --frozen-lockfile`, build command `pnpm build`, and output directory `dist`. Configure public variables per environment. Protect preview access when it may contain non-public data.
