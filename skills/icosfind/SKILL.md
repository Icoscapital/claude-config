---
name: icosfind
description: Icos Capital's target-sourcing agent. Use this skill whenever the user says "Icosfind", "icos find", "find targets", "source startups", "source LPs", "find investors", "source CVCs", "find strategic corporates", "find corporate investors", or otherwise asks to build a list of startups to invest in, limited partners to raise from, co-investors to syndicate with, or food / chemicals / materials corporates to approach for strategic investment or partnership. Also trigger when the user describes a sourcing task like "I need 20 climate-tech seed companies in the Nordics", "find me family offices in Singapore that back sustainability funds", or "find 15 food / chemical / materials corporates that invest in sustainability startups" even if they don't name the skill. The skill asks a short set of scoping questions, then does web research (press releases, company sites, news, LinkedIn) to produce a ranked shortlist as an Excel file plus a Word exec summary with suggested outreach approach for each target, plus a Pipedrive cross-check CSV for startup runs so the user can identify which targets are already in their pipeline.
---

# Icosfind — Icos Capital target sourcing

## What this skill does

Icosfind helps the user build a pre-screened shortlist of sourcing targets — **startups** to potentially invest in, **limited partners (LPs)** to raise from, **co-investors** to syndicate with, or **corporations** (food, chemicals, and materials corporates that invest in innovation directly, via a CVC fund, or as LPs in external funds, with an innovation + sustainability mandate) to approach for strategic investment or partnership. For each target it gathers signals from public sources, scores fit against the user's stated criteria, guesses likely contact emails using common patterns, and drafts a tailored outreach approach.

For startup runs, Icosfind also produces a Pipedrive cross-check CSV so the user can filter out targets already in their pipeline before outreach.

The user's firm is **Icos Capital**, a sustainability / climate-tech oriented investor. When the user doesn't specify otherwise, lean toward that thesis (climate, energy transition, circular economy, industrial decarbonization, sustainable materials, agri/food-tech, water), but always confirm rather than assume.

## The flow

1. **Ask a short set of scoping questions** using the `AskUserQuestion` tool (see the next section for the exact questions). Don't skip this step — every run needs fresh scoping.
2. **Run the research** following `references/research-playbook.md`.
3. **Score and rank** each candidate against the user's criteria, with a one-line reason per score.
4. **Deliver both** an Excel shortlist and a Word exec summary, using the column spec and doc structure in `references/output-templates.md`.
5. **Ship a Pipedrive cross-check CSV** alongside the deliverables for startup runs — a simple `Name,Domain` list the user can feed through `pipedrive_crosscheck.ps1` to identify which targets are already in their pipeline. See "Step 5 — Pipedrive cross-check" below. Skip for LP / co-investor runs.

## Step 1 — Scoping questions

Always use `AskUserQuestion` (not plain text) so the user can pick from options. Ask these in a single batch (multiple questions in one call) so it feels snappy, not interrogative.

Use this question set. Adapt wording to what the user already said — if they already told you "startups in Germany, energy storage," don't ask those again; confirm them and ask the rest.

1. **Target type for this run** — startups / LPs / co-investors / corporations (multi-select allowed).
2. **Geography** — offer sensible regions (Europe, North America, Nordics, DACH, UK & Ireland, Benelux, France, Southern Europe, Middle East, Asia, Global) with a free-text escape for specifics.
3. **Sector / thesis focus** — default options keyed to Icos themes (Climate & energy transition, Circular economy & materials, Industrial decarbonization, Agri/food-tech, Water, Mobility, Cross-sector / sustainability broadly, Other). When **corporations** is selected, bias the defaults toward Food & ingredients, Specialty chemicals, Advanced materials, Packaging, Agri-inputs, and Cross-sector industrials (the existing Icos themes stay available too).
4. **Stage or size** — for startups: pre-seed, seed, Series A, Series B+, growth. For LPs: family office, endowment/foundation, pension/insurance, fund-of-funds, corporate, HNWI/angel syndicate. For **corporations**: ask investment mode instead of stage — Direct balance-sheet / strategic equity, Dedicated CVC fund, LP in external funds, Innovation lab / accelerator partnership, Any of the above (multi-select). If multiple target types were selected, ask one question each.
5. **Signal to prioritize** (multi-select) — e.g. recently raised, new product launch, recent executive hire, expanding to a new market, recent press coverage, recently backed a similar fund (for LPs), publicly stated sustainability mandate (for LPs). For **corporations**, offer: New CVC fund or vehicle launched, Recent direct strategic investment, Publicly stated sustainability / net-zero mandate, Recent innovation / R&D partnership announcement, LP commitment to a sustainability-focused fund, New head of corporate ventures / innovation hired.
6. **How many targets** — 10 / 20 / 30 / 50. Default 20.

If anything essential is still ambiguous after the batch (e.g., a very broad thesis), ask one tight follow-up before starting research. Don't pile on clarifying questions — better to research and refine than paralyze the user with questions.

## Step 2 — Research

Follow the playbook in `references/research-playbook.md`. The short version:

- Use `WebSearch` to find candidates matching criteria. Run multiple queries — vary terms, sources, and time filters to widen the net.
- Use `WebFetch` on each candidate's website, recent press releases, news coverage, and — where available — LinkedIn company pages to confirm basic facts.
- For each target, extract: company/fund name, HQ, stage/size, one-line what-they-do, 2–3 recent signals with dates, 1–3 key people (name + title + LinkedIn URL if findable), **and the company's primary web domain** (needed for the Pipedrive cross-check step).
- For **corporations** specifically, also capture: investment mode (direct / CVC fund / LP / innovation partnership — multi-flag if more than one applies), the named innovation or ventures lead (Head of Corporate Ventures, Chief Innovation Officer, Head of Open Innovation, or equivalent), and the publicly stated sustainability mandate if any.
- Guess likely emails using the patterns in the playbook. Clearly mark every guessed email as "pattern-guessed" so the user knows it isn't verified.
- Deduplicate and filter out obvious misfits before ranking. A shortlist with 20 on-thesis names is more valuable than 50 with noise.

## Step 3 — Score and rank

For each target, attach:

- **Fit score** 1–5 (5 = bullseye on user's stated criteria)
- **Fit reason** — one sentence tying the score to concrete evidence from the research (not generic praise)
- **Why now** — the specific signal that makes this the right moment to reach out. For **corporations**, the "why now" should flag concrete activity (a newly launched CVC fund, a recent direct strategic investment, an announced innovation partnership, or a fresh innovation-lead hire) rather than generic ESG language.
- **Suggested approach** — 2–3 sentences: who to reach, what angle (warm intro target, recent news hook, shared portfolio company, mutual conference, etc.), and what not to lead with

Rank by fit score, then by strength of the "why now" signal.

## Step 4 — Deliver outputs

Produce **both** a ranked Excel shortlist and a Word exec summary in the same run, following `references/output-templates.md`. Use the `xlsx` and `docx` skills to build them — don't hand-roll openpyxl or python-docx unless those skills are unavailable.

Save all deliverables to the user's Downloads folder with filenames:
- `icosfind_<topic>_<YYYY-MM-DD>.xlsx`
- `icosfind_<topic>_<YYYY-MM-DD>.docx`
- `<topic>.csv` (Pipedrive cross-check input — see Step 5)

Where `<topic>` is a 2–4 word slug derived from the user's criteria (e.g., `climate_seed_nordics`, `family_offices_singapore`, `dutch_sustainability`). End the response with clickable links to all files and a short 2–3 sentence summary of what's in them — themes the user should notice, any caveats on the data.

## Step 5 — Pipedrive cross-check (startup runs only)

For any **startup** sourcing run, automatically produce a Pipedrive cross-check CSV alongside the xlsx and docx. This is how the user dedupes the shortlist against their existing pipeline before doing any outreach.

### What to generate

A CSV in the Downloads folder named `<topic>.csv` with exactly two columns:

```
Name,Domain
Circularise,circularise.com
Madaster,madaster.com
```

- **Name** — the company name, same spelling as in the xlsx (this is what the Pipedrive API searches on).
- **Domain** — the primary web domain (no protocol, no trailing slash, no `www.`). If you couldn't confidently find a domain during research, leave it blank — name-only matching still works.

### What to tell the user

At the end of the response, after the xlsx/docx links, include a "Pipedrive cross-check" section that says (in substance, not verbatim):

- Link to the CSV.
- Tell them to run `pipedrive_crosscheck.ps1 -Companies <topic>.csv` from wherever they keep the tools folder (installer puts it in `%USERPROFILE%\IcosCapital\tools\`).
- Remind them it produces `icosfind_<topic>_pipedrive_results.csv` with a `Yes/No` per company plus matched org + deal names, owners, stages.
- Remind them that the real working list is the **clean rows** (InPipedrive = No) — the Yes rows are intelligence about what Icos has already seen and can inform why-did-we-pass analysis, but should generally be de-prioritized for fresh outreach.

### When to skip

- **LP runs** — LPs don't live in the startup CRM in the same way. Skip.
- **Co-investor runs** — similarly skip unless the user explicitly asks.
- **Corporation runs** — skip by default; corporates aren't tracked in the startup pipeline the same way. Run it only if the user explicitly asks because they track corporate prospects in Pipedrive.
- **User explicitly says no** — respect it; they may be in a rush or already have a dedup plan.

### Why this step matters

Icos has been in European climate-tech for years. Any sourcing pass on well-known categories (circularity, grid flex, LCA, food waste) will surface names already in Pipedrive — sometimes already passed on. Without the cross-check, the shortlist looks "generic" to the user because half of it isn't actually fresh. The cross-check turns that noise into signal: "here's who's new, here's who we already looked at, here's who passed."

## Important principles

- **Be honest about uncertainty.** Public web research produces spotty data. When you can't verify something (email address, exact AUM, next fund vintage), say so in the output rather than inventing. A flagged "pattern-guessed" email is useful; a confidently wrong email is worse than useless.
- **Prefer primary sources.** A company's own website or a press release beats a secondhand blog aggregator. Cite the source URL for every signal so the user can click through.
- **Keep the shortlist focused.** If the user asked for 20 and you only found 12 on-thesis names, return 12 with a note. Don't pad to hit the number.
- **Respect robots.txt and ToS.** Use `WebSearch` and `WebFetch` — don't script aggressive scraping. If a site blocks fetching, note it and move on.
- **Remember the asymmetry of outreach.** The user will send real emails to real people based on this list. A bad target wastes a slot in their week; a good target could be a portfolio company or an LP commitment. Err toward precision over recall.
- **Never fabricate company names.** If research comes up short on the requested count, return the verified subset and say so. Fabricated names are worse than useless for outreach — they expose Icos to embarrassment the first time someone clicks through.
- **For corporations, distinguish investor modes.** In the output, clearly separate *strategic / direct investors*, *CVC funds*, and *LPs in external funds* — each requires a different outreach approach (innovation lead vs. CVC partner vs. IR/treasury), and mixing them up makes the shortlist useless.

## When NOT to use this skill

- General market research, competitive landscape analysis, or trend reports — Icosfind is specifically for building an actionable contact list. Route general research tasks to normal web research.
- Due diligence on a specific named company the user already knows about — that's a deeper, different workflow.
- Drafting the actual outreach email — Icosfind suggests the approach; the user writes the message (or asks for a separate drafting pass after).
