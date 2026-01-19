---
name: commandline-tools
description: Modern CLI tools (fd, ripgrep, ast-grep, jq, qsv, fzf, bat). Auto-activate when user says 'analyze', 'search', 'find code', 'process data', or mentions tool names (ast-grep, ripgrep, fd, jq). ALWAYS invoke IN PARALLEL with Explore/Task agents to provide tool-specific commands alongside analysis. Provides concrete ast-grep/ripgrep/jq examples for any code/data operation.
allowed-tools:
  - Bash
---

# Command Line Tools Manager (Universal)

Manages installation and provides usage guidance for modern CLI productivity tools across macOS, Linux, and Windows.

## Trigger Examples

This skill auto-activates when you say:

**Active Search & Find:**
- "Search for 'pattern' in all JavaScript files"
- "Find all files modified today"
- "Search code for this function"
- "Find TypeScript files in this project"
- "Grep for 'TODO' across codebase"
- "Search for API calls in Python files"

**Data Processing:**
- "Parse this JSON and extract field X"
- "Process CSV files" / "Analyze this CSV"
- "Query JSON in command line"
- "Get stats on this CSV file"
- "Join these two CSV files"
- "Filter CSV by column value"

**Code Analysis:**
- "Find all console.log statements"
- "Search for function declarations"
- "Find imports from React"
- "Structured code search" / "AST-based search"
- "Refactor var to const across files"
- "Find this code pattern"
- "Use ast-grep to analyze the repo"
- "Run ast-grep on the codebase"
- "Analyze code with ast-grep"
- "Find use of X" / "Find usage of X"
- "Where is X used?" / "Find all uses of this function"
- "Search for code patterns"

**File Operations:**
- "View this file with syntax highlighting"
- "List files sorted by date"
- "Show me files matching pattern"
- "Fast file search in project"
- "Interactive file picker"
- "Preview file contents"

**Better Alternatives:**
- "I need a better grep tool" / "Faster than grep"
- "Better cat with syntax highlighting"
- "Modern alternative to find" / "Better than find"
- "Modern ls replacement" / "Better git diff"

**Decision-Making:**
- "Should I use ripgrep or grep?"
- "When to use ast-grep vs ripgrep?"
- "jq or Python for JSON?"
- "fd or find command?"
- "What's better: qsv or pandas?"

**Tool Usage Questions:**
- "How do I use ripgrep for X?"
- "Show me jq examples"
- "How to use fd to find files?"
- "What's the syntax for ast-grep?"

**Pattern Triggers:**
This skill also triggers when you mention these tool names: fd, ripgrep, rg, jq, qsv, fzf, bat, eza, httpie, ast-grep, sg, zoxide, git-delta

## Use When

Use this skill when the user needs to:
- **Search files or code** with patterns, structure, or criteria
- **Process JSON/CSV data** at command line (parse, query, transform)
- **Find files** by name, date, size, or type
- **View files** with syntax highlighting
- **Compare options** for modern CLI tools vs legacy tools
- Mentions specific tool names (fd, ripgrep, jq, qsv, fzf, bat, eza, ast-grep, etc.)
- Asks for **alternatives** to grep, find, cat, ls
- Needs **decision help** choosing between tools (e.g., "ripgrep or grep?")

## Proactive Parallel Invocation

**IMPORTANT**: Invoke this skill **proactively and in parallel** with other operations when:
- User asks to explore/analyze codebase → Run **in parallel** with Explore agent to provide ast-grep/ripgrep context
- User wants to find code patterns → Invoke alongside search to suggest ast-grep vs ripgrep
- User needs to process data → Invoke to provide jq/qsv examples alongside data operations
- User searches files → Invoke to suggest fd/ripgrep alongside built-in search

**Goal**: Provide CLI tool expertise as **additional context** to enhance other operations, not replace them.

**Example parallel usage:**
```
User: "Analyze codebase for React usage"
→ Launch Explore agent (for general analysis)
→ ALSO invoke commandline-tools skill (to suggest: ast-grep -p 'import { $$$ } from "react"')
→ User gets both high-level analysis AND specific tool commands
```

## Do NOT Use When

Do NOT use this skill when:
- User is **already executing commands** correctly (they know what they're doing)
- Request is about **Jira tickets** or issue tracking (use jira skill instead)
- Request is about **code review** or **verification** (use verification-partner instead)
- User asks about **standard Unix commands** without mentioning modern alternatives
- Request is about **programming language features** (not command-line tools)
- User needs tools **not in the supported list** (see Supported Tools section)

## Scope & Capabilities

**This skill CAN:**
- Provide usage examples for modern CLI tools
- Explain when to use tool X vs tool Y
- Show installation commands for macOS (brew), Linux (apt/cargo), Windows (scoop/winget)
- Demonstrate multi-tool pipelines (e.g., `fd | fzf | bat`)
- Explain decision heuristics: "Need fastest text search → ripgrep; structural code change → ast-grep"
- Check if tools are installed before suggesting commands
- Provide platform-specific guidance (macOS/Linux/Windows)

**This skill CANNOT:**
- Execute commands for you (use Bash tool instead)
- Install tools automatically (provides commands for you to run)
- Work with unsupported tools beyond the list
- Fix issues with tool installations (provides troubleshooting guidance only)
- Create custom scripts or automation

## Quick Decision Guide

**Need to search text in files?**
- Fast, respect .gitignore → **ripgrep** (`rg "pattern"`)
- Structured code patterns → **ast-grep** (`sg -p 'function $NAME()'`)
- Universal compatibility → **grep** (fallback)

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

**Need directory listing?**
- Modern with colors/icons → **eza** (`eza -l`)
- Traditional → **ls** (fallback)

## Error Handling

**Tool Not Installed:**
- Check availability with `which <tool>` (Unix) or `Get-Command <tool>` (Windows)
- Provide installation command for user's platform:
  - macOS: `brew install <tool>`
  - Linux: `apt install <tool>` or `cargo install <tool>`
  - Windows: `scoop install <tool>` or `winget install <tool>`

**Ubuntu Naming Conflicts:**
- `fd` installed as `fdfind`, `bat` as `batcat`
- Suggest creating aliases: `alias fd=fdfind` or symlinks

**Tool Not in PATH:**
- Suggest adding `~/.local/bin` or `~/.cargo/bin` to PATH
- Windows: restart terminal to refresh PATH

**Platform Not Supported:**
- For BSD/Solaris: suggest Cargo installation as universal fallback
- Some tools (eza, qsv) may need manual builds on older systems

**Command Syntax Errors:**
- Provide corrected examples
- Explain common mistakes (e.g., forgetting quotes in shell)

## Security & Permissions

**Read Operations:**
- All search/find operations are read-only
- Tools respect .gitignore and file permissions by default
- No data modification unless explicitly requested

**Write Operations:**
- ast-grep with `--rewrite` flag modifies files (requires user confirmation)
- Always suggest `--dry-run` or `-n` flags to preview changes first
- Recommend version control (git) before bulk modifications

**Data Privacy:**
- Tools operate locally, no data sent to external services
- Be cautious with sensitive files (credentials, keys, PII)
- Use `--hidden` and `--no-ignore` flags carefully (may expose sensitive files)

**Safe Practices:**
- Preview commands before execution
- Test on small datasets first
- Use interactive modes when available (e.g., `ast-grep --interactive`)
- Back up data before bulk operations

## Supported Tools

### File Operations
- **fd**: Fast alternative to `find` (respects .gitignore, simpler syntax)
- **bat**: Cat with syntax highlighting and line numbers
- **eza**: Modern `ls` with colors and icons

### Search & Code Analysis
- **ripgrep (rg)**: Ultra-fast text search (10x faster than grep)
- **ast-grep (sg)**: AST-based code pattern search and refactoring
- **fzf**: Interactive fuzzy finder for files/history

### Data Processing
- **jq**: JSON query and transformation processor
- **qsv**: Ultra-fast CSV data wrangling toolkit with 100+ commands
- **httpie**: User-friendly HTTP client (better than curl for APIs)

### Navigation & Git
- **zoxide**: Smart `cd` that learns your patterns
- **git-delta**: Syntax-highlighted git diffs with side-by-side view

---

## Platform Detection

First, detect the operating system:

```bash
# Detect platform
case "$(uname -s)" in
    Linux*)     PLATFORM="linux";;
    Darwin*)    PLATFORM="macos";;
    CYGWIN*|MINGW*|MSYS*) PLATFORM="windows";;
    *)          PLATFORM="unknown";;
esac
```

**For PowerShell (Windows):**
```powershell
if ($IsWindows -or $env:OS -eq "Windows_NT") { $platform = "windows" }
elseif ($IsMacOS) { $platform = "macos" }
elseif ($IsLinux) { $platform = "linux" }
```

---

## Installation Reference

For detailed installation instructions, see **commandline-tools-INSTALL.md**.

### Quick Installation Check

Always check before installing:

**Unix-like (macOS/Linux):**
```bash
which <tool-name> 2>/dev/null || echo "NOT_FOUND"
```

**Windows (PowerShell):**
```powershell
Get-Command <tool-name> -ErrorAction SilentlyContinue
```

### Quick Install Commands

**macOS (Homebrew):**
```bash
brew install fd ripgrep ast-grep jq qsv fzf bat eza zoxide httpie git-delta
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install -y fd-find ripgrep jq fzf bat zoxide httpie git-delta
npm install -g @ast-grep/cli
# Note: eza and qsv require special handling (see INSTALL.md)
```

**Windows (scoop):**
```powershell
scoop install fd ripgrep ast-grep jq fzf bat eza zoxide httpie delta
```

**Universal (Cargo):**
```bash
cargo install fd-find ripgrep ast-grep bat eza zoxide git-delta --locked
cargo install qsv --locked --bin qsv -F all_features
```

---

## Usage Examples

**IMPORTANT:** Provide 2-3 relevant examples based on user's specific need. Do NOT dump all examples.

### fd (Fast Find)

#### fd vs find/locate (Quick Guidance)

**Use `fd` for modern, fast file finding.** It's user-friendly, respects `.gitignore`, and has intuitive defaults.

* **Quick searches**: Find files by name/extension with simple syntax.
* **Smart defaults**: Automatically ignores `.git`, `node_modules`, hidden files (unless `-H`).
* **Time-based queries**: Find files modified recently (`--changed-within 24h`).
* **Execute on results**: Built-in `-x` flag to run commands on matches.

**Use classic `find` when:**
* Need complex boolean logic with multiple conditions.
* Working on systems without `fd` installed (universal availability).
* Need POSIX compliance or specific `find` predicates.

**Use `locate` when:**
* Searching entire filesystem for filename (uses pre-built database).
* Don't care about real-time updates (database updated daily).
* Maximum speed for filename-only searches across entire system.

**Rule of thumb:**
* Modern project search with smart defaults → use `fd`.
* Complex nested conditions → use `find`.
* Whole-system filename search → use `locate`.
* Combine with other tools (`fzf`, `bat`, etc.) → use `fd`.

**Quick Comparison:**

```bash
# fd: Simple and fast (respects .gitignore)
fd test.js

# find equivalent (verbose)
find . -type f -name 'test.js' -not -path '*/\.git/*' -not -path '*/node_modules/*'

# fd: Find by extension
fd -e ts -e tsx

# find equivalent
find . -type f \( -name '*.ts' -o -name '*.tsx' \)

# fd: Execute on results (clean syntax)
fd -e jpg -x convert {} {.}.png

# find equivalent
find . -type f -name '*.jpg' -exec sh -c 'convert "$1" "${1%.jpg}.png"' _ {} \;

# locate: Fastest for whole-system search
locate config.yaml  # Searches pre-built database
```

**Mental model:**
* Defaults: `fd` smart (ignores git/hidden); `find` finds everything; `locate` uses database.
* Speed: `fd` fastest for projects; `locate` fastest for system; `find` slowest.
* Syntax: `fd` intuitive; `find` complex; `locate` simplest.
* Use case: `fd` = daily work; `find` = complex logic; `locate` = whole system.

---

**Common Use Cases:**
```bash
# Find all JavaScript files
fd -e js

# Find files matching "config" (case-insensitive)
fd -i config

# Find and execute command on results
fd -e json -x cat {}

# Search in specific directory
fd pattern /path/to/search

# Show hidden files
fd -H pattern
```

**Advanced Examples:**
```bash
# Find files modified in last 24 hours
fd -e py --changed-within 24h

# Exclude directories from search
fd -E node_modules -E .git pattern

# Find directories only
fd -t d pattern

# Find by size
fd -S +10m  # Files larger than 10MB

# Execute parallel commands
fd -e jpg -x convert {} {.}.png
```

*Note: On Ubuntu, use `fdfind` unless aliased/symlinked to `fd`*

---

### ripgrep (Fast Grep)

**Common Use Cases:**
```bash
# Search for pattern in current directory
rg "pattern"

# Case-insensitive search
rg -i "pattern"

# Search only specific file types
rg -t js "function"

# Search with context lines
rg -C 3 "pattern"  # 3 lines before and after

# Show only filenames
rg -l "pattern"
```

**Advanced Examples:**
```bash
# Search multiple patterns (OR)
rg "error|warning|fail"

# Search with line numbers and column
rg -n --column "pattern"

# Include/exclude files
rg --glob "*.py" --glob "!test_*" "pattern"

# Search hidden files and gitignored files
rg --hidden --no-ignore "secret"

# Replace preview (doesn't modify files)
rg "old" -r "new"

# Search with word boundaries
rg "\bword\b"

# Output with stats
rg --stats "pattern"
```

---

### ast-grep (Code Structure Search)

#### ast-grep vs ripgrep (Quick Guidance)

**Use `ast-grep` when structure matters.** It parses code and matches AST nodes, so results ignore comments/strings, understand syntax, and can **safely rewrite** code.

* **Refactors/codemods**: Rename APIs, change import forms, rewrite call sites or variable kinds.
* **Policy checks**: Enforce patterns across a repo (`scan` with rules + `test`).
* **Editor/automation**: LSP mode; `--json` output for tooling.

**Use `ripgrep` when text is enough.** It's the fastest way to grep literals/regex across files.

* **Recon**: Find strings, TODOs, log lines, config values, or non-code assets.
* **Pre-filter**: Narrow candidate files before a precise pass.

**Rule of thumb:**
* Need correctness over speed, or you'll **apply changes** → start with `ast-grep`.
* Need raw speed or you're just **hunting text** → start with `rg`.
* Often combine: `rg` to shortlist files, then `ast-grep` to match/modify with precision.

**Quick Examples:**

```bash
# Find structured code (ignores comments/strings)
ast-grep run -l TypeScript -p 'import $X from "$P"'

# Codemod (only real `var` declarations become `let`)
ast-grep run -l JavaScript -p 'var $A = $B' -r 'let $A = $B' -U

# Quick textual hunt
rg -n 'console\.log\(' -t js

# Combine speed + precision
rg -l -t ts 'useQuery\(' | xargs ast-grep run -l TypeScript -p 'useQuery($A)' -r 'useSuspenseQuery($A)' -U
```

**Mental model:**
* Unit of match: `ast-grep` = node; `rg` = line.
* False positives: `ast-grep` low; `rg` depends on your regex.
* Rewrites: `ast-grep` first-class; `rg` requires ad-hoc sed/awk and risks collateral edits.

---

**Common Use Cases:**
```bash
# Find all function declarations
sg -p 'function $NAME($$$) { $$$ }'

# Find console.log statements
sg -p 'console.log($$$)'

# Find React components
sg -p 'function $NAME() { return $$$ }' -l jsx

# Find specific imports
sg -p 'import { $$$ } from "react"'
```

**Advanced Examples:**
```bash
# Interactive rewrite mode
sg -p 'var $NAME = $VALUE' --rewrite 'const $NAME = $VALUE' --interactive

# Search multiple languages
sg -p 'def $NAME($$$): $$$' -l python

# Find with context
sg -p 'if ($COND) { $$$ }' -A 3 -B 3

# Find TODO comments with patterns
sg -p '// TODO: $$$'

# Complex refactoring pattern
sg -p 'setState({ $KEY: $VALUE })' --rewrite 'setState(prev => ({ ...prev, $KEY: $VALUE }))'
```

*Note: Only works with structured code (JS, TS, Python, Go, Rust). Does NOT work with Markdown or plain text.*

---

### jq (JSON Processor)

#### jq vs Python/grep (Quick Guidance)

**Use `jq` when working with JSON data.** It's purpose-built for JSON transformation and queries, with terse syntax and streaming support.

* **Quick JSON inspection**: Pretty-print, extract fields, validate structure.
* **Pipeline transformations**: Filter, map, reduce JSON in shell pipelines.
* **API responses**: Parse and extract data from REST API outputs.
* **Config files**: Read/modify JSON config without full programming language.

**Use Python when:**
* Complex logic beyond JSON manipulation (business rules, calculations).
* Integration with other data sources (databases, files, APIs).
* Multi-step workflows requiring state or error handling.

**Use grep/ripgrep when:**
* Just searching for presence of text in JSON (not extracting structured data).
* Pre-filtering large JSON files before parsing.

**Rule of thumb:**
* Single-line JSON query or transformation → use `jq`.
* Need structured output from JSON → use `jq`.
* Complex business logic or multi-format data → use Python.
* Just searching for strings → use `rg`.

**Quick Comparison:**

```bash
# jq: Extract nested field (clean, fast)
curl api.example.com/users | jq '.data[0].email'

# Python equivalent (more verbose)
curl api.example.com/users | python3 -c "import sys,json; print(json.load(sys.stdin)['data'][0]['email'])"

# jq: Filter and transform
cat users.json | jq '[.[] | select(.age > 25) | {name, email}]'

# Grep: Just find if email exists (no structure)
cat users.json | rg 'user@example.com'

# Combine: Pre-filter with rg, then parse with jq
rg -l '"premium": true' *.json | xargs -I {} jq '.users[]' {}
```

**Mental model:**
* Use case: `jq` = JSON Swiss Army knife; Python = full programming; grep = text search.
* Learning curve: `jq` syntax terse but learnable; Python familiar; grep simple.
* Performance: `jq` fast for JSON; Python slower startup; grep fastest for search.

---

**Common Use Cases:**
```bash
# Pretty print JSON
cat file.json | jq '.'

# Extract specific field
cat file.json | jq '.field'

# Extract nested field
echo '{"user":{"name":"John"}}' | jq '.user.name'

# Array access
cat file.json | jq '.[0]'

# Multiple fields
cat file.json | jq '.name, .age'
```

**Advanced Examples:**
```bash
# Filter arrays
cat data.json | jq '.users[] | select(.age > 25)'

# Map transformation
cat data.json | jq '.items[] | {name: .title, id: .id}'

# Collect into array
cat data.json | jq '[.users[] | .name]'

# Group by field
cat data.json | jq 'group_by(.category)'

# Sort array
cat data.json | jq 'sort_by(.date) | reverse'

# Count elements
cat data.json | jq '.items | length'

# Conditional logic
cat data.json | jq '.users[] | if .age > 18 then .name else empty end'

# Format as CSV
cat data.json | jq -r '.[] | [.name, .age, .email] | @csv'

# Merge objects
jq -s '.[0] * .[1]' file1.json file2.json
```

---

### qsv (CSV Toolkit)

#### qsv vs pandas/Excel (Quick Guidance)

**Use `qsv` when working with CSV data at the command line.** It's blazingly fast, handles huge files (millions of rows), and has 100+ specialized commands.

* **Data exploration**: Quick stats, preview, validate CSV structure.
* **ETL pipelines**: Filter, join, split, transform CSVs in shell scripts.
* **Performance critical**: Process multi-GB CSV files in seconds.
* **One-off operations**: No need to write Python scripts for simple CSV tasks.

**Use pandas (Python) when:**
* Complex analysis requiring multiple steps with intermediate state.
* Integration with machine learning, plotting, or advanced statistics.
* Need to mix CSV with other data sources (databases, APIs, Excel).
* Custom business logic or calculations.

**Use Excel when:**
* Interactive exploration with point-and-click.
* Creating visualizations and charts.
* Sharing with non-technical users.
* Files are small (<100K rows) and you need formulas.

**Rule of thumb:**
* Quick CSV operation or validation → use `qsv`.
* Large CSV (>1GB) or performance matters → use `qsv`.
* Complex multi-step analysis → use pandas.
* Visual exploration or sharing → use Excel.

**Quick Comparison:**

```bash
# qsv: Instant stats on huge file
qsv stats sales.csv  # Handles millions of rows

# qsv: SQL queries without database
qsv sql "SELECT product, SUM(revenue) FROM sales WHERE date > '2024-01-01' GROUP BY product" sales.csv

# qsv: Join two CSVs (fast)
qsv join user_id users.csv user_id orders.csv

# pandas equivalent (slower, more code)
python -c "import pandas as pd; df1 = pd.read_csv('users.csv'); df2 = pd.read_csv('orders.csv'); pd.merge(df1, df2, on='user_id').to_csv('out.csv', index=False)"

# Combine with other tools
qsv select revenue,date sales.csv | qsv stats | jq '.'  # Stats as JSON
```

**Mental model:**
* Speed: `qsv` fastest; pandas moderate; Excel slowest for large data.
* Scale: `qsv` handles multi-GB; pandas limited by RAM; Excel caps at ~1M rows.
* Scripting: `qsv` perfect for pipelines; pandas for complex logic; Excel manual.
* Commands: `qsv` has 100+ specialized commands; pandas more general-purpose.

---

**Common Use Cases:**
```bash
# View CSV with aligned columns
qsv table data.csv

# Get statistical summary
qsv stats data.csv

# Select specific columns
qsv select col1,col3 data.csv

# Filter rows by pattern
qsv search "pattern" data.csv

# Sort by column
qsv sort -s column data.csv
```

**Advanced Examples:**
```bash
# Convert CSV to JSON
qsv to json data.csv

# Count unique values in column
qsv frequency column data.csv

# Join two CSV files
qsv join id file1.csv id file2.csv

# Split large CSV into chunks
qsv split --size 1000 data.csv output_

# Deduplicate rows
qsv dedup data.csv

# Add index column
qsv enum data.csv

# SQL queries on CSV
qsv sql "SELECT * FROM data WHERE age > 25" data.csv

# Validate CSV structure
qsv validate data.csv

# Flatten nested JSON in CSV
qsv flatten data.csv

# Sample random rows
qsv sample 100 data.csv

# Transpose rows/columns
qsv transpose data.csv
```

*Note: Optimized for large CSV files (millions of rows). Use `qsv --list` to see all 100+ commands.*

---

### fzf (Fuzzy Finder)

#### fzf vs grep/Ctrl+R (Quick Guidance)

**Use `fzf` for interactive selection from lists.** It's a general-purpose fuzzy finder that turns any list into an interactive picker.

* **File selection**: Interactively choose files to open/edit/process.
* **Command history**: Better than Ctrl+R for finding past commands.
* **Process management**: Pick processes to kill, inspect, or manage.
* **Git workflows**: Select branches, commits, or files interactively.

**Use `grep/ripgrep` when:**
* Non-interactive search for specific patterns.
* Piping results to other commands automatically.
* Need regex matching and file content search.

**Use `Ctrl+R` (shell history) when:**
* Quick single command lookup without fuzzy matching.
* Minimal setup, works everywhere.

**Rule of thumb:**
* Interactive selection from any list → use `fzf`.
* Filter command history with preview → use `fzf`.
* Search file contents → use `rg`, not `fzf`.
* One-off history lookup → use `Ctrl+R`.

**Quick Comparison:**

```bash
# fzf: Interactive file selection with preview
fd -t f | fzf --preview 'bat --color=always {}'

# fzf: Better command history search
history | fzf

# Ctrl+R equivalent (but less powerful)
# Just type Ctrl+R and start typing

# fzf: Pick git branch to checkout
git branch | fzf | xargs git checkout

# fzf: Kill process interactively
ps aux | fzf | awk '{print $2}' | xargs kill

# Combine tools: find files, fuzzy select, open in editor
fd -e py | fzf -m --preview 'bat {}' | xargs code

# fzf with directory navigation
alias cdf='cd $(fd -t d | fzf)'

# rg for searching (not selecting)
rg "TODO" --files-with-matches  # Non-interactive
```

**Mental model:**
* Purpose: `fzf` = interactive selector; `grep` = pattern matcher; `Ctrl+R` = basic history.
* Mode: `fzf` interactive; `grep` batch; `Ctrl+R` quick lookup.
* Input: `fzf` works on any list; `grep` searches file contents; `Ctrl+R` only history.
* Power: `fzf` most versatile; `grep` best for content; `Ctrl+R` simplest.

**Shell Integration (Recommended):**
```bash
# Add to ~/.bashrc or ~/.zshrc for superpowers
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d'

# Ctrl+T: Fuzzy file finder
# Ctrl+R: Fuzzy history search (better than default)
# Alt+C: Fuzzy directory changer
```

---

**Common Use Cases:**
```bash
# Interactive file finder
fzf

# With file preview using bat
fzf --preview 'bat {}'

# Search command history
history | fzf

# Change directory interactively
cd $(fd -t d | fzf)

# Open file in editor
vim $(fzf)
```

**Advanced Examples:**
```bash
# Multi-select mode
fzf -m

# Custom preview window
fzf --preview 'cat {}' --preview-window=right:50%

# Search git files only
git ls-files | fzf

# Kill process interactively
ps aux | fzf | awk '{print $2}' | xargs kill

# Search and open in VSCode
code $(fzf)

# Filter mode (non-interactive)
echo -e "apple\nbanana\ncherry" | fzf --filter ban

# Custom keybindings
fzf --bind 'ctrl-y:execute-silent(echo {} | pbcopy)'

# Search with initial query
fzf --query "initial search"
```

*Note: On Ubuntu with bat, use `fzf --preview 'batcat {}'`*

---

### bat (Cat with Syntax Highlighting)

#### bat vs cat/less (Quick Guidance)

**Use `bat` for viewing code and text files.** It adds syntax highlighting, line numbers, git integration, and automatic paging.

* **Code review**: View source files with syntax highlighting and line numbers.
* **Git integration**: See uncommitted changes inline with `--diff`.
* **Piping**: Use as pager for command output with syntax detection.
* **Reading logs**: Navigate large files with built-in paging.

**Use classic `cat` when:**
* Concatenating files (actual cat use case: `cat file1 file2 > combined`).
* Need plain output for scripting (no decorations).
* Performance critical with huge files.

**Use `less` when:**
* Just need basic paging without syntax highlighting.
* Working on minimal systems without bat.

**Rule of thumb:**
* Viewing code files → use `bat`.
* Quick file preview → use `bat`.
* Piping to other commands and need clean output → use `cat`.
* Simple paging without syntax → use `less`.

**Quick Comparison:**

```bash
# bat: Beautiful syntax-highlighted output
bat config.yaml  # Auto-detects YAML, adds line numbers

# cat equivalent (plain)
cat config.yaml

# bat: View with git changes highlighted
bat --diff src/main.rs

# bat: Perfect for piped content
curl https://example.com/api.json | bat -l json

# cat for piping (clean output)
cat data.txt | grep pattern | wc -l

# bat as pager replacement
export PAGER=bat
man ls  # Man pages with syntax highlighting

# Combine with fd/fzf
fd -e py | fzf --preview 'bat --color=always {}'
```

**Mental model:**
* Purpose: `bat` = enhanced viewer; `cat` = concatenate/output; `less` = simple pager.
* Output: `bat` decorated; `cat` clean; `less` paginated.
* Use case: `bat` for humans; `cat` for pipes; `less` for navigation.
* Speed: All fast, but `cat` fastest for huge files.

---

**Common Use Cases:**
```bash
# View file with syntax highlighting
bat file.js

# Show line numbers
bat -n file.js

# Show git modifications
bat --diff file.js

# View specific line range
bat -r 10:20 file.js

# Disable paging
bat --paging=never file.js
```

**Advanced Examples:**
```bash
# Multiple files with headers
bat src/*.js

# Pipe with syntax detection
curl https://example.com/script.js | bat -l js

# Show non-printable characters
bat --show-all file.txt

# Custom theme
bat --theme="Monokai Extended" file.py

# Plain output (no decorations)
bat --style=plain file.txt

# Only show git changes
bat --diff --diff-context=3 file.js

# Compare two files
diff -u file1.txt file2.txt | bat
```

*Note: On Ubuntu, use `batcat` unless symlinked to `bat`*

---

### eza (Modern ls)

**Common Use Cases:**
```bash
# Long format with icons
eza -l

# Tree view
eza --tree

# Sort by modification time
eza -l --sort=modified

# Show hidden files
eza -la

# Long format with git status
eza -l --git
```

**Advanced Examples:**
```bash
# Tree with depth limit
eza --tree --level=2

# Only directories
eza -D

# Sort by size
eza -l --sort=size --reverse

# Show file permissions in octal
eza -l --octal-permissions

# Group directories first
eza --group-directories-first

# Show header row
eza -lh

# Custom time format
eza -l --time-style=long-iso

# Show inode numbers
eza -li

# Filter by extension
eza *.js -l
```

---

### httpie (HTTP Client)

**Common Use Cases:**
```bash
# GET request
http GET https://api.example.com/users

# POST with JSON data
http POST https://api.example.com/users name=John age=30

# POST with headers
http POST https://api.example.com/data Authorization:"Bearer token"

# Download file
http --download https://example.com/file.zip

# Follow redirects
http --follow GET https://example.com
```

**Advanced Examples:**
```bash
# Authentication
http --auth user:pass GET https://api.example.com/protected

# Custom headers
http GET https://api.example.com/data Accept:application/json User-Agent:MyApp

# Form data
http --form POST https://api.example.com/upload file@/path/to/file.jpg

# Save session
http --session=mysession POST https://api.example.com/login username=user password=pass

# Use saved session
http --session=mysession GET https://api.example.com/profile

# Pretty print only body
http --body GET https://api.example.com/data

# Save response to file
http GET https://api.example.com/data > response.json

# Query parameters
http GET https://api.example.com/search q==query limit==10

# PUT request
http PUT https://api.example.com/users/123 name=Jane

# DELETE request
http DELETE https://api.example.com/users/123
```

---

### zoxide (Smart CD)

**Common Use Cases:**
```bash
# Jump to directory matching "project"
z project

# Match multiple keywords
z doc downloads

# Query without jumping
zoxide query proj

# Add directory to database
zoxide add /path/to/dir

# Interactive selection (with fzf)
zi
```

**Advanced Examples:**
```bash
# List all tracked directories
zoxide query -l

# Remove directory from database
zoxide remove /path/to/dir

# Show directory scores
zoxide query -l -s

# Jump to subdirectory
z proj/src

# Case-insensitive match
z DoWnLoAdS  # matches ~/Downloads

# Jump to parent directory match
z ..  # Use with other tools
```

*Note: Learns over time. Requires multiple visits before shortcuts work. Must run shell initialization after install.*

**Post-Installation Setup:**
- Bash: Add to `~/.bashrc`: `eval "$(zoxide init bash)"`
- Zsh: Add to `~/.zshrc`: `eval "$(zoxide init zsh)"`
- Fish: Add to `~/.config/fish/config.fish`: `zoxide init fish | source`
- PowerShell: Add to profile: `Invoke-Expression (& { (zoxide init powershell | Out-String) })`

---

### git-delta (Better Git Diffs)

**Common Use Cases:**
```bash
# View diff (after configuration)
git diff

# View commit
git show HEAD

# View history with diffs
git log -p

# Compare branches
git diff main..feature

# View staged changes
git diff --cached
```

**Advanced Examples:**
```bash
# Side-by-side diff
git diff --side-by-side

# Word-level diff
git diff --word-diff

# Diff specific file
git diff file.js

# Diff between commits
git diff abc123..def456

# Show stats
git diff --stat
```

**Post-Installation Setup:**
Add to `~/.gitconfig`:
```ini
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    light = false
    line-numbers = true
    side-by-side = true

[merge]
    conflictstyle = diff3

[diff]
    colorMoved = default
```

*Note: Only enhances git output. Must configure git to use it as pager.*

---

## Common Error Scenarios

### Package Manager Not Found

**Homebrew (macOS):**
```
Install Homebrew from: https://brew.sh
Run: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**apt (Linux):**
```
For non-Debian systems, use:
- Cargo: cargo install <tool-name> --locked
- Distribution package manager (dnf, pacman, zypper)
```

**winget/scoop (Windows):**
```
Winget: Comes with Windows 11 and recent Windows 10
Scoop: Install with: irm get.scoop.sh | iex
```

### Ubuntu Naming Conflicts

On Ubuntu, `fd` is installed as `fdfind` and `bat` as `batcat` due to naming conflicts.

**Solutions:**
```bash
# Option 1: Create aliases in ~/.bashrc
alias fd=fdfind
alias bat=batcat

# Option 2: Create symlinks
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd
ln -s /usr/bin/batcat ~/.local/bin/bat
# Ensure ~/.local/bin is in PATH

# Option 3: Use full binary names
fdfind -e js
batcat file.js
```

### Tool Not in PATH

**Unix-like:**
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
```

**Windows:**
```
Restart PowerShell/Terminal to refresh PATH.
If still not found, add installation directory to PATH via System Environment Variables.
```

---

## Tool-Specific Notes

- **ripgrep:** Respects `.gitignore` by default. Use `--no-ignore` to search all files.
- **ast-grep:** Only works with structured code (JS, TS, Python, Go, Rust). Does NOT work with Markdown or plain text.
- **fzf:** Interactive tool. Use `--filter` flag for non-interactive mode.
- **bat:** Integrates with git. Use `--diff` to see uncommitted changes. On Ubuntu, installed as `batcat`.
- **qsv:** Optimized for large CSV files (millions of rows). Has 100+ commands. Use `qsv --list` to see all.
- **zoxide:** Learns over time. Needs multiple visits to directory before shortcut works. Requires shell initialization.
- **git-delta:** Only enhances git output. Must configure git to use it as pager.
- **httpie:** Authentication: `http --auth user:pass GET url`. Sessions: `http --session=name`.
- **fd:** On Ubuntu, installed as `fdfind`. Create alias or symlink for convenience.
- **eza:** Ubuntu 24.04+ has it in repos. Older versions need third-party repo or cargo.

---

## When NOT to Use This Skill

- User is directly executing commands (they already know what they're doing)
- User asks about standard Unix tools (grep, find, cat, ls) without mentioning modern alternatives
- User asks about tools not in the supported list
- Tool installation is part of a larger automated setup script
- User is on an unsupported platform (BSD, Solaris, etc.) - suggest Cargo instead

---

## Performance Guidelines

- **List tools:** Show only 3-4 most relevant to user's context and platform
- **Examples:** Provide 2-3 examples maximum per request, based on user's specific need
- **Installation:** Always check before install, provide platform-specific command
- **Verification:** Use appropriate command for platform (`which` vs `Get-Command`)
- **Platform detection:** Always detect first, then provide tailored response
- **Usage examples:** Focus on the specific use case the user mentioned
