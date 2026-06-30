# AGENTS.md — Juristic Care AI Working Instructions

This project is an existing Juristic Care / condominium management web app. Future AI agents must preserve the current product direction, UX, and code behavior unless the user explicitly asks for a change.

## Core non-negotiable rules

These rules are repeated here intentionally because they are the most important guardrails for this project:

1. Do not redesign the UI unless explicitly requested by the user.
2. Reuse existing components, CSS classes, layout patterns, state helpers, data structures, and i18n patterns before creating anything new.
3. Update `docs/HANDOFF_LOG.md` after every task, even when the change is small.

If a future request conflicts with these rules, clarify the scope before making changes.

## Required reading before any change

Before editing application code, every agent must read:

1. `docs/PROJECT_CONTEXT.md`
2. `docs/DESIGN_SYSTEM.md`
3. `docs/UX_RULES.md`
4. `docs/ACCEPTANCE_CRITERIA.md`
5. `docs/HANDOFF_LOG.md`

Do not start implementation from memory alone. Use the repository files as the source of truth.

## Scope control

- Do not redesign the UI unless the user explicitly requests a redesign.
- Do not change existing screens, layout structure, colors, spacing, font sizes, border radius, or interaction patterns unless the task specifically requires it.
- Do not introduce new visual tokens outside the existing design system documented in `docs/DESIGN_SYSTEM.md`.
- Reuse existing components, CSS classes, state helpers, data structures, and i18n patterns.
- Do not refactor unrelated code.
- Do not change business logic outside the requested scope.
- Keep changes small, reviewable, and directly tied to the user request.

## UX and workflow rules

- The interface must stay minimal, friendly, and easy to understand.
- Text must remain readable; avoid overly small labels for important actions or status.
- Use existing pastel/light UI direction, with green as the primary brand color and existing blue/red/amber accents for status.
- Avoid dense admin-style screens unless the workflow truly needs dense data.
- Prioritize clear task ownership, status, due dates, review state, and next actions.

## Task status rule

Do not mark a task as `Completed` immediately when an assignee submits proof or photos.

Required flow:

1. Assignee submits work/proof.
2. Task moves to `Submitted for Review`.
3. Only Admin, Assignor, or Reviewer can confirm completion.
4. Task becomes `Completed` only after that confirmation.

This rule applies to work orders and routine/daily PM tasks.

## i18n rule

All user-facing text must use the existing Thai/English i18n pattern. When adding or changing visible text, update both languages and verify the language toggle still changes the text.

## Documentation rule

After every completed task, update `docs/HANDOFF_LOG.md` with:

- Date
- Summary of changes
- Files changed
- Verification performed
- Known issues or follow-up work

## Git and handoff rule

- Work from the Git repository, not copied zip files, unless unavoidable.
- Prefer a branch per task.
- Commit logically related changes together.
- Keep the handoff log current so Codex Plus, Codex Pro, Google Antigravity, or another AI tool can continue consistently.
