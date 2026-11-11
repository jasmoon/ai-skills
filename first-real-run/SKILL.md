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
- [ ] **A first run has two budgets, and they answer different questions.** One
      deep call on one target answers the shape and the cost. A shallow call
      across a fixed sample of the real population answers coverage, and it is
      the one that finds the empty result and the refusal. An issue named three
      methods of a vendor API, and one call per method answered all three. A
      sample of ten items then found two that returned nothing, in two
      different ways: one refused with a named error, and one returned an
      empty result with no error. Name both budgets before the run. A sample
      taken by a fixed rule, such as every eleventh stored item, is cheap to
      state and to repeat.
- [ ] **A bounded run of a measurement prints numbers that look like results.**
      Label its output "not evidence" before you read it. A small sample's
      extreme value sits further from the truth, in whichever direction chance
      took. A screen on ten units read 0.520 to 0.544 against a baseline of
      0.500. The same screen on all 100 units read 0.490 to 0.511. When the full
      run lands, record both numbers.
- [ ] **Print what the code actually sees** on that first run — the resolved
      config, the path it opened, the number of records it loaded, the first
      one. "Loaded 0" answers the question the tests could not.
- [ ] **When the data is a union of partitions, list each comparison that reads
      the whole union.** Markets, regions, tenants and time zones are
      partitions. A max or a min over the union is a hidden join. One table
      kept only the live rows newer than the newest date of a grid that held
      two markets. The earlier market had already stored a finished day with
      the later market's live date, so every row of the later market was
      dropped. Every fixture held one market, so the tests passed by
      construction. Ask whether each such comparison must be per partition,
      and build one fixture that mixes the partitions in the shape that the
      real store holds now.
- [ ] **Before you add a test to a file, read the fixture it uses and two
      neighbour tests.** A fixture can have side effects in time: a refresh, a
      job or a cache fill that runs on after the request. If it does, find how
      the neighbours wait for it, and do the same. One new test read a value
      twice and compared the two, while a background refresh wrote newer rows
      between the reads. Three tests in the same file already waited for that
      refresh, and one comment named the race. When a test that compares two
      reads fails one time, suspect a writer between the reads before you call
      it flaky.

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
- [ ] **Read the failure message, and confirm that it is the guard's own.** A
      red result does not show which check fired. A sabotage of an import
      guard once crashed the test session at a circular import, before the
      guard ran, and the red suite looked like success. Where something earlier
      refuses the sabotage, write a second one that reaches the guard. A static
      check fires on a construct that the parser sees and the runtime skips.
      A refusal can also come from the platform: a rename, a file lock or a
      permission that one operating system enforces and another does not. One
      build guard was removed on purpose, and the build still raised, because
      the rename at its end refuses an existing target on Windows. On Linux and
      macOS the same rename replaces the target. Pin the guard's own message
      in the test, and name the platform that the sabotage ran on.
- [ ] **Undo a sabotage by reversing the exact edit, never by discarding the
      file.** A `git checkout` of the file once removed the sabotage and the
      uncommitted feature that the guard was written for, and the green suite
      did not show the loss. Commit or copy uncommitted work before the
      sabotage.
- [ ] **Before you fire a guard at a network service, prove that the process
      you started is the one that answers.** Read the server's own bind line,
      or check which process owns the port. A port that a brief calls "free" is
      a claim from the past. One session's server failed to bind, and its guard
      requests reached the user's own server, which had the live source. The
      check became the live call it was meant to prevent.
- [ ] **A check that passes by printing nothing must first be seen printing
      something.** A text search written for a later step differed in case from
      what it had to find, so it printed nothing while five matches remained.
      Run a new check at once, where the expected result is known, and record
      the count beside it.
- [ ] **A sabotage that still passes is a finding about the fixture, not a sign
      the guard is unnecessary.** Breaking something on purpose checks two
      things at once: whether the check is looking, and whether the input can
      be seen. Two shapes recur: the fixture has no case near the boundary the
      rule is about, and the fixture's data happens to select the same items
      under the correct rule and the broken one. Assert the discriminating
      precondition inside the test — "the two best items are both on one side,
      or this test proves nothing" — so the fixture cannot drift back into
      agreement. Where the quantity is a summary statistic, check its
      robustness: a median ignores a short tail, so the contrast must be most
      of the sample, not only present in it.
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
- [ ] **"I don't see the change" is often "the process predates the change".**
      Compare the start time of every long-running process that serves the
      feature with the time of the change, before you read the code. A process
      keeps the code it loaded at start. A file that it reads per request does
      not, so the result is a half-new system that looks like a bug.
- [ ] **A message that explains an empty result is a diagnostic guard.** One
      module printed "run the sync first" whenever no group was large enough,
      and the user had just run the sync: every group was under the size floor.
      Print what was counted. Name a cause only from a check that tells the
      causes apart, and make each cause happen once to read the message under
      it.
- [ ] **Do not diagnose from the comments around the code.** A comment is one
      person's model, and it names plausible causes precisely because plausible
      causes are what people write comments about.
- [ ] **A demonstration script derives its conclusion from what it observed.
      It never prints it as narration.** A script written to show that X
      causes Y once printed the status, the body, and then a fixed string
      naming the fault — after the service had been restarted and the request
      had succeeded. The output asserted a fault it had just disproved, and the
      genuine status code beside it lent the fabricated line its credibility.
      Assert the precondition first and fail loudly if it does not hold. Print
      the smallest value that settles the question. Every printed conclusion
      must trace to a value the run produced; anything else is a comment that
      happens to be inside a program.

---

## D. The first write against a live system

- [ ] **A command that you run "to look" is a first write until you have read
      its default path.** Before the first run of a project's entry point,
      read its main function, and name every external call and every write on
      the default path. Find the flag that suppresses them, or ask first. A
      module for groups was run once with only a database flag, to list the
      stored groups. Its default path pulled from a live account and replaced
      a local table that a recorded measurement had read. Intent to read does
      not make a command read-only.
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

### D2. The second run, when the first run's output is now an input

Any process whose output becomes part of its own input has two first runs, and
the second one cannot be rehearsed before the first has happened. Tests written
in advance encode the pre-run world, so they agree with the author exactly where
the author has not yet seen the post-run one.

- [ ] **For any command that writes a value it will later read — a marker, a
      status, a processed-at stamp, a sentinel — run it twice and diff the
      second run's plan against empty.** A backfill once stamped rows it could
      not explain with the marker `unrecorded`, so they stayed distinguishable
      from "not processed yet". The second run read its own marker as an
      ordinary reason, concluded the reason no longer applied, and planned to
      clear 1,371 flags the first run had just protected. 32 tests passed
      throughout. A second run that plans zero writes is the check. One that
      plans work is either non-idempotent or, as here, destructive. This
      strengthens "plan a diff, not a rewrite": the diff must compare against
      what is stored *including what this command itself stores*.
- [ ] **Where a search reads its starting point from the field it writes its
      answer to, the second run is a re-test of a conclusion, not a fresh
      measurement.** After the first fit shipped, the start point stopped
      being a neutral guess and became the previous answer, which is by
      construction a local optimum of that objective. A one-coordinate search
      cannot pass through a worse intermediate state, so a rule that must
      take weight off its near-copy first stays at zero, and the run reads as
      "measured, found nothing". Name the start point at the call site. Run
      from several starts and report whether they agree. Disagreement is the
      finding: the surface is flat and the answer is partly arbitrary. Then
      check the docstring and the records for a sentence about the input's
      provenance that the first run made untrue.

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

**A port that must change nothing is not proven by its ported tests.** Those
tests pass on any code that the old tests passed. Before you port the tests,
run the old and the new code on the same real inputs and compare the output
byte for byte, and watch one deliberate change break the match. After the port,
make one mutation per group of tests. A group that passes under its mutation is
a gap, not a pass. In one port, a mutation passed all 74 tests of its group.
The branch it changed was reached by 31 of 180 real renders and by no test.

---

## F. When you cannot run all of it

**"I could not run it" is usually too coarse.** Name what each check you did
run measures, and name the claim it does not reach, before the run rather than
after it. When several cheap checks pass, their combined green reads as
coverage of the whole claim.

- [ ] **Separate the composition from the commands it composes.** A new
      target ran the Python tests and then the frontend tests, and the
      container could not build the pinned Python. The target's own behaviour
      is neither half: it is the order, the stop at the first failure, the
      environment it passes down, the working directory. Each of those has a
      stand-in that runs in the environment you have — the full run proved the
      stop because it never reached the second command, and a run with the
      first half narrowed to one file that did collect proved the order.
      Report the two results separately, so the reader sees which half is
      unrun rather than one caveat over the whole change.
- [ ] **When a test run fails, run the same target on the clean tree before
      you blame the change.** Stash the change and run once. "The tests pass"
      is three claims: they ran, they passed, and they were all of them.
      Report three numbers: what ran, what passed, and what could not run and
      why. Name the files that could not run, and do not average them into a
      pass rate. In one remote session a pinned toolchain could not install,
      and the same 5 of 24 test files failed to collect on a clean checkout.
      Three days later the same pin failed 5 of 33.
- [ ] **Run a suite with its failure summary on, the first time, and keep the
      names.** For pytest that is `-rf`. A flaky failure may not come back, so
      the first run can be the only evidence. One full run was cut to its last
      line, "1 failed, 1153 passed", and the reruns passed. The report had to
      say "one test failed once and I cannot tell which", and the flaky test
      was pushed. Trim output after you know that it holds no failure.
- [ ] **For a rendered page, load `validate-rendered-output`.** A parser is
      ground truth for syntax and says nothing about layout. When no check of
      the layout ran, the delivery says the layout is unchecked, in those
      words.

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
