---
name: first-real-run
description: Pre-execution gate for the first time code meets real data or a live system, and the first move when something returns nothing or the wrong thing. Load BEFORE running a new pipeline stage against a real upstream artifact, before the first --apply or write against a live database, before trusting a fixture-backed test as evidence a stage works, and before proposing any cause for "why does this return 0 rows / empty / the wrong shape". Also when deciding whether a dry-run flag is safe to rely on. A fixture confirms the code matches its author's model of the data and cannot detect that the model is wrong; a comment, a memory and a schema clone are stand-ins with the same defect. Only running the thing against the real input discriminates. Triggers on "dry run", "--apply", "--limit", "first run", "why does this return nothing", "0 rows", "it works in tests", "the fixture passes", writing a loader for another stage's output, or reasoning about a failure you have not yet reproduced.
---

# first-real-run

The gate before code meets the real thing, and the first move when the real
thing does something you did not expect.

## Why this exists

Two incidents, four years of habit behind each.

A stage was added between two existing ones. Its input loader handled a bare
list and two wrapper shapes, all covered by passing unit tests. The upstream
stage writes a dict keyed by URL — a fourth shape — so the loader returned **0
of 20 real records**. The tests could not have caught it: they asserted the
shapes the author had assumed, and the assumption was the defect. Running the
command once against the real file surfaced it immediately.

Separately, a query returned 0 rows. A comment in the function named a
plausible cause. That cause was confirmed *real* by out-of-band checks and
asserted as the answer twice; both fixes failed. The operative cause was a stale
environment variable overriding the config file, found in under a minute once
the function was finally executed. A note in the repo saying the language
runtime was not installed had discouraged running it. The note was twenty days
old and wrong.

## The core reframe

**A stand-in is not the system.** Four of them look like evidence and are not:

| stand-in | what it actually proves |
| --- | --- |
| a **fixture** | the code matches your model of the data |
| a **comment** | someone once believed this, possibly correctly, possibly since |
| a **memory or doc** about the environment | the environment on the day it was written |
| a **structural clone** of a table | columns, types, nullability, keys — not the transport that reaches them |

Every one is useful. None discriminates. And the failure they share is specific:
**a confirmed-plausible mechanism is not a diagnosis until it is shown to be the
one firing.** Several sufficient causes can be true at once while only one is
active, so evidence gathered *around* the code will keep confirming the wrong
one, indefinitely and with increasing confidence.

The instinct this fights is that running it feels expensive or risky. Sections A
and B exist to make running it cheap and bounded, so that running it can be the
default rather than the last resort.

---

## A. Before a new stage meets real input

- [ ] **Read the producer, do not infer the shape from the consumer.** Open the
      code that writes the artifact and find the exact shape it writes. A loader
      that accepts three shapes is three guesses, and the real one can still be
      a fourth.
- [ ] **Run it once against the real artifact before calling it done.** Not a
      copy, not a trimmed sample you constructed — the file the upstream stage
      actually wrote.
- [ ] **Then add a test using that shape, and cite where the shape comes from.**
      A fixture derived from the real artifact is worth more than three
      constructed ones, and the citation is what stops the next person
      regenerating it from the same wrong assumption.
- [ ] **Bound the first run.** `--limit`, one batch, one record. A first run
      that is also a full run gives you no cheap way to look at what happened.
- [ ] **Print what the code actually sees** on that first run — the resolved
      config, the path it opened, the number of records it loaded, the first
      one. "Loaded 0" answers the question the tests could not.

**A passing suite is not a claim about the data.** It is a claim about the
agreement between the code and its author, and where the author was wrong the
suite agrees with the author.

---

## B. The dry run is a claim, and it needs its own check

A dry-run flag is a guard, and **a guard nobody has watched refuse is not known
to work.** The tests written for one naturally exercise the case it permits, so
a dry run that fails open looks exactly like one that works — while telling you
the case is handled.

- [ ] **Make it refuse once, deliberately.** Point it at something that would be
      unmissable if written, run it, confirm nothing was.
- [ ] **Check what it suppresses.** A dry-run guard that suppressed writes but
      not reads still hit the live system on every run. "Dry" usually means "no
      writes"; it rarely means "no contact".
- [ ] **A dry run that reads live data is a real run of the read path.** Rate
      limits, credentials, egress rules and paging all apply. Treat it as
      production for everything except the write.
- [ ] **Say which half you verified.** "Dry run clean" is ambiguous between "it
      wrote nothing" and "it did nothing".

---

## C. Diagnosing: execute before you explain

The first action for any *why does this return nothing / empty / the wrong
thing* question is to **run the smallest unit that reproduces the symptom** and
print what the code actually sees. Before proposing a cause, not after.

- [ ] **Reproduce first.** One function, one record, one request. If reproducing
      seems impossible, that impossibility is the first thing to check — see
      below.
- [ ] **Print the resolved values, not the intended ones.** The environment
      variable as read, the config after merging, the URL as sent, the response
      as received. Most of these bugs are a difference between the value you
      believe is in play and the one that is.
- [ ] **Do not accept a cause you have only confirmed is real.** Show it is the
      one firing — disable it, change it, and watch the symptom move. If the
      symptom does not move, it was not the cause however true it is.
- [ ] **Re-verify any environment claim before using it to rule out running.**
      A memory or a doc saying the tool is missing, the key is dead, the host is
      unreachable — check it now. Those claims decay fastest and they are the
      ones that talk you out of the one action that would have answered the
      question.
- [ ] **Do not diagnose from the comments around the code.** A comment is one
      person's model, and it names plausible causes precisely because plausible
      causes are what people write comments about.

---

## D. The first write against a live system

- [ ] **Bound it hard.** `--limit`, and small enough that you can read every row
      you touched.
- [ ] **Read it back.** A reported write is not a landed write. "Wrote N" that
      counts rows *sent* rather than rows the database changed can be wrong for
      months without anyone noticing, because the number looks right.
- [ ] **A structural clone verifies the shape, not the path.** Creating a table
      like the live one checks columns, types, nullability and keys. It does not
      exercise the API, the serializer, the auth, or the constraint the live
      table has and the clone did not inherit.
- [ ] **Plan a diff, not a rewrite.** A write that re-sends what is already
      there cannot be distinguished from one that changed everything, and it is
      not safely repeatable.
- [ ] **Report which values moved, not how many rows were touched.** A count
      cannot separate a no-op from a catastrophe.
- [ ] **A post-write step must never fail the run it follows.** A recompute or a
      refresh that errors *after* every write has landed will report a failed
      run after a complete one, and the operator will re-run it.

---

## E. What counts as having run it

Say which of these is true. They are not interchangeable:

| claim | what it took |
| --- | --- |
| "the tests pass" | fixtures only |
| "it parses the real artifact" | one real input, no writes |
| "it ran end to end, dry" | real input, real reads, writes suppressed and *verified* suppressed |
| "it ran bounded, for real" | wrote N rows, N read back and checked |
| "it ran" | unbounded, verified |

Reporting a lower row as a higher one is the failure this whole skill is about,
in miniature.

## Boundary with neighbouring skills

- **`polite-external-probing`** gates the first request to a host you do not
  own. This gates the first run against data or systems you *do* own. Where a
  first real run means fetching from someone else's infrastructure, that skill
  is stricter and wins.
- **`validate-extraction-output`** fires later, when you are about to state a
  number or bind an action to a verdict. This one fires before the code has run
  at all. The seam is diagnosis: that skill's "who actually failed?" classifies
  a failure you are reporting; this one says to reproduce it before you classify
  anything.
- **`housekeep code structure`** borrows section A wholesale for a moved
  command: a green suite proves imports resolve and nothing about invocation.

## Recommended activation setup

This is a gate before an impulse, and the impulse is to reason about a system
rather than run it. Description matching is not reliable for that, so pair it
with a line in the repo's `CLAUDE.md`:

```
Before the first `--apply`, before running a new stage against a real upstream
artifact, and before proposing any cause for a run that returned 0 rows or the
wrong shape, load `first-real-run`. Fixtures live in <path>; what the stages
actually wrote lives in <path>.
```

Naming those two paths is most of the value. The whole skill turns on knowing
which of the two you are looking at, and a repo where they are one directory
apart makes the mistake easy.

## Where this came from

Two incidents on a data pipeline, described in full at the top, plus the
dry-run, read-back and post-write rules that project had already written down
after paying for each of them separately.
