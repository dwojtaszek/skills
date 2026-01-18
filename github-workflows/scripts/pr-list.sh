#!/usr/bin/env bash
# List open PRs in the repository
# Usage: pr-list.sh [--author <username>] [--label <label>]

ARGS=""

# Parse optional arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --author)
      ARGS="$ARGS --author $2"
      shift 2
      ;;
    --label)
      ARGS="$ARGS --label $2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

echo "=== Open Pull Requests ==="
gh pr list --state open $ARGS --json number,title,author,createdAt,headRefName \
  --jq '.[] | "#\(.number) | \(.author.login) | \(.headRefName) | \(.title[:50])"'
