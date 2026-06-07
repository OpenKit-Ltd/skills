#!/usr/bin/env bash
#
# Build downloadable, skills-ONLY ZIPs into dist/ — no README, license, scripts, or repo
# noise. Two kinds of artifact are produced:
#
#   1. dist/<skill-name>.zip   One ZIP per skill, with the skill folder at the zip root
#                              (e.g. hello-openkit/SKILL.md). This is the shape the
#                              claude.ai "Upload a skill" flow requires (one skill per upload).
#
#   2. dist/openkit-skills.zip A single bundle of every skill folder at the zip root. This is
#                              the clean "give me all the skills in one click" download for a
#                              website link. Drop straight into Claude Code:
#                                  unzip openkit-skills.zip -d ~/.claude/skills/
#
# Usage:  bash scripts/build-skill-zips.sh
# Output: dist/*.zip  (gitignored; published to GitHub Releases by CI)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
DIST_DIR="$ROOT/dist"
BUNDLE_NAME="openkit-skills.zip"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Collect skill folder names that actually contain a SKILL.md
names=()
for dir in "$SKILLS_DIR"/*/; do
  name="$(basename "$dir")"
  if [[ -f "$dir/SKILL.md" ]]; then
    names+=("$name")
  else
    echo "skip:   $name (no SKILL.md)"
  fi
done

if [[ ${#names[@]} -eq 0 ]]; then
  echo "No skills found in $SKILLS_DIR — nothing to build."
  exit 1
fi

# 1. One ZIP per skill (for claude.ai per-skill upload)
for name in "${names[@]}"; do
  ( cd "$SKILLS_DIR" && zip -r -q -X "$DIST_DIR/$name.zip" "$name" -x '*.DS_Store' )
  echo "built:  dist/$name.zip"
done

# 2. One bundle ZIP of all skills (for the clean website download link)
( cd "$SKILLS_DIR" && zip -r -q -X "$DIST_DIR/$BUNDLE_NAME" "${names[@]}" -x '*.DS_Store' )
echo "built:  dist/$BUNDLE_NAME  (${#names[@]} skill(s))"

echo "Done — ${#names[@]} skill(s): ${#names[@]} per-skill ZIP(s) + 1 bundle in dist/"
