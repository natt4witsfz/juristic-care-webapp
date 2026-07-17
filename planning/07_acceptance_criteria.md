# O83 Care Program Acceptance Criteria

Version: 1.0  
Status: Normative Delivery Gate

## Purpose

These measurable criteria prevent feature teams from interpreting architectural invariants differently. “Pass” requires executable evidence in the target environment plus traceable human review where judgment is involved.

## Foundation and identity

| ID | Acceptance criterion | Features / gate |
|---|---|---|
| AC-01 | Approved SQL applies cleanly in order, validates expected objects, and repeats without unintended duplicate objects | F02 / R0 |
| AC-02 | No authoritative O83 table is exposed in `public`; every reachable object requires explicit grant and allowing policy | F02, F05 / R0 |
| AC-03 | Cross-tenant IDs are denied for every role, query, mutation, view, Storage path, search facet, and bulk action | F05 / all releases |
| AC-04 | Disabled account, ended relationship, revoked/expired Mandate, and lost device lose access within the approved tolerance | F04–F07, F24 / R0–R2 |
| AC-05 | Service credentials never reach a client; privileged actions validate caller, tenant, purpose, scope and write audit | F05, F31, F37 / all releases |
| AC-06 | Material action trace answers who, role, when, why, evidence, Authority, previous/current state and correlation | F03, F37 / R0 |

## Organization and estate

| ID | Acceptance criterion | Features / gate |
|---|---|---|
| AC-07 | Role, Responsibility, Authority, Commitment, Capability, Availability, Priority, Sequence and SLA are stored and displayed independently | F06–F08, F21–F23 / R2 |
| AC-08 | Delegation, revocation, role, capability, availability and responsibility periods reject invalid overlap/cycle and remain queryable as-of | F06–F08 / R0 |
| AC-09 | Handover transfers future stewardship and preserves predecessor decisions/actions | F08 / R0 |
| AC-10 | Property/room renaming, occupancy change, asset movement and component replacement retain durable identity and history | F09–F10 / R0 |
| AC-11 | Asset/taxonomy graphs reject prohibited cycles and code reuse | F10–F11 / R0 |

## Report, Case, Investigation, and Incident

| ID | Acceptance criterion | Features / gate |
|---|---|---|
| AC-12 | Every accepted Report creates exactly one Case; retries are idempotent; similarity never merges Cases | F12 / R1 |
| AC-13 | Five residents reporting one leak retain five acknowledgement and communication paths | F12, F18 / R1 |
| AC-14 | Immediate-danger path directs safe action before form completion; delayed reconstruction preserves separate times and uncertainty | F13 / R1 |
| AC-15 | Wrong resident/building/asset/category is corrected by new assertion; original submitted context remains visible | F14 / R1 |
| AC-16 | Cross-tenant transfer remains pending with sender responsibility until destination acceptance and scoped data authorization | F14 / R1 |
| AC-17 | Observations, hypotheses, disputes, unknowns and Assessments are visually and structurally distinct | F16–F17 / R1 |
| AC-18 | New Assessment supersedes without changing prior content or evidence basis | F17 / R1 |
| AC-19 | Incident creation fails unless an authorized human Decision verifies the event from an Assessment | F18 / R1 |
| AC-20 | Each Case-Incident association/disassociation records human, role, Authority, reason, evidence and time; batch gives per-item reconciliation | F18 / R1 |
| AC-21 | Return after two days or six months starts with investigation; human classifies recurrence/reopen/new Incident | F19 / R1 |

## Operations, Evidence, and Decisions

| ID | Acceptance criterion | Features / gate |
|---|---|---|
| AC-22 | Operation has at least one governed origin and work subject; Maintenance Plan origin needs no Incident | F20 / R2 |
| AC-23 | Commitment is explicitly accepted/declined/renegotiated; assignment alone is not acceptance | F21 / R2 |
| AC-24 | Technician can choose Execution Sequence within constraints; priority changes and interruptions remain separate historical Decisions/events | F22 / R2 |
| AC-25 | Unsafe-work refusal preserves protected dissent and routes qualified neutral review without deleting manager view | F22, F34 / R3 |
| AC-26 | SLA result reproduces from exact policy version, calendar, classification and clock events, including authorized blocked time | F23 / R2 |
| AC-27 | Offline duplicate/retry is idempotent; material conflict never uses silent last-write-wins; stale Authority is revalidated | F24 / R2 |
| AC-28 | Storage path alone never authorizes; Evidence original cannot be overwritten or client-upserted | F25–F26 / R2 |
| AC-29 | Evidence promotion preserves attachment lineage, digest, source, capture/upload time, custodian and classification | F25–F26 / R2 |
| AC-30 | Missing/corrupt Evidence raises integrity event, attempts recovery and identifies affected Assessments/Decisions | F26 / R2 |
| AC-31 | Rendition does not replace original; issued package manifest is immutable and independently verifiable | F27 / R2 |
| AC-32 | High-risk work cannot be self-verified; failed/inconclusive verification preserves attempt and returns actionable work | F27 / R2 |
| AC-33 | Decision records observation, hypothesis, evidence, alternatives, Authority, dissent, consequences; revision is a new linked Decision | F28 / R2 |
| AC-34 | Wrong repair triggers containment, corrective Operation, independent review, liability/governance branch and Knowledge feedback | F22, F27–F29, F33–F35 / R3 |
| AC-35 | Workflow transition cannot bypass domain invariant; previous/current state, actor and reason are immutable | F29 / R2 |

## Communication, governance, knowledge, and memory

| ID | Acceptance criterion | Features / gate |
|---|---|---|
| AC-36 | Notification intent is idempotent; audience/content are purpose-minimized; provider receipt differs from acknowledgement | F30 / R2 |
| AC-37 | Provider replay or inbound duplicate cannot duplicate a domain action; semantic conflict is quarantined/reconciled | F31 / R2 |
| AC-38 | Resident dispute distinguishes new Evidence, recurrence, criteria disagreement and communication failure, with independent review/appeal | F15 / R2 |
| AC-39 | Committee resolution proves effective membership, quorum, conflicts, evidence, alternatives, votes/dissent and Authority | F32 / R3 |
| AC-40 | Contractor abandonment revokes access, transfers custody, preserves management responsibility and creates replacement Commitment | F33 / R3 |
| AC-41 | Fire/rescue statutory command handoff and local liaison are timestamped; local workflow does not obstruct external command | F34 / R3 |
| AC-42 | Safety-critical asset remains isolated until qualified certification, independent verification and authorized return-to-service Decision | F34 / R3 |
| AC-43 | Knowledge cannot publish without validity context, source, confidence/limits, review and effective status | F35 / R3 |
| AC-44 | Conflicting/outdated Knowledge remains discoverable with challenge/supersession and context mismatch warning | F35 / R3 |
| AC-45 | Organizational Memory export includes identifiers, schema/event versions, evidence manifests, lineage, Decisions, Responsibility and checksums | F36 / R3 |
| AC-46 | Independent replacement team can verify and restore export without original developer/vendor | F36 / R3 |
| AC-47 | Legal hold blocks disposition across database, Storage, archive, backup procedure and derived indexes as governed | F46 / R3 |

## Search, analytics, workspaces, AI, and production

| ID | Acceptance criterion | Features / gate |
|---|---|---|
| AC-48 | Search index can be rebuilt from authoritative events/records and never reveals restricted snippets/facets | F38 / R3 |
| AC-49 | Issued KPI/report reproduces formula version, source lineage, population, exclusions, dimensions, as-of time and restatement | F39 / R3 |
| AC-50 | KPI never automatically assigns blame, priority, closure, Authority or punishment; small populations are suppressed | F39 / R3 |
| AC-51 | Resident, Technician, Manager and Committee workspaces invoke the same authorized domain contracts and show denial/exception recovery | F40–F43 / R3 |
| AC-52 | AI service has no general domain read and cannot mutate Case association, Incident, priority, responsibility, verification, closure or governance | F44–F45 / R3 |
| AC-53 | AI factual claims cite durable permitted sources; uncertainty, contrary evidence, context mismatch, model/version and human adoption are visible | F45 / R3 |
| AC-54 | Wrong/outdated AI recommendation can be declined/corrected; kill switch and manual path work during provider outage | F44–F45 / R3 |
| AC-55 | Full backup restore and Organizational Memory restore meet approved RTO/RPO and integrity reconciliation | F47 / R4 |
| AC-56 | Power/internet outage drill preserves manual Report/Case identity, emergency actions, custody and post-recovery reconciliation | F47 / R4 |
| AC-57 | Production-shaped load meets agreed SLOs with RLS and representative tenant skew; archive retrieval meets objective | F48 / R4 |
| AC-58 | WCAG/accessibility, language, low-bandwidth, shared-device and safety-content tests pass for released role surfaces | F40–F43, F48 / R4 |
| AC-59 | All 31 operational validation scenarios pass with immutable chronology and traceability | F48 / R4 |
| AC-60 | No open unaccepted Critical risk; named business, security, privacy, operations, data and technical authorities sign launch | F48 / R4 |

## Evidence format

Each criterion records environment, build/schema/config versions, test data classification, execution time, result, artifacts, reviewer, exceptions, linked defects, and acceptance Decision. A later failure supersedes the pass; it does not erase it.
