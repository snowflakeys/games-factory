#!/usr/bin/env bash
# Build a Rojo project and upload it as a place version via Roblox Open Cloud.
# Usage: VERSION_TYPE=Saved scripts/publish-place.sh games/game-NNN
# Env:   ROBLOX_API_KEY, UNIVERSE_ID, PLACE_ID  (never commit these)
# Default VERSION_TYPE is Saved (stored, NOT live). Use Published only on owner instruction.
# Untested against the live API: first run with Saved and check the version in Studio.
set -euo pipefail

PROJECT_DIR="${1:?usage: publish-place.sh <project-dir>}"
: "${ROBLOX_API_KEY:?set ROBLOX_API_KEY}"
: "${UNIVERSE_ID:?set UNIVERSE_ID}"
: "${PLACE_ID:?set PLACE_ID}"
VERSION_TYPE="${VERSION_TYPE:-Saved}"

case "$VERSION_TYPE" in
  Saved|Published) ;;
  *) echo "VERSION_TYPE must be Saved or Published" >&2; exit 2 ;;
esac

mkdir -p "$PROJECT_DIR/build"
OUT="$PROJECT_DIR/build/game.rbxl"

rojo build "$PROJECT_DIR/default.project.json" -o "$OUT"

echo "Uploading $OUT as $VERSION_TYPE to universe $UNIVERSE_ID place $PLACE_ID ..."
curl --fail-with-body --silent --show-error -X POST \
  "https://apis.roblox.com/universes/v1/${UNIVERSE_ID}/places/${PLACE_ID}/versions?versionType=${VERSION_TYPE}" \
  -H "x-api-key: ${ROBLOX_API_KEY}" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"$OUT"
echo
echo "Done. A JSON body like {\"versionNumber\":N} means success; record N in factory-state/planning-reference.md."
