# Git Workflow

Use protected `main` with short-lived branches. Branch names follow `feature/<feature-id>-<summary>`, `fix/<risk-or-feature-id>-<summary>`, `chore/<summary>`, or `docs/<summary>`. Sprint 00 infrastructure changes use a `chore` branch when committed by the team.

Before a pull request, rebase or merge current `main` according to team policy, run `pnpm validate`, and complete the repository pull-request template. Commits should describe one coherent outcome and must not mix architecture rewrites, generated database changes, and unrelated application work.

Required review depends on impact. Infrastructure changes need technical review; security, RLS, migration, privacy, accessibility, or architecture changes need the appropriate specialist. An engineering approval does not create business Authority.

Never force-push protected history, commit secrets, bypass a failing gate, or rewrite accepted migration and review evidence. Correct released behavior with a traceable forward change. See `docs/BRANCH_STRATEGY.md` and `docs/CONTRIBUTING.md` for the preserved detailed policy.
