# Security Foundation

Sprint 00 establishes least-privilege defaults without pretending to implement authorization. Only a browser-safe Supabase publishable key may enter frontend configuration. The service-role key and all secret keys remain server-side. The client adapter is lazy, centralized, and does not make a startup request.

Startup rejects missing or malformed public configuration. Error surfaces hide stack traces, credentials, and internal payloads. Development diagnostics reveal only that fields are configured. Source maps are disabled in production builds. Static assets must be non-sensitive. Vercel applies baseline anti-framing, MIME, referrer, and browser-capability headers.

The `/sign-in` and `/unauthorized` routes are presentation boundaries only. They do not authenticate, authorize, or imply access. Future Supabase Auth work must validate sessions, model tenant membership separately from identity, enforce RLS and explicit grants, and test negative cross-tenant cases.

Dependency versions and the package manager are pinned. CI uses a frozen lockfile. Tests contain synthetic values and no production data. Security logging, telemetry, CSP allowlists, RLS, storage policy, rate limits, vulnerability response, and incident operations must be completed in their authorized sprints before production.
