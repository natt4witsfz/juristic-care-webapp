# Git Workflow

## Model

Use protected-trunk development: `main` is always releasable, work occurs on short-lived branches, and changes enter through reviewed pull requests with required CI.

## Branch and commit conventions

Name branches `feature/Fxx-description`, `fix/Fxx-description`, `chore/description`, or `docs/description`. Use imperative commits with one coherent purpose, for example `chore: establish frontend quality gates`. Do not combine generated dependency changes, formatting sweeps, schema changes, and feature logic without a clear reason.

## Pull requests

Reference feature/sprint, architecture, acceptance criteria, database/API/event changes, permission impact, migration/retention effect, risks, and verification evidence. Use draft pull requests for early contract review. Squash merge after required approvals and checks.

## Protected changes

Migrations, RLS, Storage, privileged access, safety, privacy, AI, architecture, and CI/release workflows require specialist review. Production fixes preserve evidence and follow forward-correction rules when accepted data exists.

## Branch protection

Require CI, current branch, resolved conversations, and appropriate reviewers; block force-push/direct-push. Actual GitHub teams and code owners are an organizational input and must be configured before production rather than invented in this bootstrap.
