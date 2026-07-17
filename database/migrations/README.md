# Migration Workspace

The approved generated SQL remains in [`sql/`](../../sql/). Executable Supabase migrations belong in [`supabase/migrations/`](../../supabase/migrations/) and must be created with `pnpm supabase migration new <name>` after checking current CLI help. This folder stores migration design notes and validation evidence only, preventing two executable sources of schema truth.
