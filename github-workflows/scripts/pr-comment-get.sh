#!/usr/bin/env bash
# Get a specific comment on a PR
# Usage: pr-comment-get.sh <pr-number> <comment-id> [type]
# type: "review" (default) or "issue"

PR_NUMBER="${1:?Usage: pr-comment-get.sh <pr-number> <comment-id> [review|issue]}"
COMMENT_ID="${2:?Usage: pr-comment-get.sh <pr-number> <comment-id> [review|issue]}"
COMMENT_TYPE="${3:-review}"

if [ "$COMMENT_TYPE" = "issue" ]; then
  gh api "repos/{owner}/{repo}/issues/comments/$COMMENT_ID" \
    --jq '{id, type: "issue", body, created_at, user: .user.login}'
else
  gh api "repos/{owner}/{repo}/pulls/comments/$COMMENT_ID" \
    --jq '{id, type: "review", body, path, line, created_at, user: .user.login}'
fi
