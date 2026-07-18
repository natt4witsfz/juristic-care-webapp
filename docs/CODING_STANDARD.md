# Coding Standard

## Scope and intent

Code must preserve architecture meaning, remain reviewable, and fail safely. Sprint boundaries are enforceable delivery constraints.

TypeScript uses strict mode, exact optional-property behavior, unchecked-index protection, explicit type-only imports, and no explicit `any`. ESLint warnings fail CI. Prettier is the formatting authority. React components use semantic HTML, visible keyboard focus, accessible names, and restrained motion. Server state belongs in TanStack Query; local interface state stays local.

Third-party clients are created behind narrow adapters. The Supabase browser client is lazy and unique per application runtime. Credentials and configuration values are never logged. User-facing errors describe recovery without exposing stack traces, queries, identifiers, or private data.

Future business features are vertically owned under `frontend/src/features`. Shared components must be domain-neutral. Do not use generic status, owner, truth, priority, or responsibility fields that collapse the approved domain language. Never infer Authority from a UI role.

Tests accompany behavior at the lowest useful level. Every route has loading, error, denied, empty, and recovery treatment where applicable. A change is complete only when `pnpm validate` passes and its architecture, security, accessibility, and operational evidence is recorded.
