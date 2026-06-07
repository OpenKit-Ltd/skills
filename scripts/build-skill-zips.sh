#!/usr/bin/env bash
#
# Build downloadable, noise-free ZIPs into dist/ — no README, license, scripts, or repo
# scaffolding. Three kinds of artifact are produced:
#
#   1. dist/<skill-name>.zip        One ZIP per skill, skill folder at the zip root
#                                   (e.g. hello-openkit/SKILL.md). Required shape for the
#                                   claude.ai "Upload a skill" flow (one skill per upload).
#
#   2. dist/openkit-skills.zip      Bundle of every skill folder at the zip root. The clean
#                                   "give me all the skills in one click" download. Drop into
#                                   Claude Code:  unzip openkit-skills.zip -d ~/.claude/skills/
#
#   3. dist/openkit-tools-plugin.zip  The whole thing as ONE plugin (plugin manifest + all
#                                   skills). This is the file for Claude Cowork's
#                                   "upload a custom plugin file" path — installing it makes
#                                   every skill available at once.
#
# Usage:  bash scripts/build-skill-zips.sh
# Output: dist/*.zip  (gitignored; published to GitHub Releases by CI)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
DIST_DIR="$ROOT/dist"
BUNDLE_NAME="openkit-skills.zip"
PLUGIN_NAME="openkit-tools-plugin.zip"

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

# 1. One ZIP per skill (claude.ai per-skill upload)
for name in "${names[@]}"; do
  ( cd "$SKILLS_DIR" && zip -r -q -X "$DIST_DIR/$name.zip" "$name" -x '*.DS_Store' )
  echo "built:  dist/$name.zip"
done

# 2. Bundle of all skills (clean website "all skills" download)
( cd "$SKILLS_DIR" && zip -r -q -X "$DIST_DIR/$BUNDLE_NAME" "${names[@]}" -x '*.DS_Store' )
echo "built:  dist/$BUNDLE_NAME  (${#names[@]} skill(s))"

# 3. Plugin package (Cowork "upload a custom plugin file" — all skills as one plugin)
( cd "$ROOT" && zip -r -q -X "$DIST_DIR/$PLUGIN_NAME" .claude-plugin/plugin.json skills -x '*.DS_Store' )
echo "built:  dist/$PLUGIN_NAME  (plugin: openkit-tools)"

echo "Done — ${#names[@]} skill(s): per-skill ZIPs + skills bundle + plugin package in dist/"
