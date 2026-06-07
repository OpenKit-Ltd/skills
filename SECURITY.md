# Security & Trust

Agent skills can include scripts and instructions that run with whatever access the agent
has. That makes trust a first-class concern — both for us as publishers and for the people
installing these skills. Roughly a third of third-party skills audited in 2026 contained at
least one security issue, so a clean, transparent repo is how OpenKit earns trust.

## Our commitments

- **Open source.** Every skill in this repo is auditable — read `SKILL.md` and any bundled
  scripts before you install.
- **No secrets.** Skills and scripts never contain credentials, API keys, or tokens.
- **No surprising network calls.** Skills don't phone home or fetch remote code at runtime.
  Any external request a skill makes is documented in that skill's `SKILL.md`.
- **Least privilege.** Where a skill only needs read access, it declares `allowed-tools`
  accordingly.

## For people installing these skills

- Prefer installing specific skills you need rather than everything at once.
- Skim the `SKILL.md` (and any `scripts/`) for anything that doesn't match the stated
  purpose — unexpected file access, shell commands, or outbound URLs.
- Pin to a tag/commit if you need a known-good version (`/plugin marketplace add ...@<ref>`).

## Reporting a vulnerability

Found something concerning in this repo? Email **reuben@openkit.co.uk** with details.
Please don't open a public issue for security reports.
