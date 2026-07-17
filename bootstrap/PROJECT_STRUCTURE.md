# Project Structure

## Purpose

The workspace separates normative records, executable infrastructure, application boundaries, deployment tooling, and generated artifacts. It avoids duplicating the approved architecture or database schema.

## Top-level ownership

| Path               | Ownership and change rule                                           |
| ------------------ | ------------------------------------------------------------------- |
| `frontend/`        | Browser application infrastructure and future feature slices        |
| `backend/`         | Supabase client/config and future authorized application boundaries |
| `supabase/`        | Canonical CLI configuration, migrations, and local seed entry point |
| `database/`        | Approved database architecture plus migration/seed/SQL work indexes |
| `sql/`             | Approved generated SQL baseline; controlled migration source input  |
| `architecture_v2/` | Normative architecture baseline                                     |
| `architecture/`    | Implementation-facing index; no duplicated architecture             |
| `planning/`        | Approved roadmap, sprints, releases, risks, acceptance              |
| `docs/`            | Developer, contribution, and branch guidance                        |
| `scripts/`         | Reproducible setup and verification commands                        |
| `.github/`         | CI, dependency updates, pull request and issue templates            |
| `bootstrap/`       | Workspace setup and engineering policy documentation                |
| `review/`          | Architecture/database/SQL/planning validation evidence              |

## Boundary rule

Dependencies point from interface/application orchestration toward stable contracts. Screens do not own business rules; generic repositories do not expose arbitrary tables; workflow and projections do not become domain truth; Supabase service credentials never enter browser code. Future feature folders follow the owning bounded context and approved feature catalog.
