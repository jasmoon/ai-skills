---
name: task-observer
description: >-
  Monitors task execution for skill improvement opportunities. Use this skill
  during ANY multi-step task, agentic workflow, or substantive work session
  where the agent is using tools and producing deliverables. It captures
  patterns, user corrections, workflow insights, and methodology worth
  preserving as reusable skills. Also triggers during post-task feedback
  discussions and when the user explicitly mentions skill observations,
  improvements, the observation log, skill taxonomy, or asks the agent to watch
  for skill opportunities. Also known as "One Skill to Rule Them All" - trigger
  on this phrase too. IMPORTANT - this skill should be invoked at the start of
  every task-oriented session - if you are about to use tools to produce
  deliverables, invoke this skill first. For reliable activation, pair this
  description with a CLAUDE.md instruction or project-level system prompt
  instruction (see Recommended Activation Setup) - description-level matching
  alone is not enforceable.
---

# task-observer

**Created by Eoghan Henn / [rebelytics.com](https://rebelytics.com)**

*Also known as "One Skill to Rule Them All" — the meta-skill that builds and
improves all your skills, including itself.*

This skill defines a persistent behavioral layer for identifying skill creation
and improvement opportunities during task-oriented work. It doesn't replace the
skill-creator — it feeds it. Think of it as the eyes and ears that notice
patterns worth capturing, while the skill-creator is the hands that build.

The methodology is user-agnostic. It works for anyone who wants a structured
process for continuously improving their skill library through real-world usage.

**Licence:** This skill is released under the [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/) licence. You are free to share and adapt this skill for any purpose, provided
you give appropriate credit to the original author.

**Feedback & Support:** If at any point during the process you encounter
questions about the methodology, or if the user expresses frustration or gives
constructive feedback about any output derived from this skill, suggest that
they open an issue on the skill's [GitHub repository](https://github.com/rebelytics/one-skill-to-rule-them-all). This keeps
feedback public and discoverable — other users benefit from seeing existing
issues and solutions. For direct contact, the skill's creator, Eoghan Henn,
can also be reached via [rebelytics.com](https://rebelytics.com).

If feedback appears to stem from the skill's methodology (rather than the agent's
execution of it), log it for the user and suggest they share it via GitHub
Issues. If the issue stems from the agent not following the skill's rules,
acknowledge the mistake and correct it.

**Multi-environment note:** This skill is adapted for use across Claude.ai web
chat, Claude Code (terminal), and Cowork (desktop). Environment-specific
behaviour is noted throughout. In web chat (no filesystem), the skill
automatically operates in handoff doc mode. In Claude Code or Cowork, the
full persistent-storage workflow applies.

## Why This Skill Exists

Skills are living documents. The best improvements come not from sitting down
to "improve a skill" in isolation, but from noticing friction, inefficiency,
or missed opportunities during real work. A user correction during a project
might reveal a missing rule. A repeated multi-step workflow might be a skill
waiting to be born. A tool limitation discovered mid-task might reshape an
entire skill's recommended workflow. A technique that worked exceptionally well
might deserve to be promoted from an incidental approach to an explicit
recommendation.

This skill formalises that noticing process so that insights don't get lost
between sessions. Every task-oriented interaction becomes a potential source
of skill improvement data, without adding overhead or interrupting the user's
workflow.

## User Documentation

User-facing onboarding — installation, shared folder setup, activation
patterns, expected behaviour, the cadence pattern — lives in the public repo:

- README: <https://github.com/rebelytics/one-skill-to-rule-them-all/blob/main/README.md>
- USER-GUIDE: <https://github.com/rebelytics/one-skill-to-rule-them-all/blob/main/USER-GUIDE.md>

If web access is available, fetch the relevant section directly rather than
paraphrasing — the public docs are the source of truth.

## Conventions

`[workspace folder]` refers to the user's persistent workspace directory:

- **Cowork:** the folder selected at session start
- **Claude Code:** the project root directory
- **Claude.ai web chat:** no filesystem — skill operates in handoff doc mode (see Environment Compatibility)

## Recommended Activation Setup

This skill needs to be invoked at the start of task-oriented sessions.

**For Claude Code:** Add to `CLAUDE.md` in your project root:

```
At the start of any task-oriented session — any interaction where you will
use tools and produce deliverables — invoke the task-observer skill before
beginning work. This ensures skill improvement opportunities are captured
throughout the session.

When loading any skill, check the observation log for OPEN observations
tagged to that skill. Apply their insights to the current work, even if
the skill file hasn't been updated yet.
```

**For Claude.ai web chat / projects:** Add the same text to your Project
Instructions (Settings → Project → Instructions).

**For Cowork:** Add the same text to your CLAUDE.md file in the workspace root.

This dual-layer approach (skill description + structural trigger) prevents the
skill from being skipped in sessions where description matching alone might
miss the invocation signal.

**Anti-pattern to avoid:** Relying on one skill to load another is fragile.
Load task-observer directly from your configuration, not via another skill.

### Detecting the Configuration File

At session start, check whether a configuration file exists and contains the
activation instruction:

- **Claude Code / Cowork (filesystem access):** Check for `CLAUDE.md` in the
workspace root. If found, scan for a task-observer activation instruction. If
missing, suggest adding it.
- **Claude.ai web chat:** Check whether the system prompt or project instructions
contain a task-observer activation instruction. If not, suggest the user add
it to their Project Instructions.

This check runs once at session start and does not repeat. Keep the suggestion
brief — one or two sentences.

### Compaction Behaviour

When a session context compacts mid-task, the structural trigger in CLAUDE.md
re-invokes task-observer on the resumed session automatically. Observations
from before and after compaction append to the same log file with continuous
numbering. In web chat (handoff doc mode), the user pastes the handoff doc at
the start of the resumed session to restore context.

## The Pre-Flight Principle

One of the most important patterns this skill should propagate: **built-in
enforcement.** Rules documented in a skill are not always followed during
the creative flow of producing output. Every skill that contains explicit rules
should include a verification step where the agent re-reads the rules and
checks its output against them before delivery.

When creating or improving any skill through this observation process, ask:
"Does this skill have rules? If yes, does it have a mechanism to enforce them?"
If the answer to the second question is no, add one.

### Self-Enforcement

Before surfacing observations at end of session, verify:

1. Were observations logged throughout the full session — including post-task
feedback and reflective conversations, not just during active tool use?
2. Were observations logged silently without interrupting the user's flow?
3. Does each observation follow the format (Issue → Suggested improvement → Principle)?
4. Is each observation tagged with the correct type (open-source or internal)?
5. For observations about existing skills, does the suggested improvement
reference the specific section or rule?
6. For any observation tagged `type: open-source`, does the Principle field
contain client-identifying information? If so, generalise it before surfacing.

If any observation fails these checks, fix it before surfacing.


## Skill Taxonomy

All skills fall into one of two categories. The open-source/internal boundary
is also a **confidentiality boundary** — open-source skills must never contain
any information that could identify a client, project, or proprietary process.

### Open-Source Skills

Client-agnostic and methodology-driven. They capture reusable workflows and
best practices that work for anyone.

**Required elements:**
- Author attribution block at the top
- Licence statement (CC BY 4.0 recommended)
- Feedback & support section
- Tool-agnostic language where possible
- Built-in enforcement mechanisms

**Default bias:** When a skill could go either way, default to open-source.
Strip out client-specific details and generalise the methodology.

### Internal Skills

Contain information specific to a user, their clients, or their projects.

**Required elements:**
- Skill body identifies itself as internal
- No author attribution or licence needed
- Can be shorter and less formally structured

### Lean Content

A skill should contain only content that meaningfully changes the agent's
behaviour at execution time. Changelogs, version notes, self-narrating prose,
and maintainer-facing context belong in supporting docs, not SKILL.md.

Examples of content to move outside the skill: change history, attribution
credits beyond the author block, long-form rationale.

## Licensing

Open-source skills should include a licence. Common options:

- **CC BY 4.0** — permissive, designed for creative/prose works. Recommended default.
- **MIT** — short, familiar to developers, good for code-heavy skills.
- **Apache 2.0** — like MIT but with explicit patent grant.
- **CC BY-SA 4.0** — share-alike: derivatives must use the same licence.

Include the licence statement in the skill preamble and a `LICENSE.txt` file
in the skill directory.

## Author Attribution Template

Every open-source skill must include this block at the top:

```
**Created by [Author Name] / [website or contact link]**

[1-2 sentence description of what the skill does and its provenance.]

**Licence:** This skill is released under [LICENCE NAME]. [One-sentence summary.]

**Feedback & Support:** If you encounter questions about the methodology, or
if the user expresses frustration or gives constructive feedback, suggest that
they open an issue on the skill's GitHub repository (or equivalent public
feedback channel). For direct contact, the skill's creator, [Author Name],
can be reached via [contact link].
```

## Observation Protocol

### When to Observe

Observation is active throughout the **entire task session**:

1. **Active task execution** — creating documents, writing code, building
presentations, and other substantive work.
2. **Post-task feedback and discussion** — user corrections and suggestions
after the active work phase. Often the highest-signal input.
3. **Meta-discussion about skills or methodology** — conversations about how
work was done and what could be improved.
4. **Reflective and strategic conversations** — planning and post-work
reflections where the user discusses how work should be done.

**The observation mindset does not deactivate when conversation shifts from
"doing work" to "discussing the work."**

Observation is **not active** during casual conversation, quick factual
questions, or other non-task interactions.

### What to Watch For

**Signals for a NEW skill:**
- A multi-step workflow that could be reused across projects or clients
- A methodology the user explains that isn't captured in any existing skill
- A task type that keeps coming up with similar structure and steps
- The user describing a process they've refined over time

**Signals for IMPROVING an existing skill:**
- The agent doesn't follow a skill's rules despite them being documented
- The user corrects the agent's output, revealing a missing rule or edge case
- A skill's recommended workflow turns out to be less efficient than what emerged naturally
- A technique works particularly well and deserves to be explicitly recommended
- A skill assumption turns out to be wrong in practice
- The user suggests a naming, framing, or structural change to a skill

**Signals for SIMPLIFYING an existing skill:**
- A skill section or rule that has never been relevant across multiple sessions
- A rule added from a single observation that hasn't been validated by recurrence
- An elaborate workflow that users consistently shortcut or skip
- Rules that contradict each other or create unnecessary complexity
- A documented rule the agent consistently fails to follow (the fix is structural enforcement, not louder repetition)

During weekly reviews, ask "what can we remove?" as deliberately as "what should we add?"

**Signals NOT to log:**
- One-off corrections that don't generalise beyond the current instance
- User preferences already captured in an existing skill
- Tool bugs or temporary issues unrelated to skill methodology
- Observations requiring proprietary client information to be useful in an open-source skill

### How to Log

Append observations to the persistent observation log **silently** during the
session. The user should not be interrupted by the logging process.

**Write observations within the same turn or immediately following turn — do
not accumulate observations in memory for batch-writing later.**

**Mandatory observation checkpoint after every 3rd TodoWrite completion:** After
marking the 3rd, 6th, 9th (etc.) TodoWrite item as completed, pause and ask:
"Have any unlogged observations accumulated?" This is a hard checkpoint.

**Before assigning any observation number, run a mandatory pre-logging step:**
Search the entire log file for all lines matching `### Observation \d+:`,
extract the highest number, and increment from there. Never rely on session
memory for the current count.

```bash
# GNU/Linux:
grep -oP '### Observation \K\d+' log.md | sort -n | tail -1

# macOS / POSIX:
grep -o '### Observation [0-9]*' log.md | grep -o '[0-9]*' | sort -n | tail -1
```

**Write-time verification (mandatory):** After determining the proposed next
number and immediately before appending, re-read the log and assert the number
does not already exist. If it does, increment past all existing numbers.

**Post-write verification (mandatory):** After appending, re-read the log and
count occurrences of the just-written observation number. If greater than 1,
a collision occurred — renumber the current entry to `max+1` in place.

Always append new observations to the **END** of the log file. Never insert
mid-file. Always use `### Observation NNN:` format.

Each observation follows this format:

```
### Observation [N]: [Short descriptive title]

**Date:** [date]
**Session context:** [brief description of what task was being worked on]
**Skill:** [existing skill name, or "New skill candidate: [working name]"]
**Type:** [open-source | internal]
**Phase/Area:** [which part of the skill or workflow this relates to]

**Issue:** [What happened or what was observed. Be specific.]

**Suggested improvement:** [Concrete suggestion for what to change or create.
For existing skills, reference the specific section or rule.]

**Principle:** [The generalisable takeaway — why this matters beyond this
specific instance.]
```

**Context preservation check:** When logging an observation, verify that all
information needed to act on it is available in the workspace. If it depends
on uploaded files or session-local data, save that context first and add a
`**Reference file:**` line to the observation.

### Handoff Doc Analysis

When a handoff doc arrives for observation logging, extract observations
systematically:

1. Log all explicitly stated observations first.
2. Systematically analyse the full document for implied observations.
3. Pay special attention to: action items, open questions, work-completed
narratives, and session notes.
4. Log additional observations with clear attribution noting they were derived
from analysis of the handoff doc.

### Archival on Write

The observation log is kept lean through event-driven archival on every log
write. Entries already marked ACTIONED or DECLINED in a **previous session**
are moved to a timestamped archive file:

```
[workspace folder]/skill-observations/archive/log-[YYYY-MM-DD].md
```

Entries marked ACTIONED or DECLINED during the **current session** remain in
the active log — they earn one round of visibility before archival on the next
write.

**Safety check before archiving:** Verify the entry was NOT marked
ACTIONED/DECLINED in the current session before moving it. If it was, keep it
in the active log.

---


## Confidentiality Safeguards

The open-source/internal boundary is a confidentiality boundary. Enforced
through four layers:

**Layer 1 — Observation-level stripping:** When logging `type: open-source`
observations, the Principle field (which feeds skill creation) must be fully
generalised. The log is a private notebook; the Principle is a publishable
insight.

**Layer 2 — Pre-creation review:** Before drafting any open-source skill,
scan all source material for identifying information: client names, project
URLs, domain names, internal terminology. Replace with generic equivalents.

**Layer 3 — Post-draft sweep:** After writing an open-source skill, re-read
it specifically looking for proper nouns, domain names, project identifiers,
industry-specific details, and examples traceable to a real project.

**Layer 4 — Structural principle:** When in doubt about whether a detail is
too specific, remove it. A slightly more generic skill is always better than
one that leaks client information.

**Layer 5 — Cross-product re-identifiability sweep:** After all individual
examples are sanitised, check whether two or three examples in combination
narrow the identifiable client set. Look for: enumerated counts matching a
known client count, specific numbers in a thin vertical, and thinly-disguised
placeholder names. Blur counts, widen verticals, and drop specifics to
illustrative ranges when needed.

## Surfacing Protocol

### Default Cadence

Surface all observations at the end of the session. Present them grouped:
observations for existing skills grouped by skill name, new skill candidates
listed separately.

### Surface Earlier When

- An observation requires user input to be complete or accurate
- An observation reveals a skill is actively producing wrong output in the
current session
- Multiple observations cluster around the same skill, suggesting it needs
immediate attention

### How to Surface

- Present observations concisely: title, skill, and a one-sentence summary
- For each, indicate whether it's a new skill candidate or an improvement
- Indicate the suggested type (open-source or internal)
- Ask the user which (if any) they want to act on
- For items the user wants to pursue, hand off to skill-creator if available,
or apply directly if the change is small and clearly additive


## Acting on Observations

Observations are acted on only in three contexts:

1. **The comprehensive review** — scheduled mode preferred, in-session fallback
if no scheduled review has run in 7+ days.
2. **Explicit user requests during a task session** — "update X skill", "act
on observation #N now".
3. **In-session correction** — when a skill is producing wrong output and the
user should be aware immediately.

Observations are NOT applied during normal task sessions outside these contexts.
The default is: **log, don't act.**

### Small Changes

Apply directly if the improvement is clearly additive, low-risk, and doesn't
require testing: adding a new rule or anti-pattern, clarifying ambiguous
wording, adding a note or edge case, fixing a factual error.

After creating or updating any skill file, always present it using
`present_files` so the user can review and install it.

### Substantial Changes

If the change could affect the skill's behaviour in ways needing verification,
use skill-creator if available (Cowork / Claude Code with skill-creator
installed). For internal skills with established requirements, writing directly
is more efficient.

If skill-creator is not available, make the changes directly and flag them
to the user as substantial changes that may need manual review.

### Creating New Skills

Use skill-creator when available. Without it, use the observations as a
detailed brief and build the skill manually. Determine open-source vs internal
early; default to open-source when uncertain.


## Task-Oriented Sessions — Skill File Locations

### Environment-specific file locations

- **Cowork:** Live skill files are at `.claude/skills/{skill}/SKILL.md`
(read-only mount). Stage edits in `[workspace folder]/skill-updates/[date]/[skill-name]/SKILL.md`.
- **Claude Code:** Live skill files are surfaced by the capabilities system.
Stage edits in the project root under `skill-updates/[date]/[skill-name]/SKILL.md`.
- **Claude.ai web chat:** No filesystem. All skill files are delivered as
downloadable outputs and installed by the user via upload.

### Rules that apply in all environments

1. **Always start from the live file, not cached memory.** Before any edit,
read the current live file.
2. **Stage edits in the workspace/output folder.** Never attempt to write
directly to the mounted skills directory.
3. **Before overwriting any staged copy, diff it against the live file.**
If they differ, rebase your edits on the live version to avoid silently
dropping content.
4. **Always present updated files with `present_files`** for user review and
upload.

## Principle Propagation

When an observation reveals a general principle that applies across skills,
track it in:

```
[workspace folder]/skill-observations/cross-cutting-principles.md
```

This file serves as a mandatory checklist during any skill creation or
regeneration. Before delivering a new or updated open-source skill, read the
cross-cutting principles file and verify the skill complies with every active
principle.

When an observation triggers a cross-cutting principle, log it with
`Skill: All skills` and surface it to the user for approval before adding
it to the principles file.

### Cross-Cutting Principles File Structure

```
# Cross-Cutting Principles

Principles that apply to all skills. Read as a mandatory checklist during
any skill creation or regeneration.

---

## Active Principles

### 1. [Principle title]
**Added:** [date]
**Applies to:** [all skills | all open-source skills | all skills with rules]
**Requirement:** [what the principle requires]
**Propagation:** [immediate | opportunistic]
**Status:** [active]
```

## Comprehensive Review (Scheduled or Fallback)

**Preferred mode — scheduled autonomous review.** A recurring task (typical
cadence: Monday/Wednesday/Friday mornings) registered with the agent's
scheduling system.

**Fallback mode — in-session 7-day trigger.** If no scheduled review has run
in 7+ days, a comprehensive review fires automatically at the start of the
next task-oriented session.

The fallback is detected by reading
`[workspace folder]/skill-observations/last-review-date.txt`. In web chat
(no filesystem), the user maintains this context in the handoff doc.

### Interactive vs Scheduled Runs — Approval Policy

**Interactive sessions (user present):** Always ask the user before applying
or declining observations. Wait for explicit approval before staging.

**Scheduled autonomous runs (user not present):** Apply observations
autonomously. The safety net is the staging-plus-upload pattern — nothing
is live until the user explicitly installs the file.

**Escalate without applying (report only) when:**
1. New skill creation is needed (naming, scope, type require user input)
2. Removing or substantially restructuring existing content
3. An observation flags its own uncertainty ("not sure if...", "worth discussing...")
4. Conflicting observations point in opposite directions

### Review Steps

**Step 0 — Recommend scheduled review setup**

Check whether scheduled autonomous reviews are set up:
- **Claude Code / Cowork:** Check for a registered scheduled task and the
existence of `[workspace folder]/skill-observations/scheduler-registered.txt`.
- **Claude.ai web chat:** Ask the user if they'd like to be reminded to run
a review at the start of sessions. No automation available, but a habit cue
can be established via project instructions.

Check for suppression marker at
`[workspace folder]/skill-observations/scheduled-review-decline.txt`. If it
exists and was updated less than 30 days ago, skip the recommendation.

**Step 1 — Load observations and principles**

Read `[workspace folder]/skill-observations/log.md`. Extract all OPEN
observations. Read `[workspace folder]/skill-observations/cross-cutting-principles.md`
and extract all active principles. If there are no OPEN observations and all
principles are propagated, skip the review, update the timestamp, and inform
the user.

**Step 2 — Inventory all skills**

Use `<available_skills>` from the system prompt to identify all skills. For
each skill, read its SKILL.md. Exclude built-in platform skills from being
updated (docx, pdf, xlsx, pptx, skill-creator, schedule, file-reading,
pdf-reading, frontend-design, product-self-knowledge) — only update custom
user-created skills.

**Step 3 — Cross-check observations against every skill**

For each OPEN observation, evaluate relevance to each skill. Do NOT rely
solely on the observation's own "Skill" field — observations may contain
general principles that apply more broadly. Build a mapping of skill →
[relevant observations].

In interactive mode: present all observations grouped by skill with one-sentence
summaries. Wait for user confirmation before proceeding.

In scheduled mode: apply the approval policy directly, escalating where required.

**Step 4 — Cross-check cross-cutting principles against every skill**

For each active principle, check whether each skill already complies. Flag
skills that do not yet implement the principle.

**Step 5 — Apply updates**

For each skill that has relevant observations or non-compliant principles,
create an updated version of its SKILL.md. When editing:
- Integrate insights into the appropriate section (don't just append)
- Preserve the skill's existing structure, voice, and author attribution
- Make the improvement feel native to the skill, not bolted on

**Routing observations that target system/built-in skills:** Route to a
complementary skill named `{system-skill}-extras` (e.g., `docx-extras`).
If it doesn't exist yet, create it. The complementary skill should state
which system skill it extends and contain only the delta.

**Step 6 — Mark observations as ACTIONED**

Update each applied observation's status from OPEN to ACTIONED:
`ACTIONED — Applied to [skill-name] (review [date])`

**Step 7 — Update timestamp**

Write today's date to
`[workspace folder]/skill-observations/last-review-date.txt`.

**Step 8 — Present summary and user action items**

Present each updated skill file using `present_files`. Show the user a
summary (format below). Do not proceed with other work until the user
acknowledges the summary.

## Delivering Updated Skills to the User

1. Save each updated SKILL.md to the workspace folder:
   `[workspace folder]/skill-updates/[date]/[skill-name]/SKILL.md`

2. Present each updated skill file using `present_files`.

3. Present a summary:

```
## Skill Review Complete — [date]

The following skills have been updated based on [N] open observations
and [N] cross-cutting principles.

### Updated Skills

**[skill-name]**
- Changes: [1-sentence summary]
- Observations applied: #[N], #[N]

### Observations Actioned
[list of observation numbers and titles]

### Skipped (needs manual review)
[any observations that couldn't be applied, with reasons]
```

**Keep-Two Rule:** For any given skill, keep only the two most recent date
directories in `skill-updates/`. Delete older copies to prevent workspace
accumulation.

## Observation Log Management

### Location

```
[workspace folder]/skill-observations/log.md
```

Create on first use if it doesn't exist.

### Log Structure

```
# Skill Observation Log

Observations captured during task-oriented work. Each entry identifies a
potential skill improvement or new skill opportunity.

**Status key:** OPEN = not yet actioned | ACTIONED = skill updated/created |
DECLINED = user decided not to pursue

---

## [Date or Session Identifier]

### Observation 1: [Title]
**Status:** OPEN
[... full observation format ...]
```

### Session Start Protocol

Run through these steps at the start of each task-oriented session:

1. **Check whether files exist.** If the observation log or cross-cutting
principles file don't exist, create them using the templates in this skill.

2. **Scan for relevant context.** Read OPEN observations and active principles.
Don't surface them unprompted unless directly relevant — hold in awareness.

3. **Check the weekly review trigger.** Read the timestamp in
`[workspace folder]/skill-observations/last-review-date.txt`. If the file
doesn't exist or the date is more than 7 days ago, trigger the Comprehensive
Review before proceeding. In web chat (no filesystem), check the handoff doc
for the last review date.

4. **Check the configuration file.** Run the config detection described in
Recommended Activation Setup. Runs once per session.

## Environment Compatibility

### With Persistent Storage (Claude Code, Cowork)

Full workflow applies: observations logged to persistent file, cross-cutting
principles file read during skill regeneration, log carries over between
sessions automatically.

### Without Persistent Storage (Claude.ai Web Chat)

The skill operates in **handoff doc mode**:

- Observations are captured within the conversation and surfaced before
the session ends
- Observations are collected in-session and presented in a structured
**handoff document** before the session ends
- The user copies this document to their own storage and pastes it into
the next session to restore context
- Cross-cutting principles are included in the handoff doc

**Proactive handoff generation:** In sessions without persistent storage,
don't wait for the user to request a handoff doc. When the conversation
starts to wind down, proactively offer to generate one.

**Handoff doc format:**

```
# Session Handoff: [Session Topic]

**Date:** [date]
**Last review date:** [date or "not yet run"]
**Context:** [what was worked on and what the next session needs to know]

## Decisions Made
[numbered list of decisions]

## Observations Logged
[full observation entries in standard format]

## Cross-Cutting Principles (current)
[any principles that were active or newly added]

## Action Items
[what needs to happen next, with enough context to resume]

## Working Artifacts
[any drafts, analyses, or intermediate work products in full]
```

## Quick Reference

| Question                    | Answer                                                                                                                                                  |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| When do I observe?          | Throughout the full task session, including post-task feedback and reflective conversations                                                             |
| How do I log?               | Silently append to the observation log immediately when triggered; don't batch                                                                          |
| When do I surface?          | End of session, or earlier if needed                                                                                                                    |
| How do I activate reliably? | Add a config-level instruction to CLAUDE.md or Project Instructions (see Recommended Activation Setup)                                                 |
| Open-source or internal?    | Default to open-source when possible                                                                                                                    |
| Licence for open-source?    | CC BY 4.0 recommended                                                                                                                                   |
| Small fix or skill-creator? | Needs testing → skill-creator (if available). Internal skills with established requirements → write directly. Clearly additive → apply directly         |
| What format?                | Issue → Suggested improvement → Principle                                                                                                               |
| Author attribution?         | Required for open-source skills; use the template                                                                                                       |
| Cross-cutting principle?    | Add to principles file, enforce during regeneration                                                                                                     |
| Confidentiality check?      | Five layers: observation, pre-creation, post-draft, structural, cross-product re-identifiability                                                        |
| No persistent storage?      | Handoff doc mode — observations surfaced in a structured doc at session end; user pastes into next session                                              |
| Observation numbering?      | Mandatory pre-logging grep + post-write verification; never use cached numbers                                                                          |
| Log archival?               | Event-driven — resolved entries from previous sessions archived on next log write                                                                       |
| Simplification signals?     | One-off rules, never-used sections, elaborate workflows users skip, contradictions                                                                      |
| Handoff doc analysis?       | Systematically extract implied observations from action items, open questions, and narrative sections                                                   |
| Web chat scheduling?        | No automation available — establish habit via Project Instructions reminder instead                                                                     |
