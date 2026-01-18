---
name: github-workflows
description: "GitHub workflow and PR management using gh CLI. Use for checking CI/CD status, merging PRs, re-running workflows, listing PRs, and managing comments. Triggered by: can I merge, merge the PR, is the build passing, check the tests, why is CI failing, re-run CI, rerun failed, list PRs, open PRs, check workflows, check the PR, health check, any comments, reply to comment."
---

# GitHub Workflows

## Overview

Streamlined GitHub workflow operations using the `gh` CLI. All scripts have both Linux/macOS (.sh) and Windows (.cmd) versions.

**Cross-platform:** Use `.sh` on Linux/macOS, `.cmd` on Windows.

## PR Status & Merging

### pr-health-check ⭐ **Detailed Analysis**
```bash
scripts/pr-health-check.sh <pr-number>    # Linux/macOS
scripts/pr-health-check.cmd <pr-number>   # Windows
```
Gives a clear "READY TO MERGE" or "BLOCKED" verdict. Checks drafts, conflicts, reviews, and CI.

### pr-status-summary
```bash
scripts/pr-status-summary.sh <pr-number>
scripts/pr-status-summary.cmd <pr-number>
```
Shows: title, state, branch, mergeability, all CI checks, recent runs.

### pr-merge
```bash
scripts/pr-merge.sh <pr-number> [--rebase|--merge]   # Default: --squash
scripts/pr-merge.cmd <pr-number>
```

### pr-list
```bash
scripts/pr-list.sh [--author <user>] [--label <label>]
scripts/pr-list.cmd [--author <user>] [--label <label>]
```

### pr-failed-checks
```bash
scripts/pr-failed-checks.sh <pr-number>
scripts/pr-failed-checks.cmd <pr-number>
```

## Workflow Management

### workflow-main-status
```bash
scripts/workflow-main-status.sh [branch] [workflow-name]
scripts/workflow-main-status.cmd [branch] [workflow-name]
```

### workflow-pr-status
```bash
scripts/workflow-pr-status.sh <pr-number> [workflow-name]
scripts/workflow-pr-status.cmd <pr-number> [workflow-name]
```

### workflow-pr-logs
```bash
scripts/workflow-pr-logs.sh <pr-number> [job-name]
scripts/workflow-pr-logs.cmd <pr-number> [job-name]
```

### workflow-rerun
```bash
scripts/workflow-rerun.sh <pr-number> [--failed]   # Default: --failed
scripts/workflow-rerun.cmd <pr-number> [--failed]
```

## Comment Management

GitHub has two comment types:
- **Review comments**: Inline on code lines
- **Issue comments**: General PR discussion (includes bots like CodeRabbit)

### pr-comments-list
```bash
scripts/pr-comments-list.sh <pr-number>   # Shows both types
scripts/pr-comments-list.cmd <pr-number>
```

### pr-comment-get
```bash
scripts/pr-comment-get.sh <pr-number> <comment-id> [review|issue]
scripts/pr-comment-get.cmd <pr-number> <comment-id> [review|issue]
```

### pr-comment-reply
```bash
scripts/pr-comment-reply.sh <pr-number> "message"
scripts/pr-comment-reply.cmd <pr-number> "message"
```

### pr-comment-update
```bash
scripts/pr-comment-update.sh <comment-id> <review|issue> "new body"
scripts/pr-comment-update.cmd <comment-id> <review|issue> "new body"
```
