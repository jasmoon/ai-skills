---
name: prepare-long-running-task
description: Setup gate for any task that runs over many steps without a person watching each one - a /loop, a scheduled or cloud routine, a cron job, a background agent, a headless run, or a long task that will outlive several context compactions. Load BEFORE the first iteration or the first scheduled run, and when you write or change the prompt, runbook or work list that such a run reads. A long-running run has no memory except its files and no judgement except its written rules, so the setup decides what it can do safely. Triggers on "/loop", "schedule", "routine", "cron", "every day", "unattended", "autonomous", "background", "long-running", "keep going until", runbook, work list, and a run that opens a pull request by itself.
---

# prepare-long-running-task

A checklist to run **before** a task runs for many steps without you.

## Why this exists

Every rule below came from two real setups: a self-paced loop that rebuilt a
web page as a dashboard over many iterations, and a daily cloud run that
screens inputs for a score and opens one pull request per day. In both, the
run started each step with no memory of the last one. What it knew was what
its files said. What it refused to do was what its rules said.

## The core reframe

**A long-running task needs four things written down before the first step.**

| Part | Question | Section |
| --- | --- | --- |
| **Memory** | What does the run read at each step to know where it is? | A |
| **Guards** | Which rules does the run depend on, and has each one refused once? | B |
| **Output** | What does the run write that a person can check? | C |
| **Review** | What does the person check, and when? | D |

---

## A. Memory — one file that the run reads at every step

- [ ] **Put the state in one file that the run reads again at every step.** A
      compaction erases the conversation, and a scheduled run starts with
      nothing. The file holds these parts, in this order:
      1. How the run uses this file.
      2. **The stop rules**, before every other instruction: what the run
         never does. If a step would break one, the run does not do the step
         and writes what stopped it.
      3. The done-check that runs at each step.
      4. The steps, with STOP markers at the end of each stage.
      5. The stop conditions: the same failure twice, or a decision that
         belongs to a person.
      6. An assumptions list and a log, both append-only.
- [ ] **When outputs can stay unreviewed for days, the run reads them before
      it picks a task.** A daily run opens a pull request that may stay
      unmerged. Without a read of every open branch first, the next run
      repeats the task, or reuses a seed.
- [ ] **Every formula in the file states where its index starts.** A
      selection rule read "trial k uses the seed `seed * 1000 + k`" and did
      not say whether `k` starts at 0 or 1. The first unattended run reported
      the wrong seed for the one trial that mattered.
- [ ] **Give each choice a tie rule.** "Take the side with fewer trials. On a
      tie, take the first side." A rule with no tie case makes the run guess on
      exactly the day the counts are equal.

---

## B. Guards — prove each one before the first step, not during one

- [ ] **Fire every guard that a stop rule depends on, once, on purpose, before
      the first step, and write the result in the log.** One loop's rule "no
      live external calls" rested on a server flag. Each refused endpoint was
      called once before the loop started. The calls showed that one endpoint
      still did local writes under the flag, which reading the code had not
      made clear.
- [ ] **A rule that only prose holds is broken by the first run that forgets
      it.** Where the run spends a budget — a held-out data set, a quota, a
      live write — enforce the budget in code, with a refusal that has fired
      once. See `validate-predictor`, section D, for a held-out budget.
- [ ] **Before you fire a guard at a network service, prove that the process
      you started is the one that answers.** See `first-real-run`, section B.

---

## C. Output — write what a person can check, in one place they already read

- [ ] **One output per run, in a place a person already reads**, such as one
      pull request per day on its own branch. The run never merges it.
- [ ] **A named heading for decisions that belong to a person.** "When
      something is not clear, write the question under 'Question for <name>'
      and stop. A run that stops with a clear question is a good run." The
      first daily run found that its own acceptance gate could pass noise. The
      obvious fix changed a recorded decision. The run did not change it: it
      wrote the question under the heading and stopped.
- [ ] **Every command in full, scratch scripts included.** A reviewer can check
      only what the output shows. In the first daily run, the scratch scripts
      lived in a temporary folder that no longer exists. Because the output
      printed them as run, a later review could still confirm which data they
      read.
- [ ] **Check the prose against the raw output before the output goes out.**
      The tables of the first daily run were right. Three sentences around them
      were wrong: a seed, a count, and a bound quoted for the wrong sample size.
      Put the check of `validate-extraction-output`, section J, into the run's
      steps, because no person reads the prose before it is published.
- [ ] **A short section for lessons about the method**, such as "Notes for the
      observer", where a skill-observation log exists that the run cannot reach.
      The next session that reads the output harvests them.

---

## D. Review — what the person checks, and when

- [ ] **The reviewer's requests go into the run's output, with the answers.**
      In the first daily run, the reviewer sent a correction and asked for a
      closer look through the session, not the pull request. The pull request
      shows the answers, and the requests appear in one line of the journal.
      Ask the run to record each request beside its answer.
- [ ] **When the record is append-only, review the prose before the merge.** The
      first daily run was merged seven hours after it opened. Review caught one
      of the three errors in its prose. The record forbids an edit to a merged
      entry, so the two that remained can only be fixed by a later entry that
      points back.
- [ ] **Run the setup once with a person watching** before the schedule starts:
      check the toolchain, the network, the right to push, and that every live
      system fails fast rather than hangs.

---

## Enforcement

Do not summarise this skill and move on. Before the first step, or the first
scheduled run, state in the response:

1. The path of the file that the run reads at each step.
2. The stop rules, and where they sit in that file.
3. Each guard that a stop rule depends on, and when it last refused.
4. Where the run writes, and the heading for a person's decisions.
5. The step that checks the prose before the output goes out.
6. Who reviews the output, and whether the record allows edits after the merge.

Say which of these you **did not** set up, in those words.

---

## Boundary with neighbouring skills

- **`first-real-run`** — the first contact of code with real data, and how to
  fire a guard on purpose. This skill fires one step earlier, at the setup, and
  it uses that skill's section B for each guard.
- **`validate-predictor`** — when the long-running task measures candidates,
  its section D governs the held-out budget.
- **`validate-extraction-output`** — its section J is the prose check that
  section C here puts into the run's steps.
- **`task-observer`** — "Notes for the observer" is how a run with no route to
  the observation log still reports what it learned.
