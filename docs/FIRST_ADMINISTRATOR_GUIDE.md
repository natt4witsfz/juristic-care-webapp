# O83 Care First Administrator Guide

## Purpose

This guide establishes the first O83 Care administrator without inventing Authority, embedding a default account, exposing a privileged secret or bypassing tenant isolation. It is a governed bootstrap for an empty hosted project, not a self-service sign-up flow.

As of 2026-07-18, the hosted project has zero Juristic Persons, Auth users and O83 application accounts. The current Production site is therefore not ready for an administrator to sign in.

## Meaning of administrator

An O83 `admin` role permits approved technical administration. It does **not** automatically provide:

- committee power or a vote;
- emergency or expenditure Authority;
- operational Responsibility;
- a Commitment to perform work;
- technician Capability or Availability;
- permission to alter Priority, execution sequence or SLA;
- permission to verify one's own significant work;
- ownership of Organizational Memory as a human individual.

Business Authority comes from an effective, scoped and evidence-backed Mandate. The Juristic Person owns Organizational Memory; the administrator is a temporary steward.

## Security boundary

O83 authorization is not derived from email domain, browser fields, `user_metadata` or merely possessing a Supabase Auth account. Access resolves through database-owned records:

```text
Supabase Auth user
  -> iam.user_accounts
  -> org.people
  -> effective org.organization_relationships
  -> effective org.role_assignments
  -> org.role_permissions
  -> effective scoped org.mandates for Authority-bound commands
```

The first administrator cannot bootstrap this chain from the application because the commands correctly require an existing authorized actor. The initial chain must be created through a reviewed, one-time provisioning migration or controlled server-side provisioning service under two-person control.

## Prerequisites

Do not create the first administrator until all of the following exist:

- an approved legal identity and internal identifier for the Juristic Person;
- an accountable resolution or equivalent Authority instrument naming the first administrator and scope;
- approved privacy, security, identity, session/MFA, invitation/recovery and emergency-access policies;
- a separate staging project in which the candidate migrations and functions pass hosted acceptance;
- approved Supabase Auth Site URL and exact redirect allow-list;
- approved SMTP/sender or another secure invitation-delivery method;
- named primary operator, independent verifier and emergency successor;
- a backup/restore point and rollback Decision for the provisioning change;
- no real credential in Git, Markdown, browser environment variables, chat or tickets.

## Bootstrap record to prepare

The approving authority must record:

| Field                     | Required content                                                                                                                         |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Juristic Person           | Legal name, registration number, country, timezone and default locale                                                                    |
| Initial person            | Verified legal/preferred name and approved contact channel                                                                               |
| Organization relationship | Relationship type, effective time, source policy/appointment and state                                                                   |
| Administrator role        | Tenant-scoped `admin` role assignment; effective time and source                                                                         |
| Mandate                   | `permission.manage` action, Juristic Person scope, validity period, grantor, source type/source ID, delegation rule and revocation owner |
| Auth invitation           | Destination address, delivery owner, expiry and MFA/session requirements; never the password                                             |
| Change evidence           | Approver, operator, verifier, reason, ticket/Decision ID, backup reference and rollback plan                                             |

Use stable business keys and preserve all source identifiers so the bootstrap is auditable and repeatable.

## Provisioning sequence

### 1. Verify the release state

1. Confirm the intended source commit and protected branch.
2. Confirm the linked Supabase project ref and environment.
3. Compare local and remote migrations with `pnpm supabase migration list --linked`.
4. Do not provision against the current baseline if the approved administrator UI/commands and candidate migrations have not been released.
5. Confirm the hosted backup/recovery point and record the change window.

### 2. Provision the Juristic Person and reference data

Through a reviewed migration or controlled provisioning service:

1. Create the `org.juristic_persons` record.
2. In the same controlled transaction, set the tenant bootstrap context and execute the existing tenant reference-data module described in `docs/SUPABASE_SETUP.md`.
3. Verify the tenant-scoped role definitions, permission definitions, role-permission mappings and governed taxonomy terms.
4. Confirm the `admin` role has `permission.manage` while recognizing that this permission does not replace a Mandate.

Do not rerun or edit the already-applied baseline migration to obtain seed data. Package provisioning as a new reviewed forward artifact or controlled command.

### 3. Create the Auth identity securely

1. Use the Supabase Dashboard Authentication Users area or an approved server-only invitation service.
2. Invite the verified address; do not create a shared administrator identity.
3. Require the approved password/MFA/session controls.
4. Deliver the invitation through the approved channel.
5. Record the Auth user UUID in the protected provisioning workflow, not in public documentation.
6. Never use a service-role or secret key in frontend code or a `VITE_` variable.

### 4. Create the durable O83 identity chain

In the same reviewed bootstrap change where practical:

1. Create the durable `org.people` record.
2. Create an effective `org.organization_relationships` record linked to the approved relationship taxonomy and appointment source.
3. Create `iam.user_accounts`, linking the Auth UUID to the Person and Juristic Person with the approved initial account state.
4. Create the initial effective `org.role_assignments` record for `admin` with reason, source and effective time.
5. Create the scoped, effective `org.mandates` record that authorizes `permission.manage`, referencing the human approval evidence.
6. Preserve the person, relationship, role and Mandate as separate records. Do not collapse them into Auth metadata.
7. Record Audit/Timeline/provisioning evidence according to the approved bootstrap mechanism.

### 5. Verify before broader invitation

The independent verifier must confirm:

- sign-in succeeds only for the intended invited identity;
- `api.resolve_current_access()` returns the expected Juristic Person, Person, `admin` role and `permission.manage` permission;
- `api.current_authority_context` shows the correct active Mandate, scope and validity;
- the Administration workspace loads through RLS-backed views;
- the administrator can perform one approved reasoned administration action using the exact acting role assignment and Mandate;
- the resulting Audit and Timeline identify who, when, why, Authority, previous state and current state;
- anonymous access is denied;
- a user without the relationship/role/Mandate is denied;
- cross-tenant, disabled-account, expired-role and expired-Mandate tests pass in staging;
- service-role and database credentials are absent from the browser bundle and logs.

If any check fails, stop further invitations, preserve the evidence and correct through a forward change. Do not broaden RLS or grants to make the check pass.

## Creating subsequent users

After the first administrator is verified:

1. Verify or create the Person and effective organization relationship before assigning access.
2. Invite a unique Auth identity through the approved server-side process.
3. Link the Auth account to the existing Person; do not create duplicate people for role changes.
4. Assign the minimum role using the Mandate-bound `api.assign_role` command.
5. Add separate Mandates only for actions and scopes actually approved.
6. Record Capability, Availability, Responsibility and Commitment independently when relevant.
7. Verify the user's access resolution and one positive/negative scenario before operational use.
8. Never give `admin` merely to resolve a missing relationship, Mandate, RLS denial or incomplete feature.

## First-login checklist

The first administrator should:

1. Set the approved password and enroll approved MFA.
2. Confirm the displayed identity and tenant.
3. Review current roles, permissions and Mandate expiry.
4. Confirm Production/support/emergency contact information outside the application.
5. Review pending policy approvals; do not configure unapproved business values.
6. Verify no real resident, staff or operational data was preloaded without authority.
7. Confirm backup status, rollback point and on-call ownership before inviting others.
8. Create a second independently accountable successor only under an approved role/Mandate Decision.

## Suspension, departure and replacement

When an administrator departs or must be suspended:

1. Revoke or terminate active sessions through the approved Auth process; deleting a user alone does not immediately invalidate every issued JWT.
2. Use the governed account-state command to suspend/disable the O83 account with reason and expected version.
3. End the role assignment and revoke/supersede the Mandate with no Responsibility gap.
4. Transfer open Responsibilities, custody, secrets, provider ownership, backup access and unresolved risks to an effective successor.
5. Rotate credentials the departing person could access.
6. Preserve all historical Person, account, role, Mandate, Audit and Timeline records.
7. Verify denial after token/session refresh and record the result.

Never delete history to conceal an error or simplify replacement.

## Acceptance record

The bootstrap is complete only when the business approver, security verifier and technical operator sign an immutable record containing:

- source commit, migration ledger and hosted environment;
- tenant, Person, relationship, role and Mandate business keys;
- Auth user UUID retained in restricted evidence;
- approval source and effective/expiry times;
- positive and negative test results;
- Audit/Timeline references;
- backup and rollback reference;
- known limitations and next review date.

No password, recovery code, access token, service-role key or database credential belongs in the acceptance record.
