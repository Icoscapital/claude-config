---
name: Claude API token optimization defaults
description: When writing or modifying Claude API integration code, default to including prompt caching and other token-saving patterns; verify cache hits explicitly.
type: feedback
originSessionId: 903632eb-1fe1-48d2-a3dd-89bfd63c4092
---
When writing or modifying Claude API code, default to including prompt caching at minimum (top-level `cache_control: {type: "ephemeral"}` is the simplest form) and proactively apply other token optimizations the situation supports.

**Why:** User explicitly asked to optimize tokens whenever possible across all current and future projects. Prompt caching is nearly always a win — small write premium (~1.25×), large read savings (~10× cheaper) — and silent invalidators (datetimes in system prompts, unsorted JSON serialization, varying tool order) are easy to introduce by accident.

**How to apply:** When writing API code: (1) place `cache_control` on the longest stable prefix — render order is `tools` → `system` → `messages`; (2) verify after rollout via `usage.cache_read_input_tokens` and flag if it stays at 0 across repeated identical-prefix requests; (3) audit any code feeding the prefix for silent invalidators (`datetime.now()`, `uuid4()`, `json.dumps` without `sort_keys`, conditional system sections, per-user IDs in system prompt, varying tool sets); (4) for fan-out / parallel workloads, send 1 request first then fire the rest after the first response begins streaming so they read the cache. See `shared/prompt-caching.md` in the claude-api skill for the full audit table and architectural guidance.
