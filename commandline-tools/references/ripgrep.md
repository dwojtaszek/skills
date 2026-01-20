# ripgrep (rg) - Fast Text Search

Ultra-fast text search (10x faster than grep), respects .gitignore by default.

## Common Use Cases

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

## Advanced Examples

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

## Note

Respects `.gitignore` by default. Use `--no-ignore` to search all files.
