#!/usr/bin/env bash
# Reply to a PR (add a new comment)
# Usage: pr-comment-reply.sh <pr-number> "Your reply message"

PR_NUMBER="${1:?Usage: pr-comment-reply.sh <pr-number> \"message\"}"
MESSAGE="${2:?Usage: pr-comment-reply.sh <pr-number> \"message\"}"

gh pr comment "$PR_NUMBER" --body "$MESSAGE"
echo "Comment posted to PR #$PR_NUMBER"
