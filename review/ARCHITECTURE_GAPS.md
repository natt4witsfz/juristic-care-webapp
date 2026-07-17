# Architecture Gap Register

Version: 1.0  
Status: Validation Findings

## Purpose

This register contains only gaps exposed by realistic operational validation. Recommendations extend the current Version 2 architecture; they do not replace it.

## Gaps

| ID | Severity | Gap | Consequence | Recommended architecture improvement | Primary documents |
|---|---|---|---|---|---|
| GAP-01 | Critical | Report/Case party, location, asset, building, and cross-tenant correction/transfer semantics are incomplete | Privacy breach, orphaned responsibility, duplicate work, wrong SLA, broken traceability | Add immutable submitted context plus effective-dated corrected assertions; model Reporter/Affected Party/Representative; require destination acceptance and scoped evidence transfer across Juristic Persons | Domain, Workflow, Data, Security, Resident, Manager |
| GAP-02 | Medium | Bulk Case-Incident Association atomicity is undefined | Partial hidden association or lost Case coverage | Define batch command as per-item decisions with all-or-explicit-partial outcome, idempotency, audit, preview, and reconciliation | Domain, Workflow, Event, Database |
| GAP-03 | High | Wrong work/adverse outcome lacks a dedicated non-punitive remediation workflow | Concealment, retroactive approval, weak learning, repeated harm | Add adverse-outcome assessment, immediate containment, corrective Operation, independent verification, liability/governance branches, and Knowledge feedback | Operation, Workflow, Decision, Evidence, Governance |
| GAP-04 | High | Evidence loss/corruption response and manifest reconciliation are not explicit | Decisions depend on unavailable evidence; silent integrity failure | Add evidence availability/integrity events, periodic manifest verification, recovery, affected-decision tracing, and security/privacy escalation | Evidence, Security, Data, Reference Architecture |
| GAP-05 | High | Technical disagreement, protected dissent, unsafe-work refusal, and tie-break Authority are under-specified | Deadlock, Authority abuse, unsafe work, hidden dissent | Add graded disagreement workflow, stop-work rule, neutral qualified review, timebox, precautionary action, and non-retaliation | Organization, Operation, Workflow, Governance, Technician |
| GAP-06 | Medium | Repeated reopen/failed-verification cycles have no systemic-review threshold | Infinite symptom repair and misleading closure statistics | Add cycle visibility and configurable escalation to root-cause, asset strategy, independent review, or residual-risk decision; never cap valid reopen | Operation, Workflow, States, KPI |
| GAP-07 | High | Offline/device-loss conflict resolution is conceptual rather than deterministic | Duplicate actions, lost records, stale Authority, false chronology | Define secure local queue, clock uncertainty, conflict taxonomy, idempotency, Authority revalidation, reconciliation decisions, and user-visible resolution | System, Data, Workflow, Technician, Security |
| GAP-08 | High | Full service/power outage continuity and manual reconciliation are not detailed | No intake, notification, or evidence path during building emergency | Add degraded/manual modes, voice/paper Case capture, critical contact trees, recovery sequencing, and post-restoration reconciliation | System, Notification, Workflow, Reference Architecture |
| GAP-09 | High | Authority exhaustion and on-call succession are implicit | Emergency or urgent decisions stall, or unmandated actors overreach | Define succession ladder, standing emergency scope, expiry, acknowledgement, failed-contact audit, and retrospective review | Organization, Governance, Workflow, Permissions |
| GAP-10 | Critical | Major-incident command and external statutory Authority handoff are missing | Local workflow conflicts with fire/rescue command; life-safety delay | Add Major Incident coordination pattern identifying external commander, local liaison, command transfer times, restricted evidence, mass communication, and recovery transition | Foundation, Governance, Workflow, Notification, Security |
| GAP-11 | Critical | Safety-critical asset isolation and return-to-service control are not explicit | Lift/fire/power system returned unsafely; unqualified intervention | Add isolation state, qualified-person requirements, lockout/control custody, external certification, independent verification, and authorized return-to-service decision | Asset references, Operation, Evidence, States, Permissions |
| GAP-12 | High | Contractor abandonment and Commitment substitution are missing | Orphaned work, active access, lost custody, disputed liability | Add supplier failure event, access revocation, site/material/evidence custody, management residual responsibility, replacement Commitment, and contract decision links | Organization, Operation, Workflow, Security, Governance |
| GAP-13 | High | Inspection refusal and blocked-dependency/SLA handling are incomplete | Deadlock, coercion, unsafe delay, unfair SLA reporting | Add access/consent state, alternatives, lawful-entry decision, pause rules, blocked-time analytics, and escalation by risk | Workflow, SLA policy, Resident, Manager, Permissions |
| GAP-14 | Medium | Resident dispute lifecycle and independent-review target are implicit | Circular reopen, defensive closure, inconsistent treatment | Add dispute acknowledgement, categorization, independent review, appeal, outcome types, loop escalation, and reporting exclusion rules | Case, Workflow, Resident, Manager, KPI |

## Priority order

1. Resolve GAP-10 and GAP-11 before any life-safety workflow is implemented.
2. Resolve GAP-01 before multi-building or multi-Juristic-Person deployment.
3. Resolve GAP-04, GAP-05, GAP-07, GAP-08, GAP-09, GAP-12, and GAP-13 before production operations.
4. Resolve GAP-02, GAP-03, GAP-06, and GAP-14 before broad operational rollout and KPI baselining.

## Gap count

- Critical: 3
- High: 8
- Medium: 3
- Low: 0
- Total: 14
