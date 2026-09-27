#!/usr/bin/env node
// Generates the skill's documentation and images from the library sources.
// The library folders are the single source of truth.
//
// Usage:
//   node scripts/sync-skill.mjs           regenerate the skill payload
//   node scripts/sync-skill.mjs --check   exit 1 if the payload is out of date

import { mkdir, readFile, readdir, rm, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const SKILL_DIR = path.join(ROOT, 'skills', 'gxw2-libraries');
const CHECK = process.argv.includes('--check');
const QUIET = process.argv.includes('--quiet');

// Library folder and its user documentation file.
const LIBRARIES = [
  { name: 'AlarmManager', doc: 'AlarmManager.md' },
  { name: 'ModbusDriver', doc: 'Modbus.md' },
  { name: 'TimeControl', doc: 'TimeControl.md' },
  { name: 'Utils', doc: 'Utils.md' },
];

// Include the old assets directory in stale-file checks so it is removed on sync.
const GENERATED_DIRS = ['references', 'assets'];

/** Rewrites documentation image links to the per-library image folder. */
function rewriteImageLinks(text, library) {
  return text.replace(/\(\.\/img\//g, `(./img/${library}/`);
}

async function listFiles(dir) {
  const entries = await readdir(dir, { withFileTypes: true }).catch(() => []);
  const files = [];
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      for (const nested of await listFiles(full)) files.push(path.join(entry.name, nested));
    } else {
      files.push(entry.name);
    }
  }
  return files;
}

async function buildPlan() {
  const plan = [];
  for (const { name, doc } of LIBRARIES) {
    const libDir = path.join(ROOT, 'libraries', name);
    if (!(await stat(libDir).catch(() => null))) {
      throw new Error(`Missing library folder: libraries/${name}`);
    }

    const docSrc = path.join(libDir, doc);
    const docText = await readFile(docSrc, 'utf8').catch(() => {
      throw new Error(`Missing documentation file: libraries/${name}/${doc}`);
    });
    plan.push({
      source: `libraries/${name}/${doc}`,
      target: `references/${name}.md`,
      content: Buffer.from(rewriteImageLinks(docText, name), 'utf8'),
    });

    const imgDir = path.join(libDir, 'img');
    for (const image of await listFiles(imgDir)) {
      plan.push({
        source: `libraries/${name}/img/${image}`,
        target: `references/img/${name}/${image}`,
        content: await readFile(path.join(imgDir, image)),
      });
    }
  }
  return plan;
}

async function main() {
  const plan = await buildPlan();
  const expected = new Set(plan.map((entry) => entry.target));
  const changed = [];
  const missing = [];

  for (const entry of plan) {
    const target = path.join(SKILL_DIR, entry.target);
    const current = await readFile(target).catch(() => null);
    if (!current) missing.push(entry.target);
    else if (!current.equals(entry.content)) changed.push(entry.target);
  }

  const stale = [];
  for (const dir of GENERATED_DIRS) {
    for (const file of await listFiles(path.join(SKILL_DIR, dir))) {
      const rel = `${dir}/${file.split(path.sep).join('/')}`;
      if (!expected.has(rel)) stale.push(rel);
    }
  }

  if (CHECK) {
    for (const file of missing) console.error(`missing   ${file}`);
    for (const file of changed) console.error(`outdated  ${file}`);
    for (const file of stale) console.error(`stale     ${file}`);
    if (missing.length || changed.length || stale.length) {
      console.error('\nSkill payload is out of date. Run: npm run sync-skill');
      process.exit(1);
    }
    console.log(`Skill payload is up to date (${plan.length} files).`);
    return;
  }

  for (const dir of GENERATED_DIRS) {
    await rm(path.join(SKILL_DIR, dir), { recursive: true, force: true });
  }
  for (const entry of plan) {
    const target = path.join(SKILL_DIR, entry.target);
    await mkdir(path.dirname(target), { recursive: true });
    await writeFile(target, entry.content);
  }
  if (!QUIET) {
    console.log(
      `Skill payload synced: ${plan.length} files written, ` +
        `${changed.length} updated, ${missing.length} created, ${stale.length} removed.`,
    );
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
