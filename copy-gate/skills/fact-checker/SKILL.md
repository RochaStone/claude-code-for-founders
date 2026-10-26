---
name: fact-checker
description: "Verifies the factual claims in any text, response or document and rates each one on a clear scale. Use before publishing, sharing or acting on anything that contains statistics, quotes, attributed research, dates or capability claims."
---
# SKILL: FACT CHECKER

When this skill is triggered, find and verify every factual claim in the provided text, methodically.

## What counts as a factual claim

- Statistics and percentages ("87% of founders...")
- Dates and timelines ("founded in 2019")
- Attributed quotes ("According to Harvard...")
- Named research or studies ("A Stanford study found...")
- Causal claims ("X causes Y")
- Comparative claims ("the largest / fastest / most...")
- Stated capabilities ("this tool can read 200 pages at once")

Opinions, analogies and subjective statements do not need fact-checking.

## Rating scale

Give each claim one rating:

| Rating | Meaning |
|--------|---------|
| ✅ TRUE | Verified accurate from a reliable source |
| 🟡 MOSTLY TRUE | Broadly accurate but imprecise or missing context |
| ⚠️ MIXED | Contains accurate and inaccurate parts |
| 🔴 MOSTLY FALSE | Misleading or significantly inaccurate |
| ❌ FALSE | Demonstrably wrong |
| 🔍 UNVERIFIABLE | Cannot be confirmed or denied from available sources |

## Output format

For each claim:

```
CLAIM: [the exact claim, quoted]
RATING: [rating with emoji]
VERDICT: [one or two sentences: what is accurate, what is off, or why it can't be verified]
SOURCE: [where this comes from, or "No reliable source found"]
```

After all claims:

```
━━━━━━━━━━━━━━━━━━━━
SUMMARY
━━━━━━━━━━━━━━━━━━━━
Claims checked: X
True / Mostly true: X
Mixed / Unverifiable: X
False / Mostly false: X

RECOMMENDATION: [Use as is / Remove X claims / Flag before publishing / Do not publish]
```

## Rules

- Check claims in the order they appear.
- If a claim is unverifiable, say so plainly. Never guess.
- Do not "fix" inaccurate claims. Only identify them.
- Flag anything that looks like a fabricated or hallucinated source immediately.
- If you cannot verify a specific statistic, rate it UNVERIFIABLE and say what you would need to confirm it.

## Trigger phrases

- "Fact check this"
- "Verify these claims"
- "Is this true?"
- "Check this before I send it"
- "I want to make sure this is accurate"
