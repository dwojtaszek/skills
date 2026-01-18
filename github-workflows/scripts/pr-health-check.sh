#!/usr/bin/env bash
# Comprehensive PR health check - gives a clear READY/BLOCKED verdict
# Usage: pr-health-check.sh <pr-number>

PR_NUMBER="${1:?Usage: pr-health-check.sh <pr-number>}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "           PR #$PR_NUMBER HEALTH CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get basic PR info
PR_JSON=$(gh pr view "$PR_NUMBER" --json title,state,mergeable,isDraft,reviewDecision 2>/dev/null)

if [ -z "$PR_JSON" ]; then
  echo -e "${RED}❌ ERROR: PR #$PR_NUMBER not found${NC}"
  echo "   Check the PR number and try again."
  exit 1
fi

TITLE=$(echo "$PR_JSON" | jq -r '.title')
STATE=$(echo "$PR_JSON" | jq -r '.state')
MERGEABLE=$(echo "$PR_JSON" | jq -r '.mergeable')
IS_DRAFT=$(echo "$PR_JSON" | jq -r '.isDraft')
REVIEW_DECISION=$(echo "$PR_JSON" | jq -r '.reviewDecision // "REVIEW_REQUIRED"')

echo -e "${BLUE}📋 $TITLE${NC}"
echo ""

# Track issues
declare -a ISSUES=()

# Check 1: Draft status
if [ "$IS_DRAFT" = "true" ]; then
  echo -e "${YELLOW}⚠️  DRAFT PR${NC} - Mark as ready for review when complete"
  ISSUES+=("draft")
fi

# Check 2: Mergeability
case "$MERGEABLE" in
  "MERGEABLE")
    echo -e "${GREEN}✅ Mergeable${NC} - No merge conflicts"
    ;;
  "CONFLICTING")
    echo -e "${RED}❌ CONFLICTING${NC} - Has merge conflicts that must be resolved"
    ISSUES+=("conflicts")
    ;;
  "UNKNOWN")
    echo -e "${YELLOW}⏳ Mergeability unknown${NC} - GitHub is still checking..."
    ;;
esac

# Check 3: Review status
echo -n "Reviews: "
case "$REVIEW_DECISION" in
  "APPROVED")
    echo -e "${GREEN}✅ Approved${NC}"
    ;;
  "CHANGES_REQUESTED")
    echo -e "${RED}❌ Changes requested${NC} - Address reviewer feedback"
    ISSUES+=("changes_requested")
    ;;
  "REVIEW_REQUIRED")
    echo -e "${YELLOW}⏳ Review required${NC} - Awaiting reviewer approval"
    ;;
  *)
    echo -e "${BLUE}ℹ️  $REVIEW_DECISION${NC}"
    ;;
esac

# Check 4: CI Status
echo ""
echo "CI Checks:"
CI_OUTPUT=$(gh pr checks "$PR_NUMBER" 2>/dev/null)

if echo "$CI_OUTPUT" | grep -q "fail"; then
  echo -e "${RED}❌ CI FAILING${NC} - Some checks have failed"
  echo ""
  echo "Failed checks:"
  echo "$CI_OUTPUT" | grep "fail" | head -5
  ISSUES+=("ci_failed")
elif echo "$CI_OUTPUT" | grep -q "pending"; then
  echo -e "${YELLOW}⏳ CI PENDING${NC} - Some checks are still running"
  ISSUES+=("ci_pending")
else
  echo -e "${GREEN}✅ All checks passing${NC}"
fi

# Final verdict
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ${#ISSUES[@]} -eq 0 ]; then
  echo -e "${GREEN}           ✅ READY TO MERGE ✅${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Next step: Merge the PR with 'gh pr merge $PR_NUMBER'"
else
  echo -e "${RED}           ❌ BLOCKED - Action Required ❌${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Issues to resolve:"
  for issue in "${ISSUES[@]}"; do
    case "$issue" in
      "draft") echo "  • Convert from draft to ready for review" ;;
      "conflicts") echo "  • Resolve merge conflicts" ;;
      "changes_requested") echo "  • Address reviewer feedback" ;;
      "ci_failed") echo "  • Fix failing CI tests (run: workflow-pr-logs.sh $PR_NUMBER)" ;;
      "ci_pending") echo "  • Wait for CI checks to complete" ;;
    esac
  done
fi
echo ""
