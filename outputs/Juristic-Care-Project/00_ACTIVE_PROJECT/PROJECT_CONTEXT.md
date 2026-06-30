# Project Context — Juristic Care

## What this project is

Juristic Care is a prototype web app for condominium / juristic office management. It helps residents, juristic staff, committee members, technicians, housekeepers, and administrators receive, classify, assign, track, and review work requests.

The app is currently a front-end prototype built mainly with:

- `index.html`
- `styles.css`
- `app.js`
- `config.js`

The current prototype uses browser-side behavior and local/mock data patterns. It is intended for UX, workflow, and feature validation before a production backend is chosen.

## Business goal

The product goal is to create a transparent condominium management system where:

- Residents can report issues and follow relevant status.
- Google Form submissions can enter a central raw work pool.
- Authorized staff can classify and assign work.
- Assigned teams can update status, add proof, and request review.
- Admin / Co-Admin can manage users, permissions, logs, residents, announcements, organization chart, routine PM work, and reports.
- Committee and juristic staff can see operational visibility without needing to edit code.

## Main user groups

- Admin: full access, can view protected logs, manage users, permissions, residents, and system-level configuration.
- Co-Admin: elevated access assigned by Admin, but restricted from sensitive fields where specified, such as employee passwords.
- Committee: management/oversight role with access to selected dashboards, jobs, announcements, calendar, finance, and chat depending on permissions.
- Juristic staff: operational team for receiving, classifying, assigning, and following work.
- Technician team: receives maintenance jobs, updates statuses, attaches photos, submits for review.
- Housekeeping team: receives cleaning/housekeeping jobs and routine work.
- Security, gardener, contractor: supported as departments/roles for staff profiles and permissions.
- Resident: sees resident-facing pages such as overview, common-area issues, room-specific jobs, calendar, finance, Google Forms link, and Chat with Juristic depending on permissions.

## Main modules currently represented

- Authentication/login with Thai/English language toggle.
- Responsive desktop/mobile shell with sidebar and mobile navigation.
- Dashboard / overview with category summaries, main category status chart, announcements, and organization chart.
- Google Forms entry point for resident issue intake.
- Central raw work pool for incoming Google Form work.
- Work creation, assignment, status tracking, attachments, timeline, due date, export, and review flow.
- Common-area jobs.
- Resident jobs.
- My jobs.
- Technician jobs.
- Housekeeping jobs.
- Juristic team jobs.
- Team management with Admin/Co-Admin controls, profile photos, departments, rights, import/export.
- Bulk permission management for sidebar access and authority controls.
- Resident/room registry with occupants, owner/tenant status, cars, building filter, CSV import/export.
- Admin Log and Staff Log.
- Announcements with upload, preview, popup view, and download.
- Finance mockup.
- Calendar mockup prepared for Google Calendar integration.
- Organization Chart with slots based on selected staff profiles.
- Chat with Juristic for public/common and resident-private conversations.
- Routine Daily Task / Daily PM modules: dashboard, today tasks, verification, templates, calendar, reports, and settings.

## Important product rule

Work submitted with proof must not immediately become completed. It must first become `Submitted for Review`, then become completed only after Admin / Assignor / Reviewer confirmation.

