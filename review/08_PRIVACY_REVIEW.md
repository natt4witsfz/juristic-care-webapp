# Privacy Review

## Data subjects and sensitive areas

Residents, occupants, staff, contractors, committee members, reporters, and visitors may appear in identity, occupancy, communication, evidence, access, and audit records. Room occupancy and incident/evidence content can reveal behavior, location, health, safety, disputes, or private living conditions.

## Architecture controls

- Tenant and relationship-scoped access instead of a global owner field.
- Data classification fields and governed evidence metadata.
- Immutable historical records with compensating correction rather than concealment.
- Archive/retention strategy that distinguishes current access from historical integrity.
- Signed/private Storage access design and no public evidence bucket assumption.
- AI context manifests, source references, limitations, reviews, and restricted data scope.

## Required policy decisions

The Juristic Person must approve lawful basis, notices, data-subject request workflow, statutory retention, litigation/incident holds, committee access, resident visibility, CCTV/video treatment, biometric prohibition or controls, international processing, vendor subprocessors, breach notification, and deletion/anonymization rules. A request to delete an embarrassing record is not sufficient to destroy legitimate organizational history; legal erasure and restriction requests require documented assessment and, where necessary, cryptographic or referential anonymization without falsifying events.

## Launch condition

Complete a jurisdiction-specific privacy impact assessment, data inventory, processor agreements, retention schedule, Storage-object lifecycle, access-review procedure, and tested subject-request workflow. Until approved, resident production onboarding is not authorized.

