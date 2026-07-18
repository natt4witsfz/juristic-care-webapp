# CI/CD Plan

## Current continuous integration

GitHub Actions runs for pull requests, `main`, and manual dispatch. It uses read-only repository permission, pinned pnpm/Node versions, frozen-lockfile installation, concurrency cancellation, a 20-minute timeout, formatting, ESLint, TypeScript, Vitest, Vite build, and retained test coverage when generated. Dependabot proposes weekly package and action updates.

## Planned database pipeline

Sprint 0 adds an isolated Supabase validation job after the canonical baseline migration is captured. It starts a disposable local stack, resets from migrations/seeds, runs `15_validation.sql`, database/security/performance advisors, and RLS/Storage negative suites. Remote deployment uses protected environments, separate migration credentials, backups, postflight validation, and human approval. It is intentionally not automated before live SQL validation.

## Vercel delivery

Pull requests create protected preview deployments from `frontend/`. `main` may deploy staging after CI. Production promotion follows the release gate, uses environment-specific variables, records deployment/build/schema/config versions, and supports immediate traffic rollback only when accepted data is unaffected. Domain/data correction uses forward correction.

## Quality and security gates

- exact dependency lock and supply-chain review;
- format, lint, strict type check, tests, build;
- secret scan and dependency review when repository integration is enabled;
- database/RLS/Storage/advisor evidence for relevant changes;
- accessibility and browser tests for released UI;
- migration/reconciliation and rollback/forward-correction evidence;
- release Decision, risk ownership, runbooks, observability, and restore status.

## Environments

Use local, branch/preview, shared development, security test, production-shaped staging, restricted pilot, and production. No production personal or Evidence data is copied down. Promotion is artifact-based; builds are not recreated per environment. Environment secrets are stored in Supabase/Vercel/GitHub secret stores with least privilege and rotation.
