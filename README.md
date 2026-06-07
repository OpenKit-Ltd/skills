# OpenKit Skills

OpenKit's official collection of [Claude Agent Skills](https://agentskills.io) — reusable,
model-invoked capabilities for Claude Code, Claude.ai, and any tool that supports the open
`SKILL.md` standard (Cursor, Codex, Gemini CLI, Copilot, and more).

> This repo is set up so the **same GitHub repo works for both** the cross-tool
> `npx skills` installer **and** the native Claude Code plugin marketplace. Pick whichever
> route your users prefer.

---

## Install

### Option 1 — `npx skills` (easiest, works across 30+ agents)

```bash
npx skills add openkit/claude-plugins
```

No Claude session required, no restart — it drops the skills into the right place for
whichever agent you have installed. Add `-g` for a global (all-projects) install, or
`--list` to preview what's in the repo first.

### Option 2 — Claude Code plugin marketplace (versioned + auto-updating)

```text
/plugin marketplace add openkit/claude-plugins
/plugin install openkit-tools@openkit
```

Then run a skill directly, e.g. `/openkit-tools:hello-openkit`. Update later with
`/plugin marketplace update openkit`.

---

## Available skills

| Skill | What it does |
| :---- | :----------- |
| `hello-openkit` | Starter skill — introduces the collection and how to use it. _(placeholder; replace with real skills)_ |

_(This table is the front door for users — keep it updated as skills are added.)_

---

## What's in here

```
claude-plugins/
├── .claude-plugin/
│   ├── marketplace.json     # marketplace catalog (enables /plugin marketplace add)
│   └── plugin.json          # plugin manifest (this repo == one plugin: "openkit-tools")
├── skills/                  # one folder per skill, each with a SKILL.md
│   └── hello-openkit/
│       └── SKILL.md
├── templates/
│   └── SKILL.template.md    # copy this to start a new skill
├── CONTRIBUTING.md          # how to add a skill + how to cut a release
├── SECURITY.md              # trust & safety notes for users
└── LICENSE
```

The repo root doubles as both the **marketplace** and a single **plugin**
(`openkit-tools`), so all skills live in the top-level `skills/` directory.

---

## Develop & test locally

```bash
# Validate the marketplace + plugin manifests and skill frontmatter
claude plugin validate .

# Load the plugin into a throwaway Claude Code session without installing it
claude --plugin-dir .
#   then inside the session: /openkit-tools:hello-openkit
#   after edits:             /reload-plugins
```

---

## Adding your own skill

See [CONTRIBUTING.md](./CONTRIBUTING.md). Short version: copy `templates/SKILL.template.md`
to `skills/<your-skill-name>/SKILL.md`, fill in the frontmatter, add a row to the table
above, and bump the version in `.claude-plugin/plugin.json`.

---

## A note on the repo name

All install commands above assume this repo lives at **`github.com/openkit/claude-plugins`**.
If you push it somewhere else (e.g. `openkit/skills`), find-and-replace `openkit/claude-plugins`
in this README and in the `homepage`/`repository` fields of `plugin.json` and
`marketplace.json`.

---

## License

[MIT](./LICENSE) © OpenKit
