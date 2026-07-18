# Security and Audit Model

Version: 2.0  
Status: Architecture Baseline

## Purpose

Security protects people, operations, and Organizational Memory while enabling accountable access and continuity.

## Security principles

Use least privilege, deny by default, explicit tenancy, separation of duties, strong identity, purpose limitation, encryption, secure defaults, and independently testable recovery. Authorization evaluates person, acting role, mandate, resource relationship, action, context, and time.

## Identity and access

Each person has an individual identity; shared accounts are prohibited. Strong authentication is required for privileged roles. Sessions, service identities, integrations, and emergency access are scoped and revocable. Access is recertified when roles change and periodically thereafter.

## Data protection

Classify data as public, internal, confidential, or highly restricted. Encrypt in transit and at rest; manage keys separately with rotation and recovery. Minimize personal data, control exports, redact views, and enforce retention and lawful disposal. Tenant boundaries apply to storage, search, caches, events, logs, analytics, and AI contexts.

## Audit

Audit records are append-only and tamper-evident. They capture actor and acting role, action, target, event and record time, result, reason, authority reference, session/correlation, and material before/after references without logging secrets. Audit access is itself audited.

## Incident response and continuity

Security events are detected, classified, contained, investigated, recovered, communicated, and reviewed under defined authority. Backups are encrypted, isolated, retention-governed, and restore-tested. Recovery objectives reflect safety and operational risk.

## Exceptions

Emergency access is time-limited, reasoned, highly visible, and retrospectively reviewed. It does not permit history deletion. A committee request to conceal an embarrassing record follows legal retention and independent authorization, not ordinary administrative access.

## Evolution

Threat models, dependencies, access policies, cryptography, and supplier assurances are reviewed regularly. Permission intent is summarized in [22_permission_matrix.md](22_permission_matrix.md).
