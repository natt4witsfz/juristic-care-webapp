# Organization Model

Version: 2.0  
Status: Architecture Baseline

## Purpose

This model represents accountable participation without reducing governance to an owner field.

## Organizational parties

The Juristic Person is the enduring legal and data-owning organization. People and external organizations participate through time-bounded relationships: co-owner, resident, committee member, juristic manager, dispatcher, technician, supervisor, contractor, auditor, developer, or service provider. A person may hold several roles, but each action records the role exercised.

## Independent concepts

| Concept                 | Meaning                                                            | Typical record              |
| ----------------------- | ------------------------------------------------------------------ | --------------------------- |
| Responsibility          | Accountable outcome or duty                                        | Responsibility Ledger entry |
| Authority               | Permission to decide or direct                                     | Mandate and policy grant    |
| Commitment              | Accepted obligation to perform work                                | Commitment record           |
| Capability              | Demonstrated skill or qualification                                | Capability assertion        |
| Availability            | Ability to act during a period                                     | Availability declaration    |
| Organizational Priority | Authorized importance decision                                     | Priority decision           |
| Execution Sequence      | Technician's practical order                                       | Sequencing record           |
| SLA                     | Organization-level service expectation for a defined service class | Versioned service policy    |

## Authority model

Authority is explicit, scoped, effective-dated, and sourced from law, bylaws, committee resolution, contract, policy, delegation, or emergency doctrine. Delegation records grantor, grantee, scope, limits, start, end, revocation, and whether redelegation is allowed. Possessing responsibility does not imply authority; having authority does not imply capability or availability. An SLA describes an organizational service expectation; it does not assign a person, create authority, prove a commitment was accepted, or decide execution order.

## Responsibility chain

Every material action or decision links to the responsible person, acting role, relationship to the organization, applicable responsibility, authority source when needed, timestamps, context, supporting evidence, and handover history. Team responsibility may coexist with named individual actions but cannot conceal them.

The chain has four distinct links: a Responsibility Assignment defines the duty; a Mandate proves Authority; a Commitment records accepted work; and an Action or Decision records what the actor actually did. Capability and Availability assertions explain whether assignment was reasonable but do not transfer accountability. A chain gap is an operational exception routed to the responsible manager; software must not fill it by inferring an owner.

### Responsibility-chain example

A building manager may have Authority to prioritize a water leak, a dispatcher may be Responsible for arranging response, and a qualified technician may accept the Commitment and choose Execution Sequence. A supervisor may later verify the repair. Each link has its own actor, role, time, evidence, and handover; none is collapsed into one global owner.

## Handover

A handover includes open commitments, known risks, current understanding, unresolved decisions, evidence access, and acknowledgement by both sides where possible. If acknowledgement is impossible, an authorized manager records the unilateral transition and reason. The successor owns future stewardship, not the predecessor's past choices.

## Exceptions

Emergency action may rely on standing authority or necessity. The actor records scope and rationale afterward. Conflicts of interest require disclosure and reassignment or explicit independent review. Accounts are never reused when personnel change.

## Evolution

New roles and authority types are introduced through governed policy versions, not hard-coded assumptions. Historical role names and grants remain resolvable. Permissions are implemented from this model as described in [22_permission_matrix.md](22_permission_matrix.md); decision records follow [09_decision_model.md](09_decision_model.md).
