---
name: validate-predictor
description: Pre-claim gate for any statement that an input, a rule, a label or a fitted score predicts an outcome. Load BEFORE you say a candidate "works", "earns weight", "beats chance", "passes the gate" or "holds out of sample"; before you report an AUC, a lift, a hit rate, a separation or a resample stability count; before you ask to read held-out data; and before you set up a scheduled or unattended run that screens candidates. A candidate can pass every check that was run and still be the label restated, a size signal read as a direction, an input that almost never fired, or noise that is equal in every unit. Triggers on feature screens, backtests, signal research, fitted weights, held-out reads, bootstrap or resample gates, "40 of 50 draws", mirrored labels, and a run of null results against one target. Pair with a CLAUDE.md instruction in any repo that measures predictors.
---

# validate-predictor

A checklist to run **before** you say that something predicts something.

## Why this exists

Every rule below came from a real search for inputs to a score on daily market
data. In each case the result passed the checks that were run. None of those
checks asked the question that mattered.

`validate-extraction-output` asks whether the data is right. This skill asks a
second question: given that the data is right, does the input predict?

## The core reframe

**"It predicts" is four claims.** Each one can fail while the others pass.

| Claim | Question | Section |
| --- | --- | --- |
| **The label** | Does the label ask what the decision needs, and does it hold a part that the input already knows? | A |
| **Presence** | Did the input have an opinion often enough to be tested? | B |
| **Size** | Is the result larger than noise gives, and not only stable across draws? | C |
| **Budget** | How many times did the work read the held-out data? | D |

Most reports state a number and stop. Name the four claims first.

---

## A. The label — read it before you read the input

- [ ] **Which part of the label is known on the day the score is read?** A label
      such as "the highest close within 5 bars either side, then a fall within
      10 bars" has a backward half that is known on the day. Write a one-line
      feature that restates that half, and fit it alone. Then judge the model
      only inside the rows that meet it. In one project the one-line feature
      scored 0.88 alone, above every fitted rule. Inside the rows that already
      met the backward half, the fitted score read 0.52 on the held-out half: a
      coin. The held-out agreement, to three decimals, had replicated the
      definition of the label. A held-out set does not catch a leak from the
      present.
- [ ] **Does the label bundle a direction and a size?** "Moves at least X in the
      stated direction" can be predicted by an input that knows only the size of
      the move. Test the mirrored label, the same move in the other direction.
      Where the two read the same, the input reads size, not direction. Say that
      plainly, also when the work was to find direction.
- [ ] **Print the mirror in the same table, with the difference in its own
      column.** A check that needs two runs compared by hand gets skipped, and
      nothing records the skip. Where a tool takes a flag that splits the two
      sides, make the checking mode run both. In one screen, two of three
      candidates read the same number on both sides, one of them to three
      decimals, and the table showed it without arithmetic.
- [ ] **After three nulls in a row against one label, question the label.**
      Name the parts of the label that were inherited and not chosen: the
      horizon, the size threshold, the benchmark, the shape. Vary those first,
      because they need no new data. Set the count before the first candidate.
      One project tested sixteen candidates against one fixed label, and every
      one read chance. The horizon had never been chosen, and the benchmark was
      absolute where most of the variance was common to every item.

---

## B. Presence — count the input before you judge it

- [ ] **Report how often the candidate has an opinion**, as a share of the rows
      it was offered, before any separation, accuracy or lift.
- [ ] **A coin and a silence print the same number.** Where the share is too
      small to support the test, say "not measured", not "failed". A silent
      input stays an open question. A measured coin closes it.

> One rule read chance for years. Its threshold sat two orders of magnitude
> from where the data lived, so it fired about 50 times in 100,000 rows and
> could never say anything. A later candidate fired on about 11 rows in 100, so
> its coin was a measurement.

---

## C. Size — stability across draws is not size

A resample gate refits on many draws of the units (with repeats) and counts the
draws that give the candidate a weight. It answers "is this stable across
units". It does not answer "is this larger than chance".

- [ ] **Name the axis that the resample draws along, and check that each input
      varies along it.** An input that is one value per day, shared by every
      unit, is the same column in every draw of units. One such input passed on
      50 draws of 50, at the top weight, on both sides of the question. The
      result carries no information. Report "no stability result" for it.
- [ ] **A small effect that is the same in every unit is stable by
      construction.** Run the gate on columns of pure noise first, and report
      how often noise passes. In one run, 1 of 8 noise columns passed on 50 draws
      of 50. By chance it agreed with the label 50.85 times in 100, where a coin
      gives 50, and the noise was drawn per row, so the lean was equal in every
      unit. Every draw kept it, and every refit paid it. The gain it bought on
      the fit was 0.5271 to 0.5279.
- [ ] **Pair a stability gate with a size test against a null.** Compare the
      gain of the candidate with the gains of many noise columns on the same
      rows. A gate that counts the draws that give a weight does not ask what
      the weight earns.
- [ ] **A pass rate from a few noise trials carries its sample size.** With no
      pass in `n` trials, the rate is very likely (95 in 100) below about
      `3/n`. That is below 3 in 100 after 100 trials. After 8 trials it is
      below about 31 in 100 by the exact count, and `3/n` gives 37. A bound
      quoted for 100 trials says nothing about 8.

---

## D. The held-out budget

Each read of the held-out data spends some of it. After enough reads, one
candidate passes by chance, and it looks the same as a real result.

- [ ] **Count every read of the held-out data, and report the count with every
      result**: this session, and in total.
- [ ] **Enforce the budget in code, not in prose.** Use a flag that must be
      passed, a ledger line that a person writes, and a function that refuses,
      and that writes a "spent" line before it reads. Make the refusal fire once
      on purpose.
- [ ] **A scratch script imports the guarded function.** A copy of the loop is a
      copy without the guard. One evaluation session read the held-out half
      about twelve times across five hypotheses, from scratch scripts, while
      the main script had the flag.
- [ ] **An unattended run screens on the fit data only.** Each held-out read is
      a decision for a person. Before a schedule starts, check four things:
      1. The budget is enforced in code, and the refusal fired once.
      2. The run can reach current data without a live call that needs
         approval.
      3. The run writes to a journal, not to the permanent record.
      4. Every command the run ran, scratch scripts included, goes into its
         output in full, so that a reviewer can check what it read.

---

## Enforcement

Do not summarise this skill and move on. Before you say "it works", "it earns
weight" or "it holds", state these in the response:

1. **The window:** which rows and which dates, fit or held-out.
2. **The label**, and which part of it is known on the day.
3. **The firing rate** of the candidate.
4. **The mirrored result**, beside the main one.
5. **The noise pass rate** of the gate, and whether the candidate varies along
   the resampled axis.
6. **The held-out reads**, this session and in total.

Say which of these you **did not** check, in those words. An unstated gap reads
as a check that passed. Report a null result with the same plainness as a pass.

---

## Recommended activation setup

Description matching is not enough on its own. This gate must fire at the
moment a result is about to be stated, and that is when momentum skips it. Put
a trigger in the project's `CLAUDE.md`:

```markdown
**Before you say that an input, a rule or a fitted score predicts an outcome,
before you report a separation, a lift or a resample count, and before you ask
to read held-out data, load the `validate-predictor` skill and work through
it.**
```

Add two or three of the project's own cases under it: the name of its gate, its
held-out flag, its label.

## Boundary with neighbouring skills

- **`validate-extraction-output`** — *is the data right*. This skill starts
  where that one stops. Its §J (the prose is a second extraction) applies to
  every number this skill makes you report.
- **`first-real-run`** — *has this code met the real thing*. A bounded first run
  on a small sample produces numbers that look like results. That skill covers
  it: the run proves the code moves, and its numbers are not evidence.
