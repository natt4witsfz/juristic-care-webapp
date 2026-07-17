# O83 Care Architecture Risk Register

Version: 1.0  
Status: Validation Baseline

## Scale

Likelihood and impact are rated Low, Medium, High, or Critical. Residual risk is an architecture estimate after the proposed control, not a governance acceptance decision.

| ID | Risk | Likelihood | Impact | Existing controls | Required treatment | Residual |
|---|---|---|---|---|---|---|
| R-01 | Cross-tenant wrong-building transfer exposes resident/evidence data | Medium | Critical | Tenant isolation, audit, Authority model | Implement GAP-01; security test transfer and rollback | Low |
| R-02 | Automatic or accidental Case deduplication destroys individual traceability | Medium | High | Foundation invariant, separate Case identity, AI prohibition | Conformance test intake, imports, and batch tools | Low |
| R-03 | Premature Incident identity is created from suspicion | Medium | High | Verified-only Incident model and corrected states/events | Aggregate invariant and migration validation | Low |
| R-04 | Wrong repair causes harm and is concealed by completion edits | Medium | Critical | Immutable Operation/evidence/decision history | Implement GAP-03; independent adverse-outcome review | Medium |
| R-05 | Silent evidence loss invalidates historical decisions | Low | Critical | Immutable storage, backups, digests | Implement GAP-04; manifest scans and impact tracing | Low |
| R-06 | Technical dissent is suppressed by managerial Authority | Medium | Critical | Responsibility/Authority separation, dissent records | Implement GAP-05; stop-work and non-retaliation | Medium |
| R-07 | Reopen and verification loops consume resources without systemic correction | Medium | High | Immutable cycles, human decisions | Implement GAP-06; escalation thresholds and root review | Medium |
| R-08 | Offline synchronization duplicates or loses emergency records | High | High | Durable IDs, idempotency, upload chronology | Implement GAP-07; deterministic conflict protocol | Medium |
| R-09 | Power/service outage removes every digital coordination channel | Medium | Critical | Degraded mode principle | Implement GAP-08; manual continuity drills | Medium |
| R-10 | No authorized person is reachable during urgent work | Medium | Critical | Emergency necessity and standing Authority | Implement GAP-09; succession and failed-contact audit | Low |
| R-11 | Local staff conflict with statutory fire/rescue command | Low | Critical | Safety-first principle | Implement GAP-10; major-incident command handoff | Low |
| R-12 | Lift or other critical asset returns to service without qualified verification | Medium | Critical | Risk-tier evidence and verification separation | Implement GAP-11; isolation and return-to-service state | Low |
| R-13 | Contractor abandonment leaves credentials and work uncontrolled | Medium | High | Access revocation, Commitment history | Implement GAP-12; custody and replacement workflow | Low |
| R-14 | Resident access refusal creates unsafe or indefinite deadlock | Medium | High | General escalation and safety Authority | Implement GAP-13; access and SLA-block rules | Medium |
| R-15 | Resident dispute is dismissed or loops indefinitely | Medium | Medium | Challenge and append-only correction | Implement GAP-14; independent dispute workflow | Low |
| R-16 | AI error is adopted through automation bias | Medium | Critical | AI advisory-only, citations, manual path | Use-case gates, impact scans, disable control, human training | Medium |
| R-17 | Organizational Memory becomes a duplicate mutable data store | Low | High | Context-owned writes, projection-only Memory rule | Architecture fitness test and export lineage checks | Low |
| R-18 | Leadership/vendor transition leaves Authority, access, or context gaps | Medium | High | Effective mandates, handover, ADRs, portability | Transition assurance, interim mandates, exit drills | Low |

## Risk ownership

Business and governance owners must be named before production. The Juristic Person retains risk ownership even when treatment is assigned to a management company, contractor, developer, cloud provider, or AI supplier. Acceptance of Critical residual risk requires the highest applicable lawful Authority and cannot waive life-safety obligations.

## Review triggers

Review the register after a serious Incident, evidence loss, AI material error, repeated reopen, committee/manager/developer transition, new building or Juristic Person, safety-critical integration, major supplier change, or material architecture decision.

## Summary

- Risks registered: 18
- Critical-impact risks: 9
- High-impact risks: 8
- Medium-impact risks: 1
- Critical architecture issues requiring clarification: 3
