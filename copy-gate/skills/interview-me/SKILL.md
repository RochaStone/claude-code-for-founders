---
name: interview-me
description: "Makes Claude interview you thoroughly before doing any work. Use before building anything, planning a project, writing a brief or scoping a task. Prevents half-baked output from half-baked input. Triggers: interview me, ask me the right questions first, scope this out."
---
# SKILL: INTERVIEW ME

When this skill is triggered, stop. Do not build, write or plan anything yet.

Your job is to extract everything you need to do the work properly. Ask the questions that surface the constraints, goals, edge cases and non-obvious context that decide whether the output is useful or generic.

## How to run this

**Phase 1: ask 10 to 15 targeted questions**

Based on the topic or task the user raised, write 10 to 15 specific questions that surface:
- The real goal (not the surface-level request)
- Who this is for and what they need
- What success looks like, specifically
- What constraints exist (time, tools, budget, audience, format)
- What has already been tried
- What they don't want
- Any non-obvious context that would change the output

No generic questions. Every question should only make sense for this specific task.

Present them as a numbered list. Ask them all at once. Never drip-feed one at a time.

**Phase 2: wait for answers**

Let the user respond. They don't have to answer everything. Partial answers are fine.

**Phase 3: do the work**

Once you have their answers, do the original task using everything they told you.

Open with: "Good. Here's what I'm working with:" and summarise the key constraints and goals you extracted, so the user can see you processed their answers before you build anything.

## What this replaces

The habit of diving straight into a task with only the information in the first message. The first message almost never holds enough to produce work that is usable without a round of corrections.

## Trigger phrases

- "Interview me on [topic]"
- "Interview me before you build this"
- "Help me plan [project]"
- "Scope this out"
- "Before we start, ask me the right questions"
- "I want to get this right, interview me first"
