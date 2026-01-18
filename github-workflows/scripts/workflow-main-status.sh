#!/usr/bin/env bash
# Show workflow status for the default branch (main/master)
# Usage: workflow-main-status.sh [branch] [workflow-name]
# If no branch specified, auto-detects repo's default branch

WORKFLOW="${2:-}"

# Determine the branch to use
if [ -n "$1" ]; then
  # User explicitly specified a branch
  BRANCH="$1"
else
  # Auto-detect default branch
  DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null)

  if [ -n "$DEFAULT_BRANCH" ]; then
    BRANCH="$DEFAULT_BRANCH"
  else
    # Fallback: try common default branches
    if git rev-parse --verify main >/dev/null 2>&1; then
      BRANCH="main"
    elif git rev-parse --verify master >/dev/null 2>&1; then
      BRANCH="master"
    else
      echo "⚠️  Could not detect default branch. Trying 'main'..."
      BRANCH="main"
    fi
  fi
fi

if [ -n "$WORKFLOW" ]; then
  gh run list --branch="$BRANCH" --workflow="$WORKFLOW" --limit 10
else
  gh run list --branch="$BRANCH" --limit 10
fi
