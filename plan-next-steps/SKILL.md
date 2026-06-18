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

### 3. Top Concerns (up to 4, ranked by importance)
Identify concerns about the current design or approach, if applicable. Rank them from most to least critical. For each, briefly state the concern and its potential impact. If there are no concerns, say so.

These may include: scalability risks, coupling issues, unclear ownership, missing error handling, UX friction, accessibility gaps, security surface, maintainability debt, etc.

### 4. Top Questions About the Work (up to 6, ranked by importance)
Identify open questions about the work that should be answered to move forward effectively. These are questions for the user or team to consider — things that are unresolved, ambiguous, or worth discussing.

These may include: unspecified edge cases, unclear user flows, missing acceptance criteria, dependency unknowns, deployment considerations, etc.

### 5. Before You Close This Session
Identify anything worth doing before the session ends. This could include:
- Uncommitted changes that should be committed or stashed
- TODOs or decisions that should be captured somewhere (memory, a file, a comment)
- Quick fixes or cleanups that would be costly to context-switch back into later
- Notes to leave for the next session

If there's nothing urgent, say so.

## Guidelines

- Be specific to the actual work at hand, not generic
- Rankings should reflect genuine prioritization, not just ordering
- Keep each item concise (1-3 sentences)
- Tailor language and focus to the type of work (code vs. architecture vs. design doc vs. interaction design)
- For architecture/design work, emphasize systemic concerns; for implementation, emphasize practical trade-offs
- Say "I don't know" when you don't know. If you lack context on a domain, a constraint, or a decision's history, state that clearly rather than guessing or hedging. "I don't know enough about your deployment pipeline to assess this" is better than a vague concern.
- Push back on legitimate concerns, but don't nitpick. If something will cause real problems — rework, user confusion, security issues, scaling failures — say so directly and explain why. Don't flag minor stylistic preferences, naming bikesheds, or things that are purely a matter of taste.
