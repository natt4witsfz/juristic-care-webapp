# O83 Care Domain Validation

Version: 1.0  
Status: Complete  
Architecture baseline: Version 2

## Method

Each scenario was traced through Case, Investigation, Incident, Operation, Knowledge, Evidence, Workflow, Responsibility, Authority, Commitment, Capability, Availability, Organizational Priority, SLA, AI Advisor, Notification, Reporting, Governance, and Organizational Memory. Gap identifiers refer to [ARCHITECTURE_GAPS.md](ARCHITECTURE_GAPS.md).

## 1. Resident reports a water leak

- **Expected workflow:** Intake creates one Case atomically, acknowledges it, performs safety triage, opens an Investigation, records observations, and seeks evidence. An Incident exists only after human verification.
- **Responsible role:** Intake staff or automated intake preserves the Report; an investigator owns investigation duty; management owns prioritization.
- **Authority:** The resident may report and state impact; an authorized investigator verifies an Incident; an authorized manager sets Organizational Priority.
- **Evidence:** Resident narrative, time, location, optional media, later inspection, and asset readings retain provenance and uncertainty.
- **Timeline:** Report/event time, Case-created time, acknowledgement, inspection/action, recording, and upload times remain distinct.
- **Notifications:** Immediate acknowledgement, safety guidance, information requests, appropriate progress, outcome, and closure communication.
- **Decision points:** Safety escalation, Incident verification, priority, access, Operation authorization, verification, closure.
- **AI involvement:** May summarize, suggest similar history, or propose questions; cannot classify, prioritize, or verify.
- **Possible failures:** Duplicate submission, wrong location, delayed acknowledgement, inaccessible unit, or premature Incident creation.
- **Missing architecture:** Location correction and asset-resolution semantics are incomplete (GAP-01).
- **Recommendation:** Add governed Report-context correction and location/asset resolution rules without changing original submitted values.

## 2. Five residents report the same leak

- **Expected workflow:** Five Reports create five Cases. Similarity may be shown. Investigation compares evidence; an authorized human may verify one Incident and create five reasoned Case-Incident Associations.
- **Responsible role:** Intake is responsible for every Case; investigator for relationship assessment; manager for operational response.
- **Authority:** No user or AI may merge Cases. Authorized investigators decide associations under mandate.
- **Evidence:** Each account remains separate; shared location, asset, symptom, time, and inspection evidence support association.
- **Timeline:** Five intake timelines remain visible alongside one Incident and its Operations.
- **Notifications:** Each Case has its own acknowledgement and privacy-appropriate updates; messages need not reveal other residents.
- **Decision points:** Whether reports concern one event, several events, or remain uncertain; whether existing Incident is selected or a new one created.
- **AI involvement:** May rank similarity with citations and uncertainty; cannot associate automatically.
- **Possible failures:** Accidental deduplication, privacy leakage, repeated technician dispatch, or one Case being forgotten after association.
- **Missing architecture:** No blocking gap; fan-out communication reconciliation needs detailed design.
- **Recommendation:** Require a Case coverage projection showing every associated Case has an appropriate communication and disposition path.

## 3. Technician reports a different cause

- **Expected workflow:** The technician records a new observation and hypothesis in Investigation. An Understanding Assessment compares it with earlier hypotheses; any changed action requires a new or superseding human Decision Record.
- **Responsible role:** Technician is responsible for accurate observation; investigator is responsible for assessment; authorized decision maker chooses action.
- **Authority:** Technical expertise supports a hypothesis but does not itself grant Incident, priority, budget, or closure Authority.
- **Evidence:** Inspection notes, measurements, photographs, asset context, and limitations support or challenge causes.
- **Timeline:** Earlier hypothesis and decision remain visible; new evidence, assessment, and decision use actual times.
- **Notifications:** Notify responsible investigator/manager when the changed cause affects safety, work scope, cost, SLA, or resident expectation.
- **Decision points:** Accept, reject, or keep competing hypotheses; pause current work; authorize a changed Operation.
- **AI involvement:** May compare hypotheses and sources; must display disagreement and cannot select the official cause.
- **Possible failures:** Manager pressure, technician overconfidence, evidence ambiguity, or silent edit of earlier diagnosis.
- **Missing architecture:** Structured technical disagreement escalation is under-specified (GAP-05).
- **Recommendation:** Add a disagreement workflow with response time, independent review triggers, and preserved dissent.

## 4. Investigation links all Cases

- **Expected workflow:** A versioned Understanding Assessment supports Incident verification and five separate Case-Incident Association decisions or one authorized batch decision producing five auditable association records.
- **Responsible role:** Authorized investigator is responsible for reasoning; Incident Management preserves association history.
- **Authority:** Mandate must cover verification and association; batch action must not weaken per-Case traceability.
- **Evidence:** Shared and conflicting observations, asset/location match, time proximity, and inspection results are cited.
- **Timeline:** Association effective and recorded times remain distinct; later disassociation is a new record.
- **Notifications:** Managers and affected Case communication workflows receive the relationship event without disclosing private identities.
- **Decision points:** Incident identity, association relevance/type, unresolved outliers, and whether more investigation is required.
- **AI involvement:** May prepare comparison and draft rationale; human signs the decision.
- **Possible failures:** Partial batch failure, association to wrong Incident, or hidden contradictory Case.
- **Missing architecture:** Atomicity rules for authorized bulk association are absent (GAP-02).
- **Recommendation:** Define all-or-explicit-partial batch semantics and per-association decision/evidence references.

## 5. Repair is completed

- **Expected workflow:** Operation moves to AwaitingVerification; qualified verification checks risk-tier criteria; Operation becomes Completed; an authorized human separately decides Incident closure and Case outcomes.
- **Responsible role:** Technician performs work; verifier assesses acceptance; manager owns Incident closure and communication within mandate.
- **Authority:** Completion recommendation, verification, Incident closure, and Case closure are separate powers.
- **Evidence:** Before/after condition, materials, measurements, method, exceptions, and verification package.
- **Timeline:** Work end, evidence capture/upload, verification, Incident close, and Case close remain separate.
- **Notifications:** Technician receives verification outcome; affected residents receive appropriate result and limitations.
- **Decision points:** Evidence sufficiency, verification result, monitoring need, closure, and knowledge candidate creation.
- **AI involvement:** May check package completeness or draft summary; never verifies or closes.
- **Possible failures:** Self-verification, premature closure, delayed evidence, or resident Case left unresolved.
- **Missing architecture:** No blocking gap; acceptance criteria must be configured by work type.
- **Recommendation:** Enforce closure coverage checks for open Operations, unresolved Cases, evidence exceptions, and monitoring commitments.

## 6. Leak returns after two days

- **Expected workflow:** New Report creates a new Case. Investigation compares location, component, symptom, cause, repair relationship, elapsed time, and evidence; human decides reopen, new Incident, or uncertainty.
- **Responsible role:** Investigator evaluates recurrence; manager decides affected work and priority.
- **Authority:** No automatic reopen. Authorized human records recurrence classification and reason.
- **Evidence:** Previous repair record, defective-part evidence, current inspection, and temporal proximity.
- **Timeline:** Prior closure remains; new Case and any Reopen event occur later and are linked.
- **Notifications:** New Case acknowledgement; prior responsible roles may be notified for review without automatic blame.
- **Decision points:** Same event/repair failure versus new event; warranty/contract action; emergency response.
- **AI involvement:** May highlight strong contextual match and prior repair; cannot decide recurrence.
- **Possible failures:** Infinite reopen cycling, vendor blame without evidence, or reopening solely from elapsed time.
- **Missing architecture:** Reopen-cycle governance is incomplete (GAP-06).
- **Recommendation:** Add cycle-count visibility, mandatory root-review thresholds, and escalation without limiting legitimate reopen.

## 7. Leak returns after six months

- **Expected workflow:** A new Case and Investigation compare full context. The longer interval weakens but does not eliminate relationship; human chooses prior-Incident reopen, new Incident, or unresolved status.
- **Responsible role:** Investigator and authorized Incident decision maker.
- **Authority:** Same as recurrence; time-window heuristics have no decision Authority.
- **Evidence:** Asset/component identity, maintenance changes, environment, intervening work, symptom, and cause.
- **Timeline:** Six-month gap and intervening events are explicit.
- **Notifications:** Normal intake plus targeted notification if a warranty, systemic risk, or recurring pattern is established.
- **Decision points:** Context equivalence, causal relationship, knowledge validity, and priority.
- **AI involvement:** May compare historical context and expose mismatches; confidence must fall when context is uncertain.
- **Possible failures:** Treating all nearby leaks as the same Incident or ignoring useful history.
- **Missing architecture:** No blocking gap; recurrence policy needs locally approved criteria.
- **Recommendation:** Configure recurrence review prompts, not automatic windows, and report human classification uncertainty.

## 8. Wrong repair was performed

- **Expected workflow:** Record actual work and outcome, open safety assessment, fail verification or reopen Incident, preserve the original Decision/Operation, and authorize corrective Operations.
- **Responsible role:** Performer records facts; verifier/investigator assesses; manager contains harm and coordinates correction; governance reviews systemic causes.
- **Authority:** Emergency containment may precede approval; remediation, liability, and personnel actions require separate authorized decisions.
- **Evidence:** Work records, materials, before/after condition, instructions, competence/mandate at the time, and consequences.
- **Timeline:** Never rewrite the Operation as if correct work occurred; later discovery and corrective actions append.
- **Notifications:** Safety-affected residents, management, contractor, insurer, or regulator according to policy.
- **Decision points:** Hazard containment, causal assessment, corrective scope, verification, warranty/liability, and learning.
- **AI involvement:** May find divergence from approved scope; cannot blame, punish, or determine negligence.
- **Possible failures:** Concealment, retrospective approval, evidence deletion, or corrective work erasing the first failure.
- **Missing architecture:** Adverse-outcome and remediation workflow is not explicit (GAP-03).
- **Recommendation:** Add a non-punitive adverse-outcome workflow linked to safety, correction, governance, and learning.

## 9. Wrong resident reported

- **Expected workflow:** Preserve the original reporter attribution, append a correction identifying the correct affected resident if authorized, update communication relationships, and reassess consent/privacy.
- **Responsible role:** Intake/data steward validates correction; privacy-authorized role controls disclosure.
- **Authority:** A resident may request correction; authorized staff decides identity relationship changes under policy.
- **Evidence:** Reporter statement, occupancy/ownership records where lawful, contact confirmation, and correction reason.
- **Timeline:** Original submission and later correction both remain; current projections show corrected contact context.
- **Notifications:** Notify affected parties only when lawful and necessary; avoid revealing one resident's details to another.
- **Decision points:** Reporter versus affected person, consent, proxy authority, and Case access.
- **AI involvement:** May flag inconsistent identity but must not infer household relationships or protected data.
- **Possible failures:** Unauthorized data exposure, account reassignment, or deletion of the original reporter.
- **Missing architecture:** Party-role correction and contested identity workflow are absent (GAP-01).
- **Recommendation:** Model Reporter, Affected Party, Contact, and Authorized Representative as effective-dated Case relationships.

## 10. Wrong building selected

- **Expected workflow:** Preserve the submitted building, append a corrected location/asset assertion after validation, reroute responsibility and access, and reconsider Incident associations and tenant boundary.
- **Responsible role:** Intake/data steward corrects context; receiving manager accepts operational responsibility.
- **Authority:** Cross-building or cross-Juristic-Person transfer requires explicit data and operational Authority.
- **Evidence:** Address/unit confirmation, asset registry, reporter clarification, and inspection.
- **Timeline:** Submitted, discovered, corrected, transferred, and notified times remain visible.
- **Notifications:** Correct management team and resident receive correction; wrong building staff receive only necessary closure notice.
- **Decision points:** Typographical correction, operational transfer, duplicate Case at destination, privacy/legal basis, and SLA start treatment.
- **AI involvement:** May suggest a likely mismatch; cannot transfer or change tenancy.
- **Possible failures:** Cross-tenant leakage, duplicate work, wrong SLA reporting, or orphaned Case.
- **Missing architecture:** Cross-location and cross-tenant transfer semantics are critical gaps (GAP-01).
- **Recommendation:** Add governed transfer with immutable origin, destination acceptance, scoped evidence copy/reference, and reconciliation.

## 11. Evidence uploaded after work

- **Expected workflow:** Accept evidence with original capture time and later upload time, integrity-check it, link it to the Operation/claim, and trigger re-review if it could change verification or closure.
- **Responsible role:** Uploader preserves provenance; evidence steward checks integrity; verifier/decision owner reassesses relevance.
- **Authority:** Upload does not grant verification Authority or retroactively prove earlier availability.
- **Evidence:** Original file, digest, device metadata, capture method, upload event, and explanation for delay.
- **Timeline:** Capture, action, record, upload, review, and any revised decision remain distinct.
- **Notifications:** Notify verifier/manager when late evidence materially affects an open or closed decision.
- **Decision points:** Authenticity, relevance, evidence-package revision, and superseding verification/closure.
- **AI involvement:** May extract metadata or compare content; cannot authenticate or verify conclusively.
- **Possible failures:** Backdating, duplicate upload, altered files, or no review trigger.
- **Missing architecture:** No blocking gap; materiality trigger needs detailed policy.
- **Recommendation:** Require late-evidence impact assessment against every linked current Decision.

## 12. Evidence lost

- **Expected workflow:** Record an integrity/availability incident, preserve metadata and chain of custody, attempt authorized recovery, assess affected decisions, and notify security/governance roles.
- **Responsible role:** Evidence custodian and security operations respond; decision owners assess operational consequence.
- **Authority:** Recovery, disclosure, and lawful disposition differ; no administrator may fabricate replacement evidence.
- **Evidence:** Audit logs, digests, manifests, backup state, access history, and witness records.
- **Timeline:** Last-known-good, loss discovery, containment, recovery, and assessment times are retained.
- **Notifications:** Security escalation, affected decision owners, privacy/legal contacts, and external parties if required.
- **Decision points:** Loss versus access failure, breach status, recovery sufficiency, decision re-review, and reporting duty.
- **AI involvement:** May correlate logs; cannot declare authenticity, breach closure, or reconstruct missing facts as evidence.
- **Possible failures:** Silent corruption, backup also damaged, evidence referenced by closed Incident, or audit gap.
- **Missing architecture:** Evidence-loss workflow and manifest reconciliation need explicit definition (GAP-04).
- **Recommendation:** Add periodic evidence-manifest verification, loss events, impact tracing, and recovery assurance.

## 13. Technician phone damaged

- **Expected workflow:** Technician prioritizes safety, uses alternate/offline/manual capture, reports device loss/damage, revokes credentials, and reconstructs records with uncertainty after stabilization.
- **Responsible role:** Technician secures/report device; security revokes access; manager ensures operational continuity.
- **Authority:** Standing emergency and security policy permit action and credential revocation.
- **Evidence:** Device incident record, last sync, local identifiers if recoverable, witness notes, and reconstructed chronology.
- **Timeline:** Actions remain at actual times; later record/upload times disclose reconstruction.
- **Notifications:** Security, manager, affected work handover, and privacy response if data exposure is possible.
- **Decision points:** Continue work, switch device/process, remote wipe, breach assessment, and duplicate reconciliation.
- **AI involvement:** None required; unavailable by design.
- **Possible failures:** Lost unsynced evidence, credential misuse, duplicate Operation updates, or invented precision.
- **Missing architecture:** Offline conflict and device-loss recovery protocol is incomplete (GAP-07).
- **Recommendation:** Define secure local queue, recovery keys, device revocation, conflict categories, and paper-assisted continuity.

## 14. Internet unavailable

- **Expected workflow:** Offline capture creates durable local identifiers, exposes stale context, permits safety work, queues commands/evidence, and synchronizes idempotently when connectivity returns.
- **Responsible role:** Technician records; platform operations restore service; manager handles conflicts and communication alternatives.
- **Authority:** Offline mode does not expand business Authority; emergency doctrine still applies.
- **Evidence:** Local timestamps, device identity, sync receipts, conflict records, and retained originals.
- **Timeline:** Occurrence/action time is local and uncertainty-aware; server record/upload time is later.
- **Notifications:** Local acknowledgement, alternate channel for critical escalation, then delivery reconciliation.
- **Decision points:** Whether cached information is safe to use, conflict resolution, duplicate command intent, and stale Authority.
- **AI involvement:** Optional and normally unavailable; no workflow dependency.
- **Possible failures:** Clock drift, expired mandate, duplicate records, conflicting edits, or lost queue.
- **Missing architecture:** Deterministic offline conflict policy is missing (GAP-07).
- **Recommendation:** Define conflict classes, clock uncertainty, server reconciliation Authority, and user-visible outcomes.

## 15. Power outage

- **Expected workflow:** Treat outage as safety/essential-service Report(s), create Cases, activate continuity channels, investigate, verify Incident, coordinate Operations, and preserve delayed records.
- **Responsible role:** Duty staff, manager, qualified technicians, and external utility/building-system providers.
- **Authority:** Emergency/continuity mandates govern stabilization and escalation; providers retain authority over their systems.
- **Evidence:** Building-system logs, utility notices, observations, generator status, access-control state, and later uploads.
- **Timeline:** Outage start may be approximate; action, restoration, record, and verification times differ.
- **Notifications:** Safety instructions and restoration updates use emergency channels and fallbacks.
- **Decision points:** Internal versus external cause, evacuation/support, essential loads, priority override, and restoration verification.
- **AI involvement:** May summarize when available; never controls emergency response.
- **Possible failures:** Platform unavailable, clocks reset, notification provider outage, or unsafe assumptions about restoration.
- **Missing architecture:** Multi-channel business continuity and manual re-entry are under-specified (GAP-08).
- **Recommendation:** Add continuity operating modes, paper/voice intake reconciliation, and critical contact trees.

## 16. Emergency repair at midnight

- **Expected workflow:** Capable duty staff stabilize immediately under standing Authority or necessity, communicate when feasible, and reconstruct scope, action, evidence limits, and consequences afterward.
- **Responsible role:** Acting technician/duty staff for stabilization; on-call manager for escalation; later reviewer for retrospective assessment.
- **Authority:** Standing emergency mandate or necessity, bounded by capability and harm reduction.
- **Evidence:** Available observations, call logs, access records, materials, witness accounts, and later inspection.
- **Timeline:** Event/action precede record/upload; no false preapproval is created.
- **Notifications:** On-call contacts, affected residents, management, and emergency services as policy requires.
- **Decision points:** Immediate danger, safe scope, external help, service isolation, and later permanent repair.
- **AI involvement:** Not required; may later organize chronology but cannot approve retrospectively.
- **Possible failures:** No reachable manager, inadequate capability, incomplete evidence, or punitive review discouraging action.
- **Missing architecture:** On-call fallback and Authority exhaustion ladder need detail (GAP-09).
- **Recommendation:** Define emergency role succession, maximum autonomous scope, and mandatory non-punitive review.

## 17. Fire incident

- **Expected workflow:** Emergency services and evacuation take precedence. Cases may arrive from many sources; duty staff stabilize only within capability. Investigation and Incident records are reconstructed after life safety is addressed.
- **Responsible role:** Fire service commands emergency response; building duty roles support evacuation/access; juristic management preserves organizational records and recovery.
- **Authority:** Statutory emergency Authority overrides ordinary workflow; software never presents local approval as superior.
- **Evidence:** Alarm/system logs, emergency-service reports, observations, access logs, media, and chain-controlled investigation material.
- **Timeline:** Alarm, detection, evacuation, response, containment, record, and upload times are distinct and may come from different clocks.
- **Notifications:** Emergency alarms/channels first; later resident, insurer, regulator, committee, and recovery communications under policy.
- **Decision points:** Evacuation, emergency command transfer, area access, evidence restriction, recovery, and regulatory reporting.
- **AI involvement:** No command role; later summarization only with protected data and source limitations.
- **Possible failures:** Conflicting command, overloaded intake, evidence contamination, platform/power loss, or premature public statement.
- **Missing architecture:** Major-incident command and external Authority handoff are not explicit (GAP-10).
- **Recommendation:** Add major-incident coordination model distinguishing external command from O83 Care recording/support.

## 18. Lift traps residents

- **Expected workflow:** Emergency contact/rescue begins immediately; Reports create separate Cases; one verified Incident coordinates rescue support, inspection, repair, independent safety verification, and resident communication.
- **Responsible role:** Authorized lift rescue provider/emergency service leads rescue; duty staff coordinate access; manager controls building response.
- **Authority:** Only qualified rescuers act on lift machinery; residents and unqualified staff receive safety instructions, not work assignment.
- **Evidence:** Call times, lift telemetry, intercom, maintenance history, rescue report, inspection, and certification.
- **Timeline:** Entrapment, contact, rescue, shutdown, inspection, return-to-service, and records are separate.
- **Notifications:** Trapped residents, emergency contacts, manager, service contractor, affected building users, and regulator if required.
- **Decision points:** Rescue escalation, service isolation, return to service, recurrence, and independent verification.
- **AI involvement:** May surface maintenance history; cannot advise unsafe rescue or authorize return to service.
- **Possible failures:** Contractor unreachable, incorrect lift identity, premature restart, or notification panic.
- **Missing architecture:** Safety-critical asset isolation/return-to-service control is under-specified (GAP-11).
- **Recommendation:** Add qualified-person, lockout/isolation, external certificate, and return-to-service decision requirements.

## 19. Contractor disappears

- **Expected workflow:** Record failed contact and unfulfilled commitments, protect the site, assess work/evidence/material custody, invoke contractual escalation, and authorize replacement work without deleting the first contractor's history.
- **Responsible role:** Contract manager manages supplier relationship; operational manager mitigates service risk; replacement technician accepts new Commitment.
- **Authority:** Contract termination, access revocation, payment hold, and replacement procurement require distinct mandates.
- **Evidence:** Contract, accepted commitments, contact attempts, access logs, work state, materials, and handover gaps.
- **Timeline:** Missed commitments, discovery, revocation, replacement decision, and resumed work remain visible.
- **Notifications:** Manager, security/access, procurement, affected residents, insurer/legal as applicable.
- **Decision points:** Abandonment threshold, site safety, contract remedies, replacement capability, and evidence sufficiency.
- **AI involvement:** May summarize obligations; cannot declare breach, terminate, punish, or select supplier.
- **Possible failures:** Orphaned responsibility, active credentials, inaccessible evidence, disputed completion, or duplicated payment.
- **Missing architecture:** Supplier abandonment and Commitment substitution workflow are missing (GAP-12).
- **Recommendation:** Add contractor offboarding, custody transfer, replacement commitment, and unresolved-liability rules.

## 20. Resident refuses inspection

- **Expected workflow:** Record refusal and reason, assess safety and legal access options, offer alternatives, pause dependent Operation, and escalate only under authorized policy.
- **Responsible role:** Case manager coordinates; resident controls ordinary consent; authorized juristic/legal role handles mandatory access.
- **Authority:** A technician cannot force entry. Emergency/statutory access requires the proper source and proportional action.
- **Evidence:** Contact attempts, offered appointments, refusal statement, risk assessment, notices, and legal/policy basis.
- **Timeline:** Requests, refusals, SLA pauses if policy permits, escalation, and eventual access remain explicit.
- **Notifications:** Resident receives consequences/options; manager and safety/legal roles are notified according to risk.
- **Decision points:** Immediate danger, alternative evidence, pause versus closure, mandatory access, and SLA treatment.
- **AI involvement:** May draft neutral communications; cannot infer bad faith or authorize entry.
- **Possible failures:** Deadlock, unsafe delay, harassment, false SLA breach, or Case closure without resolution.
- **Missing architecture:** Access refusal, dependency blockage, and SLA pause rules are missing (GAP-13).
- **Recommendation:** Add consent/access state, escalation ladder, lawful-entry decision, and blocked-time accounting.

## 21. Manager changes

- **Expected workflow:** End old mandate/responsibility period, revoke access, perform handover, start successor records, and preserve all prior decisions under original actor/role.
- **Responsible role:** Governance/HR identity steward executes transition; outgoing and incoming managers supply/accept context.
- **Authority:** Appointment and delegation source controls effective dates; successor Authority is not inferred from job title alone.
- **Evidence:** Appointment, mandate, handover package, acknowledgement, access review, and unresolved exceptions.
- **Timeline:** Authority end/start must not overlap unintentionally or create an uncovered interval without escalation.
- **Notifications:** Staff, vendors, committee, and workflows receive purpose-appropriate transition notice.
- **Decision points:** Open commitments, interim manager, conflicts, unaccepted handover, and privileged access.
- **AI involvement:** May summarize handover with citations; cannot grant Authority or assign inherited blame.
- **Possible failures:** Authority gap, dual control, lost context, stale access, or successor shown as author of past decisions.
- **Missing architecture:** No blocking gap; automated mandate-gap detection should be explicit.
- **Recommendation:** Add transition assurance report for expiring mandates, open duties, access, and acknowledgement.

## 22. Committee changes

- **Expected workflow:** Preserve resolutions and dissent, revoke outgoing access, onboard incoming members, disclose current risks/decisions, and maintain policy versions until lawfully changed.
- **Responsible role:** Juristic governance secretary/manager administers continuity; committee members are temporary stewards.
- **Authority:** Election/appointment and bylaws define mandate; a new committee cannot retroactively rewrite old decisions.
- **Evidence:** Appointment records, minutes, resolutions, conflicts, handover, and access recertification.
- **Timeline:** Terms, effective mandates, resolutions, and later supersession remain distinct.
- **Notifications:** Management, vendors, co-owners, and systems receive changes appropriate to legal/policy requirements.
- **Decision points:** Quorum, interim Authority, policy review, unresolved risk, and contested records.
- **AI involvement:** May summarize history; cannot validate election, quorum, or resolution.
- **Possible failures:** Institutional-memory deletion, mass policy reset, access retention, or missing quorum evidence.
- **Missing architecture:** No blocking gap; quorum/e-signature rules appropriately remain jurisdiction-specific.
- **Recommendation:** Require continuity pack acceptance and privileged-access recertification at every committee transition.

## 23. Developer changes

- **Expected workflow:** Use ADRs, documented contracts, exports, runbooks, dependency checks, and controlled access handover; verify restore and build/operate knowledge without changing domain history.
- **Responsible role:** Juristic Person's technology steward owns continuity; outgoing/incoming developers are service stewards.
- **Authority:** Vendors receive scoped technical access, never ownership of data, identifiers, or governance decisions.
- **Evidence:** ADRs, schema/event versions, dependency inventory, access logs, exports, restore tests, and acceptance records.
- **Timeline:** Access revocation/grant, release ownership, migrations, and decisions remain attributable.
- **Notifications:** Technology governance, security, operators, and affected suppliers.
- **Decision points:** Transition acceptance, undocumented dependency, data export completeness, credential rotation, and migration risk.
- **AI involvement:** May explain documentation; cannot approve architecture or migration.
- **Possible failures:** Vendor lock-in, unknown secrets, unrecoverable evidence, incompatible events, or founder-dependent knowledge.
- **Missing architecture:** No blocking gap; source/build escrow and supplier-exit testing depend on contracts.
- **Recommendation:** Make full exit simulation and independent restore a periodic governance control.

## 24. AI recommendation is wrong

- **Expected workflow:** Human reviews sources and rejects the recommendation, records correction if consequential, proceeds through manual workflow, and submits AI quality feedback.
- **Responsible role:** Human reviewer owns decision; AI use-case owner investigates systemic failure; technical steward contains unsafe use.
- **Authority:** AI has none. Authorized humans decide and may disable the use case.
- **Evidence:** Prompt/context references, output, model version, citations, reviewer decision, and actual outcome.
- **Timeline:** Generation, review, adoption/rejection, correction, and evaluation times remain visible.
- **Notifications:** Reviewer/use-case owner; safety or privacy roles if harm threshold is reached.
- **Decision points:** Ignore, correct, escalate, disable, retrain/reconfigure, and reassess prior adopted outputs.
- **AI involvement:** The subject of review; another AI may assist analysis but cannot self-certify correction.
- **Possible failures:** Automation bias, fabricated citation, silent model change, or no manual path.
- **Missing architecture:** No blocking gap; retrospective impact scan thresholds need use-case policy.
- **Recommendation:** Require affected-record search and human re-review after material AI defect discovery.

## 25. AI recommendation is outdated

- **Expected workflow:** Context comparison exposes expired policy, asset, model, environment, or knowledge version; human declines or adapts it; stale source is deprecated/superseded where appropriate.
- **Responsible role:** Knowledge steward maintains validity; human reviewer decides current action; AI owner monitors retrieval freshness.
- **Authority:** Only authorized human adopts guidance or changes Knowledge status.
- **Evidence:** Historical validity context, current context, last verification, source versions, and mismatch explanation.
- **Timeline:** Source effective period, verification date, generation time, and current policy version are explicit.
- **Notifications:** Reviewer and knowledge steward receive material stale-context warning.
- **Decision points:** Reuse, adapt, reverify, deprecate, or supersede.
- **AI involvement:** Must lower confidence and show mismatch; cannot claim universal applicability.
- **Possible failures:** Cached obsolete guidance, missing version metadata, or confident answer despite mismatch.
- **Missing architecture:** No blocking gap; maximum freshness rules vary by knowledge class.
- **Recommendation:** Configure class-specific revalidation periods and fail closed for safety-critical expired knowledge.

## 26. Historical knowledge conflicts with current practice

- **Expected workflow:** Preserve both records and contexts, open Knowledge review, compare evidence/policy/environment, and publish an affirming, scoped, deprecated, or superseding record.
- **Responsible role:** Knowledge steward coordinates qualified reviewers; governance owner decides policy conflict.
- **Authority:** Publication/deprecation follows Knowledge governance; historical authors have attribution, not veto.
- **Evidence:** Source outcomes, current standards, policy versions, asset context, assumptions, and limitations.
- **Timeline:** Each Knowledge version and effective period remains visible.
- **Notifications:** Users of affected current guidance and owners of linked templates receive change notice.
- **Decision points:** True conflict versus different context; safety interim control; supersession scope.
- **AI involvement:** May compare and surface conflict; cannot resolve or hide it.
- **Possible failures:** Global overwrite, false consensus, continued use in active Operations, or loss of failed hypotheses.
- **Missing architecture:** No blocking gap; dependency notification from Knowledge to active templates needs design.
- **Recommendation:** Maintain governed usage links so supersession can identify affected workflows and open Operations.

## 27. Evidence is contradictory

- **Expected workflow:** Preserve all items, record source/reliability/limitations, maintain competing hypotheses, seek corroboration, and issue an uncertainty-aware Understanding Assessment.
- **Responsible role:** Investigator assesses; evidence steward protects integrity; authorized human decides action under uncertainty.
- **Authority:** No evidence item or AI has decision Authority; safety actions may proceed on precautionary grounds with rationale.
- **Evidence:** Contradictory items, provenance, chain of custody, measurement uncertainty, and omitted sources.
- **Timeline:** Capture and availability times matter because later evidence must not be portrayed as earlier knowledge.
- **Notifications:** Decision maker and affected responsible roles receive unresolved contradiction; external parties only as appropriate.
- **Decision points:** Reliability, further investigation, precautionary action, deferred closure, and independent review.
- **AI involvement:** May map contradictions and missing corroboration; must not synthesize false certainty.
- **Possible failures:** Cherry-picking, averaging incompatible measurements, evidence suppression, or decision paralysis.
- **Missing architecture:** Decision deadlock/precaution escalation needs explicit timing (GAP-05, GAP-09).
- **Recommendation:** Add uncertainty thresholds, precautionary decision paths, and independent-review timeboxes.

## 28. Two technicians disagree

- **Expected workflow:** Record separate observations and hypotheses, disclose capability/context, prevent destructive overwrite, and route proportionate peer or supervisor review.
- **Responsible role:** Each technician owns their statement; investigator/supervisor owns reconciliation process.
- **Authority:** Seniority alone does not prove correctness; mandate and qualification determine review Authority.
- **Evidence:** Measurements, methods, calibration, asset access, photographs, and prior repair context.
- **Timeline:** Both accounts and later assessment remain ordered.
- **Notifications:** Assigned investigator/manager; safety escalation if delay is hazardous.
- **Decision points:** Additional test, independent expert, precautionary stabilization, or accepted uncertainty.
- **AI involvement:** May compare claims and qualifications; cannot rank people or decide truth.
- **Possible failures:** Hierarchy pressure, hidden dissent, endless investigation, or duplicate conflicting Operations.
- **Missing architecture:** Formal disagreement and tie-break workflow is missing (GAP-05).
- **Recommendation:** Add graded escalation with neutral reviewer, timebox, safety fallback, and dissent preservation.

## 29. Manager disagrees with technician

- **Expected workflow:** Preserve technician's evidence and recommendation, record manager's decision with Authority and rationale, disclose override consequences, and allow safety/professional escalation.
- **Responsible role:** Technician remains responsible for truthful professional input; manager owns authorized organizational decision; governance owns conflict process.
- **Authority:** Management may prioritize/authorize but cannot manufacture technical Capability or compel unsafe/illegal work.
- **Evidence:** Technical findings, manager constraints, alternatives, risk, policy, and dissent.
- **Timeline:** Recommendation precedes decision; later outcome informs review without rewriting either.
- **Notifications:** Affected responsible roles and independent safety/professional reviewer when threshold is met.
- **Decision points:** Override, pause, second opinion, emergency stabilization, or refusal of unsafe instruction.
- **AI involvement:** May show policy and evidence; cannot side with either person or evaluate punishment.
- **Possible failures:** Authority abuse, insubordination misclassification, hidden dissent, or unsafe order.
- **Missing architecture:** Protected professional dissent and unsafe-work refusal are under-specified (GAP-05).
- **Recommendation:** Define stop-work Authority, non-retaliation, independent review, and urgent escalation.

## 30. Committee rejects recommendation

- **Expected workflow:** Committee records an authorized Decision with alternatives, evidence, rationale, votes/dissent, consequences, and review trigger; recommendation remains in history.
- **Responsible role:** Recommender owns accurate advice; committee owns reserved decision; manager implements lawful decision.
- **Authority:** Committee must have mandate/quorum and cannot override law, safety command, or professional restrictions merely by vote.
- **Evidence:** Recommendation, risk/cost options, policy, legal/professional advice, and conflict disclosures.
- **Timeline:** Recommendation, meeting, decision, effective date, implementation, and later review are separate.
- **Notifications:** Recommender, management, affected stakeholders, and co-owners where governance requires.
- **Decision points:** Reject, defer, request evidence, accept alternative, or escalate reserved/legal issue.
- **AI involvement:** May summarize papers; cannot count legal quorum, vote, approve, or reject.
- **Possible failures:** No rationale, conflicted votes, unsafe rejection, or recommendation deletion.
- **Missing architecture:** No blocking gap; local quorum and reserved-matter rules remain governed configuration.
- **Recommendation:** Require explicit consequence acceptance and review date for rejection of high-risk recommendations.

## 31. Resident disputes completion

- **Expected workflow:** Append dispute/new evidence to the resident's Case, acknowledge it, prevent automatic deletion or reopen, investigate whether verification/closure remains valid, and record a new assessment/decision.
- **Responsible role:** Case manager handles dispute; independent verifier/investigator reassesses; authorized manager decides Case/Incident action.
- **Authority:** Resident may challenge but does not unilaterally verify or reopen; manager cannot dismiss without recorded review.
- **Evidence:** Resident observation, prior evidence package, acceptance criteria, communication, and new inspection.
- **Timeline:** Original completion and closure remain; dispute, acknowledgement, investigation, and revised decision append.
- **Notifications:** Resident receives acknowledgement and reasoned outcome; verifier/manager and responsible technician receive appropriate notice.
- **Decision points:** Communication correction, failed work, recurrence, unrelated issue, reopen, new Incident, or maintain closure.
- **AI involvement:** May summarize history and identify missing acceptance evidence; cannot decide credibility or outcome.
- **Possible failures:** Circular reopen/dispute loop, defensive dismissal, retaliation, or misleading KPI closure.
- **Missing architecture:** Dispute lifecycle and independent-review SLA are not explicit (GAP-14).
- **Recommendation:** Add a Case Dispute process with independence, acknowledgement, timebox, outcome categories, and loop escalation.

## Validation result

All 31 scenarios are representable without violating the core architecture. Fourteen gaps require architectural clarification or catalog extensions before detailed implementation; three are high priority because they affect cross-tenant correction, major-incident command, and safety-critical return to service.
