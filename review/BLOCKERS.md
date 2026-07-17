# Blockers

Version: 1.0  
Date: 2026-07-17  
Status: Active and historical blockers

## BLK-01 — Local Supabase runtime unavailable — RESOLVED 2026-07-18

- **Original blocked phase:** Executing PostgreSQL migrations, database tests, and RLS tests against a local Supabase stack.
- **Original reason:** The Docker engine was unavailable and required Windows container prerequisites were disabled.
- **Resolution:** Windows Subsystem for Linux and Virtual Machine Platform were enabled, Docker Desktop was started, and the Supabase stack became healthy.
- **Verified result:** `pnpm db:start` and a subsequent clean `pnpm db:reset` passed. Database lint passed with no schema errors, and both pgTAP suites passed: 2 files and 22 tests.
- **Evidence:** `review/SUPABASE_MIGRATION_FIX_20260718.md`.

## BLK-02 — Hosted services and credentials not supplied

- **Blocked phase:** Live Supabase Auth email delivery, hosted Storage upload, remote migration deployment, and Vercel deployment.
- **Reason:** No real project URL/key, project reference, SMTP configuration, Supabase access token, or Vercel authorization was supplied.
- **Impact:** The application can implement and test browser boundaries with mocks/synthetic configuration, but cannot claim hosted sign-in, password email, invitation delivery, Storage transfer, or deployment.
- **Corrective action:** Provision development/staging projects, configure approved non-production credentials outside Git, validate redirects/email, link the CLI, and execute the deployment runbook.

## BLK-03 — Jurisdictional and organizational policy inputs absent

- **Blocked phase:** Final production approval for retention periods, emergency succession, committee mandates, life-safety command, dispute appeal, and SLA pause rules.
- **Reason:** These decisions require the Juristic Person and applicable Thai legal/safety/privacy expertise.
- **Impact:** The system can model versioned policy and preserve decisions, but must not invent binding policy.
- **Corrective action:** Obtain authorized decisions, record them with effective dates, then configure and test the corresponding workflows.
