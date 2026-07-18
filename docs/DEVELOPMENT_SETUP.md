# Development Setup

## Purpose

This guide creates a reproducible Sprint 00 workstation. It starts the infrastructure shell only; it does not deploy a database or enable O83 business behavior.

## Prerequisites

- Node.js 22.12 or later;
- pnpm 11.9.0 through Corepack;
- Git;
- Chrome, Edge, or Playwright Chromium for local end-to-end tests;
- Docker-compatible runtime only when a later authorized database task requires local Supabase.

## Setup

1. From the repository root, run `corepack enable` and `corepack prepare pnpm@11.9.0 --activate` if pnpm is unavailable.
2. Run `pnpm install --frozen-lockfile`.
3. Copy `frontend/.env.example` to `frontend/.env.local`.
4. Replace the example URL and publishable key with browser-safe development values. Never use a Supabase secret or service-role key.
5. Run `pnpm validate`.
6. Run `pnpm dev` and open `http://localhost:5173`.

The app shows a safe configuration page when required public settings are missing or invalid. The `/system-status` page reports readiness and hides configuration values.

## Common recovery

If the frozen install reports lockfile drift, do not bypass it casually; reconcile the manifest and lockfile in a reviewed dependency change. If Playwright has no browser, run `pnpm exec playwright install chromium`, or use locally installed Chrome as configured outside CI. If port 5173 is occupied, stop the conflicting local process rather than changing the committed standard port.

The Supabase CLI is project-pinned. `pnpm db:start` requires Docker, but database startup and migration execution are outside Sprint 00.
