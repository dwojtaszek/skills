#!/usr/bin/env bash
# Show workflow status and logs for a PR
# Usage: workflow-pr-status.sh <pr-number> [workflow-name]

PR_NUMBER="${1:?Usage: workflow-pr-status.sh <pr-number> [workflow-name]}"
WORKFLOW="${2:-}"

# Get the PR's branch name
BRANCH=$(gh pr view "$PR_NUMBER" --json headRefName --jq '.headRefName')

if [ -n "$WORKFLOW" ]; then
  gh run list --branch="$BRANCH" --workflow="$WORKFLOW" --limit 10
else
  gh run list --branch="$BRANCH" --limit 10
fi
