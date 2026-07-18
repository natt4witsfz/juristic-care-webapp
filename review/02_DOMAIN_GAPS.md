# Domain Gap Register

Version: 1.0  
Date: 2026-07-17  
Status: Controlled gaps requiring implementation or governance closure

## Purpose

These findings do not replace the normalized architecture. They identify where a production implementation needs policy, workflow, or operational detail that architecture alone cannot responsibly invent.

| ID | Severity | Gap | Required treatment before use | Current disposition |
| --- | --- | --- | --- | --- |
| GAP-01 | Critical | Immutable correction and cross-Juristic-Person transfer semantics | Submitted and corrected assertions, destination acceptance, evidence scoping, privacy test | Single-property implementation avoids cross-tenant transfer; correction history required |
| GAP-02 | Medium | Bulk Case–Incident association atomicity | Preview, per-item Decision, idempotency, explicit partial outcome and reconciliation | Implement only single associations initially |
| GAP-03 | High | Adverse outcome/wrong repair workflow | Containment, independent review, corrective Operation, liability/governance and learning feedback | Basic reopen supported; full adverse-outcome governance deferred |
| GAP-04 | High | Evidence loss and manifest reconciliation | Digest checks, availability events, recovery, affected-Decision tracing | Metadata/digest modeled; scheduled reconciliation deferred |
| GAP-05 | High | Technical disagreement and protected dissent | Stop-work right, neutral qualified review, timebox, non-retaliation | Dissent records supported; organizational policy required |
| GAP-06 | Medium | Repeated reopen/verification cycle escalation | Configurable cycle visibility and root-cause/asset-strategy review | Analytics can expose cycles; thresholds need policy |
| GAP-07 | High | Deterministic offline/device-loss reconciliation | Secure local queue, clock uncertainty, idempotency, Authority revalidation, conflict Decision | Online-first application; manual continuity documented |
| GAP-08 | High | Total service/power outage continuity | Paper/voice intake, contact tree, recovery order, reconciliation drill | Operational guide required before production |
| GAP-09 | High | Authority exhaustion and on-call succession | Standing emergency scope, expiry, failed-contact audit, retrospective review | Mandates modeled; real succession names cannot be invented |
| GAP-10 | Critical | External major-incident command handoff | External commander, liaison, command-transfer time, mass communication, recovery transition | Production life-safety module prohibited until governance approves |
| GAP-11 | Critical | Safety-critical isolation and return to service | Isolation state, custody, qualifications, certification, independent return Decision | Generic asset/operation support only; specialized workflow deferred |
| GAP-12 | High | Contractor abandonment and Commitment substitution | Access revocation, custody, residual Responsibility, replacement Commitment | Vendor/Commitment history modeled; complete workflow deferred |
| GAP-13 | High | Resident access refusal and blocked SLA treatment | Consent/access state, lawful alternatives, pause rules, risk escalation | Comments/timeline can record; policy and clock implementation deferred |
| GAP-14 | Medium | Resident dispute and appeal lifecycle | Acknowledgement, categorization, independent review, appeal finality | Reopen supports new evidence; formal appeal deferred |

## Constraints on implementation claims

The system may implement safe foundations for these concepts, but it must not claim certified life-safety command, legal retention compliance, offline conflict safety, or cross-tenant portability until the corresponding gap is closed through code, tests, policy, training, and operational rehearsal.

## Ownership

The Juristic Person owns acceptance or treatment of these risks. Developers, vendors, committees, managers, and AI may recommend treatment but cannot silently accept a Critical residual risk.
