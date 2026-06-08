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

One link, skills only. Unzipping gives a **flat list of three `.md` files** — one per skill,
nothing to click through.

**Download — the link for the website:**

```
https://github.com/OpenKit-Ltd/skills/releases/latest/download/openkit-skills.zip
```

Unzip and you get, side by side:

```
build-user-context.md
inbox-triage.md
build-inbox-voice.md
```

In Claude's web/desktop app, add each one under **Customize → Skills** (start with
`build-user-context` — the other two build on it). For Claude Code, use `npx skills add` or
`/plugin` from the Install section below instead; those pull straight from the repo.

**Claude Cowork plugin file** — `openkit-tools-plugin.zip` installs all three as one plugin
via Cowork's "upload a custom plugin file":

```
https://github.com/OpenKit-Ltd/skills/releases/latest/download/openkit-tools-plugin.zip
```

> These `releases/latest/download/…` URLs are **permanent** — they always serve the newest
> release, so hard-code them on the OpenKit site once and never touch them again. A new
> release is cut whenever a `v*` tag is pushed (CI rebuilds these artifacts).
> See [CONTRIBUTING.md](./CONTRIBUTING.md#cut-a-release).

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

Then run a skill directly, e.g. `/openkit-tools:inbox-triage`. Update later with
`/plugin marketplace update openkit`.

### Option 3 — Claude web & desktop (no CLI, no commands)

No commands — you add each skill through the UI:

1. Download `openkit-skills.zip` (link at the top) and unzip it — you get three `.md` files
   (`build-user-context.md`, `inbox-triage.md`, `build-inbox-voice.md`).
2. In Claude, go to **Customize → Skills** and add each one. Start with `build-user-context`,
   since the other two build on it.

**For teams:** on Team/Enterprise plans an org owner can add the skills once under
**Organization settings → Skills** so they appear automatically for everyone.

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

> Maintainers: rebuild the download artifacts locally with `bash scripts/build-skill-zips.sh`
> (outputs to `dist/`). CI does this automatically on each `v*` tag and attaches them to the
> matching GitHub Release.

---

## Available skills

These three skills make up the **OpenKit Inbox** suite. Set them up in order — start with
`build-user-context`, which the other two depend on.

| Skill | What it does |
| :---- | :----------- |
| `build-user-context` | **Run first.** Interviews you and researches your email to generate your personalised `user-context` skill — who you are, who you work with, the projects that matter, and how you write. Prerequisite for the rest. |
| `inbox-triage` | Reads your inbox over a chosen window and returns a structured brief — **Urgent / Watching / Skip** — as colour-coded priority cards that expand on click. Read-only; never drafts or sends. Uses `user-context`. |
| `build-inbox-voice` | Analyses your sent/received threads to build an `inbox-reply-drafter` skill that writes replies in your voice. Uses `user-context`. |

> `build-user-context` and `build-inbox-voice` are *builders*: running them generates two
> further skills — `user-context` and `inbox-reply-drafter` — which you install the same way
> as any other skill.

---

## What's in here

```
skills/                       # repo root (github.com/OpenKit-Ltd/skills)
├── .claude-plugin/
│   ├── marketplace.json     # marketplace catalog (enables /plugin marketplace add)
│   └── plugin.json          # plugin manifest (this repo == one plugin: "openkit-tools")
├── skills/                  # one folder per skill, each with a SKILL.md
│   ├── build-user-context/
│   │   └── SKILL.md
│   ├── inbox-triage/
│   │   └── SKILL.md
│   └── build-inbox-voice/
│       └── SKILL.md
├── templates/
│   └── SKILL.template.md    # copy this to start a new skill
├── scripts/
│   └── build-skill-zips.sh  # builds the flat skills bundle + plugin package -> dist/
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
#   then inside the session: /openkit-tools:inbox-triage
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
