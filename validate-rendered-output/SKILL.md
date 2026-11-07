---
name: validate-rendered-output
description: Pre-delivery gate for any change whose result is seen rather than read - a web page, a chart, a layout, CSS, an SVG, an image, a PDF or a slide. Load BEFORE you say that a visual change works, when the user reports a visual fault, before the second round of fixes for the same kind of fault, and before you build a layout from words about position. Tests, parsers and type checks prove that the output is well formed. They say nothing about where an element lands, how large it is, or what covers it. Triggers on "it looks wrong", "overlapping", "it disappeared", "the layout", "the chart", CSS, SVG, render, screenshot, headless browser, and any reply that would say "I have not seen it render".
---

# validate-rendered-output

A checklist to run **before** you say that a visual change works.

## Why this exists

Every rule below came from building a dashboard and its charts without a way to
see them. Each time, the agent reasoned from the source, wrote unit tests
against the drawing functions, and ended the report with a caveat. Each fault
then arrived as a sentence from the user, one fault per round.

## The core reframe

**"It renders" is three claims.** Passing one says nothing about the others.

| Claim | Question | Evidence |
| --- | --- | --- |
| **Syntax** | Is the output well formed? | a parser, a type check, unit tests |
| **Placement** | Does each element land where it should, at the size and colour it should have? | a screenshot, the rendered DOM, measured boxes |
| **Count** | How many instances of the fault exist, and not only the one that was reported? | a measurement harness |

---

## 0. Before the build — words about position have two readings

- [ ] **Name the reading of a request about position before you build it.**
      Words such as "where it was", "above", "to the right" or "in the bar"
      often fit two layouts. Write the reading that you chose in one line.
      When two readings give different layouts, ask one question with a small
      text preview of each layout. In one session the agent built one reading
      of "where it was vertically" and the user stopped it. On the next
      request of that kind, a question with previews took one message and no
      extra round. A wrong guess costs a build, a check and a correction.

---

## A. A parser checks syntax, not layout

- [ ] **Do not read a green parser or test run as a layout result.** A CSS
      parser, an HTML parser, a syntax check and 592 unit tests all passed a
      transition written on a property whose start value was `auto`, and
      `auto` does not interpolate. The class a parser cannot reach: a
      transition on a value that does not interpolate, a stacking or clipping
      ancestor, a value that resolves differently at the viewport in use, and
      anything that depends on measured height.
- [ ] **A test that looks for text on the page can pass after the text moves
      out of view.** A test that joins the text of several sections still
      finds a warning that moved behind a button. Split guarded text in two
      lists: text that must show on the first render, and text that may sit
      behind a control. Check the first list against the first render only.
      When a change moves guarded text, do not also change the input of the
      test in the same change without a line that says so. Make the test fail
      one time on the moved text, and then decide.

---

## B. See it — a browser is usually already installed

- [ ] **The absence of the preferred tool is not the absence of the
      capability.** When no browser extension or driver library works, look
      for an installed browser binary and use its headless mode (a run with no
      window). It needs no dependency, no extension and no install:

      ```
      chrome --headless --screenshot=out.png --window-size=1400,900 <url>
      chrome --headless --dump-dom <url> > dom.html
      ```

      In one session the agent closed five features with "I have not seen it
      render". When a whole section then vanished, it re-read the markup and
      found nothing. A browser had been installed the whole time. Three
      commands gave the answer: a container pushed the section 4460 pixels
      down. No reading of the source produces that number.
- [ ] **Serve a copy of the real data.** A look at the page must not be able to
      write to the real store or call a live system. Where the server has an
      offline flag, use it, and prove that the process you started is the one
      that answers (see `first-real-run`, section B).
- [ ] **Set up the safe server one time per session, not one time per
      check.** Make it a permanent named entry in the launch configuration,
      or put it in a configuration file that git does not track. Do not add
      and remove a temporary entry in a tracked file for each check. In one
      session that edit and its revert happened about 15 times, and each
      revert was a chance to commit a scratch path.
- [ ] **Keep one server and one tab for a loop of visual changes.** A static
      build is read from disk, so a reload after each build is enough. Close
      the tab and stop the server when the loop ends. In one session each
      check opened a new server and a new tab, four tabs stayed open, and the
      user asked why.
- [ ] **Read the screenshot, and search the rendered DOM** for the values that
      scripts wrote. Take the screenshot at the viewport size that the user
      has, and name that size.
- [ ] **Take a zoomed image of each hover and focus state that the change
      touches.** A full-page image at rest does not show a hover state, and a
      small element can be wrong at a size that a full-page image hides.
- [ ] **Do not trust one capture from a hidden or background browser pane.**
      A background page can paint late, so the capture can be older than the
      DOM. When such a capture shows a fault, or shows a fix, measure the DOM
      and take a second capture before you act. In one session two captures
      showed faults that did not exist.
- [ ] **See a state that depends on the time with a fake clock.** Replace the
      date object in the page with a fixed time, then wait for the page's own
      timer. This shows a label that appears only during market hours, or a
      notice that appears only after a date, with no wait and no live call.
      Say which source of the state the check used. When the page can also
      take that state from a live system, the fake clock does not prove that
      path.

---

## C. Measure it — build the harness at the second report

- [ ] **At the second report of the same kind of fault, build the smallest
      harness that turns the output into numbers.** Run the page's own drawing
      function with no browser window, print what it produced, and compute
      the property in question: do two label boxes overlap, does a marker's
      colour differ from the line under it, does a label sit above or below
      its point. Over five rounds of chart feedback, two rounds fixed the wrong
      thing first. A harness of about fifty lines found that 9 of 12 labels sat
      below their point, where the user had noticed one or two. After that,
      each round took one attempt.
- [ ] **Derive each fix from a measurement, not from the description of the
      fault.** A description gives one fault per round. It never says how many
      other instances exist, and that count decides whether the fix is a patch
      or a rule.
- [ ] **Measure the rendered box of each new element.** A new element can
      receive a rule that was written for something else. In one session a
      rule that sized every chart `svg` in a panel drew a new 13 px icon very
      large. The probe read the opacity of the icon and the height of its
      strip, and both were correct. A probe confirms only the properties that
      you chose, so add the width and height of each new element, and compare
      them with the size that the change intends.
- [ ] **Keep the harness as the regression test.**
- [ ] **Say what the harness cannot do.** It shows that the output is well
      formed and that the properties you chose to measure hold. It cannot show
      that the page looks right. Do not let a reader take it for having seen
      the page.

---

## Enforcement

Do not summarise this skill and move on. Before you say that a visual change
works, state in the response which of these you did:

1. **Syntax:** which parser, check or test ran.
2. **Seen:** a screenshot, and at which viewport size. Name each hover or
   focus state that you saw zoomed.
3. **Measured:** which property, over how many instances. For a new
   element, include its box.

If you did neither 2 nor 3, write "the layout is unchecked", in those words,
and name the specific things that a person should look at.

---

## Recommended activation setup

Description matching can miss this gate, because it must fire at the end of a
change, when the work feels done. Put a trigger in the global or the project
`CLAUDE.md`:

```markdown
**Before you say that a visual change works, and when the user reports a
visual fault, load the `validate-rendered-output` skill and work through it.**
```

## Boundary with neighbouring skills

- **`first-real-run`** — *has this code met the real thing*. Its section E
  covers how to prove a port that must change nothing, and that applies to a
  port of a page too.
- **`validate-extraction-output`** — the numbers that a page shows are claims
  about data, and that skill covers them.
- **Design and browser skills** — a design skill says how a page should look.
  A browser skill gives the tools to see it. This skill asks whether you have
  evidence that the page does what you say.
