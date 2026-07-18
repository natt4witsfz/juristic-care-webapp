# Testing Guide

## Test layers

Vitest covers pure infrastructure rules, environment parsing, React components, error boundaries, and memory-router behavior. React Testing Library queries semantic roles and user-visible text. Playwright covers a small production-like browser smoke path: application startup, navigation, system status, and client-side not-found routing.

Run `pnpm test` for unit and component tests, `pnpm test:coverage` for coverage evidence, `pnpm build` before production-output checks, and `pnpm test:e2e` for browser smoke tests. `pnpm validate` runs the complete gate.

Tests use synthetic public configuration. They must never depend on production credentials, production data, clock-sensitive external state, or a live Supabase project. Sprint 00 end-to-end tests start Vite locally and do not perform network calls to Supabase.

Coverage is diagnostic, not a substitute for risk-based assertions. The required Sprint 00 cases are application render, home resolution, unknown-route handling, safe error-boundary fallback, missing environment rejection, system-status loading without secret disclosure, production build, and browser smoke navigation.

CI runs formatting, lint, strict typecheck, unit tests, build, and Chromium smoke tests. Failed tests are fixed, not skipped. A flaky test blocks release until its cause is removed or an explicitly approved risk decision changes the gate.
