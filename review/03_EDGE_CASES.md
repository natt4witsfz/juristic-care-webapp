# O83 Care Edge-Case Review

Version: 1.0  
Status: Complete

## Purpose

This review attempts to break the Version 2 architecture through deadlock, repetition, missing Authority, unavailable people or systems, contradictory information, and data failure. Gap identifiers refer to [ARCHITECTURE_GAPS.md](ARCHITECTURE_GAPS.md).

## Deadlocks

| Deadlock | Current behavior | Failure if unresolved | Required control |
|---|---|---|---|
| Resident refuses access while evidence is insufficient | Case/Operation can pause; escalation is general | Infinite waiting, unsafe delay, false SLA breach | Access-refusal state, lawful escalation, alternative evidence, blocked-time accounting (GAP-13) |
| Technicians disagree and no qualified reviewer is available | Dissent is preserved | Work stalls or manager chooses without technical basis | Timeboxed neutral review, precautionary action, stop-work rule (GAP-05) |
| Manager and technician dispute safety | Authority and Capability are separate | Unsafe instruction or unmanaged refusal | Protected professional dissent and higher safety escalation (GAP-05) |
| Evidence contradicts and closure criteria cannot be met | Investigation can continue | Permanent open Incident | Uncertainty acceptance decision, monitoring option, review cadence |
| Required approver unavailable after hours | Emergency necessity permits action | Non-emergency work stalls indefinitely | Authority succession and expiry-aware escalation (GAP-09) |
| Contractor abandons accepted Commitment | Handover exists conceptually | Orphaned work and site custody | Commitment substitution and supplier-abandonment workflow (GAP-12) |

## Circular workflows and infinite loops

### Reopen loop

`Closed → Active → Monitoring → Closed` can repeat legitimately. The architecture correctly preserves every cycle but does not require systemic review after repeated cycles. Without a threshold, teams can repeatedly repair symptoms. Add cycle count, repeated-cause review, escalation, and explicit decision to continue monitoring, replace an asset, or accept residual risk (GAP-06). Never impose a hard maximum that would conceal recurrence.

### Verification loop

`InProgress → AwaitingVerification → InProgress` may repeat. Each failed verification must state unmet acceptance criteria and create a responsibility-aware remediation decision. After a configured threshold, independent technical review prevents a performer/verifier stalemate.

### Dispute loop

A resident may dispute every closure. The system must preserve access to challenge without endlessly reopening. A dispute workflow should distinguish new evidence, disagreement with criteria, communication failure, recurrence, and abusive repetition, with independent review and appeal finality under policy (GAP-14).

### Knowledge challenge loop

Conflicting Knowledge Records may remain challenged. This is acceptable when uncertainty is real, but current workflows must identify which policy or safety rule controls pending review. Knowledge disagreement cannot suspend statutory or approved policy Authority.

## Responsibility gaps

- Case intake, Investigation, Incident, Operation, verification, and closure use distinct responsibilities; this is sound.
- A global owner is correctly rejected.
- Cross-building transfer can create a gap between sending and receiving organizations; transfer must remain pending until destination acceptance or sender retains responsibility (GAP-01).
- Contractor abandonment can leave no accepted Commitment; management responsibility persists even when performance is outsourced (GAP-12).
- Manager/committee transitions require interim mandates when terms do not align; mandate-gap detection should alert governance.
- Notification delivery failure must return to the originating responsible function rather than become solely a provider problem.

## Authority conflicts

| Conflict | Resolution principle |
|---|---|
| Committee decision versus law/emergency command | Law and statutory emergency Authority prevail |
| Manager priority versus technician safety judgment | Manager sets Organizational Priority; technician retains stop-work duty within professional/safety rules |
| Technical access versus business Authority | Access never legitimizes a decision |
| Resident urgency versus Organizational Priority | Resident input is evidence of impact; authorized management decides priority |
| SLA versus emergency | Safety action overrides sequence; SLA consequence is recorded, not used to delay action |
| External responder versus local manager | External command governs its statutory scope; O83 Care supports and records handoff (GAP-10) |
| New committee versus historical records | New mandate may supersede policy prospectively; it cannot rewrite history |

## Audit and history risks

The baseline audits actors, roles, actions, reasons, Authority, chronology, and access. Additional audit coverage is required for attempted cross-tenant transfers, offline conflict resolution, evidence-manifest failures, AI use-case disablement, emergency Authority succession, safety isolation/return-to-service, dispute disposition, and bulk Case association.

History remains intact under correction, disassociation, withdrawn verification, reopen, late evidence, changed hypotheses, failed work, committee rejection, and steward transitions. A lawful evidence disposition must retain only permitted tombstone metadata and must not retain content law requires removed.

## Traceability and data consistency

- Every Report-to-Case link is one-to-one and stable.
- Case-Incident Association is independently reasoned and historical.
- Investigation Assessment, Decision, Incident, Operation, Evidence, Responsibility Chain, and events are traceable.
- Bulk association needs explicit all-or-partial behavior (GAP-02).
- Offline synchronization needs deterministic conflict classes and clock uncertainty (GAP-07).
- Wrong-building transfer must not copy data across Juristic Persons without Authority (GAP-01).
- Evidence objects require manifest reconciliation to detect silent loss (GAP-04).
- Derived current projections must be rebuildable and display staleness for consequential use.

## Human-error resilience

Wrong resident, building, asset, cause, repair, priority, evidence link, or Incident association must be corrected through new assertions and decisions rather than editing originals. Interfaces should show confirmation for cross-building context, safety-critical asset identity, and high-impact association/closure. Batch operations require preview, per-item results, idempotency, and reconciliation.

## Emergency exceptions

Emergency work may precede records, evidence, or ordinary approval. This exception must not become an unbounded bypass: the actor, Capability, necessity, scope, event/action/record/upload times, affected commitments, and later review remain required. Major incidents additionally require explicit transfer to external emergency command (GAP-10), and safety-critical assets require controlled isolation and return to service (GAP-11).

## Edge-case conclusion

No unavoidable circular dependency was found. Deadlocks are resolvable through explicit escalation, timeboxing, precautionary action, independent review, and Authority succession. The architecture needs the identified catalog/workflow clarifications before these controls can be implemented consistently.
