# Design Principles

Version: 2.0  
Status: Architecture Baseline

## Purpose

These principles guide product, data, workflow, and technical decisions when detailed rules do not yet exist.

## Principles

### Model reality before workflow

Capture what happened, when it happened, and who knew what before enforcing administrative sequence. The system must tolerate delayed entry and incomplete information without confusing either with misconduct.

### Case first; Incident after investigation

One report produces one Case and one acknowledgement path. Similarity may be suggested but never used to merge. An authorized investigator may associate Cases with an Incident and must record evidence and reasoning.

### Append, relate, supersede

Material facts are not edited out of history. New records correct, challenge, or supersede earlier records. Current views are projections over immutable history.

### Separate powers and constraints

Responsibility describes accountability; Authority describes permitted decisions; Commitment describes accepted work; Capability describes competence; Availability describes present capacity; Organizational Priority describes management importance; Execution Sequence describes practical order; SLA describes an organization-level service expectation. No single owner, assignee, deadline, or priority field substitutes for them.

### Safety before compliance

People may stabilize danger without waiting for approval or connectivity. The system clearly marks reconstructed records, event time, action time, record time, and upload time.

### Human judgment with visible support

Automation may validate structure, calculate, route, and recommend. Consequential classification, association, prioritization, verification, closure, punishment, and governance decisions remain attributable to authorized humans.

### Evidence with provenance

Evidence records origin, custodian, capture method, timestamps, integrity metadata, access restrictions, and relationship to claims. Absence of evidence is not evidence of absence.

### Context before reuse

Lessons and AI recommendations declare asset, component, model, location, environment, policy/workflow versions, effective period, assumptions, limitations, evidence base, and verification status.

### Least privilege and useful transparency

Access is minimized by role and purpose, while decisions affecting a participant remain explainable and contestable. Sensitive data is redacted in views rather than deleted from authoritative history.

### Evolvability

Bounded contexts communicate through versioned contracts and events. Consumers tolerate additive change. Architecture decisions and migrations preserve rationale and rollback or coexistence strategy.

### One meaning, one authority

Each important concept has one normative definition and one owning bounded context. Other contexts receive identifiers, events, or read models rather than editing another context's records. Organizational Memory is a governed capability spanning those records, not a second source of operational truth.

## Decision test

A design is rejected if it erases chronology, hides authority, merges reports, assigns accountability to AI, blocks urgent safety action, treats knowledge as universal, or makes institutional memory dependent on one vendor or person.

## Related documents

See [00_foundation.md](00_foundation.md), [02_domain_model.md](02_domain_model.md), [13_security_and_audit_model.md](13_security_and_audit_model.md), and [17_architecture_decision_records.md](17_architecture_decision_records.md).
