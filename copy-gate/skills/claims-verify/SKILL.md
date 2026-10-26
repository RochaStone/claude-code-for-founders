---
name: claims-verify
description: "Adversarial claims check for anything public: sales pages, emails, captions, carousels, PDFs, DMs. Sends a fresh-context subagent to try to REFUTE every factual claim in the draft against your canon file (prices, what is live, counts, names, your story). Runs after the humanizer and fact-checker, before anything ships. Triggers: claims-verify, verify the claims, check this copy against my facts."
---
# SKILL: CLAIMS VERIFY

The fact-checker asks "is this true in the world?"
Claims-verify asks "is this true about MY business, right now, and am I allowed to say it?"
Both pass before anything goes public.

## Your canon

Claims are checked against one short file of facts that are true about your business today.
Default location: `~/.claude/canon.md`. Start from `canon.example.md` in this folder.
It holds your current prices, what is live and what is not, your counts, the names you may use publicly, your real story, and the claims you never make.
If a fact is not in the canon, the verifier treats it as unproven. That is the point.

## Why a fresh subagent (non-negotiable)

The session that wrote the draft is contaminated. Old prices, test personas and working assumptions all feel true from inside it. That is how an invented bio ends up on a live page.
So verification runs in a subagent with NO inherited context: the Agent tool, `general-purpose` type, never a fork.
The drafting session may not pre-clear claims on the subagent's behalf.

## How to run it

### Step 1: freeze the draft
Save the exact text under review to a file, so the subagent checks the real thing, not a summary of it.

### Step 2: send the verifier
Spawn ONE fresh `general-purpose` subagent. Its prompt contains only:
(a) the draft file path, (b) the canon file path (and any other fact files the canon points to), (c) the refutation brief below, word for word.
Do not include the drafting session's reasoning, personas or earlier versions of the copy.

**Refutation brief:**
```
You are an adversarial fact-checker. Your job is to REFUTE this draft, not to approve it.
For EVERY checkable claim (every price, date, availability statement such as "live",
"launched", "included" or "open", every count, named person, client story, biographical
detail, product name and capability claim) find the canonical source and test the claim
against it.

Rules:
1. Default to suspicion. A claim you cannot ground in a canon file is UNVERIFIED, never a pass.
2. Sweep these categories explicitly:
   - PRICES: exact match to the canon, date-aware (check any scheduled change). A price the
     canon lists as retired, or a "locked for life" promise the canon does not grant = REFUTED.
   - NAMING: product and offer names must match the canon exactly, including any public
     name rules it lists.
   - AVAILABILITY: anything called live, launched or available that the canon says is not
     (or the reverse) = REFUTED.
   - COUNTS: every number of things (modules, clients, templates, years) must match the canon.
   - OVER-CLAIMS: anything the canon lists under "claims I never make" = REFUTED.
   - PEOPLE AND STORIES: every named person, client result or biographical detail must be
     the owner's real story, a real client named in the canon with permission, or a clearly
     hypothetical "imagine you..." example. Specific details that belong to no verifiable
     real person = REFUTED. Invented testimonials are never allowed.
3. Output one line per finding:
   REFUTED | <the exact quoted claim> | <canon source> | <what is true>
   UNVERIFIED | <the exact quoted claim> | <what evidence would clear it>
   Then a final line: VERDICT: CLEAR (0 refuted, 0 unverified) or BLOCKED.
4. If the draft contains nothing checkable, say so. Never invent findings.
```

### Step 3: act on the verdict
- **BLOCKED:** fix every REFUTED item in the draft. Ground every UNVERIFIED item (add the evidence to the canon or the draft) or cut it. Then freeze again and send a NEW fresh subagent. An old verdict never carries over to edited copy.
- **CLEAR:** move on to your own approval. A clear verdict is necessary, not sufficient. You still decide what ships.

## Where it sits

```
interview-me  >  draft  >  humanizer  >  fact-checker  >  claims-verify  >  publish
```

Per draft. Cheap. No skipping it on "small" posts: the worst leaks are one paragraph long.
