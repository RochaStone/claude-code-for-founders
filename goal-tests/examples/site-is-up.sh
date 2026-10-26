#!/usr/bin/env bash
# GOAL: my website's home page answers with a 2xx status in under 20 seconds.
# BUILD: ~/Projects/my-website
# Read-only: one GET request. Edit URL, then copy this file into your goals folder.
set -u
URL="https://example.com/"

code=$(curl -sS -L -o /dev/null --max-time 20 -w '%{http_code}' "$URL" 2>&1) || { echo "FAIL: could not reach $URL ($code)"; exit 1; }
case "$code" in
  2*) echo "OK $code" ;;
  *)  echo "FAIL: $URL answered $code"; exit 1 ;;
esac
