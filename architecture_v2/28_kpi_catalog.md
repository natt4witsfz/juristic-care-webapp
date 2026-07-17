# KPI Catalog

Version: 2.0  
Status: Architecture Baseline

## Purpose

KPIs support inquiry and improvement through stable definitions. They do not establish blame or Operational Truth by themselves.

## Core KPIs

| KPI | Definition | Key cautions |
|---|---|---|
| Case acknowledgement time | Acknowledged time minus received time | Separate channel failures and offline intake |
| Safety triage coverage | Cases with recorded safety assessment / eligible Cases | Missing record is not proof no assessment occurred |
| Investigation lead time | Assessment-ready time minus Case receipt | Segment by risk and information dependency |
| Case-to-Incident association rate | Cases associated by human decision / investigated Cases | Never use to drive automatic merging |
| Incident recurrence rate | Human-classified recurrence within defined context/window / closed Incidents | Context and window version required |
| Emergency reconstruction delay | Recorded time minus action time for emergency actions | Interpret with safety and connectivity context |
| Commitment reliability | Commitments fulfilled within agreed boundary / due commitments | Reflect authorized renegotiation and interruption |
| Verification first-pass rate | Operations accepted on first verification / verified Operations | Not an individual performance score |
| Evidence sufficiency rate | Packages meeting tier standard / reviewed packages | Standard version and exceptions required |
| Reopen rate | Reopened Incidents / closed Incidents | Reopen is learning, not automatically failure |
| Knowledge reuse outcome | Reused Knowledge Records with evaluated outcome / reused records | Context-match quality required |
| Responsibility coverage | Material actions with valid responsibility context / sampled actions | Does not measure moral quality |

## Common rules

Each KPI has owner, purpose, formula version, numerator/denominator, exclusions, dimensions, source lineage, event-time window, freshness, target rationale, and review date. Reports distinguish Cases, Incidents, Operations, and people. Restatements are versioned.

## Guardrails

No KPI alone triggers punishment, closure, priority, or authority decisions. Small populations are suppressed. Targets never incentivize unsafe speed, evidence fabrication, Case merging, premature closure, or avoidance of reopen. Qualitative review accompanies consequential interpretation.
