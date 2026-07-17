# Security Review

**Review date:** 2026-07-17  
**Scope:** SQL, Supabase configuration, browser client, authentication foundation, CI, and documentation  
**Result:** Conditional; no production authorization

## Positive controls

- Browser configuration accepts only a Supabase URL and publishable key; static validation rejects service-role references in frontend source.
- Only the `api` schema is exposed by Supabase configuration.
- Authoritative tables are covered by enabled and forced RLS setup.
- Auth identity is resolved separately from effective organization roles and data-driven permissions.
- Security-definer command functions set an empty search path and use qualified object names.
- Case creation verifies tenant membership, role/source compatibility, input presence, independent Report/Case creation, and immutable domain-event recording.
- AI access was narrowed during review: the AI service can read approved use cases and append interactions, recommendations, and sources; it cannot create human reviews or mutate authoritative domain records.
- AI interactions, recommendations, sources, and reviews have immutable-history triggers.
- Resident Case reads are relationship scoped; Operation worker access depends on management role or accepted Commitment.
- Password-reset response avoids account enumeration in the browser.

## Findings

| ID | Severity | Finding | Required closure |
|---|---|---|---|
| SEC-01 | Critical | Migration and RLS policies have not executed on a real PostgreSQL instance in this environment. | Run local/hosted migration, lint, database tests, and multi-user RLS fixtures. |
| SEC-02 | High | Invitation and permission mutation server-side commands are not implemented. | Add audited Edge Function/RPC with least privilege, expiry, and separation checks. |
| SEC-03 | High | Evidence upload registration, MIME/size verification, digesting, quarantine, and signed-download flow are not implemented end to end. | Complete Storage vertical slice and adversarial tests. |
| SEC-04 | High | Most domain mutations still lack controlled command functions and runtime tests. | Implement commands in dependency order; deny direct table mutation. |
| SEC-05 | Medium | No production CSP/security-header verification or dependency vulnerability result exists. | Configure, deploy to staging, scan, and record evidence. |
| SEC-06 | Medium | Jurisdictional privacy, retention, emergency authority, and breach process are not approved. | Obtain and encode Juristic Person policy decisions. |

No real secret was found or printed during this review. Absence of a runtime test means the security design is not yet security proof.

