import { createClient } from '@supabase/supabase-js';
import { createHash, randomUUID } from 'node:crypto';

const url = process.env.O83_RECOVERY_SUPABASE_URL;
const serviceRoleKey = process.env.O83_RECOVERY_SERVICE_ROLE_KEY;
if (!url || !serviceRoleKey)
  throw new Error(
    'Local Storage recovery credentials were not supplied through process environment.',
  );

const client = createClient(url, serviceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});
const bucket = 'o83-memory-archive';
const objectKey = `00000000-0000-4000-8000-000000000001/recovery-validation/${randomUUID()}.txt`;
const bytes = new TextEncoder().encode(
  `O83 Storage recovery validation ${new Date().toISOString()}`,
);
const expectedDigest = createHash('sha256').update(bytes).digest('hex');

async function upload() {
  const { error } = await client.storage
    .from(bucket)
    .upload(objectKey, bytes, { contentType: 'text/plain', upsert: false });
  if (error) throw new Error(`Storage recovery upload failed: ${error.message}`);
}

async function verify() {
  const { data, error } = await client.storage.from(bucket).download(objectKey);
  if (error || !data)
    throw new Error(`Storage recovery download failed: ${error?.message ?? 'no object'}`);
  const observedDigest = createHash('sha256')
    .update(new Uint8Array(await data.arrayBuffer()))
    .digest('hex');
  if (observedDigest !== expectedDigest)
    throw new Error('Storage recovery digest verification failed.');
}

async function remove() {
  const { error } = await client.storage.from(bucket).remove([objectKey]);
  if (error) throw new Error(`Storage recovery cleanup failed: ${error.message}`);
}

try {
  await upload();
  await verify();
  await remove();
  await upload();
  await verify();
  console.log(`Private Storage recovery validation passed with SHA-256 ${expectedDigest}.`);
} finally {
  await client.storage.from(bucket).remove([objectKey]);
}
