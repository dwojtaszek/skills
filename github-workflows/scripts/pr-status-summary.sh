#!/usr/bin/env bash
# Get comprehensive PR status summary for LLM understanding
# Usage: pr-status-summary.sh <pr-number>

PR_NUMBER="${1:?Usage: pr-status-summary.sh <pr-number>}"

echo "=== PR #$PR_NUMBER Status Summary ==="
echo ""

# Basic PR info
echo "## PR Info"
gh pr view "$PR_NUMBER" --json title,state,headRefName,baseRefName,mergeable --jq '"Title: \(.title)\nState: \(.state)\nBranch: \(.headRefName) → \(.baseRefName)\nMergeable: \(.mergeable)"'
echo ""

# CI Check status
echo "## CI Checks"
gh pr checks "$PR_NUMBER"
echo ""

# Overall workflow runs
echo "## Recent Workflow Runs"
gh run list --branch="$(gh pr view "$PR_NUMBER" --json headRefName --jq '.headRefName')" --limit 5
