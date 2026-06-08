# OpenKit Skills

OpenKit's collection of [Agent Skills](https://agentskills.io) — reusable, model-invoked
capabilities built on the open `SKILL.md` standard, so they work across **Claude** (Code,
Cowork, claude.ai), **Codex / ChatGPT**, **Cursor**, **Gemini CLI**, **Copilot**, and any
other agent that reads `SKILL.md`.

> This repo is set up so the **same GitHub repo works for both** the cross-tool
> `npx skills` installer **and** the native Claude Code plugin marketplace. Pick whichever
> route your users prefer.

---

## ⬇️ Download the skills (no repo to clone, no sifting)

Clean, skills-only ZIPs — nothing else in them. These are the links to put on the website.

**All skills in one click** — `openkit-skills.zip`:

```
https://github.com/OpenKit-Ltd/skills/releases/latest/download/openkit-skills.zip
```

The bundle contains only the skill folders. Claude Code users can drop them straight in:

```bash
curl -L -o openkit-skills.zip \
  https://github.com/OpenKit-Ltd/skills/releases/latest/download/openkit-skills.zip
unzip openkit-skills.zip -d ~/.claude/skills/
```

**As one Claude Cowork plugin** — `openkit-tools-plugin.zip` (every skill bundled into a
single plugin; this is the file for Cowork's "upload a custom plugin file"):

```
https://github.com/OpenKit-Ltd/skills/releases/latest/download/openkit-tools-plugin.zip
```

**One skill at a time** — needed for **claude.ai web/desktop**, which accepts one skill per
upload:

| Skill | Direct download link |
| :---- | :------------------- |
| `hello-openkit` | `https://github.com/OpenKit-Ltd/skills/releases/latest/download/hello-openkit.zip` |

> These `releases/latest/download/…` URLs are **permanent** — they always serve the newest
> release, so hard-code them on the OpenKit site once and never touch them again. They go live
> as soon as you cut the first release (push a `v*` tag — CI builds the ZIPs and attaches
> them). See [CONTRIBUTING.md](./CONTRIBUTING.md#cut-a-release).

---

## Install

### Option 1 — `npx skills` (easiest, works across 30+ agents)

```bash
npx skills add OpenKit-Ltd/skills
```

No Claude session required, no restart — it drops the skills into the right place for
whichever agent you have installed. Add `-g` for a global (all-projects) install, or
`--list` to preview what's in the repo first.

### Option 2 — Claude Code plugin marketplace (versioned + auto-updating)

```text
/plugin marketplace add OpenKit-Ltd/skills
/plugin install openkit-tools@openkit
```

Then run a skill directly, e.g. `/openkit-tools:hello-openkit`. Update later with
`/plugin marketplace update openkit`.

### Option 3 — Claude.ai web & desktop (no CLI, no commands)

If you use Claude in the browser or desktop app, you don't run any commands — you
**upload a skill as a ZIP**. To make that one click, every release ships pre-built,
correctly-shaped ZIPs (the claude.ai uploader requires one ZIP per skill, with the skill
folder at the zip's root):

1. Open the [**Releases**](https://github.com/OpenKit-Ltd/skills/releases) page and
   download the ZIP for the skill you want (e.g. `hello-openkit.zip`).
2. In Claude, go to **Customize → Skills → `+` → Create skill → Upload a skill** and select
   the ZIP. (Requires code execution enabled; available on Free, Pro, Max, Team, Enterprise.)

**For teams (easiest of all):** on Team/Enterprise plans an org owner uploads each skill
once under **Organization settings → Skills**, and it appears automatically for every user —
no per-person upload needed.

### Option 4 — Claude Cowork (installs every skill at once)

Cowork installs **plugins** (bundles of skills), so a single install delivers the whole kit —
no picking skills one by one. Two ways:

- **Add marketplace from GitHub** (nothing to download): Cowork → **Customize → Plugins → `+`
  → Add marketplace** → enter `OpenKit-Ltd/skills` → install **openkit-tools**. Every
  skill becomes available immediately (type `/` in chat or Cowork to see them).
- **Upload the plugin file**: download `openkit-tools-plugin.zip` from
  [Releases](https://github.com/OpenKit-Ltd/skills/releases/latest) and use the **upload**
  option on the Plugins page.

**For teams:** an org owner can distribute the marketplace org-wide and mark the plugin as
*required* / *auto-installed*, so everyone gets all the skills with zero manual steps.

> Maintainers: rebuild every skill's ZIP locally with `bash scripts/build-skill-zips.sh`
> (outputs to `dist/`). CI does this automatically on each `v*` tag and attaches the ZIPs to
> the matching GitHub Release.

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
├── scripts/
│   └── build-skill-zips.sh  # builds one claude.ai-uploadable ZIP per skill -> dist/
├── .github/workflows/
│   └── release-skill-zips.yml  # CI: attach skill ZIPs to each GitHub Release
├── CONTRIBUTING.md          # how to add a skill + how to cut a release
├── SECURITY.md              # trust & safety notes for users
└── LICENSE
```

This one repo is a single source of truth for **every** agent: any `SKILL.md`-compatible
tool (**Codex / ChatGPT**, **Cursor**, **Gemini CLI**, **Copilot**, …) installs with
`npx skills add OpenKit-Ltd/skills`; **Claude Code** uses that or `/plugin`; **Claude Cowork**
adds the repo as a marketplace and installs the whole plugin (all skills) at once, or takes
the plugin file; and **claude.ai** web/desktop users download a per-skill ZIP and upload it
in the UI.

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

All install commands and download links assume this repo lives at
**`github.com/OpenKit-Ltd/skills`**. If you ever move it, find-and-replace `OpenKit-Ltd/skills`
in this README and in the `homepage`/`repository` fields of `plugin.json` and
`marketplace.json`.

---

## License

[MIT](./LICENSE) © OpenKit
