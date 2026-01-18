#!/usr/bin/env bash
# Update an existing comment on a PR
# Usage: pr-comment-update.sh <comment-id> <type> "New body text"
# type: "review" or "issue"

COMMENT_ID="${1:?Usage: pr-comment-update.sh <comment-id> <review|issue> \"new body\"}"
COMMENT_TYPE="${2:?Usage: pr-comment-update.sh <comment-id> <review|issue> \"new body\"}"
NEW_BODY="${3:?Usage: pr-comment-update.sh <comment-id> <review|issue> \"new body\"}"

if [ "$COMMENT_TYPE" = "issue" ]; then
  gh api "repos/{owner}/{repo}/issues/comments/$COMMENT_ID" \
    -X PATCH \
    -f body="$NEW_BODY" \
    --jq '{id, updated: true}'
else
  gh api "repos/{owner}/{repo}/pulls/comments/$COMMENT_ID" \
    -X PATCH \
    -f body="$NEW_BODY" \
    --jq '{id, updated: true}'
fi

echo "Comment $COMMENT_ID updated"
