# Herb — Search Playbook

Run sources in this order. Each source has specific query patterns and extraction targets.
Always record which source each company came from in the Source(s) field.

---

## Source 1 — Crunchbase (most structured, run first)

**Query patterns:**
- `site:crunchbase.com "[sector keyword]" Europe Series A`
- `site:crunchbase.com "[mandate keyword 1]" "[mandate keyword 2]" startup`
- `crunchbase "[mandate theme]" founded:2018..2024 Series A Europe`

**Fetch targets:**
- Public Crunchbase company profile pages
- Extract: name, domain, HQ, stage, total raised, last round date + investors, description, employee count, founding year

**Tips:**
- Crunchbase public profiles are accessible via WebFetch without login
- Use the mandate keywords directly — Crunchbase indexes descriptions well
- Filter mentally for Series A/B stage; skip pre-seed and growth-stage results

---

## Source 2 — VC portfolio sites

**Query patterns:**
- `"[VC fund name]" portfolio "[sector keyword]"` — use known European sustainability VCs
- `site:[vcfund.com] portfolio "[mandate keyword]"`

**Priority VC funds to check for sustainability/climate-tech mandates:**
- EQT Ventures, Lowercarbon Capital, Pale Blue Dot, Extantia Capital
- World Fund, Planet A Ventures, 2150, Carbon Removal Partners
- SET Ventures, Clean Energy Ventures, Breakthrough Energy Ventures Europe
- Sofinnova Partners, Softech VC, Ctrl+Alt, Kiko Ventures
- Also check accelerators: EIT Food, EIT InnoEnergy, Hello Tomorrow, YC (filter by sector)

**Fetch targets:**
- Portfolio pages of relevant funds
- Extract company names and links, then fetch each company's own site for full profile

---

## Source 3 — X / Twitter

**Query patterns (via WebSearch):**
- `site:x.com "just raised" "[mandate keyword]" Europe 2025`
- `site:x.com "seed round" OR "Series A" "[mandate keyword]" 2025 2026`
- `site:twitter.com "[mandate keyword]" startup funding announcement`
- `"[mandate keyword]" startup raised million 2025 site:x.com`

**What to extract:**
- Company name from tweet text
- Funding signal (amount, round, investors)
- Date of tweet (recency = why now signal)
- Founder/CEO handle for contact intelligence

**Tips:**
- Focus on tweets from founders, investors, and tech journalists
- Prioritize posts from last 12 months
- Use the tweet content as the "why now" signal in field-spec

---

## Source 4 — LinkedIn companies

**Query patterns (via WebSearch — do not attempt authenticated LinkedIn browsing):**
- `site:linkedin.com/company "[mandate keyword]" Europe`
- `site:linkedin.com/company "[mandate keyword]" sustainability startup`
- `"[mandate keyword]" startup Europe site:linkedin.com/company`

**For each company found, also run:**
- `site:linkedin.com/in "[company name]" CEO OR founder` — to find key contact

**What to extract:**
- Company LinkedIn URL
- Description snippet from search result
- Employee count (sometimes visible in search snippet)
- Key person name + title + LinkedIn URL

---

## Source 5 — Conference and competition sites

**Query patterns:**
- `"[mandate keyword]" winner OR finalist "[year]" competition Europe`
- `hello tomorrow "[mandate keyword]" 2024 2025`
- `EIC Accelerator "[mandate keyword]" 2024 2025`
- `"[mandate keyword]" startup challenge winner Europe`

**Priority conferences/competitions for Icos sectors:**
- Hello Tomorrow (deep-tech)
- EIC Accelerator (EU-wide, well-curated)
- Bits & Pretzels (tech + food)
- AgriFood Innovation (food-tech)
- Impact Festival (sustainability)
- Greentech Festival
- Nova-Institute bioeconomy awards (bio-based chemicals)
- EFIB (European Forum for Industrial Biotechnology)

**What to extract:**
- Company name + website from conference listing
- Award/recognition (strong quality signal — note as "why now")

---

## Source 6 — PitchBook export (if provided by author)

**Triggered when:** author emails a PitchBook export file to herb@icoscapital.com

**Processing:**
- Read the Excel/CSV file from herb\pipedrive-inputs\
- Extract all rows; map columns to field-spec fields
- PitchBook typically provides: company name, website, HQ, stage, funding, description, investors
- Add source = "PitchBook (author export)" for all rows from this file

**Tips:**
- PitchBook data is high quality — prioritize these companies for icos-fit-eval
- Check the export date; flag any companies last updated >12 months ago

---

## Source 7 — Icos custom list (if provided by author)

**Triggered when:** author emails a custom company list to herb@icoscapital.com

**Processing:**
- Read the file from herb\pipedrive-inputs\
- Accept any reasonable format (Excel, CSV, plain list in email body)
- If columns are missing, do additional web research to fill them in
- Add source = "Icos list (author provided)" for all rows from this file

---

## Cross-source deduplication

After all sources are complete:
1. Group companies by domain (primary key)
2. Where domain is missing, fuzzy-match by company name (>85% similarity = same company)
3. For duplicates: keep the record with the most complete data; merge source tags
4. Result: one row per unique company with all sources listed

---

## Pipedrive cross-check

After deduplication, for every company in the merged list:
- Call `mcp__plugin_dropin-pipedrive_dropin-pipedrive__lookup_existing` with company_name and website
- Record result in "Pipedrive status" field:
  - `best_existing_deal` = null → status = "New"
  - Open deal in Icos pipeline → status = "Open deal — [stage]"
  - Won deal → status = "Won"
  - Lost deal → status = "Lost — [date]"
- Companies with status = Open/Won/Lost: keep on long list but grey them out; do NOT run icos-fit-eval on them

---

## Search volume targets

| Round | Target companies (pre-dedup) | Expected after dedup + Pipedrive filter |
|---|---|---|
| Round 1 | 60–100 | 30–50 new companies |
| Round 2 (after author feedback) | 40–60 additional | 20–30 new companies |
| Round 3 (final sweep) | 20–40 additional | 10–20 new companies |

If a source returns fewer results than expected, note it in the run-state.md
and explain to the author in the draft email what was and wasn't found.
