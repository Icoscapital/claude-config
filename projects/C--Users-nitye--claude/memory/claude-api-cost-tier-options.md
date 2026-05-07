---
name: Surface cheaper Claude API tiers proactively
description: When a Claude API workload could run on a cheaper tier (Batches API or a smaller model), surface it to the user before defaulting to Opus + synchronous calls.
type: feedback
originSessionId: 903632eb-1fe1-48d2-a3dd-89bfd63c4092
---
When the user describes a Claude API workload, evaluate whether a cheaper tier fits and surface it before writing code. Two specific cases:

- **Batches API (50% off, up to 24h latency):** if the workload is non-latency-sensitive — overnight processing, large evals, backlog classification, bulk extraction — **ask the user** whether a few-hour wait is acceptable. Don't assume.
- **Smaller models (Haiku 4.5, Sonnet 4.6):** if the task likely doesn't need Opus — simple classification, tagging, structured extraction, short summaries, single-purpose lookups — **tell the user** which model would fit and the cost delta. Don't silently downgrade; confirm before changing model strings.

**Why:** User explicitly asked to (1) ask before committing them to higher latency in exchange for lower rates, and (2) flag when Opus is overkill so they can decide. Cost vs. quality vs. latency is a user choice, not mine to make unilaterally.

**How to apply:** Trigger the check whenever the user describes an API workload — bulk processing → propose Batches; "classify these N items" → propose Haiku; "extract X from each PDF" → propose Sonnet or Haiku depending on the structure complexity. Frame batches as a question (latency tradeoff) and model tier as a recommendation with rationale (intelligence tradeoff). Pricing reference per 1M tokens (input/output): Opus 4.7 $5/$25, Sonnet 4.6 $3/$15, Haiku 4.5 $1/$5; Batches API halves all of these and stacks with prompt caching.
