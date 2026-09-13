---
name: diary
description: A personal diary in plain Markdown files that you keep for years. Invoke as `diary <what you want to keep>` to add an entry, `diary find <text>` to search, `diary recent [n]` to list the last entries, and `diary review <period>` to get a digest of a week, a month or a year. The store is one Markdown file per month in a directory that you choose, so grep, git and any editor still work on it. Load when asked to keep, note, log, capture, jot, record or save a thought; for an idiom, a phrase, a word, a turn of speech, a quote, an observation about people or society, an idea for a book chapter, a project or an essay, a question to answer later; and when asked what you wrote about a topic, what you kept last week, or for a look back over a month or a year of entries.
---

# diary

A place to keep a thought, so that you find it again in three years.

## Why this exists

A thought that you do not write down is gone. A thought that you write into a
chat window is also gone, because you cannot grep a chat window in 2029.

The store is therefore boring on purpose:

- Plain Markdown, one file per month.
- One directory that you own, on your disk.
- No database, no index, no lock file, no sync.

The skill adds the discipline that a plain directory does not have: one entry
shape, one date format, one small list of types. That is what makes the store
searchable later.

## The store

### The config file

The skill reads `~/.diary/config.json`:

```json
{
  "diary_dir": "/home/you/diary",
  "types": ["idiom", "observation", "idea", "quote", "question", "note"]
}
```

| key | meaning |
| --- | --- |
| `diary_dir` | The absolute path of the directory that holds the month files. Write an absolute path. Do not write `~`. |
| `types` | The list of entry types. The user edits this list. The skill never adds a type on its own. |

If the config file is absent, run the first-run steps in section E. Do not guess
a path, and do not write an entry to a default location.

### The layout

```
<diary_dir>/
  2026-08.md
  2026-09.md
  2026-10.md
```

One file per month. The file name is `YYYY-MM.md`. The first line of a new file
is `# YYYY-MM`. Entries go in at the bottom, so the file reads oldest first.

### The entry

```markdown
## 2026-09-13 14:22 [idiom] Pour cold water on
tags: language, work
source: a colleague in the standup

To discourage an idea or a plan.

> "The board poured cold water on the merger."
```

| line | rule |
| --- | --- |
| the heading | `## YYYY-MM-DD HH:MM [type] Title`. One line. Keep the title under 60 characters. |
| `tags:` | Always present. Lower case, comma separated. Write `tags: -` when there is no tag. |
| `source:` | Optional. Where the thought came from: a person, a book, a place, a moment. |
| `link:` | Optional. One URL. |
| the body | Free Markdown, after one blank line. |

The heading line is the index of the whole store. Every search starts there, so
write a title that you recognise later. `Pour cold water on` is a good title.
`An idiom I heard` is not.

### The types

| type | what it holds |
| --- | --- |
| `idiom` | A phrase, an idiom, a word or a turn of speech. Give the meaning and one example of use. |
| `observation` | Something that you noticed about people, society, work or a system. |
| `idea` | Something that you want to build, write or try. A chapter of a book is an idea. |
| `quote` | The words of another person. Name the person. |
| `question` | Something that you want to answer later. |
| `note` | Anything that fits no other type. |

Pick exactly one type. If two types fit, pick the one that the user leads with,
and put the second one in the tags.

---

## A. Add an entry

`diary <what the user wants to keep>`

1. **Get the date from the clock.** Run `date +'%Y-%m-%d %H:%M'` and use that
   output. Never write a date from memory. Never write a date that you inferred
   from the conversation.
2. **Pick the type** from the `types` list in the config. Ask only when two
   types are equally right and the user gave you no lead.
3. **Write the title.** Take the words of the user. Do not invent a clever
   title.
4. **Write the body.** Keep the words of the user. Fix a typo and add the
   punctuation. Do not expand a short note into a paragraph.
5. **Fill the type template** below.
6. **Add tags.** Two or three, lower case. Reuse a tag that the store already
   holds: `grep -h '^tags:' "$DIARY"/*.md | sort | uniq -c | sort -rn | head -30`.
   A new tag for every entry makes the tags useless.
7. **Append the entry** with the command in "How to write the file".
8. **Report the file and the title.** Show the entry that you wrote.

### What each type needs

| type | the entry is not complete without |
| --- | --- |
| `idiom` | The meaning in one sentence, and one example of use. |
| `observation` | The thing that you saw. Keep the observation and your reading of it in separate paragraphs. |
| `idea` | One sentence that says what the idea is. Then the detail. For a chapter, name the book in the tags. |
| `quote` | The exact words, and the person who said them. |
| `question` | The question as a question. Add what makes it hard. |
| `note` | Nothing more. |

**Ask, do not fill a gap.** If the user gives an idiom and no meaning, ask for
the meaning in one short question. Do not write a meaning that you inferred. A
diary that holds your guesses is worth less than an empty one.

### How to write the file

Warning: a wrong redirect operator destroys a month of entries. Use `>>`, never
`>`, on a month file.

```sh
DIARY="$(python3 -c 'import json,os;print(json.load(open(os.path.expanduser("~/.diary/config.json")))["diary_dir"])')"
MONTH="$(date +%Y-%m)"
FILE="$DIARY/$MONTH.md"
[ -f "$FILE" ] || printf '# %s\n' "$MONTH" > "$FILE"
cat >> "$FILE" <<'DIARY_ENTRY_EOF'

## 2026-09-13 14:22 [idiom] Pour cold water on
tags: language, work

To discourage an idea or a plan.
DIARY_ENTRY_EOF
```

Three details in that command carry the weight:

- The quoted delimiter `'DIARY_ENTRY_EOF'` stops the shell from expanding a
  `$`, a backtick or a `\` in the body of the entry.
- The blank line at the top of the heredoc separates this entry from the one
  before it.
- The `[ -f ... ]` test creates the month file with its header, one time.

On a machine with no `python3`, read the path with `sed` instead:

```sh
DIARY="$(sed -n 's/.*"diary_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' ~/.diary/config.json)"
```

Before you append, check the body for a line that starts with `## `. Change it
to `### `. A `## ` line in a body splits the entry in two for every reader and
every search.

### Fix the entry that you just wrote

The user can say "fix that" after an add. Edit the entry that this session
appended, in place. This is the one time that the skill changes an entry that
exists. See the rules in section F.

---

## B. Find an entry

`diary find <text>`

Search the headings first. They hold the date, the type and the title, so one
line of output identifies an entry.

```sh
# every entry, newest last
grep -h '^## ' "$DIARY"/*.md

# every idiom
grep -n '^## .*\[idiom\]' "$DIARY"/*.md

# every entry with a tag
grep -n '^tags:.*society' "$DIARY"/*.md

# a word in a title
grep -in '^## .*water' "$DIARY"/*.md
```

When the text can sit in a body, print the whole entry that holds it:

```sh
for f in "$DIARY"/*.md; do
  awk -v pat="pour cold water" -v f="$f" '
    /^## / { if (hit && ln) printf "%s:%d\n%s\n", f, ln, blk; blk = ""; hit = 0; ln = FNR }
             { blk = blk $0 "\n"; if (index(tolower($0), pat)) hit = 1 }
    END    { if (hit && ln) printf "%s:%d\n%s\n", f, ln, blk }
  ' "$f"
done
```

Give `pat` in lower case. The snippet lowers each line before it compares, so
the search ignores case. The snippet uses POSIX awk only. I ran it under
mawk 1.3.4 on Linux. I did not test it under the awk that macOS ships.

Report the count of entries that matched. If nothing matched, say so and offer
a wider search. Do not answer from the entries that you remember from earlier in
the session.

---

## C. List recent entries

`diary recent [n]`

```sh
grep -h '^## ' "$DIARY"/*.md | tail -20
```

The file names sort by name into date order, so the last line is the last entry.
`n` defaults to 20. For a period instead of a count, name the month files:
`grep -h '^## ' "$DIARY"/2026-09.md`.

---

## D. Review a period

`diary review <period>` — a week, a month, a quarter, a year.

Read every entry in the period. Then write the digest:

1. **What you kept.** The count of entries, and the count per type.
2. **Themes.** A subject that three or more entries touch. Quote the heading of
   each entry that you count. Two entries are a pair, not a theme. Say "a pair"
   and move on.
3. **Repeats.** The same thought, kept twice. This is the most useful output of
   a review, because a thought that returns is a thought that matters.
4. **Worth development.** The entries that are ready to become something: an
   essay, a chapter, a talk. Say what each one needs next.
5. **Open questions.** Every `question` entry in the period that no later entry
   answers.
6. **Thin entries.** An entry that you cannot understand now. Name it, so that
   the user fixes it while the memory is fresh.

Rules for a review:

- Quote the heading of an entry when you name it. The user must find it.
- Never invent an entry, a date or a tag.
- Never merge two entries into one claim.
- Say how many entries you read, and which month files you read.
- A review writes nothing to the store. If the user wants the digest kept, add
  it as one `note` entry through section A.

---

## E. First run

The config file is absent. Do this:

1. Tell the user that the skill needs a directory for the diary.
2. Propose `~/diary`. Ask for a different path if they want one.
3. **Wait for the answer.** Do not choose a path for the user.
4. Create the directory and write the config:

```sh
mkdir -p ~/.diary "$CHOSEN_DIR"
cat > ~/.diary/config.json <<'CONFIG_EOF'
{
  "diary_dir": "/absolute/path/here",
  "types": ["idiom", "observation", "idea", "quote", "question", "note"]
}
CONFIG_EOF
```

5. Show the config to the user. Tell them that the `types` list is theirs to
   edit.
6. Then write the entry that they asked for.

If `diary_dir` in the config names a directory that does not exist, stop. Report
the path. Do not create it, and do not fall back to another path. A missing
directory usually means an unmounted disk, and a fallback writes the entry
where the user never looks for it.

---

## F. The rules that keep the store safe

The diary holds years of work that exists in one copy. Treat it as such.

- **Append only.** Never rewrite a month file. Never sort it. Never reformat an
  old entry.
- **Never delete an entry.** The user deletes an entry in their editor.
- **One exception:** the entry that this session appended, when the user asks
  you to fix it. Change that entry alone.
- **Never write outside `diary_dir`.**
- **Never touch a month file other than the current one** in an add.
- **Do not commit the diary to git**, and do not run `git` in `diary_dir`,
  unless the user asks in that session.
- **The diary is private.** Do not put an entry, or a part of one, into a web
  search, an API call, a commit message or any other place outside
  `diary_dir`.
- **Do not read the whole store** for an add. An add needs the tag list and the
  current month file.

## Not in scope

The skill does not do these, on purpose. Ask before you build one.

- A database, an index file or a cache.
- Sync, backup or encryption.
- A git commit after each entry.
- An edit of an old entry.
- Analysis of an entry at add time. The skill keeps what you said. `review`
  is where interpretation happens, and only when you ask for it.

## Recommended activation setup

The skill fires on `diary`. That is enough for most use.

Add a line to `~/.claude/CLAUDE.md` if you want the plain words to work too:

```
When I say "keep this", "note that down" or "log this", load the `diary`
skill and add an entry.
```

Without that line the skill can miss a bare "note that down", because a
description match is not reliable for a phrase that short.
