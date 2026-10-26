---
name: humanizer
description: "Strips AI-written language patterns from any text and rewrites it so it sounds like a real person wrote it. Run it as the last writing step before anything is published. Catches the banned words, the stock phrases and the structural tells."
---
# SKILL: HUMANIZER

When this skill is triggered, scan the provided text for AI language patterns and rewrite it so it sounds like a real person wrote it.

## What you're looking for

**Banned words: replace every instance.**
unlock, leverage, delve, tapestry, realm, pivotal, game-changing, landscape, seamlessly, robust, holistic, transformative, groundbreaking, cutting-edge, state-of-the-art, innovative, paradigm, synergy, ecosystem, empower, foster, nurture, cultivate, harness, spearhead

(If a word on this list is one you genuinely use on purpose, delete it from your copy of this file. The list serves your voice, not the other way round.)

**Banned phrases: rewrite the sentence.**
- "In today's world / in today's fast-paced world..."
- "It's important to note that..."
- "It's worth mentioning that..."
- "Not only that, but..."
- "This is a testament to..."
- "The fact of the matter is..."
- "At the end of the day..."
- "The [thing] landscape"
- "In the realm of..."
- "A beacon of..."
- "A tapestry of..."

**Structural tells: fix these.**
- Sentences that open with "By [gerund]..." ("By using this..."). Rewrite to lead with the point.
- Paragraphs that always end with a summary sentence restating what was just said.
- Lists of three in a too-clean "X, Y, and Z" parallel pattern.
- Passive voice stacked on passive voice.
- "Furthermore", "Moreover", "Additionally" in sequence.
- Em dashes used as all-purpose glue. Use a full stop or a comma.
- "I hope this [helped / clarified / provided insight]". Delete it.

## How to run

1. Scan the text. Find every flagged word, phrase or structural pattern.
2. Rewrite it so the meaning stays exactly the same, in language that sounds like a specific person said it: direct, unpolished where it should be, no performance.
3. Do not add new content. Do not improve the ideas. Only fix the language.
4. If the text is short (under 200 words), show before and after. If it is longer, deliver the rewritten version directly.

## Quality test

After rewriting, ask: "Would someone who knows this person read this and say 'yep, that sounds like them'?" If the answer is no (too polished, too even, too clean), go again.

## Where it sits

Humanizer is step three of the pre-publish ritual in this kit:

```
interview-me  >  draft  >  humanizer  >  fact-checker  >  claims-verify  >  publish
```

The earlier steps decide what to say. Humanizer makes sure it sounds like a person said it. The checks after it make sure every fact is true.
