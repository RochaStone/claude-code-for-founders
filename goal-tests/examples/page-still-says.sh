#!/usr/bin/env bash
# GOAL: my offer page still shows the words that matter (the button text and the price line).
# BUILD: ~/Projects/my-website
# Read-only: one GET request, then a text search. Edit URL and the phrases, then copy it in.
# Catches the quiet breaks: a redeploy that dropped a section, an old version served from a cache.
set -u
URL="https://example.com/"
MUST_SAY=(
  "Example Domain"
)

page=$(curl -sS -L --max-time 20 "$URL" 2>&1) || { echo "FAIL: could not load $URL"; exit 1; }
for phrase in "${MUST_SAY[@]}"; do
  printf '%s' "$page" | grep -qF -- "$phrase" || { echo "FAIL: page no longer says \"$phrase\""; exit 1; }
done
echo "OK: all ${#MUST_SAY[@]} phrase(s) present"
