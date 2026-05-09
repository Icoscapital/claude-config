---
name: herb
description: Icos Capital deep dive sourcing agent. Herb runs multi-source startup
  searches based on a mandate provided by email, cross-checks against Pipedrive,
  applies Icos Fit scoring, and auto-creates deals in Pipedrive for approved companies.
  Trigger this skill when the user says "run herb", "start herb", "trigger herb",
  or when processing an activation email sent to herb@icoscapital.com containing
  "Hello Herb let's go fetch". Also triggers when checking herb@icoscapital.com for
  incoming files (Pipedrive exports, PitchBook results, author feedback) during an
  active run.
allowed-tools:
  - WebSearch
  - WebFetch
  - Read
  - Write
  - mcp__dropin-pipedrive__lookup_existing
  - mcp__dropin-pipedrive__create_deal_from_extracted
  - mcp__dropin-pipedrive__attach_file_to_deal
---

# Herb — Icos Capital Sourcing Agent

BASE = C:\Users\nitye\IcosCapital\ICOS-New Deals - Documenten\claude-stuff-donot-touch

References (read only when needed for that phase):
- Config/paths:     BASE\herb\config\herb-config.md
- Run state tpl:    BASE\herb\config\run-state-template.md
- Field spec:       BASE\skills\herb\references\field-spec.md
- Search playbook:  BASE\skills\herb\references\search-playbook.md
- Email templates:  BASE\skills\herb\references\email-templates.md
- Icos Fit skill:   BASE\skills\icos-fit-eval\SKILL.md

Runs folder: BASE\herb\runs\[YYYY-MM-DD-slug]\

---

## TOKEN RULES (always apply)

- **Search agents**: instruct them to return ONLY a pipe-delimited table — no prose, no headers, no explanations. Columns: Company | Domain | HQ Country | Stage | Raised | Last Round | Investors | Tech (1 line) | Food/Chem sectors served | Source URL | Why Now signal
- **Pipedrive responses**: from each lookup_existing result extract ONLY {status, lost_reason, local_lost_date, org_name} — discard all other fields immediately
- **Pipedrive batching**: max 5 simultaneous lookup calls (rate limit)
- **run-state.md**: update after every phase; this is how interrupted runs resume

---

## PHASE 0 — ACTIVATION

Trigger: email to herb@icoscapital.com containing "Hello Herb" or "let's go fetch"

0.1 Auth: sender must end in @icoscapital.com → else send T1 and STOP
0.2 Extract: theme, keywords, geography (default Europe), stage (default Series A/B), special instructions
0.3 Create: herb\runs\[YYYY-MM-DD-slug]\ + run-state.md (from run-state-template.md)
0.4 Send T2 (mandate confirmation) → wait for "Start" reply

---

## PHASE 1 — INTAKE (runs in parallel while waiting for Start)

On each email check, look for:
- Pipedrive export attachment → save to herb\pipedrive-inputs\[slug]-pipedrive.xlsx → send T3
- PitchBook export attachment → save to herb\pipedrive-inputs\[slug]-pitchbook.xlsx → send T3
- Custom company list → save to herb\pipedrive-inputs\[slug]-custom-list.csv → send T3
- "Start" reply → proceed to Phase 2

---

## PHASE 2 — SEARCH

Sources (run in parallel via agents, search-playbook.md for query patterns):
1. Crunchbase
2. VC portfolio sites (Planet A, SET, World Fund, Extantia, 2150, Kiko, EIT Food)
3. X / Twitter (WebSearch only)
4. LinkedIn companies (WebSearch only, site:linkedin.com/company)
5. Conference/competition sites (EIC Accelerator, Hello Tomorrow, Bits & Pretzels)
6. PitchBook export (if received in Phase 1)
7. Custom list (if received in Phase 1)

After all sources:
- Dedup by domain (primary key); fuzzy-match name >85% where domain missing; merge source tags
- Pipedrive cross-check (batches of 5): record New / Open deal / Won / Lost; extract only {status, lost_reason, local_lost_date, org_name}
- Pre-screen (field-spec.md gate): tag Pass or Fail — [reason]
- Icos Fit eval: invoke icos-fit-eval skill as background agent for each Pre-screen Pass; read back scorecard into Sheet 2
- Save longlist-v[N].xlsx (field-spec.md structure) to run folder
- Update run-state.md stats

---

## PHASE 3 — SEND DRAFT

- Send T4 (longlist draft) with longlist-v[N].xlsx attached; include 2–3 observations
- Record round sent in run-state.md → wait for reply

---

## PHASE 4 — ITERATE (max 3 rounds)

- Extract feedback: removals, new keywords, geography changes
- Update run-state.md; increment round counter
- Round < 3: re-run Phase 2 with adjusted mandate → Phase 3
- Round = 3, no "Finally OK": send T8 → wait

---

## PHASE 5 — FINALIZE

Trigger: "Finally OK"

- Produce final-longlist-[slug].xlsx (all icos-fit-eval results populated, summary stats row)
- Produce final-summary-[slug].docx (docx skill): cover + top picks + MONITOR table + methodology
- Send T5 with both files; ask author which companies to enter into Pipedrive

---

## PHASE 6 — PIPEDRIVE ENTRY

- Parse approved companies from author reply
- For each: lookup_existing (confirm still New) → if New: create_deal_from_extracted
- Send T6 (deals created + links)

---

## PHASE 7 — LEARN

- Send T7 (feedback request)
- On reply: append run notes to search-playbook.md under "## Run notes — [slug] — [date]"
- If scoring corrections mentioned: invoke icosfit-feedback skill

---

## Rules

- Never fabricate company names or data — mark Unknown, not invented values
- Guessed emails must be labelled "pattern-guessed"
- Pipedrive is source of truth for duplicates — always check live
- Only email @icoscapital.com addresses (T1 exception only)
- icos-fit-eval is strict — a short PROCEED list beats a long maybe list
