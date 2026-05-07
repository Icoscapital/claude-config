---
name: icosfit-feedback
description: Icos Capital investment evaluator feedback handler. Triggers whenever the user says "icosfit feedback", "icos feedback", "feedback for icosfit", or "update icosfit" followed by any content. Captures free-form feedback — scoring corrections, LP intelligence updates, sector pricing data, new sources, false positives, false negatives, diligence outcomes — and writes it to the right knowledge base file so future evaluations improve automatically. Also triggers when user says things like "icosfit should know that...", "add to icosfit...", "tell icosfit that...", or "icosfit remember...".
---

# Icosfit Feedback Handler

## What this skill does

Accepts free-form feedback from any Icos team member and routes it to the correct knowledge base file. The feedback is immediately available to all future `icos-fit-eval` evaluations for all team members via OneDrive sync.

No formatting required from the user — just say what you think and this skill handles categorization and writing.

---

## Knowledge base location

Base path: `C:\Users\<username>\IcosCapital\ICOS-New Deals - Documenten\claude-stuff-donot-touch\icos-fit-eval\knowledge-base\`

Derive `<username>` from the environment (run `whoami` if needed).

Files:
- `lp-intelligence.md` — LP priorities, preferences, recent conversations
- `sector-notes.md` — pricing data, competitive benchmarks, regulatory updates
- `evaluated-companies.md` — evaluation outcomes, false positives/negatives

---

## Step 1 — Understand the feedback

Read the user's input carefully. A single message may contain multiple pieces of feedback — handle each one separately.

Classify each piece into one or more of these categories:

**LP intelligence** — anything about what Nouryon, Bühler, or FrieslandCampina currently want, don't want, are working on, or said in a meeting.
Examples: "Nouryon told us they're not interested in bio-surfactants right now", "Bühler is actively looking for pyrolysis equipment partners", "FrieslandCampina said infant nutrition is frozen for 18 months"

**Sector note** — pricing data, competitive benchmarks, regulatory shifts, market structure observations.
Examples: "Chinese PHA is now at €1.80/kg", "EFSA approved precision fermentation whey in March", "EU tariffs on bio-based imports are being reviewed", "AspenTech just acquired a causal AI startup"

**Scoring correction** — a past evaluation scored too high or too low, with a reason.
Examples: "We passed on Bio-Prodict but we should have proceeded — they just closed a €5M round with DSM", "Vernaio was correctly scored, confirmed no revenue", "We looked at Planted and it was a false positive — B2C revenue was 40%"

**Gate calibration** — a rule or threshold in the evaluation framework needs adjusting.
Examples: "The €1M ARR floor is right but we should be more lenient on stage if the tech is exceptional", "CCUS should score higher if it directly addresses Nouryon's Scope 1 emissions", "We should not auto-fail pre-revenue companies that have EIC Accelerator funding"

**New source or intelligence** — a database, report, contact, or signal source that should be checked in future evaluations.
Examples: "Always check the Hello Tomorrow Prize shortlist — good signal for deep-tech", "Chemovator (BASF accelerator) portfolio is a useful comp set for chemicals"

**Diligence outcome** — what happened after an evaluation. Company passed diligence / failed / invested / declined at IC.
Examples: "We invested in Planted", "Bio-Prodict failed technical diligence — IP was weaker than claimed", "Ful Foods declined our term sheet"

---

## Step 2 — Confirm before writing

Before writing anything, summarize what you understood and what you're about to write, and which file(s) it goes into. Keep it short — one line per item.

Example:
> I'll add 3 notes to the knowledge base:
> - **sector-notes.md**: Chinese PHA now at €1.80/kg — structural cost risk for European PHA producers
> - **lp-intelligence.md**: FrieslandCampina — infant nutrition segment frozen for 18 months, deprioritise
> - **evaluated-companies.md**: Bio-Prodict outcome — false negative, closed €5M round with DSM

Ask: "Correct? I'll write these now." — wait for confirmation before writing.

If the user says yes or any affirmative, proceed. If they correct something, adjust and confirm again.

---

## Step 3 — Write to knowledge base files

Append to the relevant files. Use today's date in every entry.

**Format for lp-intelligence.md:**
```
[YYYY-MM-DD] [LP name] — [What was learned. How it should affect future scoring — be specific about direction: score higher / score lower / auto-flag / deprioritise.]
```

**Format for sector-notes.md:**
```
[YYYY-MM-DD] [Sector] — [Finding. Scoring implication: what should the evaluator do differently because of this?]
```

**Format for evaluated-companies.md — outcome update:**
Add an Outcome column entry if the company is already logged, or append a new row:
```
| [YYYY-MM-DD] | [Company] | [URL] | [Original result] | [X/5] | [Original rationale] | Outcome: [what actually happened — invested/passed/failed diligence/declined IC — with date and one sentence why] |
```

**Format for gate calibration or new source:**
These go into `sector-notes.md` under a special header:
```
[YYYY-MM-DD] GATE CALIBRATION — [Which gate. What the adjustment is. Why.]
[YYYY-MM-DD] NEW SOURCE — [Source name and URL. What it provides. When to use it.]
```

---

## Step 4 — Confirm what was written

After writing, tell the user exactly what was saved and to which file. One line per entry. Example:

> Done. Saved 3 entries:
> - `lp-intelligence.md`: FrieslandCampina infant nutrition freeze
> - `sector-notes.md`: Chinese PHA pricing at €1.80/kg
> - `evaluated-companies.md`: Bio-Prodict outcome updated

These updates are live immediately — the next evaluation by any team member will use them.

---

## Important notes

- Never overwrite existing entries — always append
- Always include the date — entries without dates are useless over time
- If the feedback is vague ("the scoring seems off"), ask one clarifying question: "Which company or sector are you thinking of?" — don't write a vague note
- If the user gives feedback mid-evaluation ("actually, I think the LP fit was wrong"), handle it as feedback even without the "icosfit feedback" trigger
- Multiple feedback items in one message are fine — handle all of them in one pass
