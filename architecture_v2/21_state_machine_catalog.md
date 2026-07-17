# State Machine Catalog

Version: 2.0  
Status: Normative Architecture Baseline

## Purpose

This catalog defines lifecycle meanings and allowed transitions. State is a current projection; transition history is immutable.

## Case

`Open → UnderInvestigation → AwaitingResponse → Resolved → Closed`. `UnderInvestigation` and `AwaitingResponse` may alternate. `Resolved → UnderInvestigation` records new information. `Closed → Open` is a reopen transition with reason; prior closure remains. Cancellation is allowed only for invalid system creation, never to merge a genuine report.

## Investigation

`Opened → Gathering → AssessmentReady → Concluded`. Assessment may return to Gathering. A concluded Investigation may reopen to `Gathering` when new evidence concerns the same investigative question, or a new linked Investigation may be created for a materially different question. The reasoned human choice is recorded.

## Incident

`Verified → Active → Monitoring → Closed`. Incident identity begins only after authorized human verification; suspected events remain in Investigation. `Closed → Active` is a human-authorized Reopen. Similar later Cases do not trigger it automatically. A verification decision may later be superseded, but the Incident record is retained and marked `VerificationWithdrawn` for current interpretation rather than deleted.

## Operation

`Proposed → Authorized → Scheduled → InProgress → AwaitingVerification → Completed`. `InProgress ↔ Paused`; failed verification returns to `InProgress`. Proposed or Authorized may become `Cancelled` with authority and consequence review.

## Commitment

`Offered → Accepted → InProgress → Fulfilled`; Accepted/InProgress may become `RenegotiationRequested`, then resume, be replaced, or become `Released` by an authorized party. Interruption does not silently cancel it.

## Decision

`Draft → Decided → InEffect → UnderReview → Superseded`; before effect, Decided may become `Withdrawn`. Decisions are never edited into a different outcome.

## Knowledge

`Draft → InReview → Published → Challenged → Published|Deprecated|Superseded`. Superseded records remain available in historical context.

## Evidence

Capture, upload, integrity check, review, challenge, restriction, and disposition are orthogonal flags/events rather than one state that implies truth.

## Transition contract

Every transition requires aggregate version, actor, acting role, occurred/action time, recorded time, reason, and relevant decision/authority/evidence. Invalid transitions fail visibly. Emergency reconstruction records the real sequence instead of manufacturing compliance.

State transitions do not replace Decision Records. Incident verification, association, priority override, verification withdrawal, reopen, closure, and governed cancellation require the relevant human decision in [09_decision_model.md](09_decision_model.md).
