#!/usr/bin/env node
/**
 * validate-readme.js — Flutter / pubspec.yaml
 *
 * Vérifie que chaque package listé dans pubspec.yaml est documenté
 * dans la section <!-- STACK:START --> ... <!-- STACK:END --> du README.md.
 *
 * Utilisation :
 *   node scripts/validate-readme.js
 *
 * Retourne 0 si OK, 1 si des packages manquent dans le README.
 */

const fs = require('fs');
const path = require('path');

// Packages SDK Flutter — exclus de la validation (pas des packages pub.dev)
const SKIP = new Set(['flutter', 'flutter_test', 'dart']);

/**
 * Parse pubspec.yaml et retourne l'ensemble des noms de packages
 * listés dans `dependencies` et `dev_dependencies` (hors SDK Flutter).
 */
function parsePubspecPackages() {
  const pubspecPath = path.resolve('pubspec.yaml');
  if (!fs.existsSync(pubspecPath)) {
    console.error('❌  pubspec.yaml introuvable dans le répertoire courant.');
    process.exit(1);
  }

  const content = fs.readFileSync(pubspecPath, 'utf8');
  const lines = content.split('\n');
  const packages = new Set();
  let section = null; // 'deps' | 'devdeps' | null

  for (const line of lines) {
    // Détecter les sections de niveau 0
    if (/^dependencies:\s*$/.test(line)) { section = 'deps'; continue; }
    if (/^dev_dependencies:\s*$/.test(line)) { section = 'devdeps'; continue; }

    // Toute autre clé de niveau 0 sort des sections deps
    if (/^\S/.test(line)) { section = null; continue; }

    // Dans une section deps : lignes avec 2 espaces d'indentation = package
    if (section && /^  [a-zA-Z0-9_]/.test(line)) {
      const m = line.match(/^  ([a-zA-Z0-9_]+):/);
      if (m && !SKIP.has(m[1])) {
        packages.add(m[1]);
      }
    }
  }

  return packages;
}

/**
 * Parse le README.md et retourne l'ensemble des noms de modules
 * documentés dans la section <!-- STACK:START --> ... <!-- STACK:END -->.
 */
function parseReadmeStack() {
  const readmePath = path.resolve('README.md');
  if (!fs.existsSync(readmePath)) {
    console.error('❌  README.md introuvable dans le répertoire courant.');
    process.exit(1);
  }

  const content = fs.readFileSync(readmePath, 'utf8');
  const match = content.match(/<!-- STACK:START -->([\s\S]*?)<!-- STACK:END -->/);
  if (!match) {
    console.error('❌  Section <!-- STACK:START --> ... <!-- STACK:END --> introuvable dans README.md.');
    console.error('    Ajoutez cette section avec un tableau Markdown listant les packages.');
    process.exit(1);
  }

  const documented = new Set();
  const lines = match[1].split('\n');
  for (const line of lines) {
    // Première colonne du tableau markdown : | package_name | ...
    const m = line.match(/^\|\s*`?([a-zA-Z0-9_]+)`?\s*\|/);
    if (m && m[1] !== 'Module') {
      documented.add(m[1]);
    }
  }

  return documented;
}

// ── Main ──────────────────────────────────────────────────────────────────────

const packages = parsePubspecPackages();
const documented = parseReadmeStack();

const missing = [...packages].filter(pkg => !documented.has(pkg));

if (missing.length === 0) {
  console.log(`✅  Tous les packages pubspec.yaml sont documentés dans README.md (${packages.size} packages).`);
  process.exit(0);
} else {
  console.error(`❌  ${missing.length} package(s) non documenté(s) dans README.md :\n`);
  for (const pkg of missing) {
    console.error(`  | ${pkg} | x.x | Type | Description |`);
  }
  console.error('\nAjoutez ces lignes dans la section <!-- STACK:START --> ... <!-- STACK:END --> du README.md.');
  process.exit(1);
}
