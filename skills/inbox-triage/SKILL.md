---
name: inbox-triage
description: |
  Reads the user's inbox over a specified window and produces a
  structured brief sorting everything into Urgent (needs the user
  today), Watching (going stale, including chases they're waiting on),
  and Skip (newsletters, CC noise, automated alerts, counted not
  summarised). Renders as an inline visual widget of stacked,
  colour-coded priority cards that expand on click for fuller context.
  Reads `user-context` first; bootstraps `build-user-context` if not
  installed. Trigger whenever the user asks for an inbox brief, morning
  email summary, what's in their inbox, what needs their attention,
  what came in overnight, an inbox triage, or any phrasing asking
  Claude to sort or summarise their email. Also trigger when invoked
  by a scheduled run passing a `window` parameter. Read-only: does not
  draft or send anything.
---

# Inbox triage

You produce a clear, structured brief from the user's inbox over a
specified time window. The user reads this brief once, in chat, and
knows what to act on, what to keep an eye on, and what to ignore. The
brief is the entire deliverable. You do not draft replies (the
`inbox-reply-drafter` skill does that, on demand). You do not send,
file, or modify anything in the inbox.

## Where this fits

The inbox suite is three skills installed and set up in sequence:

1. **build-user-context**. Captures who the user is, who they work
   with, and how they communicate. Produces `user-context`.
2. **build-inbox-voice**. Reads email patterns to learn the user's
   writing voice and produces `inbox-reply-drafter`.
3. **inbox-triage** (this skill). The day-to-day brief. Reads
   `user-context` to know what matters.

This skill is the daily-use one. The first two are one-time setup.

## Before you start

**Read the `user-context` skill first.** This is non-negotiable. Use
`view` to open the user-context SKILL.md and read it fully. You need
to know who the user is, who the significant people in their working
life are, and what projects matter, before you can decide what's
urgent. Without this, your judgments about urgency will be generic and
often wrong.

If `user-context` is not installed, **bootstrap it** rather than
stopping. Tell the user: "I need to set up your user context before I
can give you a useful brief. That's a 15-20 minute one-time setup.
Running `build-user-context` now, then come back to me for the
triage." Read `build-user-context`'s SKILL.md and follow it through
to the end. Once the user has installed the generated `user-context`
skill, they can re-invoke `inbox-triage` and you'll proceed normally.
Do not try to triage without `user-context`; a generic triage erodes
trust in the brief and isn't worth the few minutes saved.

**Check the email MCP is connected.** Any email connector works
(Gmail, Outlook, Zoho, or an Anesi-style Outlook MCP). If you're not
sure which tools are available, call `tool_search` with terms like
`["email", "list messages", "thread"]`. If no email source is
reachable, tell the user clearly and stop.

## Resolve the window

This skill takes a `window` parameter from the caller. It might come
through as a structured argument (when invoked by a Cowork schedule),
or it might be embedded in a natural-language prompt ("triage my
inbox from the last 12 hours"). Resolve it before reading anything.

Common windows:
- `last_12h`, `last_24h`, `last_3d`, `last_7d`
- `since_yesterday_5pm`, `since_friday_5pm` (working-hours-aware)
- `since_last_run` (if the caller provides a timestamp)

If the caller didn't specify a window, default to **the last 24 hours**
and say so in the brief. Don't ask the user mid-run; just pick the
default and proceed.

## Phase 1: Pull email in the window

Use the email MCP to list every message received within the resolved
window. Also pull every message **sent by the user** in the window,
plus a buffer of sent messages from the few hours before the window
starts (in case the user replied late at night to something that
arrived earlier).

You need both halves because outgoing messages decide two things:
(a) whether an inbound email still needs a reply or has already been
handled, and (b) which threads count as "waiting on someone else".
The first of these is the most common failure mode of triage and the
one to be most careful about.

Don't read full bodies yet. At this stage you want headers and
previews: sender, recipients (including CC), subject, snippet, time,
whether the user is in the To or CC field, whether it's part of an
existing thread.

## Phase 2: Build context

For each non-trivial email, decide whether you need more context to
classify it. You'll need context if:

- The subject references a named artefact you don't recognise ("the
  Q2 deck", "Thursday's call", "the proposal").
- The email is a reply to a thread you haven't seen.
- The sender is significant per `user-context` but the message is
  cryptic.
- The email mentions a project from `user-context` and seems
  consequential.

For these, fetch the relevant context: prior messages in the same
thread, other recent threads involving the same people, other recent
threads mentioning the same artefact or project. Read what you need to
make a good call, not more.

You can also use this phase to identify threads where the user sent
the last message and is waiting on a reply. These are relevant in two
ways: they form the basis of the Watching pile (when the wait is
recent), and they're how you detect Urgent replies (when the
counterparty has now responded).

**Check thread state for every inbound, before classifying.** For each
inbound email that's part of a thread, look at the most recent message
in that thread. If the user has already replied (their message is the
latest, or sits after the inbound you're considering), the inbound is
not waiting on them. This is the single most common reason triage
goes wrong: surfacing an email as Urgent when the user has already
handled it. Always check before deciding the pile. The only nuance is
a holding reply ("got it, will come back to you"): the user has
written back but the actual ask is still open, so it stays live. Most
substantive replies close the loop.

For low-signal emails (newsletters, automated alerts, CCs to large
distribution lists, internal noise), you don't need context. They go
to Skip with a quick classification.

## Phase 3: Classify

Sort every email in the window into one of three piles.

### Urgent

**Precondition: confirm the user hasn't already replied.** Before
placing anything in Urgent, check the thread state from Phase 2. If
the user has already sent a substantive reply, the email is not
Urgent. It may belong in Watching (if a counter-reply from the other
side is expected) or be omitted entirely if the loop is closed. The
exception is a holding reply, where the actual ask is still open: in
that case keep it Urgent and note that a holding reply was sent so
the user knows the other side isn't waiting in silence.

Goes here when one of these is true (and the precondition is met):

- The original sender expects a same-day reply (explicit or implicit
  by tone and content).
- A deadline is imminent (today, tomorrow, end of week if it's
  Thursday or Friday).
- The user is the named action-taker and the request is concrete.
- The email is a reply on a thread where the user has been waiting on
  the sender. **Replies to a chase are always Urgent**, regardless of
  whether the reply itself is short or rich. The user wanted to know
  the moment this came back.
- The email is from someone flagged in `user-context` as significant
  (manager, key client, major counterparty) and asks something of the
  user.

Don't put things here just because they sound formal or important. A
detailed update from a colleague that doesn't actually ask anything is
not Urgent.

### Watching

Goes here when:

- The user has sent a message and the recipient hasn't responded yet,
  and the wait is starting to feel stale (the user might want to
  chase). Include the original ask in the summary so the user can
  decide quickly whether to nudge.
- Something is brewing that's not urgent today but will need attention
  soon.
- The user is asked to do something with a longer or undefined
  timeline.
- A CC'd email that contains something the user genuinely should know
  about (a decision being made, a problem being raised, a project
  changing direction). CCs are not auto-Skip; evaluate the content.

### Skip

Goes here when:

- Newsletters and subscribed bulletins.
- Automated alerts (CI builds, monitoring, marketing platforms, etc.).
- Calendar invites and auto-replies.
- CCs where the user clearly isn't expected to do or know anything
  specific (broad distribution lists, routine notifications).
- Internal noise that doesn't involve the user (e.g. team threads the
  user is looped into but not engaged with).

Skip is **counted and sourced, never summarised**. Show the user how
many and what kinds (e.g. "12 newsletters: Stratechery, FT Alphaville,
Pragmatic Engineer plus 9 others"; "7 CCs you weren't the named
recipient on"). Don't paraphrase each one.

### Internal vs external

Internal emails (from the user's own organisation per `user-context`)
are classified by content like anything else. Don't auto-promote
internal stuff to Urgent because it's internal; don't auto-demote it
either. The content decides.

### CCs

When the user is CC'd rather than To'd, evaluate the content and
classify normally, but mark the item with `(CC)` so the user knows
their level of involvement at a glance.

## Phase 4: Handle the awkward cases

**Empty window.** If no email arrived in the window, say so cleanly
("Nothing new since X"). Then check for **emails still waiting on a
reply** outside the window: threads where the user sent the last
message a few days ago and the other side has gone quiet. Surface
these as a "Still waiting" addendum, framed as suggestions, not new
Urgent items. If there are none of these either, end the brief
honestly.

**Genuinely ambiguous items.** If you can't confidently place an
email (it could be Urgent or Watching; sender unknown; context too
thin even after Phase 2), do **not** force a pile. Put it in a "Worth
a second look" section at the end of the brief, with a one-line
explanation of why you couldn't decide. The user can read these
quickly and tell you. This section should be small; if you find
yourself putting many items in it, something is wrong (maybe
`user-context` is too thin or maybe the window is too large).

**Sensitive or unusual content.** If something looks like it might be
a security issue (a phishing attempt, an unexpected legal notice, an
HR matter), surface it with appropriate care. Don't bury it in Skip.
Don't speculate on what to do; just flag.

## Phase 5: Produce the brief

The brief renders as an **inline visual widget** in chat, not plain
markdown. The categories are stacked, colour-coded priority cards, and
each item card expands on click to reveal fuller context. The user
scans the headers in seconds and opens only the items they care about.

First settle the content for every item (this is the data model behind
the cards):

- **Sender + source** (e.g. "Chris Wright · Baisics"). For
  waiting-on-someone items, lead with "You → [name]".
- **Time / age** received (or sent, for waiting items).
- **Subject**, lightly trimmed.
- **One-line teaser** — what it is and what's being asked, shown on the
  collapsed card.
- **Why [urgent/watching]** — the one-line reason, shown collapsed.
- **Expanded detail** — three short lines revealed on click: *What it
  is* (the fuller summary), *Why [pile]* (the classification reason in
  context), and *Next* (the suggested next step). For "Worth a second
  look", replace the middle line with *Why I couldn't decide*.
- A `(CC)` tag after the sender name when the user was CC'd.

### Render the widget

Build the brief with the `mcp__visualize__show_widget` tool. Call
`mcp__visualize__read_me` with `modules: ["mockup"]` once per session
before your first widget if you haven't already, then render. Keep the
structure identical every run.

Use this template (fill the cards from your data model; repeat
`.tcard` blocks per item; drop a whole section if its count is zero,
except Skip which is always shown):

```html
<div style="padding:0.5rem 0;" id="triage-root">
<h2 class="sr-only">Inbox brief in stacked priority cards; each card expands to show fuller context.</h2>

<div style="font-size:13px; color:var(--color-text-tertiary); margin-bottom:10px;">[Day Date, Time] · [window] · [N] emails · [X] urgent, [Y] watching, [Z] to review</div>

<!-- One section per pile. Header colours:
     Urgent  -> background-danger / text-danger  / ti-alert-circle / border #E24B4A
     Watching-> background-warning/ text-warning / ti-eye          / border #EF9F27
     Review  -> background-info   / text-info     / ti-help-circle  / border #378ADD
     Skip    -> background-secondary/ text-secondary/ ti-archive (no cards) -->

<div style="margin-bottom:10px;">
  <div style="display:flex; align-items:center; gap:8px; padding:6px 10px; background:var(--color-background-danger); border-radius:var(--border-radius-md); margin-bottom:8px;">
    <i class="ti ti-alert-circle" style="font-size:18px; color:var(--color-text-danger);" aria-hidden="true"></i>
    <span style="font-weight:500; color:var(--color-text-danger);">Urgent</span><span style="font-size:13px; color:var(--color-text-danger);">· [count]</span>
  </div>

  <div class="tcard" style="border-left:3px solid #E24B4A;">
    <button class="thead" aria-expanded="false">
      <span style="flex:1; text-align:left;">
        <span style="display:flex; justify-content:space-between; gap:8px;"><span style="font-weight:500;">[Sender · Source]</span><span style="font-size:12px; color:var(--color-text-tertiary);">[time]</span></span>
        <span style="font-size:14px; display:block; margin-top:2px;">[Subject — short teaser]</span>
        <span style="font-size:12px; color:var(--color-text-secondary); display:block; margin-top:2px;"><i class="ti ti-bolt" style="font-size:13px; vertical-align:-1px;" aria-hidden="true"></i> [Why urgent, one line]</span>
      </span>
      <i class="ti ti-chevron-down chev" style="font-size:18px; color:var(--color-text-tertiary); flex-shrink:0; margin-left:8px;" aria-hidden="true"></i>
    </button>
    <div class="tbody">
      <p style="margin:0 0 8px;"><span style="color:var(--color-text-secondary);">What it is — </span>[fuller summary]</p>
      <p style="margin:0 0 8px;"><span style="color:var(--color-text-secondary);">Why urgent — </span>[reason in context]</p>
      <p style="margin:0;"><span style="color:var(--color-text-secondary);">Next — </span>[suggested next step]</p>
    </div>
  </div>
</div>

<!-- Skip section: count + grouped one-liner, no cards -->
<div>
  <div style="display:flex; align-items:center; gap:8px; padding:6px 10px; background:var(--color-background-secondary); border-radius:var(--border-radius-md); margin-bottom:8px;">
    <i class="ti ti-archive" style="font-size:18px; color:var(--color-text-secondary);" aria-hidden="true"></i>
    <span style="font-weight:500; color:var(--color-text-secondary);">Skip</span><span style="font-size:13px; color:var(--color-text-tertiary);">· [count]</span>
  </div>
  <div style="font-size:13px; color:var(--color-text-secondary); padding:2px 4px; line-height:1.9;">[grouped one-liner: N newsletters · N cold sales · N automated alerts · N closed CCs]</div>
</div>

<style>
#triage-root .tcard{background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:0;margin-bottom:8px;overflow:hidden}
#triage-root .thead{width:100%;display:flex;align-items:flex-start;gap:8px;background:transparent;border:none;padding:10px 14px;cursor:pointer;font-family:inherit}
#triage-root .thead:hover{background:var(--color-background-secondary)}
#triage-root .tbody{padding:0 14px 12px 14px;font-size:13px;line-height:1.6;border-top:0.5px solid var(--color-border-tertiary)}
#triage-root .tbody p:first-child{padding-top:10px}
#triage-root .chev{transition:transform .15s ease}
#triage-root .tcard.open .chev{transform:rotate(180deg)}
</style>
<script>
(function(){
  var root=document.getElementById('triage-root');
  root.querySelectorAll('.tcard').forEach(function(c){
    var body=c.querySelector('.tbody'), btn=c.querySelector('.thead');
    body.style.display='none';
    btn.addEventListener('click',function(){
      var open=c.classList.toggle('open');
      body.style.display=open?'block':'none';
      btn.setAttribute('aria-expanded',open?'true':'false');
    });
  });
})();
</script>
</div>
```

Section order is always: Urgent, Watching, Worth a second look, then
Skip last. Add a **Still waiting** section (info-coloured, same card
shape) before Skip only when Urgent and Watching are light and there
are threads outside the window where the user sent last and is waiting;
otherwise omit it. The `.tbody` detail panels start collapsed (the
script hides them on load) so the widget streams fully visible, then
becomes interactive.

Keep the collapsed teasers tight — one line each — so the stack of
headers is scannable in under a minute. Put the depth in the expanded
panel, where it's out of the way until the user wants it.

If the visualize tool is unavailable for any reason, fall back to clean
markdown with the same sections and the same per-item fields (sender,
time, subject, summary, why), so the brief still lands.

## Phase 6: End cleanly

Once the brief is rendered, don't add chat afterwards unless the user
asks. The brief is the deliverable. If the user wants drafts on
specific items, they'll ask, and `inbox-reply-drafter` will handle
that.

## Reflexes

**Read user-context first.** Always. Significant people, projects,
and norms come from there. Without it the brief is generic.

**The brief is read-only.** You do not draft, send, file, archive, or
modify anything. The user does that in their actual email client. You
just tell them what's there.

**No drafts in the brief.** Drafts come from `inbox-reply-drafter` on
demand. Including drafts inline would clutter the brief and undercut
the point of having a separate drafter skill.

**Count Skip, don't summarise it.** The user should know how much
noise was filtered and roughly what kinds, not what each Skip item
said. Skip is volume, not content.

**Replies to chases are Urgent.** Every time. The user has been
waiting; surfacing the response fast is the whole point.

**Check sent before flagging Urgent.** The user's own sent messages
decide whether an inbound is still live. An email the user has
already replied to is not Urgent, no matter what it asks. Verify
against the thread, not the snippet. Getting this wrong is the most
corrosive failure mode of the brief: it tells the user to do work
they've already done, and erodes trust in everything else in the
brief.

**Don't force the ambiguous.** If something doesn't clearly fit a
pile, "Worth a second look" exists for a reason. Forcing classification
hides uncertainty and erodes trust in the brief.

**Internal isn't automatically anything.** No auto-Urgent for internal
email; no auto-Skip for CCs. Content decides.

**Same shape every run.** The user reads this brief regularly. A
predictable structure compounds: they get faster at scanning it over
time. Don't reinvent the layout each morning, and keep the card
structure and section order identical run to run.

**Collapsed teasers, expanded depth.** The headers carry the scan; the
dropdown carries the detail. Don't overload the collapsed card, and
don't leave the expanded panel thin.

**No silent failures.** If you couldn't reach email, couldn't read
`user-context`, or couldn't resolve the window, say so plainly. Don't
generate a fake brief.
