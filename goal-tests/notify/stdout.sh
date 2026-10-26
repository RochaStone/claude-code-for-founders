#!/usr/bin/env bash
# stdout.sh SUBJECT BODY_FILE: prints the notice. Under launchd or cron it lands in the job's log file.
echo "==================== GOAL TESTS NOTICE ===================="
echo "$1"
echo
cat "$2"
echo "==========================================================="
