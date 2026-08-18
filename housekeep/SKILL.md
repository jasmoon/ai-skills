---
name: housekeep
description: Bring a project's records and code back into agreement. Two halves - `docs` audits written records (decisions, issues, observations, diagrams) and never touches source; `code` audits the source itself (structure, comments, guards) and can move modules and edit comments. Invoke as `housekeep <target>`, or `housekeep docs` / `housekeep code` / `housekeep all` to run a whole half. Default mode reads the session or branch diff and asks what it invalidated; --full extracts every checkable assertion and verifies it against current source. Always proposes before it writes. Load when asked to housekeep, tidy, audit, reconcile or update docs, a design-decision log, an ADR directory, an open-issues list, a TODO file, an observation log or a diagram; when deciding whether a package has earned a subfolder or reconciling a rename; when comments have drifted from what they describe; when asking whether the test suite really guards something; at the end of a session that changed behaviour; whenever a decision may have been superseded or an issue closed by the work just done.
---

# housekeep

A written record is a claim about the world at a moment. Every entry silently
asserts that its premises still hold. Code moves and the record does not, so the
two drift apart quietly — nothing fails, and the document keeps reading as
though it were true.

`housekeep` is the deliberate pass that closes that gap. It is not a gate and it
does not fire on its own. You run it, on a named target, and it hands you a
proposal.

## Two halves, split by what they can damage

| half | targets | touches | worst case |
| --- | --- | --- | --- |
| `docs` | `decisions` `issues` `observations` `diagrams` | records only | a wrong sentence |
| `code` | `structure` `comments` `guards` | source files | a half-done rename |

That is the whole reason for the split, and it is worth knowing before you run
anything. A `docs` pass ends when the record agrees with the code. A `code` pass
ends when **the code still runs**, which is a different and stronger claim, and
which the test suite frequently cannot settle on its own.

## Usage

```
housekeep <target> [--full]
housekeep code structure <package>
housekeep code structure --since <ref>
```

| invocation | what runs |
| --- | --- |
| `housekeep decisions` | that one target |
| `housekeep code comments` | that one target, spelled out in full |
| `housekeep docs` | every `docs` target, reported separately |
| `housekeep code` | every `code` target, reported separately |
| `housekeep all` | both halves |

**The half is a selector, not a required namespace.** `housekeep decisions` and
`housekeep docs decisions` are the same thing; nobody should have to remember
which half a target lives in to run it. Require the two-word form only if a name
ever appears in both halves — and if that happens, say so rather than silently
picking one.

No target given: ask which one. Do not guess, and do not silently run `all` — a
full sweep is a long pass and the user may want one target.

## Two modes, and they find different things

**Default — from the diff.** Start from what changed in this session or on this
branch. For each change, ask which entries in the record asserted something the
change has now made false. Cheap enough to run at the end of any session that
changed behaviour.

**`--full` — from the record.** Start from the record. Extract every checkable
assertion in it and verify each against current source. This is the only mode
that finds an entry made stale three weeks ago by work that never came near it.

Neither subsumes the other. The diff mode cannot see old rot; the full mode is
too expensive to run habitually. Say which mode produced each finding, because a
reader weighs them differently.

## The method

Six steps, in this order, for every target in either half.

### 1. Read the record's own stated convention first

Almost every record worth auditing documents how it wants to be maintained — a
"how to read an entry" section, a status vocabulary, a rule for closing an item,
a note on what the file deliberately omits. Find it and follow it.

This is the difference between housekeeping and rewriting. A proposal that
ignores the project's recorded reasoning is not a second opinion, it is a
regression. The convention also supplies the *units* — what counts as superseded
here, whether a closed issue is deleted or struck through, whether ids are
reused — and those are not guessable.

**This step earns its place most often on `code structure`.** In the run that
produced this skill, a pass proposed finishing a half-applied rename: the modules
had been renamed and the operator-facing command names had not. The decision log
had already ruled on exactly that, and the unchanged command names were the
decisive row of its cost table — the reason the move was judged cheap. The
proposal would have invalidated the decision's own justification. Nothing about
the code said so; only the record did.

If the record states no convention, say so as a finding. A record nobody has
told how to age is the one that ages worst.

### 2. Let the test suite do what it already does

Before checking anything by hand, run the suite and look for guards that already
cover the mechanical half: a test that resolves documented file paths, one that
imports documented dotted references, one that parses every diagram. Those catch
renames and broken citations better than reading does.

Two consequences:

* **Do not re-derive by hand what a passing test already proves.** Spend the
  pass on semantic staleness instead — the claims no test can express.
* **If no such guard exists, that is a finding in its own right.** Propose the
  guard. A record checked once by hand goes stale again the same week; a record
  checked by the suite cannot. This recurs often enough to have its own target —
  see `guards`.

### 3. Extract the checkable assertions before reading for narrative

Go through the record pulling out claims a machine or a grep can settle:

* file and module paths, and whether they resolve
* function, class and constant names, and whether they still exist
* constant *values* quoted in prose, and whether they still match
* verbatim lists — of columns, of statuses, of buckets — and whether they have
  grown or shrunk
* counts stated in prose that grow with the file: "seven entries carry one today"
* "not yet implemented", "there is no such function", "currently one request per
  row" — negative and exclusive claims, which rot fastest because the work that
  falsifies them never revisits the sentence

Check these against the source **first**. Read the document for narrative
second. Reading end to end finds the contradictions the document already
contains; only the code finds the ones it is missing, and those are the larger
class.

**Verify against behaviour, never against a comment.** A code comment is a
record too, and it is the one you will mistake for evidence: it sits next to the
code, so a claim it confirms feels checked. It is not. A comment agreeing with a
document is not corroboration — it is the same claim written twice, by someone
who had the same picture. Read what the function *does*.

This is not hypothetical, and both halves of it show up together. A run that
found a diagram claiming "one request per row" also found the function's own
docstring opening with the same words, twenty-six lines above the code that
explains the batched call which replaced it. Either one alone reads as
confirmation of the other.

So when a comment turns out to be stale, **do not propose a more accurate
comment.** The document is the source of truth; the comment should cite it and
stop — `# null-only fill; see decision N`. See `code comments`.

### 4. Ask what the record does not cover

Every step so far checks whether what the record says is true. This one asks
whether it says enough, and there is one gap worth checking by name.

**Write permission is the half that goes unwritten.** Mechanics get documented
because they are what you were thinking about while building them. The rules
governing what a path may overwrite, what it may only propose, and what it must
never be mistaken for are the expensive half, and they are the half that ends up
implicit. So walk the write paths and ask, for each: does the record say what
this may overwrite?

A stated rule is also what makes the next drift *findable*. In the run this step
came from, the record did state the rule — "only where null, and that is the one
write that reaches this column" — and a second write path appeared four days
later. The claim being written down is why it could be caught at all. Where no
such rule is recorded, nothing can contradict anything.

### 5. Build the cross-reference map as its own step

Note which entry is cited by which later entry. An entry that later entries lean
on, but which points forward to none of them, is where staleness accumulates —
it is load-bearing and nothing has revisited it.

### 6. Separate the three verdicts, and never conflate them

| verdict | what it means | what to do |
| --- | --- | --- |
| **superseded** | a later decision replaced this one | mark it, keep it, link forward |
| **stale** | the claim was true and the code moved | correct the claim, note when |
| **wrong** | the claim was never true | correct it and say it was an error |

Superseded is the common one and the one most often mishandled. **Do not rewrite
a superseded entry to look as though it was always right.** The reason to keep
it is that it explains the shape of what replaced it. Mark the passage in place,
add the forward link, leave the reasoning standing.

---

# The `docs` half

## `docs decisions`

Find the record's status vocabulary and its supersession convention before
touching anything — how a superseded entry is marked, whether a forward link
lives on the old entry or the new one, whether the superseded passage is struck
out, quoted, annotated in place or left alone.

Then look for four things:

1. **Direct contradiction.** Two entries stating opposite things about the same
   module, column or rule. Reading finds these.
2. **Silent closure.** An entry that leaves a question open, where later work
   answered it and never amended the entry. Only the code finds these.
3. **Quoted specifics that moved.** A list of columns that has grown, a
   threshold that changed, a function that was renamed.
4. **A decision implemented differently from how it was written.** The entry
   describes the intent; the code took another route. Both may be fine — the fix
   is usually a note, not a reversal.

Where an entry is superseded, the new decision must exist. If the work happened
but no decision records it, the proposal is to *write* that decision, not just
to mark the old one dead.

## `docs issues`

For each open issue, establish what would have to be true for it to be closed,
then check whether it is. Three outcomes, and keep them apart:

* **closed** — the thing works now. Close it by the record's own convention
  (delete the entry, strike it, move it to a closed section) and migrate the
  reasoning wherever the convention says reasoning goes.
* **advanced** — part of it shipped. Rewrite the entry to state what is left,
  not what was originally wrong. An issue that still describes a problem half of
  which is fixed will be re-diagnosed from scratch by the next reader.
* **still open** — leave it, but check its evidence still resolves. An issue
  citing a file that moved is an issue nobody can act on.

Watch for issues **opened** by the session's work. A housekeep pass that only
closes things is measuring in one direction.

Watch also for an absolute that has quietly acquired an exception — "nothing is
scheduled", "no read path filters this". The issue's substance can be intact
while its opening sentence has become false, and the fix is to narrow the claim
rather than to close the issue.

If ids are stable and never reused, do not reuse them. A gap in the sequence is
information.

## `docs observations`

Two distinct jobs, in this order:

1. **Resolve.** For each OPEN observation, check whether the work it asked for
   has since been done — a skill updated, a rule folded into a CLAUDE.md, a
   guard added. If so, mark it ACTIONED and name where it landed. An observation
   whose fix exists but which still reads OPEN makes every future review
   re-examine it.
2. **Archive hygiene.** Resolved entries belong in the archive, by whatever rule
   the log states. Check the live log for entries that should have moved and did
   not, check the numbering is a single unbroken sequence, and check every entry
   carries the fields the convention requires.

**A partial fold is not a resolution.** Where a skill absorbs one instance of an
observation's principle but not the principle itself, say so in the entry and
leave it OPEN. Banking the closure is tempting because the work was real; the
cost is that the remaining half stops being visible to any future review.

Also check for a **second copy of the log**. A repo that keeps its own log
alongside a shared one splits every review in half, and each copy invents its
own numbering. If one exists, the proposal is to migrate its entries into the
shared sequence and delete the copy — never to merge the two files.

An observation the user has declined is not resolved. Mark it DECLINED with the
reason; do not delete it and do not leave it OPEN.

## `docs diagrams`

**Run the parser.** Every diagram format has one, and reading the source is a
guess that is most confident exactly where the syntax looks simplest. Parse
before anything else — and when the parser reports failures, confirm they are
the diagram's and not the harness's. A first run that reports every file broken
is usually a line-ending or a missing-DOM problem in the runner.

Then check the diagram against the code it draws:

* every node naming a constant, function or module — does it still exist under
  that name?
* every branch — does the code still branch there, and in that order?
* every artifact path — does the pipeline still write it there?
* the index or README listing the diagrams — does it list exactly the files that
  exist?

Respect what the diagrams deliberately omit. If the record says diagrams carry
constant *names* and not values, or carry no record counts, do not "improve" one
by inlining a number — that omission is what stops the diagram from disagreeing
with the module.

A diagram whose *claim* is now wrong is not a diagram to patch. Say the claim
has changed and propose redrawing it.

---

# The `code` half

These edit source. Everything in the propose-then-apply section below applies
with more force, and each carries a verification step the `docs` targets do not
need.

## `code structure`

Two modes, and they are different jobs.

```
housekeep code structure <package>      does this package hold a cluster
                                        that has earned a subfolder?
housekeep code structure --since <ref>  a move already happened; reconcile
                                        everything it left behind
```

**Do not take a destination as an argument.** A caller who supplies
`pkg/newthing/` has already made the decision the measurement exists to make,
and the pass degenerates into justifying a grouping picked by eye. The
destination is the output.

### Classify the package before measuring it

This is the step that makes the measurement mean anything.

| the package is | the instrument |
| --- | --- |
| **imported by other code** | the import graph: internal edges high, external fan-in low |
| **invoked by a human** | data flow between artifacts, shared name prefixes, the order an operator runs them, and the grouping the command runner's help text already asserts |

**State which instrument you are using and why.** The import graph returns *no
signal at all* for a package of entry points — every command has zero importers,
because commands are invoked, not imported. Applying it there concludes "no
cluster exists anywhere", which is a fact about the instrument and not about the
code. A zero-signal result has to be readable as "wrong instrument".

### Reconciling the move

The rename is the expensive part, not the move. Take the rename map from git —
`git diff --name-status --find-renames` against the merge base returns old path,
new path and a similarity score for every one. **Do not have it typed.** A typed
list is a list that silently omits the module someone forgot, and the omission
looks exactly like a clean run.

Then reconcile, in descending order of what tooling can find for you:

* imports and dotted references — the compiler and the suite find these
* documented file paths — a doc-path guard finds these, if one exists
* **bare module names in running prose** — nothing finds these. They are the
  class that gets rewritten by hand, and the count is usually larger than
  anyone expects
* command-runner targets, entry-point strings in configs, test filenames
* comments inside the moved modules describing where they used to sit

### Verify that it still runs — the suite will not tell you

This is why `structure` is a `code` target and not a `docs` one, and it is the
step most likely to be skipped, because the suite is green and green feels like
an answer.

1. **Suite green.** Necessary, and it proves imports resolve. It proves nothing
   about invocation: the modules that moved have zero importers, so no test
   invokes them.
2. **Every entry point resolves**, driven from the command runner's own target
   list rather than a list you wrote. Resolve the name without importing it
   where import has side effects.
3. **Run at least one moved command for real**, in its dry-run mode, against a
   real upstream artifact rather than a fixture. A fixture confirms the code
   matches its author's model of the data; only the real artifact can show the
   model is wrong.
4. **If something fails, do not diagnose it from the module's comments.** A
   moved module's header describes where it used to live and what used to call
   it. Multiple sufficient causes can be true at once while only one is
   operative, and evidence gathered by reading will confirm the wrong one
   indefinitely.

**The move and the reconciliation land together or not at all.** A half-done
rename is worse than no rename: the suite passes, the docs lie, and the next
person to touch it inherits both.

## `code comments`

Narrow on purpose. This is **not** "find comments that describe changed code",
which is unbounded and mostly low value. It is one thing:

> Find comments that **restate a record** instead of citing it.

Those are findable. They are the comments reproducing a decision's reasoning,
its evidence, its numbers or its rule — often nearly verbatim, because they were
written by whoever wrote the record, on the same day.

Why they matter more than an ordinary stale comment: a comment restating a
record is a second copy that drifts, and **it drifts invisibly, because a reader
who finds the comment stops looking.** Worse, it reads as corroboration of the
document it has come to contradict.

The fix is a citation, never a better comment:

```
# null-only, and the column list is decision N -- see <the record>
```

What legitimately stays in a comment is what is true of *this* function and
nowhere else: a shape, a constraint it must satisfy, a trap at the call site, a
reason this call is not the obvious one. If the sentence would be equally true
in the record, it belongs only in the record.

Two cautions:

* **This is a preference, and it belongs to the project.** Check whether the
  project has stated one before proposing a rewrite. Some codebases deliberately
  keep long explanatory docstrings and have no external record to point at.
* **Do not strip a comment down to a pointer that points nowhere.** If the
  reasoning lives only in the comment, the proposal is to move it into the
  record first, then cite it.

## `code guards`

The audit of what the suite actually checks, as against what it appears to
check. Three questions per guard, and they are not the same question:

1. **Does a guard exist for this claim at all?**
2. **Does it read what you think it reads?** A guard over documented file paths
   may not read bare module names in prose. A guard that a diagram "opens with a
   diagram type" is not a parser. A guard matching lowercase names silently
   exempts every CONSTANT.
3. **Has it ever been observed refusing something?**

That third one is the one that costs. **A guard nobody has watched fire is not
known to work**, and the tests written for a guard naturally exercise the case
it permits, so a guard that fails open looks identical to a working one — while
telling every reader the case is handled.

So: **make each guard fail once, deliberately, and watch it.** Break the thing
it exists to catch, confirm the failure names it, restore. A guard verified this
way is worth more than three written on faith.

Failure modes to look for specifically:

* **Skip-if-toolchain-absent.** A test that silently skips when a dependency is
  missing is a guard that fails open, and it will sit green forever on a machine
  that never had the dependency. Fail loudly, or make it a command rather than a
  test.
* **The empty-collection pass.** A parametrised guard over a glob that stops
  matching passes every case. Assert the collection is non-empty — a guard on
  the guard.
* **The over-broad match.** A guard that reads prose will match English. Choose
  the writing convention deliberately — a citation is in backticks, a historical
  reference is allowlisted with a stated reason — and **record that convention
  where the guard is defined.** Without one, the first person to document a
  rename either weakens the guard or writes a worse sentence.

Proposing a new guard is in scope here. Adding one is a code change, so it
carries the same propose-then-apply rule as everything else in this half.

---

## Propose, then apply

**Never edit before showing the proposal.** A supersession is a judgement, not a
derivation, and a wrongly-marked entry is hard to spot afterwards because the
entry still reads as coherent. For the `code` half the stakes are higher: a
proposal there changes what runs.

The proposal is one row per finding:

| entry | verdict | evidence | proposed edit |
| --- | --- | --- | --- |
| decision 12 | superseded | `core/x.py:88` now does Y | mark superseded by 33, add forward link |

Rules for the proposal:

* **Evidence is a file and a line, or it is not evidence.** "This looks
  outdated" is not a finding.
* **State which mode found it** — diff or full.
* **Findings you are unsure about go in a separate list**, not mixed with the
  confirmed ones. A maybe reported alongside a certainty devalues both.
* **Report which entries moved, not how many.** A count cannot separate a pass
  that changed nothing from one that rewrote the record. Name them.
* **A finding the record already ruled against is not a finding.** Withdraw it
  plainly and say what the record said. This happens most on `structure`.
* Apply only after the user says so, and apply the whole approved set in one
  edit pass so the record is never half-updated.

## What housekeep never does

* **Never delete reasoning.** Superseded reasoning explains the current design.
  Move it, mark it, link it — do not remove it.
* **Never invent a decision to justify code.** If code contradicts a decision,
  that may be a bug in the code. Report the contradiction; let the user choose
  which side moves.
* **Never loosen a guard to make a document pass.** If a test flags a documented
  path that is deliberately historical, the fix is an allowlist entry with a
  stated reason, not a weaker pattern.
* **Never smooth over an honest gap.** If an entry records no date, or says a
  value is unknown, leave it. A value that looks like the thing it is not is
  worse than a stated absence.
* **Never move code as a side effect of an audit.** A `code structure` move
  happens because it was proposed and approved on its own terms, never because a
  `docs` pass noticed something adjacent.
* **Never touch records in another repo** without being asked, even when the
  same drift is visible there.

## Recommended activation setup

Unlike a gate, this skill is invoked deliberately — there is no impulse to catch
and no moment it must fire on its own. Description matching is enough.

What helps is telling it where the records are, and which guards already exist.
A few lines in the repo's `CLAUDE.md` save a discovery pass every run:

```
`housekeep docs` maintains: docs/design-decisions.md (decisions),
docs/open-issues.md (issues), docs/diagrams/ (diagrams). Each states its own
maintenance convention at the top; follow it rather than inventing one.
Guards that already cover the mechanical half: <name them here>.
The suite going green is not evidence that a moved command still runs.
```

That last line is worth stating explicitly in any repo whose commands are
invoked rather than imported, because it is the assumption `code structure`
exists to break.

## Where this came from

Seven incidents on a project that keeps a design-decision log, an open-issues
list and a set of pipeline diagrams.

**Step 3** comes before narrative reading because an audit of that decision log
found six of its seven problems by checking the log's factual assertions against
source, and only one by reading. One of the six quoted a list of columns that
had since grown by four.

**Step 1** exists because a structural question was asked that the repo had
already ruled on, in writing, with its own measurement. It later caught this
skill mid-run: a pass proposed finishing a half-applied rename, and the record
had already decided to keep the operator-facing names — which was the decisive
row of that decision's cost table.

**Step 2 and `code guards`** come from a guard that scans prose for module
references and could not tell a citation from an example, and from a diagram
guard whose own docstring admitted it checked shape rather than parsing.

**`code structure`** combines three findings. An import-graph cohesion test
returns no signal for a package of entry points, because commands are invoked
rather than imported — a fact about the instrument, not the code. A fixture
confirms code matches its author's model of the data and cannot detect that the
model is wrong. And diagnosing from the comments around code, instead of running
it, confirmed the wrong cause twice in one session.

**Step 4** is the observation that documentation records the mechanics and
leaves the rules about what may be overwritten implicit, which is the half where
the damage lives.

**`code comments`** is a preference one project stated after a pass found two
comments restating documents they had drifted from, each reading as
corroboration of the document it contradicted.
