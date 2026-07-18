# Architecture Traceability

## Sprint 00 mapping

| Foundation            | Implementation evidence                                         | Governing source                                                                      |
| --------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Engineering workspace | pnpm workspaces, pinned toolchain, scripts, CI                  | `planning/01_feature_catalog.md` F01                                                  |
| UI composition        | app providers, route catalog, layout and feedback components    | `architecture_v2/14_system_architecture.md`, `architecture_v2/15_ui_ux_principles.md` |
| Public configuration  | validated environment reader and safe failure page              | `architecture_v2/13_security_and_audit_model.md`, `database/11_rls_strategy.md`       |
| Supabase boundary     | lazy browser client using URL and publishable key               | `database/00_database_overview.md`, `database/11_rls_strategy.md`                     |
| Quality               | ESLint, strict TypeScript, Vitest, Playwright, production build | `planning/06_definition_of_done.md`                                                   |
| Deployment foundation | Vercel rewrite and baseline headers                             | `planning/04_release_plan.md`, `planning/05_risk_register.md`                         |

The shell intentionally implements no Case, Investigation, Incident, Operation, Evidence, Notification, AI, authentication, or database workflow. Those concepts remain in their approved bounded contexts and future sprint dependencies. Database migration execution is deferred because the active Sprint 00 instruction prohibits tables and schema work.

Sprint evidence resides in `review/SPRINT_00_PREFLIGHT.md`, `review/SPRINT_00_IMPLEMENTATION_REPORT.md`, `review/SPRINT_00_VALIDATION.md`, `review/SPRINT_00_RISK_REGISTER.md`, `review/SPRINT_00_TRACEABILITY.md`, and `review/SPRINT_00_GO_NO_GO.md`.
