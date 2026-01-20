# bat - Cat with Syntax Highlighting

Enhanced file viewer with syntax highlighting, line numbers, and git integration.

## When to Use

| Tool | Use Case |
|------|----------|
| **bat** | Viewing code with highlighting |
| **cat** | Concatenating files, piping (clean output) |
| **less** | Basic paging without syntax |

## Quick Comparison

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
```

## Common Use Cases

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

## Advanced Examples

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

## Ubuntu Note

On Ubuntu, use `batcat` unless symlinked:
```bash
alias bat=batcat
# or
ln -s /usr/bin/batcat ~/.local/bin/bat
```
