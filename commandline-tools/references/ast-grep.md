# ast-grep (sg) - AST-based Code Search

Structural code search and refactoring using Abstract Syntax Trees.

**Note:** The CLI command is `sg` (short for "structural grep"). The full name `ast-grep` is used for installation and documentation.

## Pattern Syntax

| Syntax | Meaning | Example |
|--------|---------|---------|
| `$NAME` | Metavariable - matches single AST node | `function $NAME()` matches any function |
| `$$$` | Ellipsis - matches zero or more nodes | `console.log($$$)` matches any args |
| `$$X` | Named ellipsis - captures multiple nodes | `import { $$ITEMS } from "react"` |

## ast-grep vs ripgrep

| Aspect | ast-grep | ripgrep |
|--------|----------|---------|
| **Unit** | AST node | Line |
| **False positives** | Low | Depends on regex |
| **Rewrites** | First-class | Needs sed/awk |
| **Speed** | Fast | Fastest |

**Use ast-grep when:**
- Structure matters (ignores comments/strings)
- Refactoring/codemods needed
- Policy checks across repo

**Use ripgrep when:**
- Just searching text
- Recon (TODOs, logs, config values)
- Pre-filtering files

## Quick Examples

```bash
# Find structured code (ignores comments/strings)
sg -l TypeScript -p 'import $X from "$P"'

# Codemod (var to let) - applies changes with -U
sg -l JavaScript -p 'var $A = $B' -r 'let $A = $B' -U

# Combine rg speed + sg precision
rg -l -t ts 'useQuery\(' | xargs sg -l TypeScript -p 'useQuery($A)' -r 'useSuspenseQuery($A)' -U
```

## Common Use Cases

```bash
# Find all function declarations
# $NAME matches function name, $$$ matches any params and body
sg -p 'function $NAME($$$) { $$$ }'

# Find console.log statements (any number of arguments)
sg -p 'console.log($$$)'

# Find React components
sg -p 'function $NAME() { return $$$ }' -l jsx

# Find specific imports
sg -p 'import { $$$ } from "react"'
```

## Advanced Examples

```bash
# Interactive rewrite mode (review each change)
sg -p 'var $NAME = $VALUE' --rewrite 'const $NAME = $VALUE' --interactive

# Search Python code
sg -p 'def $NAME($$$): $$$' -l python

# Find with context lines
sg -p 'if ($COND) { $$$ }' -A 3 -B 3

# Complex refactoring pattern
sg -p 'setState({ $KEY: $VALUE })' --rewrite 'setState(prev => ({ ...prev, $KEY: $VALUE }))'
```

## Notes

- Only works with structured code (JS, TS, Python, Go, Rust)
- Does NOT work with Markdown or plain text
- Use `-l <language>` flag for snippets/stdin; auto-detected for files
- Install via `npm install -g @ast-grep/cli` (recommended) or `cargo install ast-grep`
