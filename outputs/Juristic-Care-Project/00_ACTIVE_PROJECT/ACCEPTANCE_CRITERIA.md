# General Acceptance Criteria

Use this checklist for every future task.

## Scope

- The change directly matches the user request.
- No unrelated refactor was introduced.
- No unrelated UI redesign was introduced.
- No unrelated business logic was changed.

## Build and syntax

- If JavaScript changes, run an appropriate syntax/build check such as `node --check app.js` when available.
- If CSS/HTML changes, verify the app still loads locally.
- If dependencies or tooling are added, document why.

## UI consistency

- Existing design tokens are reused.
- No new colors, spacing, font sizes, border radius, or layout systems are added unless explicitly requested.
- Existing components are reused or minimally extended.
- Thai and English labels remain consistent.
- Text remains readable on desktop and mobile.

## Responsive behavior

Check the affected screen in:

- desktop layout;
- mobile/device-mobile layout when relevant.

The layout should not overflow, hide important controls, or create cramped unreadable content.

## Permissions and roles

If the task touches access control:

- Admin behavior is preserved.
- Co-Admin restrictions are preserved.
- Resident restrictions are preserved.
- Sensitive fields such as employee passwords remain hidden from roles that should not see them.
- Sidebar access follows the current permission system.

## Task workflow

If the task touches work orders or routine tasks:

- Submitted proof moves to `Submitted for Review`.
- `Completed` is only set after Admin / Assignor / Reviewer confirmation.
- Timeline/log entries remain intact.
- Required photos, dates, and review notes are validated according to existing rules.

## Data import/export

If CSV/PDF import/export changes:

- Existing fields remain backward compatible where possible.
- Nested data is exported in an editable format when requested.
- Sensitive data is exported only for roles that are allowed to see it.
- Import should update existing records and add new records according to documented keys.

## Logs and handoff

- Important Admin/Co-Admin changes are logged in the app when relevant.
- `docs/HANDOFF_LOG.md` is updated after the task.
- The final response summarizes changed files, verification performed, and known follow-ups.

