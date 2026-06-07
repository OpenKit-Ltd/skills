# Contributing to OpenKit Skills

## Add a new skill

1. **Create the folder.** One folder per skill under `skills/`, named in `kebab-case`:

   ```bash
   mkdir -p skills/my-skill-name
   cp templates/SKILL.template.md skills/my-skill-name/SKILL.md
   ```

2. **Write the skill.** Edit `skills/my-skill-name/SKILL.md`:
   - `name:` must exactly match the folder name (lowercase, digits, hyphens, ≤64 chars).
   - `description:` is the most important line — it's all Claude sees at session start, so
     state clearly *what* the skill does and *when* to use it.
   - Optional supporting files (reference docs, `scripts/`, assets) live alongside `SKILL.md`.

3. **List it** in the "Available skills" table in `README.md`.

4. **Validate:**

   ```bash
   claude plugin validate .
   ```

5. **Test it live:**

   ```bash
   claude --plugin-dir .
   # inside the session:
   /openkit-tools:my-skill-name      # explicit invocation
   /reload-plugins                   # after edits, no restart needed
   ```

## Cut a release

This plugin uses an explicit version, so **users only receive updates when the version
changes.** On every meaningful change:

1. Bump `version` in `.claude-plugin/plugin.json` (semver).
2. Commit and push to `main`.
3. (Optional) Tag the release so you can pin to it later:

   ```bash
   claude plugin tag .        # creates an openkit-tools--v<version> git tag
   git push --tags
   ```

> **Alternative (lower maintenance):** delete the `version` field from `plugin.json`
> entirely. Claude Code then uses the git commit SHA as the version, so every push is
> automatically treated as a new release and you never have to remember to bump. Trade-off:
> users don't get nice semver numbers.

## Keep it installable both ways

- `npx skills add` discovers any `SKILL.md` under `skills/` — no extra config needed.
- `/plugin marketplace add` reads `.claude-plugin/marketplace.json` → `plugin.json` → `skills/`.

Don't move `skills/` out of the repo root, and don't put `skills/` inside `.claude-plugin/`
(only the two `*.json` manifests belong in `.claude-plugin/`).

## Style

- Write skill bodies as imperative instructions to the model, not human docs.
- Favour progressive disclosure: short `SKILL.md`, large material in sibling files that
  Claude reads on demand.
- No secrets, credentials, or surprising network calls in skills or scripts (see
  `SECURITY.md`).
