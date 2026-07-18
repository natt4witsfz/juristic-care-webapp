# Event Architecture

Version: 2.0  
Status: Architecture Baseline

## Purpose

Events communicate completed domain facts across bounded contexts and preserve an interpretable operational chronology.

## Event envelope

Every event includes unique event identifier, event type and schema version, aggregate type/id/version, tenant, occurred time, recorded time, actor and acting role, correlation and causation identifiers, producer, classification, and payload. Upload time is included when offline capture matters. Sensitive payloads use references or minimized fields.

## Semantics

Event names use past tense, such as `CaseCreated`, `UnderstandingAssessmentRecorded`, `IncidentVerified`, `CaseAssociatedWithIncident`, `OperationInterrupted`, `EvidenceUploaded`, `DecisionSuperseded`, and `IncidentReopened`. There is no `IncidentSuspected` domain event because suspicion belongs to Investigation; `HypothesisRecorded` or `InvestigationOpened` expresses that stage. An event states what was accepted by the source aggregate, not an instruction or inference.

## Delivery and consistency

The source transaction writes state and an outbox atomically. Delivery is at least once; consumers are idempotent using event identity and track processing outcomes. Ordering is guaranteed only per aggregate stream. Consumers tolerate duplicates, delay, and out-of-order cross-aggregate events.

## Evolution

Schemas are immutable after publication. Additive compatible changes remain within a version; semantic or structural breaks create a new version. Producers provide deprecation windows and consumer impact analysis. Replay uses controlled authorization, rate limits, and side-effect suppression.

## Failure handling

Retries use backoff. Poison events enter a visible quarantine with no data loss. Operators can inspect, correct consumer configuration, and replay; they cannot edit the original event. Reconciliation compares source aggregates, outbox, transport, and projections.

## Boundaries

Events do not grant authority and do not expose evidence or personal data broadly. External integration events are translated through anti-corruption adapters. State transitions are listed in [21_state_machine_catalog.md](21_state_machine_catalog.md).

Events contributing to Decision Evolution carry references rather than duplicating full assessments or evidence. Responsibility-related events identify actor and acting role but do not substitute for the authoritative Mandate, Responsibility, or Commitment record in the Organization and Work contexts.
