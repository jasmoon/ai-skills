---
name: diary
description: A personal diary in plain Markdown files that you keep for years, and that works inside an Obsidian vault. Invoke as `diary <what you want to keep>` to add an entry, `diary find <text>` to search, `diary recent [n]` to list the last entries, and `diary review <period>` to get a digest of a week, a month or a year. The store is one Markdown file per month plus a `tags.md` that holds the vocabulary, so grep, git, Obsidian and any editor still work on it. Load when asked to keep, note, log, capture, jot, record or save a thought; for an idiom, a phrase, a word, a turn of speech, a quote, an observation about people or society, an idea for a book chapter, a project or an essay, a question to answer later; and when asked what you wrote about a topic, what you kept last week, or for a look back over a month or a year of entries.
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
shape, one date format, and one vocabulary file that stops the tags from
drifting. That discipline is what makes the store searchable in year three.

## The store

```
~/.diary/config.json       the settings of the skill
<diary_dir>/tags.md        the vocabulary: the types and the tags
<diary_dir>/2026-08.md     the entries of August
<diary_dir>/2026-09.md     the entries of September
```

### The config file

```json
{
  "diary_dir": "/home/you/diary"
}
```

| key | required | meaning |
| --- | --- | --- |
| `diary_dir` | yes | The absolute path of the directory that holds the entries. Write an absolute path. Do not write `~`. |

Read it like this:

```sh
DIARY="$(python3 -c 'import json,os;print(json.load(open(os.path.expanduser("~/.diary/config.json")))["diary_dir"])')"
```

On a machine with no `python3`, read the path with `sed` instead:

```sh
DIARY="$(sed -n 's/.*"diary_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' ~/.diary/config.json)"
```

The `sed` reader stops at the first `"`. A path that holds a `"` or a `\`
therefore reads back wrong. Use the `python3` reader on such a path.

Three rules for the config file:

- If the file is absent, run the first-run steps in section E. Do not guess a
  path, and do not write an entry to a default location.
- If `diary_dir` is absent from the file, stop and report it. Do not add the
  key on your own.
- Ignore a key that you do not know. The user owns this file. Never rewrite it
  to add a key, and never reformat it.

The month file name is `YYYY-MM.md`. The first line of a new month file is
`# YYYY-MM`. Entries go in at the bottom, so the file reads oldest first.

Warning: every command in this skill globs `"$DIARY"/[0-9]*.md`, never
`"$DIARY"/*.md`. The `[0-9]` keeps `tags.md` out of the entry search. A search
that reads `tags.md` reports the vocabulary as if it were an entry.

### The entry

```markdown
## 2026-09-13 14:22 Pour cold water on
tags: #type/idiom #language #work
source: a colleague in the standup

To discourage an idea or a plan.

> "The board poured cold water on the merger."
```

| line | rule |
| --- | --- |
| the heading | `## YYYY-MM-DD HH:MM Title`. One line. Keep the title under 60 characters. Use no `[`, `]`, `#`, `|` or `^`, so that an Obsidian link to the entry holds. |
| `tags:` | Always present. The type tag comes first, then the other tags. Lower case, one space between them, each with a `#`. |
| `source:` | Optional. Where the thought came from: a person, a book, a place, a moment. |
| `link:` | Optional. One URL. |
| the body | Free Markdown, after one blank line. An Obsidian `[[link]]` is welcome here. |

The heading and the `tags:` line together are the index of the whole store.
Every search reads those two lines first, so write a title that you recognise
later. `Pour cold water on` is a good title. `An idiom I heard` is not.

### The vocabulary

`tags.md` holds every type and every tag that this diary uses. Read it before
you write an entry.

- Every entry has exactly one `#type/...` tag.
- Every other tag must already be in `tags.md`.
- **Never invent a tag.** When no tag in the file fits, propose a new one and
  say what it means. Add it to `tags.md` only after the user agrees, in the
  same session.

This rule exists because tags drift. Month nine gives you `#society`,
`#societal` and `#people` for one idea, and then no search finds all three.

---

## A. Add an entry

`diary <what the user wants to keep>`

1. **Get the date from the clock.** Run `date +'%Y-%m-%d %H:%M'` and use that
   output. Never write a date from memory. Never write a date that you inferred
   from the conversation.
2. **Read `tags.md`.** You need the type list and the tag list.
3. **Pick the type.** Ask only when two types are equally right and the user
   gave you no lead. If two fit, the second one is not a type. Drop it.
4. **Write the title.** Take the words of the user. Do not invent a clever
   title.
5. **Write the body.** Keep the words of the user. Fix a typo and add the
   punctuation. Do not expand a short note into a paragraph.
6. **Fill what the type needs**, from the table below.
7. **Pick two or three tags from `tags.md`.** Propose a new tag only when none
   fits, and wait for the user to agree.
8. **Append the entry** with the command in "How to write the file".
9. **Commit it**, under the rules in section F. Skip this step in silence when
   `<diary_dir>` is not a git repo.
10. **Report the file and the title.** Show the entry that you wrote.

### What each type needs

| type | the entry is not complete without |
| --- | --- |
| `#type/idiom` | The meaning in one sentence, and one example of use. |
| `#type/observation` | The thing that you saw. Keep the observation and your reading of it in separate paragraphs. |
| `#type/idea` | One sentence that says what the idea is. Then the detail. For a chapter, tag the book. |
| `#type/quote` | The exact words, and the person who said them. |
| `#type/question` | The question as a question. Add what makes it hard. |
| `#type/note` | Nothing more. |

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

## 2026-09-13 14:22 Pour cold water on
tags: #type/idiom #language #work

To discourage an idea or a plan.
DIARY_ENTRY_EOF
```

Three details in that command carry the weight:

- The quoted delimiter `'DIARY_ENTRY_EOF'` stops the shell from expanding a
  `$`, a backtick or a `\` in the body of the entry.
- The blank line at the top of the heredoc separates this entry from the one
  before it.
- The `[ -f ... ]` test creates the month file with its header, one time.

Before you append, check the body for a line that starts with `## `. Change it
to `### `. A `## ` line in a body splits the entry in two for every reader and
every search.

### Fix the entry that you just wrote

The user can say "fix that" after an add. Edit the entry that this session
appended, in place. This is the one time that the skill changes an entry that
exists. See the rules in section G.

---

## B. Find an entry

`diary find <text>`

Search the heading and the tags first. Those two lines identify an entry.

```sh
DIARY="$(python3 -c 'import json,os;print(json.load(open(os.path.expanduser("~/.diary/config.json")))["diary_dir"])')"

# every entry: the heading and its tags, oldest first
grep -h -A1 '^## ' "$DIARY"/[0-9]*.md | grep -v '^--$'

# every idiom
grep -h -B1 '^tags:.*#type/idiom' "$DIARY"/[0-9]*.md | grep '^## '

# every entry with a tag
grep -h -B1 '^tags:.*#society' "$DIARY"/[0-9]*.md | grep '^## '

# a word in a title, with the file and the line
grep -in '^## .*water' "$DIARY"/[0-9]*.md

# which tags this diary really uses, and how much
grep -ho '#[a-z][a-z0-9/-]*' "$DIARY"/[0-9]*.md | sort | uniq -c | sort -rn
```

When the text can sit in a body, print the whole entry that holds it:

```sh
for f in "$DIARY"/[0-9]*.md; do
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
DIARY="$(python3 -c 'import json,os;print(json.load(open(os.path.expanduser("~/.diary/config.json")))["diary_dir"])')"
grep -h -A1 '^## ' "$DIARY"/[0-9]*.md | grep -v '^--$' | tail -40
```

Each entry is two lines of output, so `tail -40` gives 20 entries. `n` defaults
to 20. The file names sort by name into date order, so the last entry is last.
For one month, name the file: `grep -h -A1 '^## ' "$DIARY"/2026-09.md`.

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
5. **Open questions.** Every `#type/question` entry in the period that no later
   entry answers.
6. **Thin entries.** An entry that you cannot understand now. Name it, so that
   the user fixes it while the memory is fresh.

Then ask one question: **keep this digest as an entry?**

- Write it only after the user says yes.
- Write it through section A, with `tags: #type/note #review`.
- Title it `Review of <period>`.
- If the user says no, write nothing. The digest stays in the chat.

Rules for a review:

- Quote the heading of an entry when you name it. The user must find it.
- Never invent an entry, a date or a tag.
- Never merge two entries into one claim.
- Say how many entries you read, and which month files you read.
- A review changes no entry that exists.

---

## E. First run

`~/.diary/config.json` is absent. Do this:

1. Tell the user that the skill needs a directory for the diary.
2. Propose `~/diary`. Ask for a different path if they want one. If they keep
   an Obsidian vault, propose a directory inside that vault.
3. **Wait for the answer.** Do not choose a path for the user.
4. Create the directory, write the path file, and seed the vocabulary:

```sh
CHOSEN_DIR="/absolute/path/here"
mkdir -p ~/.diary "$CHOSEN_DIR"
cat > ~/.diary/config.json <<CONFIG_EOF
{
  "diary_dir": "$CHOSEN_DIR"
}
CONFIG_EOF
cat > "$CHOSEN_DIR/tags.md" <<'TAGS_EOF'
# Tags

The vocabulary of this diary. The `diary` skill reads this file before it writes
an entry. It uses a tag from this file, and it asks you before it adds a new one.

## Types

Every entry carries exactly one type tag.

| tag | what the entry holds |
| --- | --- |
| `#type/idiom` | A phrase, an idiom, a word or a turn of speech. |
| `#type/observation` | Something you noticed about people, society, work or a system. |
| `#type/idea` | Something you want to build, write or try. A chapter of a book is an idea. |
| `#type/quote` | The words of another person. |
| `#type/question` | Something you want to answer later. |
| `#type/note` | Anything that fits no other type. |

## Tags

| tag | meaning |
| --- | --- |
| `#review` | The digest of a review of a period, kept as an entry. |

Add a tag here before you use it. Keep the list short. A tag that names one
entry is not a tag.
TAGS_EOF
```

The delimiter `CONFIG_EOF` carries no quotes, so the shell expands
`$CHOSEN_DIR` into the file. This is the one heredoc in this skill that wants
expansion. The heredoc that writes an entry always keeps its quotes.

5. Offer a local git repo, with the words in section F. On a yes:

```sh
git -C "$CHOSEN_DIR" init -q
git -C "$CHOSEN_DIR" add -- tags.md
git -C "$CHOSEN_DIR" commit -q -m "diary: start the store"
```

6. Show the config file and `tags.md` to the user. Tell them that the file is theirs to edit, and
   that a tag outside it does not get used.
6. Then write the entry that they asked for.

If `diary_dir` names a directory that does not exist, stop. Report the path.
Do not create it, and do not fall back to another path. A missing directory
usually means an unmounted disk, and a fallback writes the entry where the user
never looks for it.

---

## F. The local git repo

A diary has one copy and no undo. A local git repo gives you both, and it adds
no exposure, because it has no remote.

**The skill commits to a local repo. The skill never pushes.** The difference is
the whole point: the value comes from the history, and every risk comes from the
remote.

### When the skill commits

After each write: an entry, a change to `tags.md`, a review digest that the user
kept. Before it commits, it tests three things. All three must hold.

| test | why |
| --- | --- |
| `git` is installed and `<diary_dir>` is a repo | No repo means the user did not ask for this. |
| the top level of that repo **is** `<diary_dir>` | A repo above it is the vault repo. A commit there sweeps in files that are not the diary. |
| the repo has **no remote** | A remote means the diary leaves the machine. |

Run this after the append. It does all three tests, and it reports each refusal:

```sh
if ! command -v git >/dev/null 2>&1; then
  echo "no git: nothing committed"
elif ! TOP="$(git -C "$DIARY" rev-parse --show-toplevel 2>/dev/null)"; then
  echo "not a git repo: nothing committed"
elif [ "$TOP" != "$(cd "$DIARY" && pwd -P)" ]; then
  echo "the repo is $TOP, above the diary: nothing committed"
elif [ -n "$(git -C "$DIARY" remote)" ]; then
  echo "the repo has a remote ($(git -C "$DIARY" remote | tr '\n' ' ')): nothing committed"
else
  git -C "$DIARY" add -- "$FILE"
  git -C "$DIARY" commit -q -m "diary: add an entry to $MONTH"
  echo "committed $(git -C "$DIARY" rev-parse --short HEAD)"
fi
```

Tell the user which branch ran. The two refusals matter:

- **A repo above the diary.** Say which directory holds it. If that is an
  Obsidian vault that syncs with git, the diary already leaves the machine, and
  the user probably does not know.
- **A remote.** Say the name. Then stop. Do not push, and do not offer to.

### What goes in a commit

- Stage the file that you wrote, by name. Never `git add -A` and never
  `git add .`. Both sweep in files that the user did not mean to commit.
- The message names the file and the action, never the content of an entry:
  `diary: add an entry to 2026-09`. The reason is in section G: an entry must
  not appear outside `<diary_dir>`, and a commit message is a place that gets
  copied out.
- A commit can carry an edit that the user made by hand in the same file. That
  is fine. Git keeps the version from before it either way.

### Never

- `git remote add`, `git push`, `git pull`, `git clone` to a remote.
- `git commit --amend`, `git rebase`, `git reset --hard`, `git filter-repo`,
  a force push. The history is the backup. A rewrite destroys the backup.
- `git checkout` or `git restore` over a month file. That throws away every
  entry written since the commit. Recover by hand, as below.

If the user asks for a remote, do not add one. Tell them what a remote costs:
git never forgets, so an entry that they delete stays in the history and reaches
every machine that ever clones it.

### Get a lost entry back

The user deletes an entry by accident, or edits one into nonsense. Find it:

```sh
# which commits added or removed this text?
git -C "$DIARY" log --oneline -i -S'pour cold water' --pickaxe-regex -- '*.md'

# the whole entry, as it was before the newest of those commits
SHA="$(git -C "$DIARY" log --format=%H -i -S'pour cold water' --pickaxe-regex -- '*.md' | head -1)"
git -C "$DIARY" show "$SHA^:2026-09.md" | awk '/^## 2026-09-13 14:22/ {p=1; print; next} /^## / {p=0} p'
```

`-S` searches the content of every version, so it finds an entry that no version
on disk still holds. That is the search that a plain directory cannot do.

Warning: plain `-S` matches the case exactly, and you rarely remember the case
of a lost entry. Always keep `-i` and `--pickaxe-regex` together, as above. The
pattern is then a regex, so escape a `.` or a `*` in it.

Then append the recovered text back through section A, with its original date
and time in the heading. Do not restore the whole file over the current one.

---

## G. The rules that keep the store safe

The diary holds years of work that exists in one copy. Treat it as such.

- **Append only.** Never rewrite a month file. Never sort it. Never reformat an
  old entry.
- **Never delete an entry.** The user deletes an entry in their editor.
- **One exception:** the entry that this session appended, when the user asks
  you to fix it. Change that entry alone.
- **Never write outside `<diary_dir>`.**
- **Never touch a month file other than the current one** in an add.
- **Change `tags.md` only when the user agrees to a new tag**, in that session.
- **Commit only under the rules in section F.** Never add a remote, never
  push, and never rewrite the history.
- **The diary is private.** Do not put an entry, or a part of one, into a web
  search, an API call, a commit message or any other place outside
  `<diary_dir>`.
- **Do not read the whole store** for an add. An add needs `tags.md` and the
  current month file.

## Not in scope

The skill does not do these, on purpose. Ask before you build one.

- A database, an index file or a cache.
- Sync, backup or encryption.
- A git remote, a push, or a history rewrite. Section F says why.
- An edit of an old entry.
- Analysis of an entry at add time. The skill keeps what you said. `review`
  is where interpretation happens, and only when you ask for it.

## Use it in an Obsidian vault

Put `<diary_dir>` inside the vault. Then:

- The tag pane shows a `type` tree, because `#type/idiom` is a nested tag.
- Every other tag appears there too, and `tags.md` documents what each one
  means.
- The body of an entry takes a `[[link]]` to any note in the vault.
- A link to one entry is `[[2026-09#2026-09-13 14:22 Pour cold water on]]`.
  This is why the heading holds no `[`, `]`, `#`, `|` or `^`. I did not verify
  which of those characters Obsidian rejects in a heading link. The heading
  format avoids all five.

## Recommended activation setup

The skill fires on `diary`. That is enough for most use.

Add a line to `~/.claude/CLAUDE.md` if you want the plain words to work too:

```
When I say "keep this", "note that down" or "log this", load the `diary`
skill and add an entry.
```

Without that line the skill can miss a bare "note that down", because a
description match is not reliable for a phrase that short.
