---
name: prompt-master
description: "Takes a messy, vague or underperforming prompt and rebuilds it with the six-lever framework (who, where, what, shape, avoid, bar). Works for any AI tool: Claude, ChatGPT, Gemini, Perplexity, Midjourney, Cursor and more. Use when a prompt keeps giving you average output."
---
# SKILL: PROMPT MASTER

When this skill is triggered, take the user's prompt and rebuild it with the six-lever framework. The goal: a prompt that leaves nothing for the AI to guess.

## The six levers

Every strong prompt pulls all six. Weak prompts pull one or two and let the model fill in the rest with average guesses.

**1. WHO: the role**
Tell the AI who it is. Not "a helpful assistant". Something specific: "You are a senior direct-response copywriter who hates passive voice" or "You are a short-form video strategist who has studied thousands of Reels." The role sets the depth and tone of everything after it.

**2. WHERE: the context**
Paint the world the AI is working in. The business, the audience, what has been tried, what is at stake. Without context the AI makes assumptions. With context it makes decisions.

**3. WHAT: the real task**
Not a vague intent. A specific finish line. Not "help me with my LinkedIn post". Something like: "Rewrite this post so it reads like a founder sharing a hard-won lesson, not a consultant pitching." The difference is whether the AI knows where it is meant to land.

**4. SHAPE: the output format**
What does the result look like when it lands? A three-column table? A 300-word block? Five bullet points? One post? If you don't say, the model guesses, and the guess rarely matches.

**5. AVOID: the guardrails**
The explicit list of what NOT to do. "No em dashes. No phrases like 'in today's world'. Never use the words unlock or delve." Negative rules cut off the most common ways AI writing drifts into generic.

**6. BAR: the quality standard**
Define done. "Good enough to post without a rewrite." "Specific enough that I can make a pricing decision in five minutes." "Would my best client read this and feel understood?" One line. It sharpens everything above it.

## How to run

**Step 1: diagnose the original.**
Say which levers the original prompt pulled and which are missing or weak.

**Step 2: ask for what is missing.**
If WHO, WHERE or BAR are completely absent, ask the user to fill them in before rebuilding. You may suggest defaults from context, but confirm before you proceed.

**Step 3: rebuild the prompt.**
Rewrite it with all six levers. Use XML tags to separate the sections. Claude (and most AI tools) reads tagged sections like labelled containers, not a wall of text:

```
<role>
[WHO: specific, narrow role]
</role>

<context>
[WHERE: business, audience, what has been tried]
</context>

<task>
[WHAT: the specific finish line]
</task>

<output_format>
[SHAPE: exact format of the deliverable]
</output_format>

<constraints>
[AVOID: explicit do-nots]
</constraints>

<quality_bar>
[BAR: one sentence defining done]
</quality_bar>

[Any inputs: paste the content or data to work with BELOW the instructions]
```

**Step 4: deliver with a short explanation.**
Show the rebuilt prompt. Say which levers you added and why. If the user can give a better WHO or WHERE, say so: those two levers move quality the most.

## Run it on yourself

Add this to your CLAUDE.md so it checks your long prompts automatically:

```
Before any long-form task (content, strategy, analysis), check the prompt against the six levers.
If fewer than four are present, ask for the missing context before starting.
```

## Works everywhere

The six-lever structure works in Claude, ChatGPT, Gemini, Perplexity, Grok, Cursor, Notion AI and image and video tools. The syntax varies (XML tags are Claude's native format) but the structure carries over.
