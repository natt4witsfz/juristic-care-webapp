# Contribution Guide

## Before starting

Confirm the issue references a feature ID, sprint, architecture documents, database objects, permission impact, required tests, acceptance criteria, and risk. Ask for a binding product/governance decision when local law, retention, SLA, Authority, or safety policy is unknown; do not invent it in code.

## Change process

1. Branch from current `main` using the branch convention in [`BRANCH_STRATEGY.md`](BRANCH_STRATEGY.md).
2. Keep the change inside one coherent outcome; split unrelated refactors.
3. Add or update tests before review and keep migrations backward compatible.
4. Run `pnpm check` and any feature-specific database/security/accessibility suites.
5. Complete the pull-request template with evidence and risk impact.
6. Obtain domain/code review plus specialist review for database, RLS, privacy, safety, accessibility, AI, or operational changes.
7. Squash merge after required checks and approvals pass.

## Review expectations

Reviewers verify architecture meaning, authorization, immutable history, tenant scope, idempotency, concurrency, error/offline states, migration compatibility, observability, tests, and documentation. A review approval is not business Authority. Consequential product/policy decisions must link the authorized Decision or ADR.

## Prohibited shortcuts

Do not expose service credentials, disable RLS to resolve errors, add `SECURITY DEFINER` casually, trust user metadata for authorization, overwrite historical facts, merge Cases, create suspected Incidents, allow AI to decide, copy production data into tests, or bypass a failed gate through a feature flag.
