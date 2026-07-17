# Cross-Reference Check

Version: 2.0  
Status: Passed

## Purpose

This report verifies that the architecture forms a navigable repository rather than isolated documents.

## Method

All Markdown links targeting repository documents were extracted and resolved against `architecture_v2`. The review also checked that major concepts have an authoritative definition and that implementation-facing catalogs point back to their governing models.

## Automated result

- Markdown documents scanned: 32
- Broken Markdown document links: 0
- Missing required numbered documents: 0
- Duplicate required number prefixes: 0

## Semantic reference map

| Concern | Authoritative document | Principal consumers |
|---|---|---|
| Foundational invariants | `00_foundation.md` | All documents; repository guide |
| Canonical terminology | `16_project_glossary.md` | Domain, workflow, states, permissions, experiences |
| Domain identities and aggregates | `02_domain_model.md` | Data, database, event, workflow, reporting |
| Organizational accountability | `03_organization_model.md` | Governance, operations, permissions, workspaces |
| Operational work | `04_operation_model.md` | Workflow, technician, manager, states, evidence |
| Knowledge validity | `05_knowledge_model.md` | AI advisor, AI collaboration, KPI learning |
| Governance and authority | `06_governance_model.md` | Decisions, permissions, committee, security |
| AI boundary | `07_ai_advisor_model.md` | AI collaboration, UI, workspaces, analytics |
| Evidence semantics | `08_evidence_model.md` | Evidence standard, decision, security, operations |
| Human decisions | `09_decision_model.md` | Incident association, priority, closure, ADRs |
| Workflow orchestration | `10_workflow_model.md` | States, notifications, role experiences |
| Security and audit | `13_security_and_audit_model.md` | Permissions, reference architecture, evidence |
| Logical system boundaries | `14_system_architecture.md` | Data, events, database, reference architecture |
| Architecture governance | `17_architecture_decision_records.md` | Repository change process and evolution |
| Data and chronology | `18_data_architecture.md` | Database, events, analytics, security |
| Event contracts | `19_event_architecture.md` | System, workflow, data, reference architecture |
| State transitions | `21_state_machine_catalog.md` | Workflow and role experiences |
| Permissions | `22_permission_matrix.md` | All role experiences and governance |
| Evidence sufficiency | `27_evidence_standards.md` | Technician, manager, operations, AI |
| Measurement | `28_kpi_catalog.md` | Reporting, manager, committee |
| Deployment conformance | `30_reference_architecture.md` | Future implementation architecture |

## Navigation assessment

The `README.md` establishes a coherent reading order and normative hierarchy. Cross-references avoid circular redefinition: documents refer to the glossary for meaning, to domain/governance models for business rules, and to catalogs for normalized states, permissions, evidence, and KPIs.

## Result

Passed. No broken or semantically orphaned cross-reference was found.
