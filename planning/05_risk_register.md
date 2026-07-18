# O83 Care Engineering Program Risk Register

Version: 1.0  
Status: Active Delivery Register

## Scale and governance

Severity combines plausible harm and implementation exposure. Critical risk cannot be accepted by the delivery team alone. Each risk has an accountable business owner before its first production-facing release; assignment to a supplier does not transfer ownership from the Juristic Person. Evidence, review date, trigger indicators, treatment status, and residual-risk Decision are maintained throughout delivery.

## Risks

| ID | Severity | Risk / trigger | Primary treatment and validating features | Owner / gate | Target residual |
|---|---|---|---|---|---|
| PR-01 | Critical | Cross-tenant or sensitive data exposure through RLS, view, Storage, search, Realtime, or support tooling | Private schemas, F05 policy matrix, F25 object authorization, F38 source-equivalent search, penetration and negative tests | Security owner / R0–R4 | Low |
| PR-02 | Critical | Evidence metadata/object divergence, corruption, overwrite, or silent loss | F25–F27 immutable originals, digest/custody, orphan/manifest scan, affected-decision tracing, restore tests | Evidence custodian / R2 | Low |
| PR-03 | Critical | Migration/backfill overwrites history or invents actor, time, Authority, or evidence | F02 expand-contract, explicit unknowns, reconciliation/as-of comparison, forward correction, sealed migrations | Database owner / every release | Low |
| PR-04 | Critical | Local workflow conflicts with statutory emergency command | F13 and F34 external commander/local liaison/handoff, restricted evidence, mass communication, drills | Safety/governance owner / R3 | Low |
| PR-05 | Critical | Lift, fire, electrical, or other critical asset returns to service without qualified independent verification | F10/F27/F34 isolation, lockout custody, certification, verification, authorized release Decision | Asset safety owner / R3 | Low |
| PR-06 | Critical | Offline conflict, clock uncertainty, or damaged device duplicates/loses emergency actions | F24 encrypted durable queue, server reauthorization, deterministic conflict classes, device revocation, reconciliation | Operations/security / R2 | Medium |
| PR-07 | Critical | Power/cloud/provider outage removes all reporting and coordination paths | F13/F47 paper/voice/manual intake, contact trees, restore/failover, custody and reconciliation drills | Continuity owner / R4 | Medium |
| PR-08 | Critical | Service role, privileged function, support access, or integration bypasses business Authority/audit | F05/F31/F37 scoped principals, no client secret, caller/purpose checks, access logging, grant review | Security owner / R0–R4 | Low |
| PR-09 | Critical | Wrong, outdated, biased, or injected AI advice is adopted as a decision | F44–F45 mediated context, citations, limits, human adoption, evaluation, kill switch, training | AI use-case owner / R3 | Medium |
| PR-10 | Critical | Retention/disposition violates law, privacy, legal hold, or evidence needs | F32/F36/F46 versioned policy, hold precedence, verified disposition, backup/cache coverage | Privacy/legal owner / R3–R4 | Low |
| PR-11 | High | Automatic/accidental Case merge or premature Incident destroys traceability | F12 and F18 hard invariants, command tests, no merge control, human verification | Domain owner / R1 | Low |
| PR-12 | High | Authority unavailable after hours or succession is ambiguous | F07/F08/F13 expiry alert, standing emergency scope, succession ladder, failed-contact audit | Governance owner / R1–R3 | Low |
| PR-13 | High | Manager suppresses technical dissent or unsafe-work refusal | F22/F28/F34 protected dissent, stop-work, neutral reviewer, non-retaliation | Safety/HR governance / R2–R3 | Medium |
| PR-14 | High | Contractor abandonment leaves access, custody, and work uncontrolled | F21/F33 replacement Commitment, revocation, custody transfer, residual responsibility | Vendor owner / R3 | Low |
| PR-15 | High | Reopen/verification/dispute loops hide systemic failure or consume capacity | F15/F19/F27/F39 cycle visibility, independent review, escalation without hard cap | Operations owner / R2–R3 | Medium |
| PR-16 | High | Event, audit, evidence, or analytics growth degrades 20-year operations | F02/F37/F38/F46 partition/archive/index/plan/volume testing and rebuildable projections | Data/SRE owner / R4 | Medium |
| PR-17 | High | Notification/integration provider duplicates, loses, or over-discloses messages | F30–F31 idempotent intent, purpose rendition, delivery history, reconciliation, adapter isolation | Integration owner / R2 | Low |
| PR-18 | High | Organizational Memory becomes mutable duplicate truth or vendor-locked archive | F36 source lineage, sealed manifest, open export, independent restore and exit drill | Memory custodian / R3 | Low |
| PR-19 | High | Metrics cause gaming, premature closure, Case merging, or individual punishment | F39 formula governance, guardrails, suppression, qualitative review, no automatic consequences | KPI owner / R3 | Medium |
| PR-20 | High | Production rollout outruns training, support, configuration, or operational ownership | F48 phased pilot, readiness dossier, role training, hypercare, expansion freeze criteria | Program sponsor / R4 | Low |

## Critical risk count

There are **10 Critical** and **10 High** program risks. “Implementation Ready: YES” means the work is sequenced with owners and gates; it does not mean these risks are already closed.

## Escalation and review triggers

Immediate review follows any safety event, cross-tenant denial anomaly, evidence integrity failure, unbounded audit/outbox backlog, failed restore, AI material error, repeated reopen, provider abandonment, migration discrepancy, or governance/staff/developer transition. A Critical risk with failed control evidence blocks the applicable release. Residual Critical risk requires the highest lawful Authority and cannot waive life-safety duties.
