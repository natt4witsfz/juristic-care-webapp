# Architecture Decision Records

Version: 2.0  
Status: Architecture Baseline

## Purpose

Architecture Decision Records (ADRs) preserve why the system took a direction so future stewards can evaluate it without relying on founders or vendors.

## Required content

Each ADR has identifier, title, status, decision scope, context, problem, observations, hypotheses, evidence, constraints, considered alternatives, decision, rejected alternatives and reasons, trade-offs, expected consequences, responsible person and acting role, authority, participants and dissent, decision timestamp, effective version, review triggers, later reviews, and superseding ADR links.

## Statuses

Proposed, Accepted, Rejected, Superseded, and Withdrawn are historical statuses. Accepted means authorized for the stated scope, not eternally correct. Material revision creates a new ADR and supersedes the old one.

## Governance

Architecture authority is defined by project governance. Security, privacy, data-retention, interoperability, or major cost decisions require relevant specialists and business authority. AI may collect context or compare alternatives but cannot accept an ADR.

## Initial decision index

| ADR     | Decision                                                               |
| ------- | ---------------------------------------------------------------------- |
| ADR-001 | One Report creates one immutable Case identity.                        |
| ADR-002 | Incident identity is established by authorized human investigation.    |
| ADR-003 | Material history is append-only with supersession.                     |
| ADR-004 | Responsibility and Authority use effective-dated ledgers and mandates. |
| ADR-005 | Domain-centered modular architecture precedes service extraction.      |
| ADR-006 | Reliable domain events use an outbox and idempotent consumers.         |
| ADR-007 | AI is advisory, cited, optional, and never accountable.                |
| ADR-008 | Knowledge reuse requires validity-context comparison.                  |
| ADR-009 | Organizational Memory is portable and owned by the Juristic Person.    |

Each indexed decision must have a complete ADR before implementation depends on it. Repository review checks for orphan decisions and stale reviews; incomplete ADRs fail the architecture quality gate.
