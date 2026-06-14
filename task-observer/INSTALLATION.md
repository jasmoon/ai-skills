# Task Observer - Installation Guide

**First time?** Start with [SETUP-GUIDE.md](SETUP-GUIDE.md) to choose between Personal or Work setup.

---

## Personal Setup
### Mobile + Multiple Desktops

This setup uses Claude.ai Web as primary, with handoff docs to sync observations across devices.

#### Step 1: Upload the Skill to Claude.ai Web

1. Go to a Claude.ai chat session
2. Click on "Upload Files" or the attachment button
3. Select `SKILL.md` from this directory
4. The skill is now available for that session

#### Step 2: Activate in Your Project Instructions

Add to your **Project Instructions** (Settings → Project → Instructions):

```
At the start of any task-oriented session where you will use tools and 
produce deliverables, invoke the task-observer skill before beginning work.

When the session winds down, ask the skill to generate a handoff document
with all observations. Copy this to your cloud storage (Dropbox, iCloud, etc.)
for access across devices.
```

#### Step 3: Set Up Cross-Device Sync (Optional)

Create a cloud-synced folder for observation handoff docs:
- **Dropbox:** `~/Dropbox/claude-observations/`
- **iCloud:** `~/Library/Mobile Documents/com~apple~CloudDocs/claude-observations/`
- **Google Drive:** `~/Google Drive/claude-observations/`

Store handoff docs here, then paste them into the next session to restore context.

#### Step 4: Mobile Workflow

On mobile devices:
1. Use Claude.ai Web in your browser
2. Upload `SKILL.md` at the start of each session
3. At session end, save the handoff doc to your cloud folder
4. On your next device, retrieve and paste it to restore observations

---

## Work Setup
### Local Desktops Only

This setup uses Claude Code as primary, with persistent local storage.

#### Step 1: Upload the Skill to Claude Code

1. Open Claude Code (CLI, desktop, or web)
2. Access the skills management interface
3. Select "Upload Custom Skill" or similar option
4. Choose the `SKILL.md` file from the `task-observer/` directory
5. Confirm the upload

#### Step 2: Activate in Your Project

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

#### Step 3: Set Up Skill Observations Directory (Optional)

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

---

## For Claude Code Users (Work Setup)

Multiple desktops — set up the skill in each project following steps 1-3 above.

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