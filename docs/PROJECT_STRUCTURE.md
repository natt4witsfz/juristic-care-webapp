# Project Structure

## Purpose

The workspace separates long-lived decisions, executable infrastructure, future feature ownership, and validation evidence.

| Path                                | Responsibility                                                   |
| ----------------------------------- | ---------------------------------------------------------------- |
| `architecture/`, `architecture_v2/` | Normative architecture and navigation history                    |
| `planning/`                         | Delivery order, dependencies, acceptance, and risk               |
| `database/`, `sql/`                 | Approved database design and historical SQL baseline             |
| `frontend/`                         | Browser application shell and future vertical features           |
| `backend/`                          | Shared TypeScript infrastructure boundaries; not a deployed API  |
| `supabase/`                         | Project-scoped CLI configuration and future canonical migrations |
| `docs/`                             | Developer-operating guidance                                     |
| `scripts/`                          | Reproducible workspace checks                                    |
| `.github/`                          | Review templates, dependency policy, and CI                      |
| `review/`                           | Immutable review and sprint evidence                             |

Within `frontend/src`, `app/` owns providers and composition; `routes/` owns navigation; `pages/` owns route surfaces; `components/common`, `components/feedback`, and `components/layout` own reusable presentation; `config/` validates public settings; `lib/` contains controlled third-party adapters; `styles/` owns theme tokens; and `test/` owns shared test setup.

Future work belongs under `features/<feature-name>/` and must follow the approved sprint. A feature owns its local components, schemas, queries, and tests. Shared folders are not dumping grounds. Imports must not make common infrastructure depend on a business feature.

The `backend/` package currently exposes only generic environment, validation, repository, service, result, and Supabase client boundaries. It contains no HTTP API and no O83 workflow logic.
