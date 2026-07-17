# Branch Strategy

O83 Care uses trunk-based development with short-lived branches and protected `main`.

## Branch names

- `feature/F12-report-intake`
- `fix/F05-cross-tenant-denial`
- `chore/ci-node-update`
- `docs/architecture-link-index`
- `hotfix/<incident-summary>` only under the production incident process

Use the approved feature or risk identifier where applicable. Branches should normally live for days, not weeks. Long-running work is decomposed behind secure, default-off interfaces; database compatibility remains additive.

## Main branch protection

Require pull requests, CI, resolved review conversations, current branch, and at least one code-owner-equivalent review. Require specialist review for migrations/RLS/Storage, security/privacy, safety, accessibility, AI, and architecture changes. Prevent direct pushes, force pushes, and branch deletion. Configure actual GitHub teams before enforcement; this bootstrap does not invent owner identities.

## Releases and hotfixes

Tag accepted releases with immutable semantic versions and link the release evidence pack. Hotfixes begin from the production tag, minimize scope, preserve history, pass focused and regression tests, and merge back to `main`. A data correction is an authorized forward correction, not an unreviewed rollback.
