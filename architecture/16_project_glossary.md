# Project Glossary

Version: 2.0  
Status: Normative Architecture Baseline

## Purpose

These definitions are canonical across O83 Care. Documents may add context but must not redefine these terms.

| Term                     | Definition                                                                                                                                                              |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Report                   | A submitted communication describing an observation, concern, request, or impact.                                                                                       |
| Case                     | The separately traceable service and investigation record created for exactly one incoming Report.                                                                      |
| Investigation            | The structured activity of gathering observations, hypotheses, and evidence to determine operational relationships and understanding.                                   |
| Understanding Assessment | A versioned statement of what the organization currently knows, infers, disputes, and does not know for an Investigation; it may be superseded but never overwritten.   |
| Incident                 | One human-verified operational event, potentially associated with multiple Cases.                                                                                       |
| Operation                | A bounded unit of work performed to inspect, stabilize, resolve, verify, communicate about, or prevent an Incident.                                                     |
| Operational Truth        | The organization's best current understanding based on verifiable evidence; time-bound and revisable, never absolute.                                                   |
| Observation              | What a person or instrument perceived or measured, with source and context.                                                                                             |
| Hypothesis               | A proposed explanation that may be supported, challenged, or unresolved.                                                                                                |
| Evidence                 | Provenanced material used to support or challenge a claim.                                                                                                              |
| Decision                 | An accountable human choice among alternatives under a source of authority.                                                                                             |
| Revised Understanding    | A later assessment linked to, but not overwriting, earlier understanding.                                                                                               |
| Responsibility           | Accountability for a defined duty or outcome.                                                                                                                           |
| Authority                | Permission to decide, assign, interrupt, override, approve, or disclose within scope.                                                                                   |
| Commitment               | Work a person or party has explicitly accepted.                                                                                                                         |
| Capability               | Relevant skill, qualification, knowledge, or operational ability.                                                                                                       |
| Availability             | Whether a person or resource can act during a period.                                                                                                                   |
| Organizational Priority  | Importance decided by an authorized organizational role.                                                                                                                |
| Execution Sequence       | Practical order chosen for performing accepted work within constraints.                                                                                                 |
| SLA                      | A versioned organization-level service expectation for a defined service class; it is not personal responsibility, authority, commitment, priority, or execution order. |
| Due Commitment           | Required completion boundary or service obligation.                                                                                                                     |
| Responsibility Ledger    | Effective-dated history of responsibilities, actors, context, and handovers.                                                                                            |
| Responsibility Chain     | The time-ordered relationship among Responsibility assignments, Authority mandates, Commitments, Actions, Decisions, Verifications, and Handovers for a defined scope.  |
| Organizational Memory    | Durable Cases, Incidents, Operations, evidence, decisions, responsibilities, outcomes, knowledge, exceptions, and context owned by the Juristic Person.                 |
| Juristic Person          | The enduring legal organization that owns and governs O83 Care records.                                                                                                 |
| Validity Context         | Conditions under which knowledge may reasonably apply.                                                                                                                  |
| Reopen                   | A new lifecycle transition based on recurrence, new evidence, incomplete resolution, or revised understanding; not erasure of a prior close.                            |
| Supersede                | Replace as current guidance or understanding while preserving the previous record.                                                                                      |
| Decision Evolution       | The linked history from observations and hypotheses through evidence, assessments, decisions, new evidence, and revised or affirming decisions.                         |
| Actor                    | A human or technical identity that performs a recorded action; only humans may be accountable decision makers.                                                          |
| Acting Role              | The organizational capacity exercised for a specific action.                                                                                                            |

## Usage rules

Do not use ticket as a synonym for Incident. Do not call an unverified suspected event an Incident; it remains part of an Investigation. Do not use owner to collapse Responsibility and Authority. Qualify priority as Organizational Priority, notification urgency, safety severity, or Execution Sequence. Use occurrence time, action time, recorded time, and upload time precisely. Use `current` only for a reproducible projection and never as permission to overwrite history.
