#!/usr/bin/env bash
# Merge a PR (squash merge by default)
# Usage: pr-merge.sh <pr-number> [--rebase|--merge]

PR_NUMBER="${1:?Usage: pr-merge.sh <pr-number> [--rebase|--merge]}"
MERGE_TYPE="${2:---squash}"

echo "Merging PR #$PR_NUMBER with $MERGE_TYPE..."
gh pr merge "$PR_NUMBER" "$MERGE_TYPE" --delete-branch

if [ $? -eq 0 ]; then
  echo "✅ PR #$PR_NUMBER merged successfully"
else
  echo "❌ Failed to merge PR #$PR_NUMBER"
  exit 1
fi
