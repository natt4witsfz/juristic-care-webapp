# CI and CD Guide

## Continuous integration

GitHub Actions runs on pull requests, pushes to `main`, and manual dispatch. The quality job installs pinned Node and pnpm versions, uses the frozen lockfile, checks formatting, lints, typechecks, runs Vitest, and builds. A dependent end-to-end job installs Playwright Chromium, builds, and runs smoke tests with synthetic local public configuration. Coverage and Playwright reports are short-lived artifacts.

Workflow permissions are read-only by default, concurrent superseded runs are cancelled, and no production secret is required. A failing job blocks merge. Dependency automation is controlled by the committed Dependabot policy.

## Deployment foundation

Vercel is configured for Vite and client-side route rewrites. Baseline response headers disable framing, MIME sniffing, and unused browser capabilities and set a restrictive referrer policy. A production Content Security Policy must be derived from approved Supabase, telemetry, and asset domains before production release; guessing those domains in Sprint 00 would create either breakage or false security.

Preview and production deployments must use separate Supabase projects and environment values. Deployment approval, rollback, monitoring, domain configuration, CSP, and release evidence remain production-readiness work. Sprint 00 prepares the build and does not claim production release authorization.
