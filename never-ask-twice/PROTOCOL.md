# The never-ask-twice protocol

This is the deal between you and Claude.
Paste the snippet in `CLAUDE.md.snippet` into your `~/.claude/CLAUDE.md` and Claude works this way in every session.

## Why it exists
Claude suggests something. You miss it. It is never mentioned again.
Or the opposite: the same question, four times in one afternoon.
Both cost you. One loses the work, the other loses your attention.

## The one list
Everything unresolved lives in one file, `OPEN_ITEMS.md`.
Not in chat scrollback. Not in your head.
One line per item. Open items at the top, parked and done below.

## The six rules

1. **Every item carries a default.**
   When Claude adds an item, it writes what will happen if you say nothing.
   Silence moves things forward. Silence used to freeze them.

2. **Unanswered means "take the default".**
   If Claude asks and you never answer, it does not ask again.
   Next session it takes the default, does it, and tells you in one line:
   `Took the default on #4: used the candy pink header.`
   Missing a question costs you nothing.

3. **Some items are genuinely yours.**
   Money, your voice, your positioning, anything that cannot be undone.
   Those are marked ME. Claude raises each one at most once per session, in one line, and never chases.
   Everything else is marked CLAUDE: decided, done and reported.

4. **Three flags, maximum, per reply.**
   Ranked by consequence: money and anything client-facing first.
   Everything else waits in the file, quietly.

5. **Items leave only two ways: DONE or PARKED.**
   Never by being forgotten.
   DONE moves to the Done table with a date.

6. **"Leave it" parks it.**
   Say "leave it" (or "park it") and the item moves to Parked.
   It stops surfacing completely until you reopen it.

## At the start of every session
The session-start hook prints the open items in one compact block, so Claude sees them before it sees your first message.
Claude then does every CLAUDE-owned default that is now unblocked and reports them in one short block.

## At the end of every session
Claude updates `OPEN_ITEMS.md`: new items in with a default, closed items moved to Done with the date.

## The measure
You can read one page and know everything outstanding.
You never need to remember something for it to happen.
