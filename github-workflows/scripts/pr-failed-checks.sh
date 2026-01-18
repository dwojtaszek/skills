#!/usr/bin/env bash
# Show only failed/pending checks for a PR
# Usage: pr-failed-checks.sh <pr-number>

PR_NUMBER="${1:?Usage: pr-failed-checks.sh <pr-number>}"

echo "=== PR #$PR_NUMBER Failed/Pending Checks ==="
echo ""

# Get PR title and branch
TITLE=$(gh pr view "$PR_NUMBER" --json title --jq '.title')
echo "PR: $TITLE"
echo ""

# Get checks and filter for failed/pending
gh pr checks "$PR_NUMBER" | grep -E '(fail|pending|skipping)' || echo "✅ All checks passing"

