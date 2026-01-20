---
name: commandline-tools
description: "Modern CLI tools (fd, ripgrep, ast-grep, jq, qsv, fzf, bat). Use for file search, code analysis, and data processing. Triggered by: search for pattern, find files, find code, process JSON, parse CSV, analyze codebase, use ast-grep, run ripgrep, how to use jq, better than grep, modern alternative to find, fuzzy finder, syntax highlighting, should I use ripgrep or grep, when to use ast-grep vs ripgrep, jq or Python for JSON."
allowed-tools:
  - Bash
---

# Command Line Tools

Modern CLI productivity tools for file search, code analysis, and data processing.

## Quick Decision Guide

**Need to search text in files?**
- Fast, respects .gitignore → **ripgrep** (`rg "pattern"`)
- Structural code patterns → **ast-grep** (`sg -p 'function $NAME()'`)
- Universal fallback → **grep**

**Need to find files?**
- Modern project search → **fd** (`fd pattern`)
- Complex boolean logic → **find** (traditional)
- Whole system search → **locate** (pre-indexed)

**Need to process data?**
- JSON queries → **jq** (`jq '.field'`)
- CSV operations → **qsv** (`qsv stats file.csv`)
- Complex multi-step → **Python/pandas**

**Need to view files?**
- With syntax highlighting → **bat** (`bat file.js`)
- Plain text, piping → **cat** (traditional)

**Interactive selection?**
- Fuzzy finder → **fzf** (`fd | fzf --preview 'bat {}'`)

**Need to list files?**
- Modern with icons/git → **eza** (`eza -l --git`)
- Standard → **ls**

## Supported Tools

### Search & Code Analysis
| Tool | Description | Example |
|------|-------------|---------|
| **ripgrep (rg)** | Ultra-fast text search | `rg "TODO" -t js` |
| **ast-grep (sg)** | AST-based code search | `sg -p 'console.log($$$)'` |
| **fzf** | Interactive fuzzy finder | `fd \| fzf --preview 'bat {}'` |

### File Operations
| Tool | Description | Example |
|------|-------------|---------|
| **fd** | Fast file finder | `fd -e py --changed-within 24h` |
| **bat** | Cat with syntax highlighting | `bat --diff file.js` |
| **eza** | Modern ls with icons | `eza -l --git` |

### Data Processing
| Tool | Description | Example |
|------|-------------|---------|
| **jq** | JSON processor | `cat data.json \| jq '.users[]'` |
| **qsv** | Ultra-fast CSV toolkit | `qsv stats data.csv` |

### Other
| Tool | Description | Note |
|------|-------------|------|
| **zoxide** | Smart cd that learns | Requires shell init |
| **httpie** | HTTP client (`http GET url`) | |
| **git-delta** | Better git diffs | Requires .gitconfig setup |

## Quick Install

**macOS:**
```bash
brew install fd ripgrep ast-grep jq qsv fzf bat eza zoxide httpie git-delta
```

**Ubuntu/Debian:**
```bash
sudo apt install -y fd-find ripgrep jq fzf bat zoxide httpie git-delta
npm install -g @ast-grep/cli  # Requires Node.js

# Create aliases for Ubuntu naming quirks (use ~/.zshrc for zsh)
echo 'alias fd=fdfind' >> ~/.bashrc
echo 'alias bat=batcat' >> ~/.bashrc
source ~/.bashrc
# Note: eza, qsv not in apt - use cargo or see installation.md
```

**Windows (scoop):**
```powershell
scoop install fd ripgrep ast-grep jq fzf bat eza zoxide httpie delta
```

## Scope

**Use for:** File search, code pattern matching, JSON/CSV processing, modern CLI alternatives.

**Not for:** Jira tickets (use jira skill), code review/verification (use verification-partner), simple Unix commands where modern alternatives aren't needed (e.g., basic `ls`, `cd`, `mkdir`).

## Proactive Usage

Invoke this skill **in parallel** with other operations:
- User analyzes codebase → Suggest ast-grep/ripgrep commands
- User processes data → Provide jq/qsv examples
- User searches files → Suggest fd alongside built-in search

## Reference Files

Detailed examples and advanced usage:
- [references/fd.md](references/fd.md) - File finding
- [references/ripgrep.md](references/ripgrep.md) - Text search
- [references/ast-grep.md](references/ast-grep.md) - Code pattern search
- [references/jq.md](references/jq.md) - JSON processing
- [references/qsv.md](references/qsv.md) - CSV processing
- [references/fzf.md](references/fzf.md) - Fuzzy finding
- [references/bat.md](references/bat.md) - File viewing
- [references/other-tools.md](references/other-tools.md) - eza, httpie, zoxide, git-delta
- [references/installation.md](references/installation.md) - Platform-specific install
- [references/troubleshooting.md](references/troubleshooting.md) - Common issues
