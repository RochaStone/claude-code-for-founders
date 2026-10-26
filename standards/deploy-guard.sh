#!/usr/bin/env bash
# deploy-guard.sh: Claude Code PreToolUse hook for Bash. A reminder, never a block.
# When Claude is about to run a deploy, publish or push command, this adds a short checklist to
# Claude's context just before the command runs. Every other command passes with no output.
input=$(cat)
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)
else
  cmd=$(printf '%s' "$input" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("tool_input",{}).get("command",""))
except Exception: print("")' 2>/dev/null)
fi
[ -z "$cmd" ] && exit 0

PATTERN='git push|vercel( .*)?--prod|vercel deploy|netlify deploy|firebase deploy|fly deploy|wrangler (deploy|publish)|npm publish|pnpm publish|yarn publish|gh release create|docker push|supabase db push|terraform apply|kubectl apply|heroku .*release|railway up'
printf '%s' "$cmd" | grep -qE "$PATTERN" || exit 0

msg="DEPLOY GUARD (a reminder, not a block). Before this runs: (1) Has the human said yes to this deploy or push in THIS session? If not, stop and ask. (2) Run ./scripts/security-check.sh if the repo has one. It must pass. (3) Name the destination out loud: which remote, branch, project or URL this lands on. (4) Afterwards, prove it worked with the real end state: load the live URL and look for the change, or compare the local and remote commit. An exit code is not proof."
if command -v jq >/dev/null 2>&1; then
  jq -n --arg m "$msg" '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $m}}'
else
  python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": sys.argv[1]}}))' "$msg"
fi
exit 0
