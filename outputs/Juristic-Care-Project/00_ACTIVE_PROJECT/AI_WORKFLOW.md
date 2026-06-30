# AI Workflow — Continuing Across Codex Plus, Codex Pro, and Google Antigravity

## Source of truth

Use the Git repository as the source of truth:

`https://github.com/natt4witsfz/juristic-care-webapp`

Future agents should not work from copied zip files unless unavoidable. Zip files can be useful as backups or references, but they easily cause version drift.

## Start-of-task workflow

1. Pull or clone the latest repository.
2. Confirm the current branch and working tree.
3. Read:
   - `AGENTS.md`
   - `docs/PROJECT_CONTEXT.md`
   - `docs/DESIGN_SYSTEM.md`
   - `docs/UX_RULES.md`
   - `docs/ACCEPTANCE_CRITERIA.md`
   - `docs/HANDOFF_LOG.md`
4. Inspect the relevant code before editing.
5. Create a task branch when possible.

Suggested branch names:

- `feature/<short-description>`
- `fix/<short-description>`
- `docs/<short-description>`
- `checkpoint/<date-or-topic>`

## During implementation

- Keep the task small and scoped.
- Reuse existing components and style tokens.
- Do not redesign screens unless the user explicitly requested a redesign.
- Preserve current business rules and role restrictions.
- Update Thai and English i18n together.
- Avoid broad refactors in `app.js` unless the task is specifically a refactor.
- Keep generated files, zip backups, and experimental outputs out of the main flow unless required.

## Verification

Use the acceptance criteria in `docs/ACCEPTANCE_CRITERIA.md`.

At minimum:

- Check changed screens locally.
- Check desktop and mobile where relevant.
- Run syntax/build checks when applicable.
- Confirm role/permission behavior when the task touches access control.
- Confirm submitted work uses `Submitted for Review` before `Completed`.

## Commit and pull request workflow

Recommended flow:

1. `git status`
2. Review diffs.
3. Commit logically related changes.
4. Push branch.
5. Open pull request or provide a handoff summary.

Commit messages should be specific:

- `docs: add ai workflow handoff instructions`
- `fix: align announcement download button behavior`
- `feature: add bulk permission preset controls`

## Handoff log rule

After every task, update `docs/HANDOFF_LOG.md` with:

- date;
- summary;
- files changed;
- verification performed;
- known issues;
- recommended next task.

This is required so Codex Plus, Codex Pro, Google Antigravity, or another AI tool can continue without guessing.

## Tool-specific notes

### Codex Plus / Codex Pro

- Start by reading `AGENTS.md`.
- Use repository inspection before edits.
- Prefer small patches.
- Report verification clearly.

### Google Antigravity

- Open the repository folder directly.
- Read the required docs before prompting implementation.
- Ask it to preserve the existing design system and update the handoff log.
- Avoid asking it to recreate the app from screenshots or zip files.

## If a zip file must be used

Only use a zip file if the Git repository is unavailable or the user explicitly asks to compare against a zip.

If a zip is used:

1. Extract it to a separate comparison folder.
2. Compare against the Git working tree.
3. Port only intentional changes.
4. Do not replace the repository blindly.
5. Update `docs/HANDOFF_LOG.md` with what was imported.

