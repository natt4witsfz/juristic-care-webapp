import { createClient, type SupabaseClient, type User } from 'npm:@supabase/supabase-js@2.110.7';

const configuredOrigins = (
  Deno.env.get('O83_ALLOWED_ORIGINS') ??
  'http://localhost:5173,http://127.0.0.1:5173,http://127.0.0.1:4175'
)
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

export function corsHeaders(request: Request): HeadersInit {
  const origin = request.headers.get('origin') ?? '';
  return {
    'access-control-allow-origin': configuredOrigins.includes(origin)
      ? origin
      : (configuredOrigins[0] ?? 'null'),
    'access-control-allow-headers': 'authorization, x-client-info, apikey, content-type',
    'access-control-allow-methods': 'POST, OPTIONS',
    vary: 'Origin',
  };
}

export function json(request: Request, body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders(request),
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
    },
  });
}

export function clients(request: Request): {
  userClient: SupabaseClient;
  serviceClient: SupabaseClient;
} {
  const url = Deno.env.get('SUPABASE_URL');
  const publishableKey = Deno.env.get('SUPABASE_ANON_KEY');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  const authorization = request.headers.get('authorization');
  if (!url || !publishableKey || !serviceRoleKey || !authorization)
    throw new Error('Trusted workflow environment or authorization is unavailable.');
  return {
    userClient: createClient(url, publishableKey, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false },
    }),
    serviceClient: createClient(url, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    }),
  };
}

export async function authenticatedUser(userClient: SupabaseClient): Promise<User> {
  const { data, error } = await userClient.auth.getUser();
  if (error || !data.user) throw new Error('A valid authenticated user is required.');
  return data.user;
}

export async function sha256(bytes: Uint8Array): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return [...new Uint8Array(digest)].map((value) => value.toString(16).padStart(2, '0')).join('');
}
