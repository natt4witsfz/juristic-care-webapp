# Architecture Traceability

| Invariant / capability | Architecture | Database / SQL | Application / test evidence |
|---|---|---|---|
| One Report creates one separate Case | `02_domain_model`, `10_workflow_model` | `intake.reports`, `intake.cases`, `api.create_case` | Cases form; gateway duplicate-submission test |
| Cases link only through Investigation to verified Incident | `02_domain_model`, `04_operation_model` | Investigation/Incident/Case-link tables; `api.create_investigation` creates no Incident | Cases page starts Investigation; Incident view is read-only |
| Operational Truth is time-bound and revisable | `00_foundation`, `09_decision_model` | truth assertions, revisions, events, immutable history | Not yet exposed as a complete UI vertical slice |
| Responsibility concepts remain separate | `03_organization_model`, `04_operation_model` | assignments, ledger, Mandates, commitments, capabilities, availability, priority, sequence, SLA | Operation page explains separation; mutation UI pending |
| Emergency safety exception | `01_design_principles`, `27_evidence_standards` | event/action/record timestamps and exception evidence model | Documentation only; command/test pending |
| Evidence is never silently replaced | `08_evidence_model`, `27_evidence_standards` | evidence versions, custody/integrity/disposition and immutable triggers | Storage vertical slice pending |
| Decision evolution preserves disagreement | `09_decision_model` | decisions, revisions/relationships, sources, event history | UI pending |
| Organizational Memory belongs to Juristic Person | `05_knowledge_model`, `18_data_architecture` | tenant ownership, knowledge versions/contexts/reviews | Long-term export/restore proof pending |
| AI is an Organizational Mirror | `07_ai_advisor_model`, `29_ai_collaboration_principles` | narrowed AI RLS; immutable interactions/recommendations/sources/reviews | Local non-authoritative adapter and boundary test |
| Auth is not authority | `13_security_and_audit_model`, `22_permission_matrix` | user account, effective relationships/roles/permissions, forced RLS | AuthProvider, `resolve_current_access`, protected routes/tests |
| Human-readable references | `20_database_blueprint` | `CASE-YYYY-NNNNNN` and domain business keys | Created Case response displayed |
| Long-term change survivability | `05_knowledge_model`, `30_reference_architecture` | versioning, audit, archive and migration strategies | Backup/operations/deployment guides; restore test pending |

Traceability is strongest for architecture and schema, partial for executable command boundaries, and incomplete for the majority of required UI vertical slices. The gap is explicit and is not represented as implementation completion.

