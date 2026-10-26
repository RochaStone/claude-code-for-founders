#!/usr/bin/env bash
# webhook.sh SUBJECT BODY_FILE CONFIG: POSTs the notice as JSON to a webhook URL.
# The body carries "text" (Slack style) and "content" (Discord style), plus subject and body,
# so most chat tools and automation tools (Zapier, Make, n8n) accept it as is.
# URL: env GOAL_TESTS_WEBHOOK_URL wins, else notify.webhook_url in the config.
# A webhook URL is a password. Prefer the env var, set in your owner-only secrets.env.
set -u
CONFIG="${3:-}"
url="${GOAL_TESTS_WEBHOOK_URL:-}"
if [ -z "$url" ] && [ -f "$CONFIG" ]; then
  url=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("notify",{}).get("webhook_url",""))' "$CONFIG" 2>/dev/null)
fi
[ -z "$url" ] && { echo "webhook: no URL set (GOAL_TESTS_WEBHOOK_URL or notify.webhook_url)" >&2; exit 1; }
case "$url" in https://*) ;; *) echo "webhook: refusing a non https URL" >&2; exit 1 ;; esac
payload=$(python3 -c '
import json, sys
subject = sys.argv[1]
body = open(sys.argv[2], encoding="utf-8").read()
text = subject + "\n\n" + body
print(json.dumps({"text": text, "content": text[:1900], "subject": subject, "body": body}))
' "$1" "$2") || exit 1
code=$(printf '%s' "$payload" | curl -sS --max-time 20 -o /dev/null -w '%{http_code}' \
  -H 'Content-Type: application/json' -X POST --data-binary @- "$url")
case "$code" in 2*) exit 0 ;; *) echo "webhook: HTTP $code" >&2; exit 1 ;; esac
