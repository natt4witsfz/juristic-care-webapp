# Reporting and Analytics Model

Version: 2.0  
Status: Architecture Baseline

## Purpose

Reporting provides reproducible views of operational history for service, oversight, and learning while preserving definitions, time context, and privacy.

## Analytical layers

Operational views read current projections for active coordination. Governed reports use versioned semantic definitions and reproducible snapshots. Longitudinal analysis uses immutable events and effective-dated dimensions. Exploratory analysis is clearly labeled and cannot silently redefine official metrics.

## Rules

Every report declares owner, purpose, audience, included population, exclusions, formula/version, time zone, as-of time, data freshness, suppression rules, and drill-through provenance. Counts distinguish Reports, Cases, Incidents, Operations, and people. Five related reports therefore count as five Cases and, after human association, may count as one Incident.

The semantic owner is Responsible for metric meaning; the data steward is Responsible for lineage and quality; an authorized publisher has Authority to label a report official or restated. Analysts and AI may propose interpretations but have no Authority to redefine a published KPI or make an operational decision from it.

## Time and revisions

Event time supports operational chronology; recorded/uploaded time supports data-quality analysis. Late data updates later snapshots but does not rewrite previously issued reports. Restated reports retain the original, reason, approver, and replacement.

## Responsible use

Metrics indicate system conditions, not automatic blame. Personnel evaluation requires separate governance, context, and human review. Small groups and sensitive categories use suppression or aggregation. AI-generated analysis exposes sources, assumptions, and uncertainty.

## Quality

Completeness, timeliness, validity, uniqueness, provenance, and reconciliation are monitored. Exceptions identify impact and remediation owner. KPI definitions are normative in [28_kpi_catalog.md](28_kpi_catalog.md); data sourcing follows [18_data_architecture.md](18_data_architecture.md).

## Edge cases and evolution

Late Case-Incident associations are reflected in later as-of views without changing earlier issued reports. Verification withdrawal removes an Incident from current verified counts according to the metric version while preserving its historical inclusion. Taxonomy, SLA, and organization changes use effective-dated dimensions. New analytics products require privacy review, lineage, reproducibility, and an exit path before official use.
