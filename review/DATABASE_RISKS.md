# Production Database Risk Register

Version: 1.0  
Status: Pre-SQL Baseline

## Critical risks

| ID | Risk | Architectural control | Required implementation evidence |
|---|---|---|---|
| DBR-01 | RLS/Data API misconfiguration exposes cross-tenant or sensitive records | Private domain schemas, intentional exposed boundary, tenant/relationship/Mandate policies, explicit grants | Complete policy matrix, negative cross-tenant tests, view/function review, production-scale plans |
| DBR-02 | Evidence database metadata and Supabase Storage objects diverge or are lost | Attachment promotion, immutable original, digest, integrity checks, manifests, dispositions, archive reconciliation | Upload failure tests, orphan scan, digest verification, restore and legal-hold tests |
| DBR-03 | Migration/backfill overwrites history or invents chronology/Authority | Expand-contract, immutable versions/events, explicit unknowns, ADR and sealed validation | Rehearsed migration, reconciliation totals, as-of comparisons, rollback/forward-correction proof |
| DBR-04 | Event/audit/evidence growth degrades operational queries over decades | Schema separation, partition strategy, partial indexes, hot/warm/cold tiers, rebuildable projections | Volume forecast, partition tests, retention jobs, archive retrieval objectives, query plans |
| DBR-05 | Privileged service/function bypass defeats business Authority and audit | Least privilege, no client secret/service role, governed privileged execution outside exposed schemas, access audit | Credential inventory, grant review, caller checks, tamper test, advisor/security findings resolved |
| DBR-06 | Effective-dated and graph relationships produce overlapping “current” truth or cycles | Non-overlap, subset, acyclic, version/current-selection constraints and reconciliation | Constraint tests for Mandate, Responsibility, Asset, taxonomy, Decision, workflow, SLA timelines |

## High risks

| ID | Risk | Control |
|---|---|---|
| DBR-07 | Stale JWT/app metadata permits revoked access | Database authorization, short sensitive-session tolerance, current-session checks where required |
| DBR-08 | Generic JSON or polymorphic links hide business relationships | Explicit link tables/FKs; JSON limited to governed content/rule payloads |
| DBR-09 | Over-indexing harms high-volume writes | Named index consumers, plan evidence, partial indexes, usage review |
| DBR-10 | Archive breaks search/traceability | Online manifests, durable IDs, restore events, relationship-aware export |
| DBR-11 | Retention conflicts with privacy/legal hold | Versioned policies, holds, dispositions, minimum lawful tombstones, governance review |
| DBR-12 | Realtime or AI retrieval leaks restricted data | Approved projections/topics, RLS, mediated AI context, no raw restricted broadcasts |
| DBR-13 | Offline conflict resolution uses last-write-wins | Expected versions, durable IDs, conflict records, human Decision for material conflict |
| DBR-14 | External identifiers are mistaken for durable O83 identity | Issuer-scoped effective mapping and non-recycled O83 UUID/business key |

## Risk count

- Critical database risks: 6
- High database risks: 8
- Total tracked database risks: 14

All Critical risks have architectural controls but remain open until implementation evidence is reviewed. “Ready for SQL generation” does not mean ready for production deployment.
