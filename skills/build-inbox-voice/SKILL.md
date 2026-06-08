---
name: build-inbox-voice
description: |
  Analyses the user's email history to build a personalised
  `inbox-reply-drafter` skill that writes replies in their voice. Reads
  full email threads (sent and received together) so it understands not
  just tone but how the user responds to different kinds of incoming
  email. Reads `user-context` before doing anything; bootstraps
  `build-user-context` first if not installed. Trigger when the user
  asks to build their inbox voice, set up their reply drafter, train
  Claude on how they write emails, or refresh a stale drafter. Also
  trigger when the user says their existing drafter sounds wrong or
  out of date. Also trigger when the user asks to draft or reply to an
  email and no `inbox-reply-drafter` is installed; offer to build the
  drafter or produce a one-off draft. Prompts for analysis depth (Quick
  / Standard / Thorough), reads and synthesises, then generates a
  single-file SKILL.md the user installs as `inbox-reply-drafter`.
---

# Build inbox voice

You are generating a personalised reply-drafter skill for the user. The
output is a single SKILL.md file that, once installed, will draft email
replies that sound like them and that handle the kinds of situations
they actually encounter.

The quality of the generated skill depends entirely on how well you read
the user's existing email. You're not just capturing tone; you're
capturing how they handle the recurring scenarios in their working life:
how they chase, how they decline, how they update colleagues, how they
respond to a tricky ask. Read enough to see patterns, not just samples.

## Where this fits

The inbox suite is three skills installed and set up in sequence:

1. **build-user-context**. Captures who the user is, who they work
   with, and how they communicate. Produces `user-context`.
2. **build-inbox-voice** (this skill). Reads email patterns to learn
   the user's writing voice and produces `inbox-reply-drafter`.
3. **inbox-triage**. The daily-use skill. Produces an inbox brief.

This skill is step 2. It depends on `user-context` from step 1, and
it enables the on-demand reply drafting that complements step 3.

## Before you start

**Detect how you were triggered.** There are two paths:

- *Standard path.* The user asked to build their inbox voice, set up
  their drafter, refresh a stale drafter, or similar. Proceed through
  all phases normally.
- *Draft-an-email path.* The user asked to draft or reply to an email
  but no `inbox-reply-drafter` is installed. Before doing anything
  else, ask via `ask_user_input_v0`: "I don't see a personalised
  drafter installed yet. Want me to (a) build one now from your email
  patterns (10-15 minutes, you'll have a permanent drafter
  afterwards), or (b) do a one-off generic draft for this email now
  and you can build the voice skill later?"
    - If they choose (a), proceed through all phases. After Phase 5,
      remind them of the email they originally wanted to draft so they
      can ask again with the freshly installed drafter.
    - If they choose (b), skip the full build. Read the email they
      referenced, read `user-context` if available (bootstrap it only
      if the user explicitly wants to; otherwise proceed without),
      draft a reply, present it, and end the run. Tell them they can
      run `build-inbox-voice` properly any time.

**Read the `user-context` skill.** Non-negotiable for the standard
path. Locate and `view` the file at the user-context skill's SKILL.md
path. Read it fully.

If `user-context` is not installed, **bootstrap it first**. Tell the
user: "I need to set up your user context before I can build the
voice skill. That's a 15-20 minute one-time setup. Running it now,
then we'll come back to the voice build." Then read
`build-user-context`'s SKILL.md and follow it through to the end.
Once the user has installed the generated `user-context` skill, they
can re-invoke `build-inbox-voice` and you'll pick up from here. Do
not try to build voice without `user-context`.

**Check the email MCP is connected.** Same as `build-user-context`. If
no email connector is available, call `search_mcp_registry` and
`suggest_connectors`. Without email access this skill cannot produce a
useful output; tell the user clearly and stop.

## Phase 1: Choose depth

Ask the user how deep to go using `ask_user_input_v0`. Three options:

- **Quick** (around 50 threads, roughly 5 minutes). Good for a first
  pass or a low-volume inbox.
- **Standard** (around 150 threads, roughly 15 minutes). The default
  choice for most users.
- **Thorough** (around 300 threads, roughly 30 minutes). For users with
  high email volume or who want maximum fidelity.

The numbers are approximate. The user should pick based on patience and
how nuanced they want the drafter to be. Recommend Standard unless they
have a clear reason otherwise.

## Phase 2: Pull and filter threads

Read email from the last 6 months. The shape of what you want:

- Threads where the user sent at least one substantive reply. Skip
  threads where they never engaged, or only sent a one-liner like "ok"
  or "thanks".
- Full threads, not just the user's outgoing message. You need to see
  what they were responding to.
- A mix of correspondents. If the same person dominates results,
  diversify: you want to see how the user writes to managers, peers,
  clients, vendors, internal teams, and external counterparties.
- A mix of scenarios. Look for variety in what the email is about, not
  just who it's with.

Filter out:

- Newsletters and automated messages.
- Calendar invites and auto-replies.
- Threads where the user only sent a forwarded message with no comment.
- Threads where the user's reply is purely transactional ("attached" /
  "see below").

If the inbox has fewer qualifying threads than the chosen depth, read
all of them and tell the user.

While you read, keep a running scratchpad organised by scenario type.
The scenarios you're looking for include but aren't limited to:

- Replying to a request or ask.
- Chasing someone who hasn't responded.
- Declining or pushing back politely.
- Confirming or agreeing.
- Internal updates and status reports.
- Introductions and warm intros.
- Apologising or explaining a delay.
- Sharing a decision or position.
- Asking a question or seeking input.
- Handling a tricky or sensitive situation.

Not all of these will appear in every user's email; capture what's
actually there. If you find scenarios that don't fit the list above,
add them.

For each scenario you observe, capture:

- Two or three representative examples (full thread context plus the
  user's reply).
- The patterns that recur: opening line style, structure, length, tone,
  closing style, signature style.
- Any noticeable variations by recipient type (e.g. shorter to peers,
  more formal to senior external).

## Phase 3: Synthesise

You should now have a clear picture of the user's voice across
scenarios. Before generating the SKILL.md, do a quick internal pass:

- Are the patterns you've identified actually patterns, or single-case
  observations dressed up as patterns? If something only appears once,
  it's an example, not a rule.
- Do any patterns contradict the `user-context` skill's communication
  norms section? If so, the email evidence wins (it's more specific and
  more recent), but note the discrepancy in case the user wants to
  reconcile.
- Is the voice consistent or does it vary by audience? Most users vary;
  capture the variation rather than averaging it into mush.

## Phase 4: Generate the inbox-reply-drafter skill

Write a single SKILL.md file at
`/mnt/user-data/outputs/inbox-reply-drafter/SKILL.md`. One file, no
reference files, no subdirectories. The user will install this exactly
like they installed `build-inbox-voice`.

The generated skill's frontmatter must be:

```yaml
---
name: inbox-reply-drafter
description: |
  Drafts email replies in the user's voice. Trigger whenever the user
  asks to draft an email, reply to a message, write a response, draft
  a follow-up, or any similar phrasing that indicates they want help
  composing an outgoing email. Works either from an email thread the
  user pastes into chat, or from an email available via a connected
  email MCP. Default is two drafts; produces one when the user is
  specific about what they want to say, three in genuinely ambiguous
  cases. Reads the user-context skill before drafting.
---
```

Below the frontmatter, structure the generated skill as follows:

```markdown
# Inbox reply drafter

You write email replies that sound like the user. You know their role,
the people they work with, and the projects that matter (from the
user-context skill). You know how they handle the scenarios that come
up in their working life (from the patterns below).

## Before drafting

Read the `user-context` skill via `view`. You need to know who the
sender is to the user (manager? peer? client? unknown?) before you can
draft well.

**Check the thread before drafting.** Before writing anything, look at
the most recent message in the thread. If the user has already sent a
substantive reply, do not draft over it. Surface this to the user
instead: "You've already replied to this on [date]. Your reply said:
[brief paraphrase]. Did you want to send a follow-up, or did you mean
a different email?" Only draft after the user confirms they actually
want a new reply. The exception is a holding reply ("got it, will come
back to you") where the actual ask is still open, in which case draft
the substantive response and note that they sent a holding reply
earlier so the tone can pick up from there.

If the email was pasted into chat directly, this check is moot (the
paste is the source of truth and the user clearly wants a reply).
Apply the check only when fetching from an email MCP.

## How to draft

Identify which scenario the incoming email falls into. The user's
patterns for each scenario are documented below. Use them as a guide,
not a script. The goal is a reply that sounds like the user and fits
the specific situation, not a Mad Libs fill-in of a template.

### How many drafts to produce

- **One draft** if the user has been specific about what they want to
  say. ("Tell them yes, Thursday works, and confirm the venue.")
- **Two drafts** by default. Vary them meaningfully (e.g. one warmer
  and longer, one tighter and more direct), not just by surface
  wording.
- **Three drafts** only when the situation is genuinely ambiguous and
  the user could reasonably go in multiple directions (e.g. accept /
  defer / decline on a tricky ask). Label each one with what it
  optimises for.

### Where the email comes from

Two ways to invoke this skill:

1. **From a paste.** The user pastes a thread or forwarded email into
   chat. Read it. Draft.
2. **From an MCP.** The user references an email by sender or subject
   (often after seeing an inbox-triage brief). Use the connected email
   MCP to fetch the thread, then draft. If you can't unambiguously
   identify the email, ask before reading.

## The user's voice

[A paragraph or two on the user's overall voice: register, length
preference, structural habits, signature style. Concrete and
observational, not generic.]

## Scenarios

For each scenario observed during voice-building, a section like:

### [Scenario name]

**When this applies:** [one or two sentences describing what kind of
incoming email triggers this scenario.]

**How the user typically writes:** [a paragraph on length, structure,
opening, closing, tone, recurring phrases or moves. Be specific. Don't
say "professional and warm"; say "opens by acknowledging the previous
message, then states position in one short paragraph, often closes
with 'happy to discuss if useful'."]

**Examples:**

[Two or three real examples drawn from the user's actual sent email,
lightly anonymised if they contain sensitive specifics, with brief
context. Format each as: incoming context one or two lines, then the
user's reply verbatim.]

[Repeat per scenario.]

## Variations by audience

[If the user's voice varies meaningfully by audience type, document the
variations here. E.g. "With external clients, the user tends to be
slightly more formal and uses 'Best regards'. With internal peers, more
casual, often no signature, ends with 'cheers'.")]

## What not to do

[A short list of moves the user clearly doesn't make. E.g. "Doesn't use
exclamation marks", "Doesn't open with 'I hope this finds you well'",
"Doesn't sign off with full job title". Drawn from what's notably
absent from the user's email, not from guesses.]
```

Include real examples from the user's email in the scenarios section.
This is where the drafter's quality lives. A scenario section with no
examples is a generic instruction; a scenario section with three real
examples is a fingerprint.

Anonymise sensitive specifics if appropriate (replace deal names with
[project] etc.), but err on the side of keeping enough detail that the
examples remain useful. The user can edit the generated file afterwards
if anything is too sensitive to keep.

Keep the total file under 800 lines. Long enough to cover the
scenarios well, short enough that the drafter can read all of it
quickly when invoked.

## Phase 5: Present, explain, and hand off to step 3

Use `present_files` to show the user the generated SKILL.md. Tell them:

1. Install this file as the `inbox-reply-drafter` skill. They install
   it the same way they installed this one.
2. They can edit it freely. If the voice isn't quite right or an
   example is too sensitive to keep, they fix it directly.
3. To use it, paste an email thread into chat and ask for a reply, or
   reference an email by sender/subject if their email MCP is
   connected.
4. If the drafter starts to feel stale (new role, new colleagues, new
   tone), they can rerun `build-inbox-voice` to generate a fresh
   version and replace the old one.
5. **You're now set up to use `inbox-triage`** for the daily inbox
   brief. That's step 3 of 3, and it's the day-to-day skill: ask for
   a brief in the morning, after a meeting, or whenever you want to
   know what's in your inbox without opening it.

**Bootstrap case.** If this run was triggered by `inbox-triage`
needing the voice skill, or by a draft-an-email request that went down
the "build voice first" path, remind the user of that original
request: "Now that the drafter is installed, ask me to [triage your
inbox / draft that reply] again and I'll pick it up."

Then end the run.

## Reflexes

**Read user-context first.** Always. The drafter you generate will read
it; the version you generate should be aware of what's in it.

**Examples over generalisations.** A drafter built on "the user is
warm and professional" produces generic emails. A drafter built on
three real examples per scenario produces emails that sound like the
user. When in doubt, include the example.

**Patterns, not single instances.** If a phrasing only appears once in
the user's email, it's an example, not a rule. Don't promote
one-offs to patterns.

**The user has final say.** They can edit anything in the generated
file. If they tell you "I don't actually write that way any more",
update and regenerate.

**Snapshot in time.** The voice you capture will go stale as the
user's role and relationships change. Say so in the generated file.
Make rerunning this skill easy.

**No fabrication.** If you don't have evidence for a scenario, don't
invent one. Better to ship a drafter with five well-evidenced
scenarios than ten with three guessed.
