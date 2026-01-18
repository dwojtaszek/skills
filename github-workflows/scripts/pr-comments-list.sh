#!/usr/bin/env bash
# List all comments on a PR (both review comments and issue comments)
# Usage: pr-comments-list.sh <pr-number>

PR_NUMBER="${1:?Usage: pr-comments-list.sh <pr-number>}"

echo "=== Review Comments (inline on code) ==="
review_comments=$(gh api "repos/{owner}/{repo}/pulls/$PR_NUMBER/comments" \
  --jq '.[] | "\(.id) | review | \(.created_at) | \(.user.login) | \(.path):\(.line // "N/A") | \(.body[:80])"' 2>/dev/null)

if [ -z "$review_comments" ]; then
  echo "(none)"
else
  echo "$review_comments"
fi

echo ""
echo "=== Issue Comments (general PR discussion) ==="
issue_comments=$(gh api "repos/{owner}/{repo}/issues/$PR_NUMBER/comments" \
  --jq '.[] | "\(.id) | issue | \(.created_at) | \(.user.login) | \(.body[:80])"' 2>/dev/null)

if [ -z "$issue_comments" ]; then
  echo "(none)"
else
  echo "$issue_comments"
fi
