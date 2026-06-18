# Updating Task Observer - Quick Reference

Made changes to `SKILL.md`? Here's how to sync them across your setups.

---

## Personal Setup (Mobile + Multiple Desktops)

### Quick Update

**Option 1: Replace the skill in Claude.ai Web**
1. Go to the Claude.ai Web skills interface
2. Replace the existing skill with the updated `SKILL.md`
3. Done — changes take effect for all future sessions

**Option 2: Inline update** (for small changes)
1. Edit the specific section directly in your Claude.ai Project Instructions
2. No file upload needed
3. Works well for quick tweaks

### Best Practice

- Keep the canonical `SKILL.md` in your repository (source of truth)
- When updating, replace the skill via the Claude.ai Web skills interface

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
| Replace skill file | ✅ | ✅ | Medium | Manual |
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
