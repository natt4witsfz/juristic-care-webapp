# O83 Care Architecture Repository — Version 2

Version: 2.0  
Status: Architecture Baseline

## Purpose

This repository is the internally consistent architecture baseline for building O83 Care. It contains architecture only: no application code, API specification, database code, or frontend implementation.

## Reading order

Start with [00_foundation.md](00_foundation.md), [01_design_principles.md](01_design_principles.md), and the normative [16_project_glossary.md](16_project_glossary.md). Continue through domain and governance models (02–10), interaction and assurance models (11–15), then decision/data/event architecture (17–22), role experiences and standards (23–29), and [30_reference_architecture.md](30_reference_architecture.md).

## Normative hierarchy

Applicable law and juristic governance remain external authorities. Within this repository, Foundation invariants and Glossary definitions govern. Domain and governance models define business meaning. State, permission, evidence, and AI catalogs are normative within their scope. Reference architecture constrains implementation shape. A conflict is resolved through an Architecture Decision Record rather than silent interpretation.

## Repository-wide invariants

One Report creates one Case; suspected events remain Investigations until human verification creates an Incident; humans determine Case-Incident relationships; Operations perform work; history is immutable; Operational Truth is revisable; the Responsibility Chain and Decision Evolution remain traceable; Responsibility, Authority, Commitment, Capability, Availability, Organizational Priority, Execution Sequence, and SLA remain distinct; safety precedes workflow; AI is advisory; knowledge is context-bound; and Organizational Memory belongs to the Juristic Person.

## Change governance

Material changes require impact analysis across terminology, states, permissions, events, data, user experiences, security, reporting, AI, and continuity. Accepted changes record an ADR, effective version, migration/coexistence plan, validation evidence, and human authority. Previous versions remain available for historical interpretation.

## Production readiness gate

Before implementation is considered conformant, reviewers must validate the fourteen recurring scenarios: multiple duplicate reports, later association, near and distant recurrence, out-of-hours emergency work, interruption, delayed evidence, remote verification, off-system work reconstruction, revised hypotheses, predecessor learning, invalid historical context, attempted timeline removal, and full founder/staff turnover. Each must preserve chronology, authority, responsibility, evidence limits, AI boundaries, and Organizational Memory.
