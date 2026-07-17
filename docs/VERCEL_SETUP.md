# Vercel Setup

## Purpose

Vercel hosts the static React application. Supabase remains the identity, data, and storage platform.

## Configuration

Set the project root to `frontend` only if the Vercel workspace is configured to install the monorepo dependencies from the repository root; otherwise keep the repository root and use `pnpm --filter @o83/frontend build`. Publish `frontend/dist`.

Required browser variables are `VITE_APP_ENV`, `VITE_APP_VERSION`, `VITE_SUPABASE_URL`, and `VITE_SUPABASE_PUBLISHABLE_KEY`. The publishable key is designed for browser use but still depends on RLS. Never configure `SUPABASE_SERVICE_ROLE_KEY` or database credentials as `VITE_` variables.

`frontend/vercel.json` provides the SPA fallback. Add the final deployment origin and approved preview origins to the Supabase Auth redirect allow-list. Restrict production deployments to the protected release branch and require the CI checks.

## Verification

After deployment, verify the public home and system-status routes, sign-in, recovery redirect, protected-route redirect, logout, CSP/security headers, and one read-only tenant query with a least-privileged test account. Record the deployment URL and result in the release evidence; this repository does not claim that deployment has occurred.
