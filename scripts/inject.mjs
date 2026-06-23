// Inject the bongle plugin + branding into a built Blockbench index.html.
// Idempotent: running twice does not duplicate the tags.
//
// Usage: node scripts/inject.mjs <path-to-index.html>

import { readFileSync, writeFileSync } from 'node:fs';

const target = process.argv[2];
if (!target) {
	console.error('usage: node scripts/inject.mjs <index.html>');
	process.exit(1);
}

const STYLE_TAG = '<link rel="stylesheet" href="bongle.css">';
// Classic (non-module) script; the plugin waits internally for the Blockbench
// bundle to define the plugin API before registering.
const SCRIPT_TAG = '<script src="bongle.js"></script>';

let html = readFileSync(target, 'utf8');

if (!html.includes(STYLE_TAG)) {
	html = html.replace('</head>', `\t${STYLE_TAG}\n</head>`);
}
if (!html.includes(SCRIPT_TAG)) {
	html = html.replace('</body>', `\t${SCRIPT_TAG}\n</body>`);
}

writeFileSync(target, html);
console.log(`injected bongle plugin + styles into ${target}`);
