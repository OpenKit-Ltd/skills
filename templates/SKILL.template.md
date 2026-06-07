---
name: my-skill-name
description: One or two sentences describing WHAT this skill does and WHEN Claude should use it. This is the only text loaded at session start, so make the trigger conditions explicit (e.g. "Use when the user is writing SQL migrations").
# --- Optional Claude Code extensions (ignored by other tools) ---
# disable-model-invocation: true   # only run when explicitly called as /openkit-tools:my-skill-name
# allowed-tools: Read, Grep, Glob  # restrict which tools this skill may use
---

# My Skill Name

Write the instructions Claude should follow when this skill activates. Be direct and
imperative — you're writing instructions for the model, not documentation for a human.

## Guidelines

- Keep the body focused; aim for under ~500 lines.
- Put large reference material in sibling files (e.g. `reference.md`) and tell Claude to
  read them only when needed — this keeps the context cost low (progressive disclosure).
- Bundle any helper scripts in a `scripts/` subfolder and reference them by relative path.

## Rules for the `name` field

- Lowercase letters, digits, and hyphens only; max 64 characters.
- Must exactly match the skill's folder name (`skills/my-skill-name/`).
