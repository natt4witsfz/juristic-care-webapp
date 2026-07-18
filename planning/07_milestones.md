# O83 Care Program Milestones

Version: 1.0  
Status: Execution Baseline

## Purpose

Milestones are evidence-based decision points. Dates are assigned after team capacity, governed configuration, and provider lead times are confirmed. A milestone is achieved only when its exit evidence is accepted.

| Milestone | Sprint | Outcome | Required evidence | Decision authority |
|---|---:|---|---|---|
| M0 Program mobilized | 0 start | Owners, environments, governance, backlog, risk process established | Team/owner map, environment and secret model, baseline manifest, initial risks | Program sponsor and technical lead |
| M1 Live database baseline | 0 end | Approved SQL executes and validates on target Supabase | Migration checksum/results, object counts, advisor disposition, recovery proof | Database and security owners |
| M2 Trusted domain foundation / R0 | 2 end | Identity, tenant isolation, audit/events, organization and estate context ready | RLS matrix, temporal/graph tests, master-data reconciliation, R0 pack | Security, domain and data owners |
| M3 Safe intake pilot / R1A | 3 end | Reports create separate Cases with resident-safe tracking and emergency path | accessibility, five-report, wrong-context/transfer, triage tests | Resident service and safety owners |
| M4 Verified event management / R1 | 4 end | Investigation and human Incident verification work end-to-end | Assessment revisions, association trace, recurrence tests | Operations/domain owner |
| M5 Operational beta core | 6 end | Work, commitments, SLA, field offline and Evidence work safely | field usability, sync conflict, Storage/integrity, independent verification tests | Operations, evidence, security owners |
| M6 Accountable workflow / R2 | 8 end | Decisions, workflows, disputes, notifications and integrations are durable | Decision Evolution, workflow, provider retry/replay, dispute evidence | Operations and service owners |
| M7 Safety and governance gate | 9 end | Major-incident command, return-to-service, supplier and committee control proven | fire/lift drills, contractor failure, quorum/Authority tests | Highest applicable safety/governance authority |
| M8 Institutional stewardship / R3A | 11 end | Knowledge, memory, retention, search and reporting are governed/rebuildable | validity tests, export/restore, legal hold, search rebuild, KPI reproduction | Governance, privacy, memory, KPI owners |
| M9 Integrated human workspaces / R3B | 12 end | Manager and committee users perform authorized end-to-end work | role journey, denial, accessibility, replacement/handover tests | Business owners |
| M10 Governed AI / R3 | 13 end | Advisory AI is mediated, cited, reviewable and disableable | injection/privacy/evaluation, wrong/outdated advice, manual fallback | AI use-case and governance owners |
| M11 Continuity proven | 14 end | System survives outage, restore, and manual reconciliation | power/internet/provider game days, full restore, RTO/RPO results | Continuity and safety owners |
| M12 Production readiness / R4 | 15 end | Pilot, migration, operations, training and risk posture accepted | 60 criteria, 31 scenarios, load/pen/accessibility, readiness dossier | Juristic Person authorized body |

## Milestone slippage rules

A missed milestone is re-estimated from remaining uncertainty and dependency impact. Scope may be deferred only if its absence does not violate a release invariant or safety/security gate. F05, F12–F14, F18, F24–F28, F34, F36–F37, F44, F46–F48 cannot be waived for the production scope they protect. No team may relabel a failed control as accepted without a named lawful risk Decision.

## Progress measures

Track accepted features, acceptance criteria passed, open control failures, escaped defects, risk burn-down, migration/reconciliation health, accessibility findings, restore evidence, and training readiness. Do not use story points completed or status color alone as evidence of operational readiness.
