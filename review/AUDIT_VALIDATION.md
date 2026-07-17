# Auditability Validation

Version: 1.0  
Status: Passed with Control Requirements

## Purpose

This report tests whether every important action can answer who acted, when, why, based on what evidence, under whose Authority, and how state changed.

## Mandatory action envelope

Every consequential action or transition must record:

| Question | Required data |
|---|---|
| Who? | Actor identity, human/technical principal type, acting role, organization relationship |
| When? | Event/action, effective, recorded, and upload times as applicable; clock/source confidence |
| Why? | Structured reason code plus narrative for consequential exceptions/overrides |
| Based on what? | Evidence, Observation, Hypothesis, Assessment, Recommendation, policy, and omitted-source references |
| Authorized by whom/what? | Mandate/policy/law/contract/emergency-necessity source effective at action time |
| Previous state? | Aggregate version and prior state/reference, not merely display text |
| Current state? | Accepted next state and new aggregate version |
| Reason for change? | Decision/transition rationale, consequences, affected commitments, correlation/causation |

## Audit coverage matrix

| Action class | Domain record | Security audit | Additional requirement |
|---|---|---|---|
| Report acceptance/Case creation | Report, Case, Domain Event | Channel/system actor | Idempotency outcome and original payload identity |
| Party/location correction or transfer | Assertion/transfer Decision | Access and cross-tenant audit | Currently missing semantic model |
| Incident verification/withdrawal | Decision, Assessment, Incident transition | Privileged action audit | Authority and considered Evidence mandatory |
| Case-Incident association | Association and Decision | Bulk/privileged audit | Per-Case result for batch action |
| Priority/override/interruption | Decision, Priority, Interruption | Actor/session audit | Affected commitments and consequence |
| Emergency action | Operation/Action reconstruction | Failed-contact and retrospective access audit | Actual action time; no fake preapproval |
| Work/verification/closure | Operation transition, Verification, Decision | Separation-of-duty audit | Performer/verifier identities and criteria version |
| Evidence capture/upload/view/export/redact/dispose | Evidence and custody events | Every privileged access/disclosure | Digest, rendition lineage, legal Authority |
| Responsibility/Mandate/Handover | Organization records | Privileged administration audit | Effective-time overlap/gap report |
| Contract/SLA change | Contract/Policy Decision | Governance audit | Model currently incomplete |
| Knowledge publish/supersede | Knowledge version/review | Steward action audit | Validity Context and source lineage |
| AI generation/adoption/disablement | AI Interaction, Recommendation, human Decision | AI access/configuration audit | Model/service version and data purpose |
| Notification rendering/delivery/correction | Intent/Attempt | Provider/admin audit | Template/policy version and disclosed fields |
| Workflow definition/migration | Policy/Definition/Decision | Deployment/admin audit | Instance mapping, affected population, rollback |
| KPI/report issue/restatement | Definition/Snapshot/Restatement | Publisher access audit | As-of dataset, formula version, suppression |
| Export/restore/archive | Memory Manifest | Highly privileged audit | Scope, digest, custody, result, reconciliation |

## Domain events versus Audit Entries

Domain Events explain accepted business facts. Audit Entries explain security and administrative activity, including failed attempts and reads that do not change business state. They may correlate but must not be conflated: deleting an account, viewing restricted evidence, failed authorization, or changing AI configuration may need audit even when no domain aggregate changes.

## Tamper evidence and independence

Audit persistence must be append-only, tenant-scoped, access-restricted, integrity-verifiable, and operationally independent enough that an ordinary domain administrator cannot alter it. Audit access is audited. Clock synchronization and offline clock uncertainty must be represented; ordering by record time alone is insufficient.

## Audit gaps

1. Contract/SLA, property/asset, transfer, Task, taxonomy, and proactive-maintenance actions cannot be completely audited until their business semantics exist.
2. Read/export purpose and legal basis require a consistent access-decision record.
3. Delegated Authority needs a verifiable chain and cycle prevention.
4. Audit/event/evidence retention alignment needs jurisdiction-specific policy.
5. High-volume failed attempts and provider callbacks need scale and aggregation rules that preserve forensic value.

## Auditability score

Auditability: **92/100**. The required questions are architecturally supported for modeled domains. Missing domain semantics prevent complete audit coverage in the identified critical areas.
