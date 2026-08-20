# AI Skills

Skills for Claude Code, and the global instructions that I recommend with them.

| Path | What it holds |
| --- | --- |
| `CLAUDE.global.md` | Ground rules and writing rules to copy into your own setup |
| `check-global-subset.sh` | A check that keeps that file honest |
| One directory per skill | Six skills, listed below |

## The skills

| Skill | When it fires |
| --- | --- |
| `first-real-run` | Before code meets real data or a live system for the first time. Also the first move when a run returns nothing, or the wrong shape. |
| `housekeep` | When the records and the code disagree. `docs` audits written records. `code` audits the source. |
| `plan-next-steps` | When you want the design decisions, the concerns and the open questions on the current work. It asks you questions first. |
| `polite-external-probing` | Before any request to infrastructure that you do not own. Covers the first fetch, the delay between requests, and a 403 or a 429. |
| `task-observer` | During a work session, to catch a pattern that is worth a new skill. Written by Eoghan Henn, [rebelytics.com](https://rebelytics.com). |
| `validate-extraction-output` | Before you report a number that came from data you extracted, parsed or ingested. |

### Install a skill

Copy the directory into `~/.claude/skills/`:

```sh
cp -r validate-extraction-output ~/.claude/skills/
```

Claude Code reads the skill from `~/.claude/skills/<name>/SKILL.md`. For one
project only, copy it to `.claude/skills/` in that project instead.

The copy does not track this repo. Copy the directory again after you change a
skill here.

### Four of them need a line in your CLAUDE.md

`first-real-run`, `polite-external-probing`, `validate-extraction-output` and
`task-observer` all say the same thing in their own words. A skill fires when its
description matches what you asked for. That match is not reliable for a gate that
must fire at a set moment, such as before the first live run, or after the last
number is counted. Each skill ships a short trigger block for you to paste into the
`CLAUDE.md` of a project that does that kind of work.

## The global instructions

`CLAUDE.global.md` holds seven ground rules and the writing rules. Copy everything
below the `---` marker. Two places take it:

- Claude Code on your computer: the file `~/.claude/CLAUDE.md`.
- Claude Code on web and on desktop: the "Instructions for Claude" field.

The file is named `CLAUDE.global.md`, not `CLAUDE.md`, on purpose. A file named
`CLAUDE.md` at the root of a repo loads into every session that works in that repo.
This file is a template for your own global settings. It is not guidance for work
in this repo, so it must not load here.

### The check

`CLAUDE.global.md` is a subset of a larger personal file. Every rule below the
marker must also appear, word for word, in `~/.claude/CLAUDE.md`. The script
compares the two:

```sh
bash check-global-subset.sh [template] [global]
```

It defaults to `CLAUDE.global.md` and to `~/.claude/CLAUDE.md`.

| Exit | Meaning |
| --- | --- |
| 0 | Every rule below the marker is in the global file |
| 1 | A rule is missing. The script names each one |
| 2 | A file is absent, the `---` marker is absent, or no line sits below the marker |
