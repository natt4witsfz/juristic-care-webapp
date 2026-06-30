# Handoff Log

## 2026-06-30 — AI workflow documentation baseline

### Current state

The project is an existing Juristic Care / condominium management web app prototype. It is currently implemented primarily as a static front-end app using `index.html`, `styles.css`, `app.js`, and `config.js`.

The repository is connected to:

- GitHub: `https://github.com/natt4witsfz/juristic-care-webapp`
- Branch observed: `master`
- Last known checkpoint commit before this documentation task: `9e83c0b checkpoint: current working version before ai workflow setup`

### Completed modules observed

- Login/authentication mock flow with room/staff credentials.
- Thai/English language toggle and i18n dictionaries.
- Responsive desktop/mobile application shell.
- Sidebar with grouped/collapsible navigation.
- Google Forms entry point.
- Dashboard with category summaries, main-category status overview, announcements, and organization chart.
- Central work pool for Google Form/raw jobs.
- Job creation, assignment, tracking, timeline, attachments, due/follow-up date behavior, and export concepts.
- My jobs, common-area jobs, resident jobs, technician jobs, housekeeping jobs, and juristic team jobs.
- Trello-like status boards for multiple job sidebars.
- Team management with Admin/Co-Admin behavior, departments, permissions, profile images, CSV import/export.
- Bulk permission management.
- Resident/room registry with occupants, cars, building filter, and CSV import/export.
- Admin Log and Staff Log.
- Announcements/backhouse module with upload, preview, popup, and download behavior.
- Finance mockup.
- Calendar mockup prepared for Google Calendar connection.
- Organization Chart sidebar and dashboard display.
- Chat with Juristic module.
- Routine Daily Task / Daily PM modules including dashboard, today tasks, verification, templates, calendar, reports, and settings.

### Important files and folders

- `index.html`: main app markup and initial screen structure.
- `styles.css`: current design system, responsive layout, component styles.
- `app.js`: main application state, rendering, i18n, role logic, modules, mock data, and interactions.
- `config.js`: configuration placeholder.
- `README.md`: current product and workflow notes.
- `README-DEPLOY-TH.md`: Thai deployment-related notes.
- `DEPLOYED-URLS.md`: deployment URL notes.
- `apps-script/`: Google Apps Script related files.
- `docs/`: documentation and continuation instructions.
- `outputs/` and `work/`: generated/exported/mockup/support files. Do not treat these as the main source of truth unless a task explicitly asks.

### Known issues / risks

- The app is still a prototype and appears to rely heavily on front-end/localStorage behavior.
- `app.js` is large, so unrelated refactors carry high risk.
- Some integrations are mock or prepared for future backend work, including Google Calendar and production storage.
- Logs and audit behavior need production backend support before real operational use.
- Attachments/photos should eventually move to object storage rather than browser-only/local mock storage.
- Future agents must avoid UI drift because many UI refinements have been made incrementally.
- Future agents must preserve the review workflow: submitted proof does not equal completed work.

### Design rules that should not be changed without explicit request

- Keep the current green brand foundation.
- Keep existing pastel/light UI direction with existing blue, amber, purple, and red accents.
- Keep rounded cards, soft borders, soft shadows, and readable spacing.
- Keep Dashboard first in the sidebar and visually emphasized.
- Keep mobile behavior aligned with the existing `device-mobile` approach.
- Reuse existing panels, cards, buttons, modals, chips, tables/lists, and Trello board patterns.

### Verification for this entry

- Inspected project structure.
- Inspected `styles.css` root tokens and core layout/component styles.
- Inspected `index.html` auth structure and typography imports.
- Inspected `README.md` current module notes.
- No application code was changed for this documentation baseline.

### Recommended next task

Create a clean Git branch for the next real feature or bugfix, then choose one scoped task only. Recommended first technical task: review and stabilize the permission model and role-based sidebar visibility with tests/manual checklists before adding more modules.

