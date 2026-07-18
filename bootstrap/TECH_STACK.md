# Technical Stack

## Runtime and package management

Node.js 22.12+ and pnpm 11.9 are the engineering baseline. Dependencies are exact-pinned and the lockfile is committed. Upgrades use automated pull requests, compatibility review, and the full quality pipeline.

## Frontend

React 19.2, TypeScript 6.0, Vite 8.1, Tailwind CSS 4.3 through the Vite plugin, React Router 7.18, and TanStack Query 5.101. React owns rendering, Router owns route composition, Query owns remote state, and Tailwind/theme tokens own presentation. Vitest and Testing Library provide automated tests.

## Backend platform

Supabase supplies hosted PostgreSQL, Auth, Storage, and platform services. `@supabase/supabase-js` 2.110 is the client library. The browser receives only the URL and publishable key. Private schemas, RLS, explicit grants, mediated privileged operations, immutable audit/history, and Storage metadata alignment follow the approved database architecture.

## Delivery

Vercel hosts the Vite SPA from `frontend/`; the committed rewrite supports client-side routes. GitHub Actions installs from the frozen lockfile, checks format, lints, type-checks, tests, and builds. Supabase migration deployment remains a separately approved environment workflow until Sprint 0 live validation passes.

## Version policy

Major upgrades require compatibility review and a recorded change Decision when they affect security, persistence, runtime behavior, accessibility, or architecture. The Supabase changelog and CLI help are checked before platform changes. Pre-release dependencies are prohibited in production without explicit approval.
