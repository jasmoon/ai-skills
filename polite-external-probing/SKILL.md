---
name: polite-external-probing
description: Pre-fetch gate for any request to infrastructure you do not own. Load BEFORE the first exploratory fetch, before writing an adapter or crawler for a third-party site or private API, before choosing concurrency or a delay, and before responding to a 403, 429, challenge page or block. Also when deciding whether a fetch failure came from the target or from your own network, and when reading robots.txt. The first exploratory request is a production request as far as the other party's servers are concerned — there is no rehearsal, and the resource it spends is the user's standing with that host, which cannot be refunded. Triggers on "let me just check the endpoint", "scrape", "crawl", "sitemap", "robots.txt", "rate limit", "got a 403", "blocked", "user agent", "retry", "proxy", writing a parser against a payload you have not yet seen, or probing an undocumented API. Description matching is unreliable for a gate that must fire before an impulse — pair this with a CLAUDE.md instruction in any repo that fetches from hosts it does not own.
---

# polite-external-probing

A checklist to run **before** a request leaves your machine, not after a host
stops answering.

## Why this exists

Every rule below was paid for by a real incident, on a project that reads
several third-party platforms it does not own.

The failure is not carelessness. It is that exploratory requests feel free.
They are not: they are drawn against an account you cannot see the balance of,
in someone else's name.

## The core reframe

**There is no probe stage.** You may think of the first ten requests as a
rehearsal, a spike, a quick look. The other party's servers cannot tell them
apart from the run, because they are not different. Whatever you would do to be
polite "once it's real" has to be true of request one.

The resource being spent is not bandwidth or quota. It is **the user's standing
with that host** — and unlike a rate limit, standing does not reset overnight.
A sweep of 240 URLs at 8 concurrent workers earned a permanent IP ban that no
amount of subsequent good behaviour has lifted.

---

## A. Before the first request

- [ ] **Read `robots.txt` and the terms of service first.** If a path is
      disallowed, stop. Do not design around it — a workaround is a decision to
      ignore a stated "no", made by someone who read it.
- [ ] **Match robots rules by most specific path (RFC 9309), not by file
      order.** Language-standard parsers commonly return the *first* matching
      group instead. A file that opens with `Allow: /` and disallows a specific
      path further down will be reported as fully crawlable, and the path most
      likely to be disallowed is the one that most deserves the protection —
      real users' order pages, account pages, carts.
- [ ] **A stated `Crawl-delay` always beats your own guess**, even when yours is
      more conservative — it is the host telling you its number.
- [ ] **No robots.txt means "no stated rules", not permission to be greedy.**
- [ ] **Look for a published index before designing a crawl.** A sitemap the
      host advertises is the access route it *chose* to offer. Reaching for a
      search or location-varying endpoint before checking for one builds load
      the host never invited and usually returns less.

> A permission guard written for this only ever returned "allowed". It looked
> identical to a working guard right up until it mattered, because the tests
> written for it naturally exercised the permitted case. **Verify a permission
> check on its negative case before trusting it** — the failure mode of a
> permission check is silent permissiveness.

---

## B. The first request is production

- [ ] **Serial, delayed, resumable — from request one.** One at a time, a stated
      or conservative delay between, and results written to disk after *every*
      record. Not "once we scale it up".
- [ ] **Never add concurrency to a host you do not own.** It is the single
      change most likely to convert a working relationship into a ban, and it
      buys you a wait you were going to spend anyway.
- [ ] **Persist as you go.** A run holding results in memory converts one late
      failure into total loss: 3,190 already-parsed records were thrown away by
      a crash at the end of a run whose only state was a counter. Re-fetching is
      the expensive, block-inducing part — never discard work already on disk.
- [ ] **Test on a handful first**, with a longer delay than the real run, and
      look at what came back before scaling.
- [ ] **Fetch once, take everything.** The response that answers your question
      usually carries several other facts worth having. Harvest them on that
      request rather than paying for a second pass. Deduplicate targets first —
      distinct identifiers often share one page.

---

## C. When something refuses you

- [ ] **Establish *who* refused before deciding how to respond.** A failure from
      the target and a failure from your own egress layer are the same exception
      and the opposite problem: one calls for backing off and seeking sanctioned
      access, the other for changing the network path. The traceback does not
      distinguish them. Test an unrelated host, and test the same host by a
      different route.
- [ ] **Keep three failure modes distinct**, because they need three different
      responses:

      | Mode | Meaning | Response |
      | --- | --- | --- |
      | **Blocked** | the host is refusing *you* | stop the whole run, non-zero exit |
      | **Disallowed** | robots said no | skip this target, never work around it |
      | **Transport error** | this one request failed | skip it, continue |

- [ ] **A block ends the run — it is not a per-target error.** Retrying a block
      in a loop is the behaviour that turns a temporary refusal into a permanent
      one.
- [ ] **Never rotate user agents, forge challenge tokens, or proxy around a
      block.** That is evasion, and it is a different activity from the one you
      were asked to do. The route back is the host's own contact channel — block
      pages usually name one. These are commercial operators whose own users
      want their data found; sanctioned access is both the honest path and the
      durable one.
- [ ] **Distinguish a block from one dead target.** Match the host's block
      *wording*, not a bare 403 — a 403 may be one removed page, and killing the
      run on it wastes the whole sweep.

---

## D. Building an adapter before you can observe the interface

Building blind is often correct — the alternative is not building. The goal is
not to be right; it is to make first contact with reality correct the code in
minutes rather than days.

- [ ] **Test the founding assumption first: where does the data actually live?**
      Order your first live checks so this is settled before any parsing detail.
      An adapter built without access got its central assumption wrong not in
      degree but in kind — and hardening a parser against the payload *moving*
      is no defence at all against the payload not being there.
- [ ] **Make every assumption executable, searchable and cheap to falsify.**
      Executable: a fixture. Searchable: one named constant, not a value spelled
      out in four places. Cheap to falsify: a one-shot verification path that
      checks a single target and prints what it saw.
- [ ] **Prefer one observation to any amount of estimating.** A disagreement
      between two candidate designs was settled not by costing each one but by
      instrumenting the real client and watching the legitimate consumer use the
      interface. Watching the official client is observation, not evasion — it
      is what the host serves its own users.
- [ ] **Look for the data in this order** before reaching for a browser:
      server-rendered structured markup → a framework payload already in the
      HTML → an XHR observed in a real client. Verify emptiness by inspecting
      raw HTML, not a converted or rendered view of it: converters routinely
      strip embedded structured data, so a page holding a full payload can read
      as empty.
- [ ] **Bank a real payload as a fixture** the first time you get one, and make
      the tests run offline against it. Tests must never reach the network.

---

## E. Report what the host did, not why

State the observation. "Returned 403 on 4 of 4 paths, and robots.txt returned
200 from the same address in the same session" — not "they've banned us".
Those are different claims, and the second forecloses the diagnosis in §C.

Say plainly when a route is closed. A host that requires permission requires
permission; the answer is to ask, not to fetch more cleverly.

---

## Enforcement

Before the first request of any new target:

1. Say which of §A you checked, and what `robots.txt` actually said.
2. State the delay and the concurrency you are about to use, in numbers.
3. State explicitly which checks you **did not** run, in those words.

An unstated gap reads to the user as a check that passed.

---

## Recommended activation setup

Description-level matching is not enough on its own. Skills load by description
at the *start* of a turn, and this one has to fire before an impulse — the
impulse being to treat one exploratory fetch as free. Pair it with a structural
trigger in the project's `CLAUDE.md`:

```markdown
**Before the first request to any host this project does not own — including a
one-off "let me just check" — and before responding to a 403, a challenge page
or a block, load the `polite-external-probing` skill.**
```

Then name the project's own hosts and its measured delays underneath, so the
trigger is recognisable in the moment rather than in the abstract. Where a
project's own fetching rules and this skill disagree, the stricter one wins —
say so explicitly, or the two documents will be read as alternatives.

## Boundary with neighbouring skills

- **`validate-extraction-output`** covers *is this result true, and what does
  the number mean*. It runs after extraction; this runs before the fetch. They
  do not overlap: this one can be fully satisfied by a run that then reports a
  meaningless number, and that one by a correct number obtained rudely.
- The rule that a guard must be verified on its **negative** case is more
  general than fetching — it covers dry-run guards and diagnostic guards too,
  and belongs in a global `CLAUDE.md` rather than here. §A carries the
  permission-check instance of it, because that is where it was first paid for.
