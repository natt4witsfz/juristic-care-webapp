# Environment Configuration

## Public variables

| Variable                        | Required | Meaning                                                       |
| ------------------------------- | -------- | ------------------------------------------------------------- |
| `VITE_APP_ENV`                  | Yes      | `development`, `test`, `staging`, or `production`             |
| `VITE_APP_VERSION`              | No       | Public build or release identifier; defaults to `unversioned` |
| `VITE_SUPABASE_URL`             | Yes      | Supabase project or local API URL                             |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | Yes      | Browser-safe publishable key                                  |

Every `VITE_` value is bundled into browser output and must be treated as public. Supabase service-role keys, secret keys, access tokens, passwords, signing secrets, and production evidence never belong in these variables.

The application validates configuration before rendering. Failure produces a safe user message and a field-only diagnostic in the developer console; configured values are not printed. Tests use synthetic local values and make no Supabase request.

Developers use `frontend/.env.local`, which Git ignores. CI supplies non-production test values through Playwright configuration. Vercel environments must define separate development, preview, and production values. Rotate keys and review deployment access through the platform process; never commit a temporary real value to `.env.example`.

Legacy Supabase anonymous keys may exist in older projects, but the application contract calls the browser credential a publishable key. No credential grants business authority; authorization remains a future database and application concern.
