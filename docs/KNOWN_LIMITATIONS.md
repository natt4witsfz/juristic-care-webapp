# Known Limitations

## Current implementation boundary

The repository contains a comprehensive architecture, 135-table SQL design, timestamped Supabase migration, RLS/storage policies, Auth foundation, access resolution, controlled Case and Investigation commands, operational projections, a protected React workspace, and automated frontend/backend/static-SQL checks.

The following are not production-complete:

- The migration and RLS suite has not been executed because this workstation has no Docker/container runtime and no hosted test-project credentials.
- Hosted Auth email, invitations, recovery delivery, Storage, Realtime, and Vercel deployment have not been proven.
- Only Case creation and Investigation creation have controlled write commands. Incident association, Operation/task workflow, Responsibility transfer, evidence registration/upload, completion, verification, reopen, follow-up, announcements, compliance mutation, reporting, and permission mutation need vertical-slice implementation and tests.
- Property/resident/staff/asset administration has database design but no production UI command boundary.
- The AI adapter is deliberately local and non-authoritative; no external AI service is connected.
- Housekeeping has an identity role but no approved Case source or operational command.
- Jurisdiction-specific retention, privacy, committee mandates, emergency authority, evidence requirements, SLAs, RPO/RTO, and notification templates require Juristic Person approval.

The system must not be used as the sole production operational record until `review/14_GO_NO_GO.md` conditions are closed.
