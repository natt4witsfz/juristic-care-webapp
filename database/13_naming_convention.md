# Database Naming Convention

Version: 1.0  
Status: Normative

## Purpose

Names remain readable, stable, portable, and unambiguous across PostgreSQL, Supabase, migrations, events, reports, and decades of developer change.

## General rules

- Lowercase `snake_case`; ASCII; no quoted identifiers; no reserved words.
- Schema names are bounded-context nouns.
- Tables use plural nouns: `cases`, `decision_records`.
- Primary key is `id`; foreign keys are `<singular_table>_id` or semantically explicit (`verification_decision_id`).
- Tenant key is always `juristic_person_id`.
- Human business key uses domain name (`case_number`, `asset_code`), not generic `code` when ambiguity exists.
- Booleans begin `is_`, `has_`, `requires_`, or an explicit predicate; lifecycle should use governed state, not many booleans.
- Timestamps end `_at`; dates `_on`; effective periods `valid_from/valid_to` or `effective_from/effective_to`; durations state unit or use interval.
- Immutable version tables use `version_number` and `supersedes_version_id`; aggregate concurrency uses `row_version`.
- Digest columns state scope when needed (`content_digest`, `payload_digest`).

## Controlled suffixes

| Suffix | Meaning |
|---|---|
| `_state` | Current lifecycle projection with a specific state machine |
| `_status` | Review/publication/result status not aggregate lifecycle |
| `_type` | Closed structural discriminator, not user vocabulary |
| `_term_id` | Foreign key to governed taxonomy term |
| `_code` | Stable human/system code never repurposed |
| `_number` | Human-facing sequential/structured identifier |
| `_reference` | Opaque external/object locator, not relational identity |
| `_summary` | Human-readable derived or decision text, not authoritative relationship |

## Constraint and index names

Names encode table, columns/purpose, and kind: primary key, foreign key, unique, check, exclusion, index, or policy. Long names use meaningful abbreviations consistently; generated random names are prohibited because operational errors must be diagnosable after team changes.

## Event and enum naming

Domain Event types are past-tense PascalCase in contracts (for example `CaseCreated`) while stored database codes use stable text values. States and taxonomy codes use lowercase snake case. Existing codes are never renamed in place for cosmetic reasons; display labels may change through versioned taxonomy/localization.

## Prohibited names

`owner_id`, `priority`, `status`, `data`, `metadata`, `type`, or `user_id` without precise domain qualification are prohibited where they collapse meaning. `deleted_at` is not a universal lifecycle. `ticket`, `incident_suspected`, and `ai_decision` are prohibited domain names.
