#!/usr/bin/env bash
#
# Build the downloadable release artifacts into dist/. Two files:
#
#   1. dist/openkit-skills.zip       The main download. Unzips to a FLAT list of one
#                                    <skill-name>.md file per skill — no nested folders to
#                                    click through. Each .md is the skill's full SKILL.md
#                                    content (with its name/description frontmatter), so you
#                                    can drag an individual file into Claude's web/desktop UI.
#
#   2. dist/openkit-tools-plugin.zip The whole kit as ONE plugin (plugin manifest + all skill
#                                    folders). For Claude Cowork's "upload a custom plugin
#                                    file" path — installs every skill at once.
#
# Note: the flat bundle assumes each skill is a single SKILL.md with no supporting files
# (scripts/, references/, assets/). If a skill gains supporting files, it can't ship as a
# single flat .md — give that skill its own folder-based zip instead.
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

# 1. Flat markdown bundle: one <skill-name>.md per skill, no subfolders
stage="$(mktemp -d)"
for name in "${names[@]}"; do
  cp "$SKILLS_DIR/$name/SKILL.md" "$stage/$name.md"
done
( cd "$stage" && zip -q -X "$DIST_DIR/$BUNDLE_NAME" ./*.md )
rm -rf "$stage"
echo "built:  dist/$BUNDLE_NAME  (${#names[@]} flat .md file(s): ${names[*]})"

# 2. Plugin package (Cowork "upload a custom plugin file" — all skills as one plugin)
( cd "$ROOT" && zip -r -q -X "$DIST_DIR/$PLUGIN_NAME" .claude-plugin/plugin.json skills -x '*.DS_Store' )
echo "built:  dist/$PLUGIN_NAME  (plugin: openkit-tools)"

echo "Done — flat skills bundle + plugin package in dist/"
