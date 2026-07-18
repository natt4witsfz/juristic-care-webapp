# O83 Care Release Plan

Version: 1.0  
Status: Execution Baseline

## Purpose

Releases are controlled capability gates, not automatic deployments at sprint boundaries. Every release is deployable to a restricted environment, preserves backward compatibility and history, has observable success criteria, and can be disabled or forward-corrected without deleting accepted data.

## Release strategy

Use environment progression: ephemeral/branch → shared development → security test → production-shaped staging → restricted pilot → production. Database changes use expand-and-contract. Feature flags may hide incomplete interaction paths but never weaken database constraints, RLS, audit, or history. Rollback is allowed only before accepted data would be lost; after acceptance, use forward correction and explicit reconciliation.

## R0 — Trusted foundation

**After:** Sprint 2.  
**Audience:** Engineering, security, database, and nominated tenant administrators only.  
**Scope:** F01–F11 and F37: environments, live schema, observability, Auth, RLS, audit/events, organization, Authority, responsibility/capability/availability, property/assets, taxonomy.  
**Entry:** Target Supabase/PostgreSQL versions and environment owners approved.  
**Exit:** Clean migration passes; RLS foundation matrix passes; master data imports reconcile; Authority/temporal/graph constraints pass; no unowned critical finding.  
**Rollback/disable:** Recreate non-production environment before operational data; otherwise forward-correct. Disable all external access while preserving audit.

## R1 — Controlled intake and verified-event pilot

**After:** Sprint 4.  
**Audience:** Trained internal staff and a small consented resident test cohort; no safety-critical production reliance.  
**Scope:** F12–F14, F16–F19, F40: Reports, Cases, triage, correction/transfer, resident view, Investigation, Assessments, verified Incidents, recurrence.  
**Entry:** R0; approved safety content and test property/occupancy data.  
**Exit:** one Report/one Case invariant, no pre-verification Incident, resident access isolation, five-reports/one-Incident, wrong-building transfer, and recurrence scenarios pass.  
**Rollback/disable:** Close pilot submission channels, preserve accepted Cases, continue assisted intake and export; never delete pilot history.

## R2 — Operational coordination beta

**After:** Sprint 8.  
**Audience:** Selected managers, technicians, vendors, residents, and verifiers in a non-life-safety operating scope.  
**Scope:** F15, F20–F31, F41: Operations, Commitments, priority/sequence/SLA, field/offline, Evidence, verification, Decisions, workflow, disputes, notifications, integrations.  
**Entry:** R1; provider sandbox contracts; evidence/storage threat review.  
**Exit:** offline/device-loss, evidence loss, midnight emergency reconstruction, disagreement, wrong repair, provider retry, resident dispute, and full traceability tests pass; Storage/RLS negative matrices pass.  
**Rollback/disable:** Stop new beta scope, retain read/export and manual continuity, reconcile queued work and provider messages, forward-correct accepted records.

## R3 — Governed institutional system

**After:** Sprint 13.  
**Audience:** Full trained non-production organization and restricted operational pilot.  
**Scope:** F32–F46: governance, suppliers, major incidents, safety isolation, knowledge, memory, retention, search, analytics, manager/committee workspaces, governed AI.  
**Entry:** R2; local governance/retention/SLA configuration; provider risk approvals.  
**Exit:** fire/lift, contractor abandonment, committee/manager/developer replacement, archive/export/restore, KPI reproducibility, AI wrong/outdated recommendation and disablement tests pass.  
**Rollback/disable:** AI, search, analytics, and external adapters have independent kill switches; authoritative domain paths and export remain available.

## R4 — Production general availability

**After:** Sprint 15.  
**Audience:** Approved production population by phased building/Juristic Person rollout.  
**Scope:** F47–F48 plus all prior features; disaster recovery, manual continuity, production migration, training, pilot, hypercare.  
**Entry:** R3; named risk owners; production configuration; approved RTO/RPO; support/on-call and stewardship owners.  
**Exit:** all mandatory criteria pass; 31 scenarios pass; production-shaped load and restore meet objectives; no unaccepted critical risk; Juristic Person authorizes launch.  
**Rollout:** internal users → one low-risk building/cohort → additional buildings → full tenant; multi-tenant expansion only after transfer/isolation evidence.  
**Failure response:** freeze expansion, activate continuity, preserve inputs, reconcile explicitly, and make a human go/no-go Decision with evidence.

## Release evidence pack

Every gate includes scope and version manifest, architecture/ADR references, migration checksums/results, API/event contract versions, test and advisor results, security/privacy/accessibility evidence, data reconciliation, known risks and owners, telemetry/runbooks, training status, rollback/forward-correction plan, and signed release Decision. The pack becomes an Organizational Memory manifest after acceptance.
