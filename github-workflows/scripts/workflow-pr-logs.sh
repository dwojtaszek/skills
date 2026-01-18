#!/usr/bin/env bash
# Show logs for the latest workflow run of a PR
# Usage: workflow-pr-logs.sh <pr-number> [job-name]

PR_NUMBER="${1:?Usage: workflow-pr-logs.sh <pr-number> [job-name]}"
JOB_NAME="${2:-}"

# Get the PR's branch name
BRANCH=$(gh pr view "$PR_NUMBER" --json headRefName --jq '.headRefName')

# Get the latest run ID for this PR
RUN_ID=$(gh run list --branch="$BRANCH" --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
  echo "No workflow runs found for PR #$PR_NUMBER"
  exit 1
fi

if [ -n "$JOB_NAME" ]; then
  gh run view "$RUN_ID" --log --job="$JOB_NAME"
else
  gh run view "$RUN_ID" --log
fi
