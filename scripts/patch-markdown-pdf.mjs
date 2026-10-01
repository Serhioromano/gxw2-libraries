#!/usr/bin/env node
/**
 * Patch the installed `yzane.markdown-pdf` VS Code extension so that
 * ```iecst fences (IEC 61131-3 Structured Text) are syntax highlighted in
 * exported PDF / PNG / JPEG files.
 *
 * Why: markdown-pdf highlights code with highlight.js v11, which ships no
 * Structured Text language. Unknown languages are emitted as plain escaped
 * text, so every ```iecst block in the library manuals ended up black & white.
 *
 * What it does:
 *   1. copies scripts/vendor/hljs-iecst.js into <extension>/dist/hljs-iecst.js
 *   2. inserts a guarded `hljs.registerLanguage("iecst", require("./hljs-iecst.js"))`
 *      at the top of buildHighlightCallback() in <extension>/dist/extension.js
 *   3. keeps a one-time backup as dist/extension.js.orig and validates the
 *      patched bundle with `node --check`
 *
 * The patch is idempotent and must be re-applied after every markdown-pdf
 * update (VS Code replaces the extension folder).
 *
 * Usage:
 *   node scripts/patch-markdown-pdf.mjs            # patch every installation found
 *   node scripts/patch-markdown-pdf.mjs --check    # report status only
 *   node scripts/patch-markdown-pdf.mjs --revert   # restore dist/extension.js.orig
 */

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const GRAMMAR_SRC = path.join(__dirname, 'vendor', 'hljs-iecst.js');
const GRAMMAR_NAME = 'hljs-iecst.js';
const BUNDLE = 'extension.js';
const BACKUP = 'extension.js.orig';
const MARKER = 'markdown-pdf-st-patch';

const ANCHOR = 'function buildHighlightCallback(hljs, escapeHtml3) {\n';
const INJECTION = [
  '  // ' + MARKER + ': register IEC 61131-3 Structured Text for ```iecst fences',
  '  try {',
  '    if (hljs && typeof hljs.registerLanguage === "function" && !hljs.getLanguage("iecst")) {',
  '      hljs.registerLanguage("iecst", require("./' + GRAMMAR_NAME + '"));',
  '    }',
  '  } catch (error) {',
  '  }',
  '',
].join('\n');

const args = process.argv.slice(2);
const mode = args.includes('--revert') ? 'revert' : args.includes('--check') ? 'check' : 'patch';

/** Candidate extension roots, Windows (via /mnt or native) and Linux/WSL. */
function extensionRoots() {
  const home = os.homedir();
  const roots = [
    path.join(home, '.vscode', 'extensions'),
    path.join(home, '.vscode-server', 'extensions'),
    path.join(home, '.vscode-server-insiders', 'extensions'),
    path.join(home, '.vscode-insiders', 'extensions'),
  ];
  const appData = process.env.APPDATA;
  if (appData) roots.push(path.join(appData, 'Code', 'extensions'));
  if (process.platform === 'win32') {
    if (appData) roots.push(path.join(appData, 'Code - Insiders', 'extensions'));
  } else {
    // Linux/WSL: look at the Windows profile as well (/mnt/c/Users/<user>)
    for (const userDir of safeReadDir('/mnt/c/Users')) {
      for (const [base, sub] of [
        ['AppData/Roaming/Code', 'extensions'],
        ['AppData/Roaming/Code - Insiders', 'extensions'],
        ['.vscode', 'extensions'],
      ]) {
        roots.push(path.join('/mnt/c/Users', userDir, base, sub));
      }
    }
  }
  return [...new Set(roots.map((r) => path.resolve(r)))];
}

function safeReadDir(dir) {
  try {
    return fs.readdirSync(dir);
  } catch {
    return [];
  }
}

function findInstallations() {
  const found = [];
  for (const root of extensionRoots()) {
    for (const name of safeReadDir(root)) {
      if (!/^yzane\.markdown-pdf-/.test(name)) continue;
      const dir = path.join(root, name);
      if (fs.existsSync(path.join(dir, 'dist', BUNDLE))) found.push(dir);
    }
  }
  return found;
}

function statusOf(dir) {
  const bundle = fs.readFileSync(path.join(dir, 'dist', BUNDLE), 'utf8');
  const hasGrammar = fs.existsSync(path.join(dir, 'dist', GRAMMAR_NAME));
  return { patched: bundle.includes(MARKER), hasGrammar };
}

function patch(dir) {
  const dist = path.join(dir, 'dist');
  const bundlePath = path.join(dist, BUNDLE);
  const backupPath = path.join(dist, BACKUP);
  const grammarPath = path.join(dist, GRAMMAR_NAME);
  const bundle = fs.readFileSync(bundlePath, 'utf8');

  if (bundle.includes(MARKER)) {
    if (!fs.existsSync(grammarPath)) {
      fs.copyFileSync(GRAMMAR_SRC, grammarPath);
      return 'already patched, restored missing ' + GRAMMAR_NAME;
    }
    return 'already patched';
  }
  if (!bundle.includes(ANCHOR)) {
    return 'SKIPPED: anchor not found (unsupported markdown-pdf version) — check the bundle structure';
  }

  if (!fs.existsSync(backupPath)) fs.copyFileSync(bundlePath, backupPath);
  fs.copyFileSync(GRAMMAR_SRC, grammarPath);
  fs.writeFileSync(bundlePath, bundle.replace(ANCHOR, ANCHOR + INJECTION));

  try {
    execFileSync(process.execPath, ['--check', bundlePath], { stdio: 'pipe' });
  } catch (error) {
    fs.copyFileSync(backupPath, bundlePath);
    return 'FAILED: patched bundle is not valid JS (' + String(error.message).split('\n')[0] + ') — rolled back';
  }
  return 'patched (backup: dist/' + BACKUP + ')';
}

function revert(dir) {
  const dist = path.join(dir, 'dist');
  const bundlePath = path.join(dist, BUNDLE);
  const backupPath = path.join(dist, BACKUP);
  if (!fs.existsSync(backupPath)) return 'nothing to revert (no ' + BACKUP + ')';
  fs.copyFileSync(backupPath, bundlePath);
  fs.rmSync(path.join(dist, GRAMMAR_NAME), { force: true });
  return 'reverted from dist/' + BACKUP;
}

const installations = findInstallations();
if (installations.length === 0) {
  console.log('No yzane.markdown-pdf installation found. Searched:');
  for (const root of extensionRoots()) console.log('  ' + root);
  process.exitCode = 1;
} else {
  for (const dir of installations) {
    const { patched, hasGrammar } = statusOf(dir);
    const state = patched ? 'patched' : 'not patched';
    const grammar = hasGrammar ? 'grammar present' : 'grammar missing';
    let result;
    if (mode === 'check') result = state + ', ' + grammar;
    else if (mode === 'revert') result = revert(dir);
    else result = patch(dir);
    console.log('- ' + dir);
    console.log('  ' + result);
  }
  if (mode === 'patch') {
    console.log('\nRestart VS Code (or reload the window) and export a document with ```iecst blocks.');
    console.log('Re-run this script after every markdown-pdf update.');
  }
}
