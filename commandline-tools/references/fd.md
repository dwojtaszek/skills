# fd - Fast File Finder

Fast alternative to `find` - respects .gitignore, simpler syntax, smart defaults.

## When to Use

| Tool | Use Case |
|------|----------|
| **fd** | Modern project search with smart defaults |
| **find** | Complex boolean logic, POSIX compliance |
| **locate** | Whole-system filename search (pre-indexed) |

## Quick Comparison

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

# locate: Fastest for whole-system search
locate config.yaml
```

## Common Use Cases

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

## Advanced Examples

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

## Ubuntu Note

On Ubuntu, `fd` is installed as `fdfind`. Create alias:
```bash
alias fd=fdfind
```
