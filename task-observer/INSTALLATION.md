# Task Observer - Installation Guide

## Quick Start

1. **Download the skill file** — grab `SKILL.md` from this directory
2. **Upload to Claude Code** — use the skill upload feature in your Claude Code interface
3. **Activate in your project** — add the activation instruction to your `CLAUDE.md`

## Step-by-Step for Claude Code

### Step 1: Upload the Skill

1. Open Claude Code (CLI, desktop, or web)
2. Access the skills management interface
3. Select "Upload Custom Skill" or similar option
4. Choose the `SKILL.md` file from the `task-observer/` directory
5. Confirm the upload

### Step 2: Activate in Your Project

Add this text to your project's `CLAUDE.md` file:

```markdown
## Skill Activation

At the start of any task-oriented session — any interaction where you will
use tools and produce deliverables — invoke the task-observer skill before
beginning work. This ensures skill improvement opportunities are captured
throughout the session.

When loading any skill, check the observation log for OPEN observations
tagged to that skill. Apply their insights to the current work, even if
the skill file hasn't been updated yet.
```

### Step 3: Set Up Skill Observations Directory (Optional)

Create a `skill-observations` directory in your project root for persistent observation logging:

```
your-project/
├── skill-observations/
│   ├── log.md
│   ├── cross-cutting-principles.md
│   └── archive/
├── CLAUDE.md
└── ...
```

The skill will auto-create this structure on first use if you prefer.

## For Claude.ai Web Users

### Upload the Skill

1. Go to a Claude.ai chat session
2. Click on "Upload Files" or the attachment button
3. Select `SKILL.md`
4. The skill is now available for that session

### Persistent Use Across Sessions

Add to your **Project Instructions** (Settings → Project → Instructions):

```
At the start of any task-oriented session where you will use tools and 
produce deliverables, invoke the task-observer skill before beginning work.
```

Then upload the skill file at the start of each session, or ask Claude to 
reference it during work.

## For Cowork Users

1. Upload `SKILL.md` to your Cowork workspace
2. Add the activation instruction to your workspace `CLAUDE.md`
3. The skill will have access to persistent storage in your workspace

## What Gets Created

When activated, task-observer will create and manage:

- `skill-observations/log.md` — your observation log
- `skill-observations/cross-cutting-principles.md` — shared principles across skills
- `skill-observations/archive/` — timestamped archives of completed observations
- `skill-observations/last-review-date.txt` — tracks when reviews happen

You can delete these anytime and they'll be recreated on next use.

## Troubleshooting

**"Skill not recognized"** — Ensure the `SKILL.md` file is properly uploaded and the activation instruction is in your configuration file.

**"No observation log"** — Create the `skill-observations` directory manually, or the skill will create it on first run.

**"Previous observations lost"** — Check the `skill-observations/archive/` directory. The skill archives resolved observations monthly.

## Questions?

See the full skill documentation in `SKILL.md`, or visit the GitHub repository:
https://github.com/rebelytics/one-skill-to-rule-them-all
