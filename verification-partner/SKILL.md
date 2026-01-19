---
name: verification-partner
description: "Get second opinions from different AI models (OpenAI via Cursor, Google via Copilot). Use for cross-validating code, architecture, and technical decisions. Triggered by: get a second opinion, verify this code, review this for me, cross-check my approach, is this a good design, validate this architecture, brainstorm alternatives, what do other models think, independent review, check this implementation, sanity check, double-check this, does this look right, another perspective on this."
---

# Verification Partner

Cross-validate decisions using external AI models (OpenAI + Google) for independent perspectives.

## Critical: Bash Timeout

**Set timeout to 240000ms (4 minutes)** - the script has a 3-minute internal timeout.

## Prerequisites

```bash
cursor agent status    # Should show "connected"
gh auth status         # Should show "Logged in"
```

## Privacy Notice

Code is sent to external AI providers (Cursor → OpenAI, Copilot → Google). Do NOT use with sensitive code, credentials, or PII without clearance.

## Quick Start

**Run from skill directory:** `cd ~/.claude/skills/verification-partner`

### code-review --git-diff ⭐ **Most Common**
```bash
./scripts/verify.py --mode code-review --git-diff
```
Reviews unstaged changes - use this for quick feedback before staging.

### Other Commands
```bash
# Review staged changes (before commit)
./scripts/verify.py --mode code-review --git-staged

# Review branch vs main
./scripts/verify.py --mode code-review --git-branch main

# Review specific files
./scripts/verify.py --mode code-review --files src/auth.ts src/middleware.ts

# Manual content
./scripts/verify.py --mode code-review \
  --context "Express.js auth middleware" --content "$(cat auth.ts)"
```

## Modes

| Mode | Use For |
|------|---------|
| `code-review` | Security, bugs, quality, performance |
| `brainstorm` | Alternatives, design options, trade-offs |
| `doc-review` | Documentation completeness, clarity |
| `adr-review` | Architecture Decision Records |
| `verify` | General verification (default) |

## CLI Options

```
--mode           code-review|brainstorm|doc-review|adr-review|verify
--context        Background context (auto-generated for git options)
--content        Content to verify (or use git/file options)
--tool           cursor|copilot|both (default: both)
--model          Specify model (cursor: gpt-5.2-codex-xhigh, gemini-3-pro; copilot: gpt-5.1-codex-max, gemini-3-pro-preview)
--json           JSON output
--check-status   Check tool availability

Git Integration:
--git-diff       Review unstaged changes
--git-staged     Review staged changes
--git-branch X   Review changes vs branch X
--git-files      Include full file contents, not just diff
--files F1 F2    Review specific files
```

## Scope

**Use for:** Second opinions on code/architecture, independent code reviews, brainstorming alternatives, validating API designs, cross-checking documentation.

**Not for:** Executing code, implementing features, Jira tickets (use jira skill), file search (use commandline-tools).

**Capabilities:** Analyzes code for bugs/security/performance, reviews architectural decisions, suggests alternatives, runs two AI providers in parallel. Cannot execute code, modify files, or guarantee correctness.

## Large Content Handling

The script automatically handles large content by:
- Splitting by file boundaries when possible
- Chunking large single files intelligently
- Warning when content exceeds size thresholds

For very large reviews, use `--git-diff` or `--files` which format content with clear boundaries.

## Multi-File Content Format

When manually preparing content, format as:
```
### File: src/auth.ts
\`\`\`ts
[contents]
\`\`\`

### File: src/middleware.ts
\`\`\`ts
[contents]
\`\`\`
```

Pipe large content via stdin: `echo "[content]" | ./scripts/verify.py --mode code-review --context "..."`

## Troubleshooting

See [references/troubleshooting.md](references/troubleshooting.md) for common issues.
