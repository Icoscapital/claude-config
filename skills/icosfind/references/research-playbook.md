# Research playbook

How to actually gather the intel once you have the user's scoping answers.

## Search strategy

Run a *portfolio* of searches rather than one. Vary:

- **Phrasing:** "climate tech seed funding Nordics 2025" vs "Series A carbon capture Europe" vs "sustainability startup raises Amsterdam"
- **Source type:** news sites, trade publications (Sifted, TechCrunch, Tech.eu, Axios Pro, PV Magazine, Canary Media), company blogs, fund websites, LP databases' public pages
- **Recency:** for signal-driven searches, add year/month filters or "last 6 months" framings
- **Angle:** for startups, search by technology keyword *and* by who's funding them. For LPs, search by "backed sustainability fund" / "commits to climate" / their disclosure-report pages. For corporations, search by corporate name + "ventures" / "CVC" / "innovation" / "invests in" / "strategic investment" / "sustainability fund commitment", and separately scan trade press for recent deal announcements in the sector

Aim for at least 4–6 distinct `WebSearch` queries before moving to `WebFetch` on specific candidates. More for broader asks.

## Per-target enrichment

Once you've identified a candidate, fetch these in order:

1. **Their own site** — "about", "team", "press" or "news" pages. This is your ground truth for name spelling, title, focus area, HQ, **and the primary domain** (needed for the Pipedrive cross-check CSV).
2. **A recent press release or news article** (ideally <6 months old) — gives you the "why now" signal.
3. **LinkedIn company page** (public view) — for team size, location confirmation, recent hires if visible.
4. **A second independent source** — confirms the signal isn't hallucinated. Prefer primary press releases over aggregators.

Keep source URLs. Every claim in the output needs a URL to back it up.

## Capturing the domain (for Pipedrive cross-check)

For startup runs, record the primary web domain for every target. This is the host part of their main marketing URL, without protocol, path, or `www.`:

- `https://www.circularise.com/about` → `circularise.com`
- `https://orbisk.com` → `orbisk.com`
- `https://app.jedlix.com` → `jedlix.com` (prefer the root domain over app/subdomain)

If a company has a country-specific site, use the main one (e.g. `sensorfact.nl` if that's the flagship, even if they also have `sensorfact.de`). If you genuinely cannot determine a domain, leave it blank — name-only Pipedrive matching still works, just less precisely.

## Finding corporate investors

For **corporations** (food, chemicals, materials, and adjacent industrials that invest in innovation), start from:

1. **The corporate's own website** — "Ventures", "Innovation", "Open Innovation", "Corporate Venturing", "R&D Partnerships", or "Sustainability" sections. Large groups often have a dedicated CVC microsite (e.g. `bcv.basf.com`, `evonik-venture-capital.com`, `shell.com/ventures`) — note both the parent domain and the CVC domain.
2. **The annual report and sustainability / ESG report** — usually linked from investor relations. These disclose innovation spending, CVC vehicle size, LP commitments to external funds, and strategic partnership announcements more reliably than press releases.
3. **Trade press for the sector** — AgFunderNews and Food Dive for food and agri-inputs; Chemical & Engineering News, Specialty Chemicals Magazine, ICIS, and FoodNavigator for chemicals and food ingredients; Packaging Europe and Plastics News for packaging and materials. Filter for "invests in", "leads round", "backs", "launches venture fund" in the last 12 months.
4. **LinkedIn** — search the parent company + "ventures" or "innovation" to surface the named CVC managing director, Head of Open Innovation, or Chief Innovation Officer. Named innovation leads move frequently; prefer a LinkedIn-sourced current title over an older press quote.

Capture the **investment mode** explicitly: direct strategic / balance-sheet, dedicated CVC fund, LP in external funds, or innovation partnership / accelerator. A single corporate may use several modes in parallel — flag all that apply.

## Finding people

For startups: CEO, CTO if technical thesis, Head of BD/Partnerships if you're looking for commercial angle.
For LPs: IR / Head of Investments / Manager Selection / the named partner on sustainability mandate. Family offices rarely publish these — sometimes the principal's name is the best you get.
For co-investor VCs: the named partner in the thesis area, not the generic "info@".
For corporations: the Head of Corporate Ventures / CVC Managing Director, Chief Innovation Officer, or Head of Open Innovation / Sustainability Partnerships. The CEO is almost always the wrong contact.

Check:
- Company "About"/"Team" page
- Their LinkedIn company page (employees tab, public view)
- Recent press releases (often quote named execs)
- Conference speaker lists in the thesis area
- Crunchbase / PitchBook public profiles if surfaced in search

Record: full name, title, LinkedIn URL (if found), and the source you found them on.

## Email guessing (pattern-based, flag as unverified)

You do not have a verified-email data provider connected. Everything here is a pattern guess. Mark each email in the output as `(pattern-guessed — verify before sending)`.

Common B2B patterns, ranked by prevalence (2024 data):

1. `firstname.lastname@domain` — most common, ~40% of firms
2. `firstname@domain` — common at startups and smaller funds, ~20%
3. `flastname@domain` (first initial + last name) — ~15%
4. `firstnamelastname@domain` — ~10%
5. `firstname_lastname@domain` — rare but present
6. `lastname@domain` — rare, mostly at old-school firms

If you see one real email on the company's contact page (e.g. `press@`, `hello@`, or a named person), infer the firm's pattern from that and use it. That's far more reliable than guessing blind.

In the output, provide:
- The **most likely** email (your best pattern guess)
- The **generic catch-all** if one exists (`info@`, `contact@`, `partners@`) — useful as a fallback
- A clear note that the primary email is pattern-guessed

Never invent or assert an email is verified.

## Quality filters before returning

Before adding a target to the shortlist, check:

- **On-thesis?** Does their actual work match the user's stated sector? Re-read the about page if unsure.
- **Geography match?** HQ or primary operations in the requested region?
- **Stage match?** For startups, the stated stage matches the user's ask (seed vs Series A is not interchangeable). For LPs, the check size is plausibly in range.
- **Active?** Last news/activity within the past 18 months. A fund that's done nothing for 3 years is probably in wind-down.
- **Not already in their portfolio/relationship?** You don't have access to their CRM, but if the target is an obvious Icos portfolio co (search "Icos Capital portfolio" to sanity-check), flag or exclude. The Pipedrive cross-check (Step 5 in SKILL.md) is the real dedup mechanism — this is just a basic filter.

## Suggested approach — what good looks like

A useful "suggested approach" is specific, not generic. Compare:

Bad: *"Reach out about their sustainability focus."*
Good: *"Warm intro via [shared portfolio co] if possible; otherwise email Sarah directly referencing their March announcement on the green steel pilot — the Series A rumor in Sifted suggests they're opening a round soon. Lead with the Icos portfolio cos in adjacent verticals, not with fund generalities."*

Every suggested approach should name the hook (specific news or connection), a who (specific person), and a what-not-to-do (avoid a common mis-step for that target type).

## Time and scope discipline

For a 20-target shortlist, spend roughly:
- 20% of effort on broad discovery (casting the net)
- 60% on enrichment of the candidates that survive the first filter
- 20% on scoring, ranking, and writing up the approach

If discovery is turning up only thin results, widen the geography or sector one step rather than grinding the same queries. If enrichment is hitting dead ends (no public website, no team page), drop that candidate — don't fabricate.
