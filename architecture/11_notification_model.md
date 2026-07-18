# Notification Model

Version: 2.0  
Status: Architecture Baseline

## Purpose

Notifications make relevant changes visible without becoming the authoritative record or substituting for responsibility.

## Model

A Notification Intent references a domain event, audience rule, purpose, urgency, disclosure policy, available channels, expiry, and required acknowledgement. Delivery Attempts record channel, destination reference, provider response, sent time, delivery time when known, and failure. Message content is a rendered projection; the source event remains authoritative.

The originating bounded context is Responsible for deciding that communication is required. The Notification context is Responsible for rendering and delivery attempts. Authority to define mandatory audiences, emergency override, disclosure, and templates comes from versioned policy; a provider has no Authority to change meaning or recipients.

## Business rules

- Case reporters receive acknowledgement and appropriate progress, outcome, and closure communications.
- Safety alerts override quiet hours when policy authorizes them.
- Sensitive evidence and private details are never embedded when a secure link or summary suffices.
- Organizational Priority does not automatically equal notification urgency.
- A delivered message does not prove it was read; acknowledgement is explicit when required.
- Preference settings cannot suppress legally or safety-required notices.

## Escalation

Escalation is a governed workflow triggered by elapsed time, risk, failed delivery, or missing acknowledgement. It identifies the responsible role and alternate channel; it does not silently reassign responsibility. Failed providers enter retry and exception queues using idempotency keys.

## Edge cases

Shared contact points require consent and careful disclosure. Invalid contact data creates a visible follow-up. Offline recipients may receive later delivery without altering event chronology. Corrections are new messages linked to the original. Multilingual rendering retains the source-language canonical meaning and translation version.

If a source event is later superseded, the system evaluates whether a correction is materially necessary; it never retracts the historical Delivery Attempt. If a notification arrives out of order, rendering includes the current as-of context or withholds the stale message under policy and records that decision.

## Evolution

Channels and templates are versioned. New providers must satisfy privacy, audit, delivery, and exit requirements. Notification effectiveness is measured without treating opens as proof of understanding. Related workflows are defined in [10_workflow_model.md](10_workflow_model.md); access constraints follow [13_security_and_audit_model.md](13_security_and_audit_model.md).
