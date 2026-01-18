#!/usr/bin/env bash
# Re-run a failed or all workflows for a PR
# Usage: workflow-rerun.sh <pr-number> [--failed]

PR_NUMBER="${1:?Usage: workflow-rerun.sh <pr-number> [--failed]}"
RERUN_TYPE="${2:---failed}"

# Get the latest run ID for this PR
RUN_ID=$(gh run list --branch "$(gh pr view $PR_NUMBER --json headRefName --jq '.headRefName')" --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
  echo "❌ No workflow runs found for PR #$PR_NUMBER"
  exit 1
fi

echo "Re-running workflow $RUN_ID for PR #$PR_NUMBER ($RERUN_TYPE)..."

if [ "$RERUN_TYPE" = "--failed" ]; then
  gh run rerun "$RUN_ID" --failed
else
  gh run rerun "$RUN_ID"
fi

if [ $? -eq 0 ]; then
  echo "✅ Workflow re-run triggered"
  gh run watch "$RUN_ID"
else
  echo "❌ Failed to re-run workflow"
  exit 1
fi
