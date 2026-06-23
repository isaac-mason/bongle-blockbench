#!/usr/bin/env bash
#
# Build the Bongle Blockbench static distribution.
#
#   1. Bundle the bongle plugin.
#   2. Build the upstream Blockbench web app (read-only submodule).
#   3. Assemble dist/: Blockbench runtime files + injected plugin + branding.
#
# Output: dist/  -> sync to S3, serve behind CloudFront.
#
# Blockbench's web build only emits blockbench/dist/bundle.js; the served site
# is the Blockbench directory itself (index.html references css/, assets/,
# dist/bundle.js, etc.), the way gh-pages deploys it. So we copy that tree.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BB="$ROOT/blockbench"
DIST="$ROOT/dist"

if [ ! -e "$BB/package.json" ]; then
	echo "error: blockbench submodule not initialised. Run: git submodule update --init --recursive" >&2
	exit 1
fi

echo "==> Bundling bongle plugin"
npm run build:plugin

echo "==> Building upstream Blockbench web app"
( cd "$BB" && npm ci && npm run build-web )

echo "==> Assembling dist/"
rm -rf "$DIST"
mkdir -p "$DIST"
# Copy the Blockbench runtime tree (skip VCS, deps, and the desktop/build tooling).
rsync -a \
	--exclude '.git' \
	--exclude 'node_modules' \
	--exclude 'electron' \
	--exclude 'types' \
	"$BB/" "$DIST/"

echo "==> Injecting bongle plugin + branding"
# bongle.js is the committed, self-contained plugin (starter embedded).
cp bongle.js "$DIST/bongle.js"
# overlay/ holds branding assets (bongle.css, favicon overrides, etc.).
[ -d "$ROOT/overlay" ] && cp -R "$ROOT/overlay/." "$DIST/"
node scripts/inject.mjs "$DIST/index.html"

echo "==> Done. Static site in $DIST"
echo "    Preview: npm run preview"
