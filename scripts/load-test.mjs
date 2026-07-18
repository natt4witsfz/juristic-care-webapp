import { performance } from 'node:perf_hooks';
import { spawn } from 'node:child_process';

const target = process.env.O83_LOAD_TARGET ?? 'http://127.0.0.1:4173/';
const requests = Number(process.env.O83_LOAD_REQUESTS ?? 100);
const concurrency = Number(process.env.O83_LOAD_CONCURRENCY ?? 20);
const budgetMilliseconds = Number(process.env.O83_LOAD_P95_MS ?? 800);
const durations = [];
let failures = 0;
let cursor = 0;

const packageManagerScript = process.env.npm_execpath;
if (!process.env.O83_LOAD_TARGET && !packageManagerScript) {
  throw new Error('pnpm execution path is required to start the managed load target.');
}
const managedServer = process.env.O83_LOAD_TARGET
  ? null
  : spawn(
      process.execPath,
      [
        packageManagerScript,
        '--filter',
        '@o83/frontend',
        'exec',
        'vite',
        'preview',
        '--host',
        '127.0.0.1',
        '--port',
        '4173',
      ],
      { stdio: 'inherit' },
    );

async function waitForTarget() {
  for (let attempt = 0; attempt < 50; attempt++) {
    try {
      const response = await fetch(target);
      if (response.ok) return;
    } catch {
      // The preview process is still starting.
    }
    await new Promise((resolve) => setTimeout(resolve, 200));
  }
  throw new Error(`Load target did not become ready: ${target}`);
}

async function worker() {
  while (cursor < requests) {
    const index = cursor++;
    const started = performance.now();
    try {
      const response = await fetch(`${target}${target.includes('?') ? '&' : '?'}load=${index}`, {
        redirect: 'manual',
      });
      if (!response.ok) failures++;
      await response.arrayBuffer();
    } catch {
      failures++;
    }
    durations.push(performance.now() - started);
  }
}

try {
  await waitForTarget();
  await Promise.all(Array.from({ length: concurrency }, () => worker()));
  durations.sort((left, right) => left - right);
  const p95 = durations[Math.max(0, Math.ceil(durations.length * 0.95) - 1)] ?? Infinity;
  console.log(
    `Load validation: ${requests} requests, concurrency ${concurrency}, failures ${failures}, p95 ${p95.toFixed(1)} ms.`,
  );
  if (failures > 0 || p95 > budgetMilliseconds)
    throw new Error(
      `Load budget failed: failures=${failures}, p95=${p95.toFixed(1)}ms, budget=${budgetMilliseconds}ms.`,
    );
} finally {
  managedServer?.kill();
}
