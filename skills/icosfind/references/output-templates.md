# Output templates

Outputs produced every run:
- Excel shortlist (operational artifact — sort, filter, hand off)
- Word exec summary (partner-ready briefing)
- Pipedrive cross-check CSV (startup runs only — dedup input for `pipedrive_crosscheck.ps1`)

## Excel shortlist — column spec

Use the `xlsx` skill to build this. One row per target, ranked by Fit score descending.

Required columns, in this order:

| # | Column | Notes |
|---|---|---|
| 1 | Rank | Integer, 1 = top |
| 2 | Target name | Company or fund |
| 3 | Type | Startup / LP / Co-investor / Corporation |
| 4 | HQ | City, Country |
| 5 | Sector / thesis | Short — "Green steel", "Family office — sustainability", "Specialty chemicals — strategic CVC", etc. |
| 6 | Stage / size | For startups: stage + last round size. For LPs: AUM if known. For corporations: investment mode + vehicle size if known (e.g. "CVC fund — $250M", "Direct + LP tickets", "Innovation lab only"). |
| 7 | One-liner | What they do, in plain English, ≤20 words |
| 8 | Fit score | 1–5 |
| 9 | Fit reason | One sentence tied to evidence |
| 10 | Why now | The specific signal — include date |
| 11 | Key person | Name, Title. For corporations prefer the Head of Corporate Ventures / Chief Innovation Officer / Head of Open Innovation — not the CEO. |
| 12 | LinkedIn | URL if found, blank otherwise |
| 13 | Likely email | Pattern-guessed, flag as such |
| 14 | Generic/fallback email | info@/partners@ etc. if on their site |
| 15 | Suggested approach | 2–3 sentences |
| 16 | Source URLs | Pipe-separated list, the 2–3 most important |
| 17 | Notes / caveats | Anything flagged during research — conflicting info, outdated data, etc. |

Formatting:

- Freeze the header row
- Bold header row, light fill
- Auto-width columns, but cap "One-liner", "Fit reason", "Why now", "Suggested approach", "Notes" at reasonable widths and wrap text
- Fit score column: conditional format 1–5 with a color scale (red → green)
- "Likely email" and "Generic/fallback email" columns: format as hyperlinks if they're complete addresses
- Source URLs column: each URL hyperlinked where possible

Add a second sheet named **"Run info"** with:
- Date of run
- User's stated criteria (from the scoping questions)
- Number of candidates surfaced before filtering
- Number in the final shortlist
- Known gaps or limitations of the run
- For startup runs: a note pointing to the `<topic>.csv` and the cross-check command

## Word exec summary — doc structure

Use the `docx` skill. Keep it tight — this is a briefing, not a report.

**Filename:** `icosfind_<topic>_<YYYY-MM-DD>.docx`

**Structure:**

1. **Title** — "Icosfind: [topic] — [date]"
2. **Scope (1 paragraph)** — target type, geography, sector, stage, signal priorities. Mirror what the user asked for, explicitly, so they can sanity-check.
3. **Top-level themes (3–5 bullets)** — what patterns did the research surface? E.g., "Seed valuations in European battery tech appear to have compressed ~20% vs H1 2025." Concrete, evidence-backed observations, not platitudes. This is the single most valuable section for a partner skim-read. For corporation runs, themes should surface patterns like which majors are newly active, which are pulling back, and emerging sector-specific mandates (e.g. "Three of the top 10 European specialty chemicals groups announced new CVC vehicles in the last 12 months").
4. **Top targets (5–8)** — one short block each, 3–4 sentences:
   - Bold name + one-line description
   - Why they rank high (fit + signal)
   - Suggested approach in plain prose
5. **Full list reference** — one line pointing to the accompanying spreadsheet for the complete ranked list.
6. **Next step — Pipedrive cross-check (startup runs only)** — short paragraph telling the user to run `pipedrive_crosscheck.ps1 -Companies <topic>.csv` before outreach, and that the real working list is the clean rows.
7. **Caveats (short)** — data limitations, anything the user should treat with skepticism. Include that emails are pattern-guessed.

**Formatting:**
- Letter-size, 1" margins
- Sans-serif body (Calibri or equivalent)
- Section headings in a consistent style
- No cover page, no TOC — this is a working document
- Page numbers in footer

## Pipedrive cross-check CSV — format

Only for **startup** runs. Skip for LPs / co-investors.

**Filename:** `<topic>.csv` (the same topic slug used in xlsx/docx names)

**Columns (header row required):**

```
Name,Domain
```

- `Name` — target company name, same spelling as in the xlsx
- `Domain` — primary web domain without protocol or `www.` (e.g. `circularise.com`). Blank if unknown.

**Example:**

```
Name,Domain
Circularise,circularise.com
Madaster,madaster.com
Orbisk,orbisk.com
```

Save to the same Downloads folder as the xlsx/docx. In the chat response, include a link to this CSV and the command:

```
.\pipedrive_crosscheck.ps1 -Companies <topic>.csv
```

The user runs this from `%USERPROFILE%\IcosCapital\tools\` (where the installer places it).

## Naming and saving

Save all files to the user's Downloads folder (the workspace folder they have access to).

Topic slug rules:
- 2–4 words, lowercase, underscores
- Derived from the most distinctive elements of the user's ask
- Examples: `climate_seed_nordics`, `family_offices_singapore`, `series_a_circular_europe`, `dutch_sustainability`

Date format: `YYYY-MM-DD`, always reflecting the run date (not hard-coded).

## Response wrap-up

After saving, the response to the user should be:

1. A link to the Excel file
2. A link to the Word doc
3. For startup runs: a link to the `<topic>.csv` and the cross-check command
4. A 2–3 sentence summary: how many targets, top theme, any major caveat, and (for startup runs) a reminder that the Pipedrive cross-check is the next step

Do **not** paste the full list into the chat. The files are the deliverable. Keep the chat response skimmable.
