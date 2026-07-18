# O83 Care Estimation Model

Version: 1.0  
Status: Planning Baseline

## Purpose

Estimates support capacity and sequencing without pretending uncertainty is time certainty. They include discovery, contracts, data, permissions, UI, tests, migration, observability, documentation, and acceptance—not coding alone.

## Complexity scale

| Size | Capacity units | Typical profile |
|---|---:|---|
| XS | 2 | One bounded contract, no migration/security novelty |
| S | 3 | Small vertical change with known patterns |
| M | 5 | One aggregate or role journey plus integration/tests |
| L | 8 | Multiple contracts/roles, significant lifecycle or security |
| XL | 13 | Cross-context, safety/security/history/offline/provider or migration-heavy |

An XL feature must be decomposed into executable stories by command/query/event/UI/test slice before a sprint starts. Its feature acceptance remains atomic at the milestone.

## Feature baseline

The catalog contains 7 L features and 41 XL features, totaling **589 capacity units**. The high profile is deliberate: each item is a production vertical feature with security, history, operations, and acceptance included. Story-level estimates will be smaller.

| Sprint | Features | Baseline units | Dominant uncertainty |
|---:|---|---:|---|
| 0 | F01–F02 | 21 | Live SQL compatibility and environment setup |
| 1 | F03–F05, F37 | 42 | RLS/privileged access and audit/event semantics |
| 2 | F06–F11 | 68 | Temporal organization/property imports and graph constraints |
| 3 | F12–F14, F40 | 52 | Safety content, resident UX, transfer/privacy |
| 4 | F16–F19 | 47 | Human verification and association semantics |
| 5 | F20–F23, F41 | 65 | Field usability and concept separation |
| 6 | F24–F27 | 52 | Offline conflicts, Storage, integrity, verification |
| 7 | F28–F29 | 26 | Decision/workflow boundary |
| 8 | F15, F30–F31 | 34 | Provider behavior and dispute policy |
| 9 | F32–F34 | 39 | Local legal rules and life-safety drills |
| 10 | F35–F36, F46 | 39 | Retention law, archive portability, validity context |
| 11 | F38–F39 | 26 | Scale, lineage and suppression |
| 12 | F42–F43 | 26 | Integrated role usability and data minimization |
| 13 | F44–F45 | 26 | Provider/model risk and evaluation thresholds |
| 14 | F47 | 13 | Infrastructure topology and continuity exercise |
| 15 | F48 | 13 | Defect/risk burn-down and rollout evidence |
| **Total** | **48 features** | **589** | |

## Capacity and schedule use

The 16 sprints are program increments, not assumed two-week iterations. Feature teams may run shorter engineering iterations within them. With multiple stable vertical squads, work inside a sprint can be parallelized after predecessor contracts are published. Calendar forecasting uses each squad's demonstrated accepted-unit throughput, availability, review capacity, provider lead time, and risk contingency. Do not divide 589 by an aspirational velocity.

Reserve explicit capacity: 15–25% for security/data quality/operational hardening throughout; 20–30% contingency for Sprints 0, 1, 6, 9, 14, and 15; and named specialist availability for database, RLS, accessibility, safety, privacy, evidence, and continuity reviews. Provider procurement, legal/governance approval, translations, test devices, and production data preparation are lead-time dependencies rather than coding estimates.

## Re-estimation triggers

Re-estimate when live SQL or advisor results change design; a normative rule changes; jurisdictional retention/SLA/governance input arrives; tenant volume/skew exceeds assumptions; provider capability differs; accessibility testing exposes a redesign; a critical risk materializes; offline/restore drills fail; or a feature crosses another bounded context. Preserve the old estimate and reason for change.

## Confidence

Baseline estimates are **Class 4 / roadmap-level**: suitable for sequencing and staffing, not commitments. Confidence becomes Class 3 after feature contract and UX discovery, Class 2 after production-shaped spike and test plan, and Class 1 only after comparable accepted delivery. Milestone dates require at least Class 3 estimates for their critical-path features.
