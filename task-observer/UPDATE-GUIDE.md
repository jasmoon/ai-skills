# Updating Task Observer - Quick Reference

Made changes to `SKILL.md`? Here's how to sync them across your setups.

---

## Personal Setup (Mobile + Multiple Desktops)

### Quick Update

**Option 1: Re-upload the file**
1. Save updated `SKILL.md` to your cloud storage folder
2. In your next Claude.ai Web session, upload the latest `SKILL.md`
3. Done — changes take effect immediately

**Option 2: Inline update** (for small changes)
1. Edit the specific section directly in your Claude.ai Project Instructions
2. No file upload needed
3. Works well for quick tweaks

### Best Practice

- Keep `SKILL.md` in your cloud folder (Dropbox/iCloud/Google Drive)
- At the start of each session, upload the latest version
- Or maintain a "master" copy in your project instructions that you update manually

---

## Work Setup (Local Desktops Only)

### Auto-Sync (Recommended)

1. Edit `task-observer/SKILL.md` in your project
2. Commit to git: `git add task-observer/SKILL.md && git commit -m "Update skill"`
3. Claude Code automatically reads the live file on session start
4. No upload needed — changes are live

**Requirement:** Your `CLAUDE.md` must reference the skill:
```markdown
## Skills
The task-observer skill is stored in: `task-observer/SKILL.md`
```

### Manual Re-Upload (if needed)

1. Edit `task-observer/SKILL.md`
2. In Claude Code, open skills management
3. Re-upload the updated `SKILL.md`
4. Restart your session

### Multiple Desktops

- Keep `task-observer/` in a shared git repo or cloud workspace
- All desktops pull the same version
- Changes sync automatically via git

---

## Comparison

| Method | Personal | Work | Effort | Sync Time |
|--------|----------|------|--------|----------|
| Re-upload file | ✅ | ✅ | Medium | Manual |
| Inline edit | ✅ | ❌ | Low | Immediate |
| Auto-sync (git) | ❌ | ✅ | Low | Automatic |

---

## Tips

- **Test changes first** in a single session before rolling out
- **Commit regularly** to git for the work setup (easier to rollback)
- **Keep a changelog** if your skill evolves significantly
- **Version your skill** in SKILL.md metadata if tracking versions

---

See [INSTALLATION.md](INSTALLATION.md) for detailed setup instructions.