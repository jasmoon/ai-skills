---
name: validate-extraction-output
description: Pre-delivery gate for any claim derived from extracted, scraped, parsed, or ingested data. Load BEFORE reporting a count, rate, success percentage, match result, coverage figure, or a diff against a destination dataset; before binding an action (write, delete, retire, flag, fill) to a classifier's verdict; and before concluding that an extractor "works". "The extraction worked" is four separate claims — structural validity, measurement, coverage, and meaning — and passing one says nothing about the other three. Triggers on phrases like "X% success", "N rows matched", "parsed N items", "the fill worked", "no data found", dedupe, backfill, enrichment, sampling a payload, diffing extracted records against a database, or evaluating a detector against ground truth. Description matching alone is unreliable for a gate that fires at the END of a task — pair this with a CLAUDE.md instruction in any repo that does extraction work.
---

# validate-extraction-output

A checklist to run **before** stating a result derived from data, not after
someone questions it.

## Why this exists

Every rule below was paid for by a real incident on a production data pipeline.
In every one of them the agent already knew the rule. It was mid-flow, holding
a number, about to report it.

That is the shape of the failure: not ignorance, but momentum. So this is a
gate, not a reference.

## The core reframe

**"The extraction worked" is four different claims.** They are independent.
Passing one is no evidence for the others.

| Claim | Question | Measured by |
| --- | --- | --- |
| **Validity** | Is the output well-formed? | schema checks, tests |
| **Measurement** | Is the number I computed about the world? | sampling design |
| **Coverage** | How much of the domain did I reach, and can anything use the output? | three separate counts |
| **Meaning** | Do the values mean what the field name says? | provenance, time, identity |

Most reporting collapses all four into one sentence. Separate them first.

---

## A. Validity — a schema check measures the parser, not the extractor

Output conforming to a schema can be entirely noise. Every check that measures
*shape* passes on it.

- [ ] **Sample the values, not just the schema.** Read 10–20 actual rows. A
      loose heuristic produces confidently-shaped garbage.
- [ ] **At least one fixture is captured, not constructed.** Tests written from
      the same mental model as the code test the model, so they pass in exactly
      the case where the model is wrong. A real captured payload is the only
      artifact that can contradict a shared assumption.
- [ ] **Treat a captured specimen as a dataset about the upstream system.** It
      answers questions it was never collected for — especially negative ones.
      An absent field is invisible from consuming code and obvious in a real
      specimen.
- [ ] **State the converse:** one specimen proves a contract's *shape*, never
      its *stability*.

> A test module that could not even be collected reported coverage in the file
> listing and delivered none, because the fixture it needed was gitignored. It
> worked for whoever wrote it and for nobody else.

---

## B. Measurement — how you sampled decides what you concluded

- [ ] **What ordered the data I sampled?** A rate measured on the head of a
      dataset measures the sort order.
- [ ] **State `n` beside any separation claim.** Few points make any boundary
      fit. Perfect separation at small n is the *null* result, not a finding.
      "These two signals agree everywhere" at n=9 means only that they have not
      yet been observed disagreeing.
- [ ] **Classify the population before sampling from it.**
- [ ] **Re-test the rows a human hedged on, first.** In a hand review those get
      treated as noise. They are precisely the rows a mechanical rule is most
      likely to decide differently.
- [ ] **Reject a fix that merely reproduces the hand triage.**
- [ ] **A suspiciously round count is truncation until disproved.** A limit you
      wrote is visible on review; a limit the server applied is invisible unless
      you look for it. Pass page size explicitly, order the query (offset paging
      over an unordered result repeats and skips rows), and prove you reached
      the end by reading a short page.

> A read returned exactly 1,000 rows against a true 1,083. The API capped the
> response and reported the cap only in a header nothing was reading. The only
> tell was the roundness of the number.

---

## C. Coverage — three numbers, not one

A success rate alone is close to meaningless. Report all three:

1. **Reachable set** — how large is the domain this can even be attempted on?
2. **Success rate within it** — of what was attempted, what worked?
3. **Consumable output** — can anything downstream actually use the result?

One pipeline was simultaneously 99% reliable, unable to reach 99.97% of its
domain, and writing to a dead end. Each number alone told a flattering story.

- [ ] **Read every column the diff reasons about.** Absence *inferred* from a
      partial read is not absence. Self-consistent tooling cannot detect this,
      because the code that builds the picture of the destination is the code
      that reads it.
- [ ] **Gate a fill on the quality of the incoming value, not only on the
      emptiness of the target.** "Is the destination missing this?" is half the
      question. "Is what we would put there any good?" is the other half — and
      where a fill only fires on a null, a placeholder is permanent, because
      nothing downstream can ever replace it.

---

## D. Meaning — time, identity, and which copy survived

- [ ] **Is this field point-in-time?** Any value whose meaning depends on *when*
      you looked must never be folded into permanent state. "Not available right
      now" and "gone for good" are different facts that a source often expresses
      in similar words. Merged, they produce a clean boolean that marks live
      records as dead.
- [ ] **If I deduplicated: which copy won, and why?** "Whichever came first" is
      a choice made by the upstream document's layout. Counts stay correct while
      attribution silently moves.
- [ ] **What wrote the key I joined on?** An exact join on a key that was itself
      populated by an earlier fuzzy match launders that uncertainty into
      apparent precision. A key of unknown provenance must not gate a
      destructive action.
- [ ] **Absent is not zero. Unknown is not false.** Preserve the distinction end
      to end; an unparseable value is dropped, not recorded as a negative.

---

## E. The action is a second claim

**Verifying a classifier tells you nothing about whether the action bound to its
output is right.** This is the most expensive item on the list.

- [ ] **Enumerate the causes of each verdict before binding an action.** A
      verdict with several causes needs a second discriminator or a human, never
      a default action.
- [ ] **Record every threshold with the population it was read off**, and
      re-derive it when ground truth arrives.
- [ ] **Low overlap between two detectors is evidence they find different
      things**, not that one is weaker.
- [ ] **A destructive action needs a proof, and "a good match" is not one.**
      State redundancy in terms of *identity* — an exact shared key — not
      resemblance. Enumerate every cascading foreign key and check each is empty
      *now*. Export the rows first. Keep whatever the proof does not cover
      rather than rounding up.

> A classifier was tested exhaustively and was correct on 7 of 7 conflicts. The
> action bound to it was never tested. At least 3 of those 7 conflicts had a
> benign cause, and the action would have discarded the more current record.

---

## F. Who is judging?

- [ ] **Did I use knowledge the pipeline does not have?** An agent reviewing
      extraction output brings outside knowledge, silently raising the apparent
      quality of the review above what the pipeline can reproduce unattended.
      The gap tends to appear only when someone asks how a verdict was reached.
- [ ] **Say which judgements were made with that knowledge and which were not**,
      and substitute a measurable proxy before claiming a rate.

---

## G. Who actually failed?

Before diagnosing *what* failed, classify *who*: pipeline, environment,
terminal, or version control. A failure at the boundary of your environment
looks exactly like a failure in your code, and the fix is in a different
repository.

- [ ] Has the documented invocation drifted from what is installed?
- [ ] Can the terminal render what the source returned?
- [ ] Is every fixture a test depends on actually committed?
- [ ] Does an uncollectable test module fail the suite, or silently shrink it?

---

## H. Report what was seen, not why

State the observation. "parsed 0 items" — not "the source has no data".
Guessing a cause once dressed up a parser looking in the wrong place entirely
as a finding about the data.

---

## Enforcement

Do not summarise this skill and move on. Before delivering the result:

1. Name which of the four claims you are actually making.
2. Walk the checklist for that claim, in the response or in your reasoning.
3. State explicitly which checks you **did not** run, in those words — "I didn't
   check coverage", "this rate is from the head of the file".

An unstated gap reads to the user as a check that passed.

---

## Recommended activation setup

Description-level matching is not enough on its own. Skills load by description
at the *start* of a turn, and this one needs to fire at the *end* of a task —
which is exactly when the flow of producing a result makes rules easiest to
skip. Pair the skill with a structural trigger in the project's `CLAUDE.md`:

```markdown
**Before reporting any count, rate, match result, or coverage figure derived
from data — and before binding a write, deletion or flag to a classifier's
verdict — load the `validate-extraction-output` skill and work through it.**
```

Then add two or three of the project's own concrete cases underneath, so the
trigger is recognisable in the moment rather than in the abstract. Good
candidates: any paged API read, any reported extraction yield, any verdict that
gates a write.

`CLAUDE.md` stays in context for the whole session, so this converts the
question from "does this task look like extraction?" into "am I about to state
a number?" — which is checkable at the point it matters.

## Boundary with neighbouring skills

- **Verifying writes** — *did the write land*: rows sent versus rows changed,
  derived columns that go stale because only inserts recompute them, transport
  failures in a long write path. This skill covers *is the result true*. They
  meet at server-side read truncation (§B), which corrupts a coverage claim.
- **Polite external probing** — *may I fetch this, and at what rate*. That runs
  before extraction; this runs after.
