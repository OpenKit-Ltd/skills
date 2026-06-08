---
name: build-user-context
description: |
  Interviews the user and researches their email to produce a personalised
  `user-context` skill that captures who they are professionally, who they
  work with, what projects matter, and how they communicate. Run this skill
  first, before any other inbox skill. Trigger when the user says they want
  to set up the OpenKit inbox skills, build their user context, install the
  inbox assistant, get started with inbox triage, or any phrasing that
  indicates first-time setup of the inbox suite. Also trigger when the user
  says their context is stale, their role has changed, or they want to
  refresh the user-context skill. This skill is the prerequisite for
  build-inbox-voice and inbox-triage; both depend on the user-context skill
  that this one produces. Combines targeted multiple-choice questions with
  autonomous email research, then generates a single SKILL.md file the user
  installs as `user-context`.
---

# Build user context

You are setting up the foundation skill for the OpenKit inbox suite. Your
job is to produce a single high-quality `user-context` SKILL.md file that
captures who the user is at work, the people in their professional life,
the projects and themes that recur, and how they tend to communicate. Two
downstream skills (`build-inbox-voice` and `inbox-triage`) will read what
you produce. The quality of those skills depends on the quality of yours.

You will not get this perfect from email alone, and you will not get it
perfect from questions alone. The recipe is: ask a few targeted questions
to anchor the basics, then go and research email patterns thoroughly, then
return with findings and let the user confirm or correct. Then synthesise.

## Where this fits

The inbox suite is three skills designed to be installed and set up
together, in this order:

1. **build-user-context** (this skill). Captures who the user is, who
   they work with, and how they communicate. Produces the `user-context`
   skill that the other inbox skills read.
2. **build-inbox-voice**. Reads the user's email more deeply to learn
   their writing voice and produces a personalised
   `inbox-reply-drafter` skill.
3. **inbox-triage**. The daily-use skill. Produces a structured brief
   of what's urgent, what's worth watching, and what to skip.

This skill is step 1. The other two depend on the `user-context` you
produce here. When you finish, hand off explicitly to
`build-inbox-voice` as step 2, not as one of two options.

## Before you start

Check that an email MCP is connected. The skill works with any email
connector the user has available (Gmail, Outlook, Zoho, or any Anesi-style
Outlook MCP). If none is connected, call `search_mcp_registry` with terms
like `["email", "inbox", "gmail", "outlook"]` and use `suggest_connectors`
to offer the user the relevant ones. Do not proceed until at least one
email source is reachable.

If the user is running this in a session with no email MCP available and
does not want to connect one, you can still produce a context skill from
interview alone, but tell the user clearly that the result will be thinner
and that re-running once they have email connected will substantially
improve downstream skills.

## Phase 1: Anchor with multiple-choice questions

Open with three to five multiple-choice questions using
`ask_user_input_v0`. Keep them short and ask them one at a time, or in a
single call if they're independent. The aim is to anchor the research, not
exhaust the topic. Examples of the kinds of questions to ask:

- What's your role type? (Individual contributor / Team lead or manager /
  Senior leadership / Founder or owner / Other)
- What kind of organisation? (Startup / Scaleup / Large company /
  Professional services / Public sector / Other)
- How much of your work is external vs internal? (Mostly external clients
  or counterparties / Mostly internal team and stakeholders / Roughly
  balanced)
- What's the dominant communication style around you? (Formal and
  measured / Direct and brief / Warm and collegial / Mixed depending on
  audience)

Adapt these questions to what makes sense. You're trying to set baseline
expectations before reading email, so research doesn't get derailed by
unusual signals (a partner at a law firm and a designer at a startup both
send and receive emails; the same patterns mean different things).

Do not ask the user to enumerate their colleagues or projects at this
stage. You'll discover most of that from email, and asking up front turns
a 20-minute setup into a 45-minute slog.

## Phase 2: Autonomous email research

Now go and read. The goal is a structured understanding of the user's
working world, grounded in evidence.

Use whatever email MCP is connected. Different connectors have different
tool names but the same underlying actions: list messages in a date range,
read a message, read a thread. If you're not sure which tools you have,
call `tool_search` with terms like `["email search", "list emails",
"thread"]`.

Pull email from the last 90 days. You can go further if the user is in a
quiet role or has low email volume, but 90 days is usually the right
balance between recency and signal. Focus on sent items and threads the
user has engaged with (replied to at least once). Skip newsletters,
automated alerts, calendar invites, and CC-only threads where the user
never replied. Skip threads the user hasn't actively participated in.

For each thread you read, you're building up four kinds of evidence:

**People.** Who does the user actually correspond with? Build a list with:
sender/recipient email, name (best guess from headers and signatures),
frequency over the period, the direction of conversation (who initiates),
and any hints about their role (signatures, job titles, what they're
asking about). Don't speculate beyond what evidence supports. If you can't
tell whether someone is internal or external, note that you can't tell.

**Projects and themes.** What named projects, deals, products, accounts,
or initiatives recur? Look for proper nouns in subject lines and bodies
that appear across multiple threads. Note approximately when each one
first appears in the user's recent email and whether it still seems
active (recent activity vs gone quiet).

**Rhythms.** What does the user's working week look like through their
email? When are they most active? Are there standing meetings or weekly
deliverables visible from email? Do they handle inbound in real-time or
batch?

**Communication norms.** How does the user write? Formal vs casual, long
vs short, warm vs direct, signature style, salutation style, how they
handle delicate situations (chasing, declining, disagreeing). This is
intentionally lighter than what `build-inbox-voice` will do later; you're
capturing the high-level register, not the full voice. The downstream
voice skill will go deeper.

Aim to read enough to be confident in your findings without burning the
user's tokens. A few dozen substantial threads will usually suffice for a
clear picture. If you hit ambiguity, prefer reading another thread over
guessing.

While you research, keep a running scratchpad. You'll use it to brief the
user in phase 3.

## Phase 3: Confirm and fill gaps

Come back to the user with what you found. Don't dump raw data; present
it as a structured digest they can react to.

Show, for each of the four evidence buckets, what you observed and where
you have low confidence. Use `ask_user_input_v0` to confirm or correct
specific findings:

- "I see you correspond most with [X, Y, Z]. Are these your closest
  working relationships, or am I overweighting noisy ones?"
- "I see project names [A, B, C] recurring. Which are still active?"
  (multi-select)
- "[Person] seems to be your manager based on the patterns I see. Is that
  right?" (yes / no / other relationship)
- "How would you describe your default tone with external counterparties?"
  (multi-select among the patterns you observed)

Ask at most six to eight questions in this phase. The user has already
done one round of questions; this is the confirm-and-fill round, not a
second interrogation. Prioritise:

1. Things that will most affect downstream skill behaviour (who matters,
   what counts as urgent).
2. Things you're least confident about.
3. Things the user is likely to have strong opinions on.

Skip questions you're confident the email already answered well.

Also ask one open question at the end: "Anything else important about
your work that wouldn't show up in email? Direct reports who don't email
much, contractors, off-platform contacts, projects you're spinning up
that haven't hit your inbox yet."

## Phase 4: Generate the user-context skill

You now have everything you need. Write a single SKILL.md file at
`/mnt/user-data/outputs/user-context/SKILL.md`. The file is the entire
deliverable; do not create reference files or subdirectories.

The generated skill's frontmatter must be:

```yaml
---
name: user-context
description: |
  Reference skill containing the user's professional context: role,
  people they work with, projects, communication norms. Read by
  inbox-triage, build-inbox-voice, and inbox-reply-drafter. This skill
  is consulted explicitly by other skills via `view`; it should not be
  triggered directly by user prompts. If the user wants to update their
  context, they should re-run build-user-context or edit this file
  directly.
---
```

The triggering language in the description is deliberately weak. This
skill is a data file, not an actor.

Below the frontmatter, organise the content with these sections:

```markdown
# User context

_Generated by build-user-context on [DATE]. Snapshot in time; the user's
working world will change. Re-run build-user-context to refresh._

## Who the user is

A short paragraph: name (if known), role, organisation type, what they
broadly do day-to-day. Two to four sentences.

## People

A list of the user's significant correspondents. For each, in order of
significance:

- **Name** ([email]). Role/relationship, internal/external,
  approximate interaction frequency, one sentence on what they tend to
  discuss with the user.

Group by category where it helps (e.g. "Internal team", "Key external
counterparties", "Senior stakeholders").

If the user mentioned anyone in phase 3 who doesn't appear in email,
include them with a note: "(mentioned in setup, low email signal)".

## Projects and themes

The active projects, accounts, deals, or initiatives that recur. For
each:

- **[Name]**. What it is, status (active/winding down/new), who else
  is involved.

Include any themes that aren't named projects but recur (e.g. "Weekly
sales pipeline reviews", "Quarterly board reporting").

## Communication norms

Two or three short paragraphs covering:

- Default register (formal/direct/warm), with concrete examples observed.
- Common scenarios the user handles and how (chasing, declining,
  delegating, internal updates).
- Anything distinctive about the user's voice the downstream voice
  builder should know.

## How this skill should be used

A short closing note for other skills that read this one, explaining
that this is a snapshot, that some people and projects will become more
or less relevant over time, and that the user has the final word on what
matters.
```

Do not include speculation. If you're uncertain about something, either
omit it or mark it explicitly as low-confidence. The user will read this
file and downstream skills will rely on it; getting it wrong is worse
than leaving it sparse.

Keep the total file to roughly 200-400 lines of markdown. Long enough to
be useful, short enough that downstream skills can read it all at once
without burning context.

## Phase 5: Present, explain, and hand off to step 2

Once the file is written, use `present_files` to show the user
`/mnt/user-data/outputs/user-context/SKILL.md`. Then tell them three
things:

1. This file is their `user-context` skill. They install it like any
   other skill, in the same way they installed this one.
2. They can edit it freely. It's just a markdown file. If you got
   someone's role wrong or missed a project, they should fix it
   directly.
3. **Next step: install this file, then run `build-inbox-voice`.**
   That's step 2 of 3 in the setup chain. It reads their email more
   deeply to learn their writing voice and produces a personalised
   `inbox-reply-drafter` skill. Once that's done, they're set up to use
   `inbox-triage` for the daily inbox brief whenever they want it.

Don't offer `build-inbox-voice` and `inbox-triage` as a choice. They
are sequential, not alternatives: the voice-builder reads deeper email
patterns that triage doesn't need, and the resulting drafter makes the
day-to-day workflow much better. Send the user to `build-inbox-voice`
next.

**Bootstrap case.** If this run was triggered by another skill
(typically `inbox-triage` or `build-inbox-voice`) because
`user-context` was missing, say so explicitly in this final message:
"Once you've installed this, ask me to [triage your inbox / build your
inbox voice] again and I'll pick up where we left off." The user
should know the original request hasn't been forgotten.

Then end the run.

## Reflexes

**Evidence-first.** Every person, project, or pattern in the output
should be traceable to something you actually observed in email or
something the user confirmed. No inferring from one signal; no inventing
context to fill gaps.

**The user is the source of truth.** If the user corrects something you
observed in email, the correction wins. Don't argue with a user who says
"that person isn't my manager"; update and move on.

**Snapshot, not prophecy.** The skill you generate will go stale. Say so
in the generated file. Don't pretend the context is permanent.

**Generic, not bespoke.** This skill ships to anyone. Don't bake in
assumptions about industry, company, tooling, or workflow that wouldn't
generalise. If the user works in a niche, the generated `user-context`
will capture that, but `build-user-context` itself stays universal.

**No silent failures.** If you can't reach email, can't get past Phase
1, or run into something you can't handle, tell the user clearly. Don't
generate a context skill from thin air and pretend it's grounded.
