#!/usr/bin/env bash
# GOAL: the endpoint behind my contact form is still there (answers, and is not a 404 or a 5xx).
# BUILD: ~/Projects/my-website
# Read-only on purpose. This probe NEVER submits the form, because a test that sends a real
# message every morning is not a test, it is spam. It asks with HEAD, which reads nothing and
# writes nothing. Many form endpoints answer 405 (method not allowed) to HEAD. That still proves
# the endpoint exists, so 405 counts as alive.
set -u
URL="https://example.com/api/contact"

code=$(curl -sS -I -o /dev/null --max-time 20 -w '%{http_code}' "$URL" 2>&1) || { echo "FAIL: could not reach $URL ($code)"; exit 1; }
case "$code" in
  404|410) echo "FAIL: $URL is gone ($code)"; exit 1 ;;
  5*)      echo "FAIL: $URL is erroring ($code)"; exit 1 ;;
  000)     echo "FAIL: no answer from $URL"; exit 1 ;;
  *)       echo "OK $code" ;;
esac
