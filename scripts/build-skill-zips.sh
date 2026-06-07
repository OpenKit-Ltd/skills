#!/usr/bin/env bash
#
# Build one Claude.ai-uploadable ZIP per skill into dist/.
#
# claude.ai (web & desktop) installs skills by ZIP upload, and the ZIP must contain
# the skill's FOLDER at its root (e.g. hello-openkit/SKILL.md), not the bare files and
# not the repo's skills/ prefix. This script produces exactly that, one zip per skill.
#
# Usage:  bash scripts/build-skill-zips.sh
# Output: dist/<skill-name>.zip  (gitignored; published to GitHub Releases by CI)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
DIST_DIR="$ROOT/dist"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

count=0
for dir in "$SKILLS_DIR"/*/; do
  name="$(basename "$dir")"
  if [[ ! -f "$dir/SKILL.md" ]]; then
    echo "skip:  $name (no SKILL.md)"
    continue
  fi
  # cd into skills/ so the archived path is "<name>/..." (folder at zip root)
  ( cd "$SKILLS_DIR" && zip -r -q -X "$DIST_DIR/$name.zip" "$name" -x '*.DS_Store' )
  echo "built: dist/$name.zip"
  count=$((count + 1))
done

echo "Done — built $count skill ZIP(s) in dist/"
