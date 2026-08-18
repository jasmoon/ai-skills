---
name: housekeep
description: Bring a project's written records back into agreement with its code. Invoke with a target — decisions, issues, observations, diagrams, or all — to find entries the code has since contradicted, decisions a later decision superseded, issues the work already closed, and diagrams that no longer describe the flow they draw. Two modes - the default reads the session or branch diff and asks what it invalidated; --full extracts every checkable assertion in the record and verifies it against current source. Always proposes before it writes. Load when asked to housekeep, tidy, audit, reconcile or update docs, a design-decision log, an ADR directory, an open-issues list, a TODO file, an observation log or a diagram; at the end of a session that changed behaviour; whenever a decision may have been superseded, an issue may have been closed by the work just done, or a document is suspected of being stale.
---

# housekeep

A written record is a claim about the world at a moment. Every entry silently
asserts that its premises still hold. Code moves and the record does not, so the
two drift apart quietly — nothing fails, and the document keeps reading as
though it were true.

`housekeep` is the deliberate pass that closes that gap. It is not a gate and it
does not fire on its own. You run it, on a named target, and it hands you a
proposal.

## Usage

```
housekeep <target> [--full]
```

| target | the record it audits |
| --- | --- |
| `decisions` | the design-decision log, ADR directory, or equivalent |
| `issues` | the open-issues list, TODO file, or tracker export kept in-repo |
| `observations` | the task-observer log, plus its archive hygiene |
| `diagrams` | the diagram files and the claims they make |
| `all` | each of the above in turn, reported separately |

No target given: ask which one. Do not guess, and do not silently run `all` — a
full sweep across four records is a long pass and the user may want one.

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

Five steps, in this order, for every target.

### 1. Read the record's own stated convention first

Almost every record worth auditing documents how it wants to be maintained — a
"how to read an entry" section, a status vocabulary, a rule for closing an item,
a note on what the file deliberately omits. Find it and follow it.

This is the difference between housekeeping and rewriting. A proposal that
ignores the project's recorded reasoning is not a second opinion, it is a
regression. The convention also supplies the *units* — what counts as superseded
here, whether a closed issue is deleted or struck through, whether ids are
reused — and those are not guessable.

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
  checked by the suite cannot.

When you add or touch such a guard, decide up front how the docs are meant to
write a name they are *not* citing — a historical reference, an example of a
path that no longer exists — and record that convention where the guard is
defined, with a reason per allowlist entry. A checker that reads prose imposes a
writing convention whether or not anyone chose one. Without a stated one, the
first person to document a rename either weakens the guard or writes a worse
sentence.

### 3. Extract the checkable assertions before reading for narrative

Go through the record pulling out claims a machine or a grep can settle:

* file and module paths, and whether they resolve
* function, class and constant names, and whether they still exist
* constant *values* quoted in prose, and whether they still match
* verbatim lists — of columns, of statuses, of buckets — and whether they have
  grown or shrunk
* "not yet implemented", "there is no such function", "currently one request per
  row" — negative claims, which rot fastest because the work that falsifies them
  never revisits the sentence

Check these against the source **first**. Read the document for narrative
second. Reading end to end finds the contradictions the document already
contains; only the code finds the ones it is missing, and those are the larger
class.

### 4. Build the cross-reference map as its own step

Note which entry is cited by which later entry. An entry that later entries lean
on, but which points forward to none of them, is where staleness accumulates —
it is load-bearing and nothing has revisited it.

### 5. Separate the three verdicts, and never conflate them

| verdict | what it means | what to do |
| --- | --- | --- |
| **superseded** | a later decision replaced this one | mark it, keep it, link forward |
| **stale** | the claim was true and the code moved | correct the claim, note when |
| **wrong** | the claim was never true | correct it and say it was an error |

Superseded is the common one and the one most often mishandled. **Do not rewrite
a superseded entry to look as though it was always right.** The reason to keep
it is that it explains the shape of what replaced it. Mark the passage in place,
add the forward link, leave the reasoning standing.

## Per-target procedures

### `decisions`

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

### `issues`

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

If ids are stable and never reused, do not reuse them. A gap in the sequence is
information.

### `observations`

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

Also check for a **second copy of the log**. A repo that keeps its own log
alongside a shared one splits every review in half, and each copy invents its
own numbering. If one exists, the proposal is to migrate its entries into the
shared sequence and delete the copy — never to merge the two files.

An observation the user has declined is not resolved. Mark it DECLINED with the
reason; do not delete it and do not leave it OPEN.

### `diagrams`

**Run the parser.** Every diagram format has one, and reading the source is a
guess that is most confident exactly where the syntax looks simplest. Parse
before anything else.

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

## Propose, then apply

**Never edit a record before showing the proposal.** A supersession is a
judgement, not a derivation, and a wrongly-marked entry is hard to spot
afterwards because the entry still reads as coherent.

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
* **Never touch records in another repo** without being asked, even when the
  same drift is visible there.

## Recommended activation setup

Unlike a gate, this skill is invoked deliberately — there is no impulse to catch
and no moment it must fire on its own. Description matching is enough.

What does help is telling the skill where the records are. A line in the repo's
`CLAUDE.md` naming them saves a discovery pass every run:

```
Records `housekeep` maintains: docs/design-decisions.md (decisions),
docs/open-issues.md (issues), docs/diagrams/ (diagrams). Each states its own
maintenance convention at the top; follow it rather than inventing one.
```

## Where this came from

Three incidents on a project that keeps a design-decision log, an open-issues
list and a set of pipeline diagrams.

Step 3 comes before narrative reading because an audit of that decision log
found six of its seven problems by checking the log's factual assertions against
source, and only one by reading. One of the six quoted a list of columns that
had since grown by four.

Step 1 exists because a structural question was asked that the repo had already
ruled on, in writing, with its own measurement — and answering from taste would
have produced a plausible proposal contradicting a settled decision.

Step 2 exists because a guard that scans prose for module references fired three
times on the entry documenting a rename. The entry quoted the old names to
explain why they changed. The guard could not tell a citation from an example,
and nobody had decided how the docs were meant to write a name they were not
citing.
