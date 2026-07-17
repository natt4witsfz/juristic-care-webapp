# Sprint 00 Validation

Version: 1.0  
Date: 2026-07-17  
Status: Passed

## Environment

Validation used the managed Node.js runtime with pnpm 11.9.0 on Windows. The host shell itself does not expose Node.js or Git on its default `PATH`. Local Chrome was used for browser smoke tests after the Playwright Chromium download endpoint timed out. CI remains configured to install pinned Chromium.

## Final results

| Command | Result | Evidence |
| --- | --- | --- |
| `pnpm install --frozen-lockfile` | Passed | Lockfile current; 3 workspace projects resolved |
| `pnpm format:check` | Passed | All checked files matched Prettier style |
| `pnpm lint` | Passed | Backend and frontend; zero warnings permitted |
| `pnpm typecheck` | Passed | Backend and frontend strict TypeScript builds |
| `pnpm test` | Passed | 4 frontend files/7 tests and 1 backend file/2 tests |
| `pnpm test:coverage` | Passed | Frontend 70% statements; backend 100% statements |
| `pnpm build` | Passed | TypeScript build and Vite production bundle completed |
| `pnpm test:e2e` | Passed | 2 Chrome smoke scenarios passed |
| `pnpm dev --host 127.0.0.1` | Passed | Vite ready on port 5173; HTTP probe returned 200 |

The production frontend bundle contained 215 transformed modules and generated HTML, CSS, and JavaScript assets successfully. Tests use synthetic public configuration and make no live Supabase request.

## Failures encountered and resolved

1. pnpm initially refused to rebuild `node_modules` without a TTY. Validation set the standard CI mode for the non-interactive install, refreshed the lockfile, and then proved a frozen install passes.
2. Typecheck initially identified an `ImportMetaEnv` structural mismatch and missing Node types for Playwright. The environment reader was made explicit and the pinned Node 22 type package was added.
3. Vitest initially discovered the Playwright file. Vitest was constrained to `src` test files, separating unit/component tests from end-to-end tests.
4. The Playwright-managed Chromium download failed because of CDN timeout/DNS resets. Local installed Chrome ran both smoke scenarios successfully; CI continues to install managed Chromium on Linux.
5. The first smoke server used preview output built before test variables were supplied. The smoke configuration now uses a Vite test server whose process receives synthetic variables before module transformation.

## Validation conclusion

All required assertions pass. The transient browser-download failure is an environment/network risk, not a test failure or source defect. No blocker remains inside Sprint 00 scope.
