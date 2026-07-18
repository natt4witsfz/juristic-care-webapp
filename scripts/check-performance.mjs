import { readdir, readFile, stat } from 'node:fs/promises';
import { join } from 'node:path';
import { gzipSync } from 'node:zlib';

const assetsDirectory = join(process.cwd(), 'frontend', 'dist', 'assets');
const files = await readdir(assetsDirectory);
const assets = await Promise.all(
  files.map(async (name) => {
    const path = join(assetsDirectory, name);
    const raw = (await stat(path)).size;
    const gzip = gzipSync(await readFile(path)).byteLength;
    return { name, raw, gzip };
  }),
);

const scripts = assets.filter((asset) => asset.name.endsWith('.js'));
const styles = assets.filter((asset) => asset.name.endsWith('.css'));
const totalScriptGzip = scripts.reduce((sum, asset) => sum + asset.gzip, 0);
const failures = [
  ...scripts
    .filter((asset) => asset.gzip > 220_000)
    .map(
      (asset) => `${asset.name} exceeds the 220 KB compressed chunk budget (${asset.gzip} bytes).`,
    ),
  ...styles
    .filter((asset) => asset.gzip > 80_000)
    .map(
      (asset) =>
        `${asset.name} exceeds the 80 KB compressed stylesheet budget (${asset.gzip} bytes).`,
    ),
  ...(totalScriptGzip > 700_000
    ? [`Total compressed JavaScript exceeds 700 KB (${totalScriptGzip} bytes).`]
    : []),
];

for (const asset of assets.sort((left, right) => right.gzip - left.gzip))
  console.log(`${asset.name}: ${asset.raw} raw bytes, ${asset.gzip} gzip bytes`);
if (failures.length) throw new Error(`Performance budget failed:\n${failures.join('\n')}`);
console.log(
  `Performance budget passed: ${scripts.length} route-split scripts, ${totalScriptGzip} total gzip bytes.`,
);
