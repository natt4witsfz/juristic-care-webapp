# Missing Areas and Remaining Decisions

Version: 1.0  
Status: No Blocking Architecture Gaps

## Purpose

This report distinguishes missing architecture from details that appropriately require later human governance or implementation design. It contains no placeholders; each item has a defined decision owner and timing.

## Architecture gaps

No blocking gap was identified in the Version 2 architecture repository. The core domain, governance, workflow, evidence, data, event, security, AI, user-experience, and continuity concerns are represented and consistent.

## Remaining governed decisions

| Decision area | Why it remains open | Required Authority | Required before |
|---|---|---|---|
| Jurisdiction-specific retention periods | Depends on Thai law, condominium policy, insurance, contracts, and data categories | Juristic Person with legal/privacy review | Production data retention configuration |
| Role and mandate assignments for a specific condominium | Architecture defines the model, not local office holders | Committee/juristic management under bylaws | User provisioning and operational launch |
| SLA classes and target durations | Must reflect approved service policy, budget, staffing, risk, and contracts | Authorized committee or juristic manager | Workflow configuration and KPI targets |
| Evidence risk-tier mapping by work type | Requires asset risk assessment and professional/legal standards | Authorized management with qualified safety/engineering input | Operation templates and verification rules |
| Recovery and availability targets | Need risk, volume, cost, and dependency analysis | Business continuity and technology authorities | Production topology procurement |
| External integration contracts | Depend on selected identity, messaging, building, contractor, and accounting systems | Data owner and integration/security authorities | Detailed integration design |
| AI provider and approved use cases | Depend on privacy, residency, retention, model evaluation, and supplier terms | Juristic governance and risk owners | Any production AI activation |

## Non-issues

The absence of SQL, APIs, frontend code, physical infrastructure, vendor selection, and numeric performance targets is intentional. Those are subsequent design artifacts and must conform to this architecture rather than be invented during architecture review.

## Remaining issues summary

- Architecture contradictions: 0
- Broken references: 0
- Blocking missing areas: 0
- Governed decisions required before production configuration: 7
