---
name: plan-next-steps
description: Analyze current work to identify design decisions, concerns, and questions — asks clarifying questions first, then produces the analysis. Works for code, design docs, system architecture, and interaction design.
---

# plan-next-steps

Applicable to: code implementation, design docs, system architecture, user interaction design, and adjacent technical work.

When this skill is invoked:

## Phase 1: Gather Context

Automatically gather context from available sources:
- Current git diff and staged changes
- Recent commits (last ~10)
- Open/active files in the conversation
- Conversation history
- **The repository's own decision records**, searched for the topic of the request: a decision log, an open-issues file, an ADR directory, a plan with a worklist. A diff shows what changed; the records show what was decided, and the most useful context for "should we do X" is usually the last time someone wrote down when X would be worth doing. If a recorded position exists, measure the current code against it and lead the analysis with that measurement. A recorded position is a hypothesis to re-derive, not an answer to defer to.

**When the request carries a belief** — "I think X leads to Y", "the 2nd one is stronger than the 1st" — ask which case or cases made the user believe it. A hypothesis about markets, users or failures usually rests on one or two remembered examples. Those examples are the cheapest test, and the one whose result the user will accept, because they are the user's own evidence. Read them before the build. A motivating case that does not show the effect closes the phase before it opens, and one that does sets the gate for the build.

Then, identify what additional information you still need. Ask any clarifying questions about:
- What the user is working on (if not clear from the gathered context)
- The goals, constraints, or scope of the work
- Any ambiguity in requirements or direction

Present these as a concise list and wait for the user's answers before proceeding. If the gathered context is sufficient and nothing is unclear, proceed directly to Phase 2.

## Phase 2: Produce Analysis (automatically after Phase 1 is answered)

Once you have sufficient context, produce all sections:

### 1. Overall Evaluation
Give an honest, high-level assessment of the idea, design, or work. What's working well? What's the overall trajectory — solid, promising but rough, or fundamentally flawed? Be direct. If there are legitimate concerns that could derail the work or lead to significant rework, push back clearly and explain why. Don't be nit-picky about minor style or preference differences — only raise things that materially affect outcomes.

### 2. Top Design Decisions (up to 4, ranked by importance)
Identify the most significant design decisions relevant to the current work. Rank them from most to least important. For each, briefly state what the decision is and why it matters.

These may include decisions about: API shape, data modeling, component boundaries, state management, protocol choices, user-facing behavior, system boundaries, trade-offs between simplicity and flexibility, etc.

**Where a phase or milestone blocks several dependents, look for the cold-start lever before accepting the sequence.** A long-pole phase is usually splittable wherever a seed mechanism — a hand-curated allowlist, a fixture, a static first version — lets a dependent surface render real content without waiting for the full upstream dependency. Bundling a schema, an RPC, two UI surfaces and a discovery UX into one phase holds everything at the speed of the slowest part, and the seam is generally visible once you ask which dependent could ship against a stub.

**Where a decision is a choice between options that persist data, evaluate each one against failure, not only the happy path.** Partial writes and atomicity, a client crash mid-operation, a network drop before commit — what does each option leave behind, and what does recovery cost? Then say which you recommend. Competing persistence designs tend to look alike while everything works; what separates them is the state a half-finished operation leaves. Produce this by default rather than waiting to be asked for it.

### 3. Top Concerns (up to 4, ranked by importance)
Identify concerns about the current design or approach, if applicable. Rank them from most to least critical. For each, briefly state the concern and its potential impact. If there are no concerns, say so.

These may include: scalability risks, coupling issues, unclear ownership, missing error handling, UX friction, accessibility gaps, security surface, maintainability debt, etc.

**One concern class is worth checking by hand every time: a rule the work makes
conditional on an existing mechanism.** "Gated by X", "validated by X", "the
same threshold as Y" — the phrasing borrows the mechanism's authority without
borrowing its domain, and the sentence reads as complete either way. Read the
mechanism's signature, enumerate the cases the new rule spans, and for each one
say which argument is missing or which branch applies. A rule was once made
conditional on a function comparing an existing record against an incoming one;
for a brand-new entity there is no existing record, so the condition was
unstatable across a third of the cases it claimed to cover, and only a reader's
question exposed it. Cases where the mechanism cannot run need their own rule,
not silent inheritance of its name.

**For any request to tune, weight, rank or score something, find the target the fit optimises and state it in plain words beside the decision the output drives.** The request names the parameters, because those are the part the user can see. The target is buried in a labelling function, and the parameters are downstream of it: one change to the label once moved a rule from the smallest weight to the joint largest. Where the target and the decision differ — the fit finds "a local high" and the user reads the number as "sell today" — that gap is concern number one, above anything about the method. Deliver the requested tuning as well. The gap is a finding, not a reason to withhold the answer.

### 4. Top Questions About the Work (up to 6, ranked by importance)
Identify open questions about the work that should be answered to move forward effectively. These are questions for the user or team to consider — things that are unresolved, ambiguous, or worth discussing.

These may include: unspecified edge cases, unclear user flows, missing acceptance criteria, dependency unknowns, deployment considerations, etc.

One question stands whenever the work rests on a belief: **can the motivating case be checked with one read before the build?** If it can, put the check first in the sequence. A build that precedes its cheapest test is a build whose gate was set after the result.

### 5. Before You Close This Session
Identify anything worth doing before the session ends. This could include:
- Uncommitted changes that should be committed or stashed
- TODOs or decisions that should be captured somewhere (memory, a file, a comment)
- Quick fixes or cleanups that would be costly to context-switch back into later
- Notes to leave for the next session

If there's nothing urgent, say so.

## When the analysis becomes a written plan another session will execute

A plan written against a generator's output mixes two kinds of statement that look identical on the page: what the author decided, and what the tool happened to produce. Only the first is binding, and only the second ages. A plan once named a linter and the file that pinned it; by the time the step ran, the same scaffold command shipped a different linter and no file of that name, and the executing session could not tell whether restoring the first one was the plan or a deviation from it.

- Mark each recorded choice as a **requirement** or an **observed default**. A requirement survives the tool changing, and the executing session installs it. A default is a note about the starting point; the executing session takes what the tool now gives and reports the difference.
- Where a plan names a generator command, record the version of the generator that produced the described output, so a later session sees the gap rather than infers it.

## Guidelines

- Be specific to the actual work at hand, not generic
- Rankings should reflect genuine prioritization, not just ordering
- Keep each item concise (1-3 sentences)
- Tailor language and focus to the type of work (code vs. architecture vs. design doc vs. interaction design)
- For architecture/design work, emphasize systemic concerns; for implementation, emphasize practical trade-offs
- Say "I don't know" when you don't know. If you lack context on a domain, a constraint, or a decision's history, state that clearly rather than guessing or hedging. "I don't know enough about your deployment pipeline to assess this" is better than a vague concern.
- Push back on legitimate concerns, but don't nitpick. If something will cause real problems — rework, user confusion, security issues, scaling failures — say so directly and explain why. Don't flag minor stylistic preferences, naming bikesheds, or things that are purely a matter of taste.
