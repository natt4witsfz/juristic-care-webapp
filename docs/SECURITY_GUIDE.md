# Security Guide

## Trust boundaries

Supabase Auth establishes identity, not business authority. Effective tenant relationships, roles, permission mappings, Mandates, Responsibility, and contextual rules establish access. PostgreSQL RLS and controlled functions enforce the boundary; hidden links do not.

The browser receives only the Supabase URL and publishable key. Service-role, database, SMTP, and third-party integration secrets remain in server-managed secret stores. Logs must redact tokens, credentials, personal identifiers, and evidence URLs.

## Data handling

Classify resident identity, room occupancy, contact data, evidence, and access logs. Collect the minimum necessary, use signed Storage access, validate MIME type and size server-side, calculate integrity digests, and quarantine files until checks finish. Original evidence is not silently replaced.

## Access lifecycle

Provision access through an authenticated administrative boundary with separation of duties. Review privileged roles regularly. On departure, disable the Auth/account relationship and end effective assignments; never delete historical actions. Break-glass access requires time limits, reason, approver, and retrospective review.

## Development rules

- Validate every untrusted value at the command boundary.
- Use parameterized Data API calls or reviewed SQL functions.
- Keep security-definer functions on an empty or explicit search path.
- Grant schema/object privileges explicitly and keep RLS forced.
- Do not render raw HTML from user or AI content.
- Keep dependency and secret scanning in CI.
- Treat AI output and external messages as untrusted input.

Report suspected exposure through the Juristic Person's approved incident channel. Do not include sensitive payloads in public issues.
