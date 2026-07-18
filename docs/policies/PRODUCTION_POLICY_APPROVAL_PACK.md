# O83 Care Production Policy Approval Pack

## Purpose

This pack contains the business and governance decisions that cannot be made by software. The implemented system enforces approved values after they are configured; it does not infer consent, legal basis, committee authority, service levels, emergency powers, or retention periods.

The policy owner must approve each section for the named juristic person before Production GO. Approval means that the values have been reviewed against applicable law, contracts, building operations, insurance, resident communications, and committee resolutions. Technical deployment or a passing test is not policy approval.

## Approval record

| Field               | Required approval evidence                                                          |
| ------------------- | ----------------------------------------------------------------------------------- |
| Juristic person     | Registered legal name and internal identifier                                       |
| Policy owner        | Named accountable human and effective organization relationship                     |
| Approving authority | Committee resolution, delegated Mandate, or other lawful instrument                 |
| Effective date      | Date and time at which configured policy becomes applicable                         |
| Review date         | Next required human review date                                                     |
| Superseded policy   | Prior policy identifier, if any; the prior version remains immutable                |
| Decision evidence   | Resolution, legal review, contract, risk assessment, and consulted Evidence Package |
| Approval status     | Pending human approval until an authorized human signs and records the Decision     |

## 1. Privacy, consent, and disclosure

The approving authority must define:

- lawful purposes for resident, staff, contractor, visitor, operational, Evidence, and audit data;
- which notices and consent mechanisms apply to each collection channel;
- rules for special-category, health, child, biometric, CCTV, voice, and emergency information;
- authorized internal audiences and minimum disclosure for residents, vendors, committee members, insurers, emergency services, and authorities;
- redaction standards for resident-facing Evidence and reports;
- data-subject request intake, identity verification, exception, appeal, and response times;
- cross-border processing and subprocessor conditions; and
- breach classification, notification authority, timing, and communication templates.

The system must be configured with the approved classification, disclosure scope, and recipient policy versions. Private Evidence access remains relationship-based and does not become public because a report or notification exists.

## 2. Retention, archive, legal hold, and disposal

The approving authority must assign a period, trigger, legal basis, custodian, archive tier, review cycle, and lawful disposal method for each category:

| Category                                                         | Decision required                                                                |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Reports, Cases, Investigations, Incidents, Operations, and Tasks | Operational and statutory retention after closure                                |
| Evidence originals and renditions                                | Retention by classification, dispute, safety significance, and legal hold        |
| Decisions, Mandates, Responsibility ledger, audit, and timeline  | Long-term or permanent Organizational Memory treatment                           |
| Notifications and delivery attempts                              | Communication proof and privacy-minimizing retention                             |
| Knowledge and AI interactions                                    | Validity review, deprecation, source retention, and model-replacement continuity |
| Backup and Memory archives                                       | Backup window, archive window, geographic location, encryption, and destruction  |

Deletion must never rewrite history. Lawful disposition is a governed Decision and immutable disposition record. Storage objects must not be removed before metadata, hold, Decision, custody, and restore implications are reconciled.

## 3. Emergency authority and after-action recording

Human safety precedes workflow. The approving authority must define:

- which roles may order or perform emergency work for fire, trapped residents, flooding, electrical danger, structural risk, and comparable hazards;
- monetary and operational limits, escalation contacts, vendor call-out authority, and emergency-service coordination;
- when work may begin before records or Evidence can be entered;
- required minimum contemporaneous notes when connectivity or equipment is unavailable;
- the maximum time for retrospective Case, Incident, Operation, Evidence, Commitment, and Decision entry;
- independent review requirements; and
- exception investigation when the retrospective deadline is missed.

Emergency work never grants permanent Authority and never permits silent evidence fabrication. The system records occurred time separately from recorded time and requires an explicit evidence exception where completion Evidence was unsafe or impossible.

## 4. Responsibility, delegation, and segregation of duties

The approving authority must define who may:

- create and transfer Responsibility Assignments;
- issue, accept, revoke, and supersede Mandates;
- assign or end roles and suspend accounts;
- offer work and who may accept Commitments;
- verify significant and critical work independently;
- close or reopen an Incident; and
- publish reports, Knowledge, and Organizational Memory exports.

Responsibility, Authority, Commitment, Capability, Availability, Priority, and execution sequence remain separate. A transfer must identify a successor, effective instant, handover summary, open risks, and acceptance evidence. Significant and critical work must not be self-verified.

## 5. Service levels, priority, and communication

The approving authority must approve versioned SLA definitions for acknowledgement, investigation, response, restoration, completion, verification, and resident update. Each definition must state population, exclusions, clock start, authorized pause reasons, blocking party, calendar, escalation, breach handling, and reporting formula.

Notification approval must identify:

- event-to-audience rules and disclosure limits;
- severity and acknowledgement rules;
- in-app, email, SMS, voice, and emergency channels;
- quiet hours and safety overrides;
- provider, sender identity, locale, template owner, retry, suppression, correction, and opt-out rules; and
- the human owner of failed delivery queues.

Technical in-app routing is active only when explicit Responsibility resolves a recipient. External providers and message wording require the approved configuration and credentials.

## 6. Evidence standards and malware handling

The approving authority must approve:

- allowed evidence types and maximum sizes;
- capture, consent, provenance, timestamp, device, location, and witness expectations;
- before/after and independent verification requirements by risk;
- acceptable exceptions when safety or connectivity prevents normal capture;
- quarantine review authority, malware escalation, false-positive release, and disposal;
- hash algorithm and migration policy; and
- who may see originals, renditions, redactions, packages, exports, and custody records.

The implemented intake computes SHA-256 over actual bytes, checks declared size and file signature, detects the standard antivirus test signature, blocks browser access after quarantine, and promotes originals only through a trusted processor. Approval must decide whether an additional contracted malware-scanning provider is required for the organization's risk and file types.

## 7. Backup, restore, continuity, and recovery objectives

The approving authority must approve separate objectives for PostgreSQL records and Storage object bytes because database backups do not contain Storage objects:

| Control            | Decision required                                                                                  |
| ------------------ | -------------------------------------------------------------------------------------------------- |
| RPO                | Maximum acceptable record and object loss by criticality                                           |
| RTO                | Maximum restoration time for emergency, operational, and reporting service                         |
| Backup frequency   | Hosted database, point-in-time recovery, Storage object copy, and Memory export cadence            |
| Restore authority  | Who can authorize an isolated test, staging restore, or Production restoration                     |
| Recovery custody   | Named people and vendors controlling backups, encryption keys, and archives                        |
| Test cadence       | Database restore, Storage byte recovery, application verification, and incident exercise frequency |
| Offline continuity | Supported devices, local queue duration, loss reporting, synchronization, and conflict ownership   |

Production restoration requires a human incident commander and approved change record. The automated local validation scripts never connect to or destroy hosted Production data.

## 8. AI Organizational Mirror

The approving authority must approve each AI use case, input classification, allowed sources, model/provider, retention, review qualification, freshness threshold, and suspension rule. AI output is advice and must show its sources, assumptions, limitations, conflicts, and generation time. AI cannot:

- verify an Incident;
- accept Authority, Responsibility, or Commitment;
- approve expenditure or priority;
- complete or verify work;
- close or reopen an Incident;
- publish Knowledge or policy; or
- impersonate a human review.

Outdated, unsupported, or conflicting recommendations must be visibly challenged or withdrawn while the prior record remains available.

## 9. Security operations and vendor access

The approving authority must define MFA requirements, session duration, inactivity timeout, privileged-access review, service-principal ownership, secret rotation, vulnerability response, logging review, support access, incident response, vendor onboarding/offboarding, contract expiration, and emergency revocation. Cross-tenant access is prohibited. Service-role credentials remain server-side and must be rotated after suspected exposure.

## Production approval Decision

Production GO may be recorded only after every section above has an approved version, accountable owner, effective Mandate, configured values, and linked Decision evidence. Any rejected or deferred section keeps operational Production at NO GO even when technical validations pass.
