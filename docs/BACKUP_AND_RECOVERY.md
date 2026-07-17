# Backup and Recovery

## Objectives

Backups protect operational continuity and Organizational Memory. A backup is not accepted until a restore has been demonstrated.

Use Supabase-managed daily backups and point-in-time recovery appropriate to the contracted plan, plus independently retained logical exports for critical reference/configuration data. Storage objects require a separately verified retention and recovery process because database recovery alone does not recreate missing evidence objects.

## Recovery tiers

- Identity/configuration incident: restore or reconstruct the affected configuration with audited forward changes.
- Accidental logical change: prefer compensating records; immutable history is never deleted to conceal the error.
- Database loss/corruption: restore to an isolated project, validate integrity and tenant boundaries, then execute the approved cutover.
- Storage-object loss: restore the immutable object, verify its digest, append custody/integrity events, and preserve the period of unavailability.

## Restore exercise

At least quarterly, restore a production-like backup to isolation and verify schema count, constraints, RLS, Auth linkage, evidence metadata/object reconciliation, audit continuity, Case-to-Incident traceability, and critical reports. Record achieved recovery point and recovery time. The Juristic Person approves target RPO/RTO before launch; until then they are an explicit production blocker, not an assumed value.
