# Task Observer - Installation Guide

## Choose Your Setup

| Feature | Personal | Work |
|---------|----------|------|
| Mobile access | ✅ Via Claude.ai Web | ❌ |
| Multiple devices | ✅ With handoff docs | ✅ Multiple desktops |
| Persistent logs | ✅ Cloud synced | ✅ Local filesystem |
| Setup complexity | Medium | Low |
| Primary interface | Claude.ai Web | Claude Code or CLI |
| Sync method | Manual handoff docs | Automatic (local) |

**Personal** — if you work from multiple devices or on mobile.
**Work** — if you work from local desktops only and want persistent local logs.

You can use both simultaneously — follow each section separately for different projects.

---

## Personal Setup
### Mobile + Multiple Desktops

This setup uses Claude.ai Web as primary, with handoff docs to sync observations across devices.

#### Step 1: Upload the Skill to Claude.ai Web

Upload `SKILL.md` once as a skill in Claude.ai Web — it persists and is available across all future sessions without re-uploading.

1. Open Claude.ai Web
2. Go to the skills interface and upload `SKILL.md`
3. The skill is now available in every session

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

Since the skill is uploaded once and persisted in Claude.ai Web, no re-upload is needed on mobile:

1. Open Claude.ai Web in your browser
2. Start your session — the skill is already available
3. At session end, save the handoff doc to your cloud folder
4. On your next device, open Claude.ai Web and paste the handoff doc to restore observations

#### Step 5: Syncing SKILL.md Updates

When there are updates to `SKILL.md`:

1. Go to the Claude.ai Web skills interface and replace the existing skill with the updated `SKILL.md`
2. The update is then live for all future sessions
3. For quick tweaks, copy the updated section directly into your Project Instructions instead

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

#### Step 4: Syncing SKILL.md Updates

**Recommended (Auto-sync):**
1. Edit `task-observer/SKILL.md` in your repository
2. Commit the changes to git
3. Claude Code reads the live file on each session start — no re-upload needed

**To enable auto-sync**, add this to your `CLAUDE.md`:

```markdown
## Skills

The task-observer skill is stored in the project at: `task-observer/SKILL.md`
Claude Code reads this file at session start, so updates sync automatically.
```

**If manual re-upload is needed:**
1. Edit `task-observer/SKILL.md` locally
2. In Claude Code, re-upload via the skills management interface
3. Restart your session to load the updated skill

**Multiple desktops:** Keep `task-observer/` in a git repository or shared workspace so all desktops access the same `SKILL.md`.

---

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
