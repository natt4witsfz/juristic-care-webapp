# Coding Standard

## TypeScript

Use strict TypeScript, explicit boundary types, immutable inputs, discriminated results, and `unknown` before validation. Avoid `any`, unsafe casts, non-null assertions, ambient global state, and generic table APIs. Names describe business meaning when features begin; abbreviations require glossary support.

## React

Use function components except error boundaries. Keep rendering pure, effects narrow, remote state in TanStack Query, route composition centralized, and feature code colocated. Provide semantic HTML, keyboard access, focus visibility, reduced-motion support, and explicit loading/empty/denied/offline/error/recovery states.

## Backend and data boundaries

Validate transport input, authorize current acting context, invoke one explicit use case, enforce database invariants, emit durable audit/events, and return purpose-specific data. Do not infer Authority from authentication or role labels. Avoid broad `select *`, client-side joins that reveal restricted context, and last-write-wins for material conflicts.

## Errors and observability

Use stable non-sensitive error codes, actionable user messages, and correlation identifiers. Log operational facts, not secrets or raw sensitive content. Expected denials are observable but not treated as system crashes.

## Formatting and quality

Prettier is authoritative for formatting; ESLint for static rules; TypeScript for type safety; Vitest/Testing Library for tests. Every pull request passes `pnpm check`. Comments explain why, constraint, risk, or source—not obvious syntax.

## Security invariants

Never expose secret/service-role keys, trust user metadata for authorization, disable RLS to fix access, add privileged functions without review, overwrite history, or use Storage paths as sole authorization. See the approved permission, security, database RLS, and Storage documents.
