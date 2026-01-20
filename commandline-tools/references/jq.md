# jq - JSON Processor

Purpose-built for JSON transformation and queries.

## When to Use

| Tool | Use Case |
|------|----------|
| **jq** | JSON queries, transformations, API responses |
| **Python** | Complex logic, multi-format data |
| **grep/rg** | Just searching for text presence |

## Essential Flags

| Flag | Purpose | Example |
|------|---------|---------|
| `-r` | Raw output (no quotes) | `jq -r '.name'` → `John` instead of `"John"` |
| `-c` | Compact output (one line) | `jq -c '.'` |
| `-s` | Slurp (read all inputs as array) | `jq -s '.' file1.json file2.json` |
| `-e` | Exit non-zero if result is null/false | `jq -e '.key'` for scripting |

**Important:** Use `-r` when piping to other commands to avoid quoted strings.

## Quick Comparison

```bash
# jq: Extract nested field (clean, fast)
curl api.example.com/users | jq '.data[0].email'

# Python equivalent (more verbose)
curl api.example.com/users | python3 -c "import sys,json; print(json.load(sys.stdin)['data'][0]['email'])"

# jq: Filter and transform
cat users.json | jq '[.[] | select(.age > 25) | {name, email}]'

# Combine: Pre-filter with rg, then parse with jq
rg -l '"premium": true' *.json | xargs -I {} jq '.users[]' {}
```

## Common Use Cases

```bash
# Pretty print JSON
cat file.json | jq '.'

# Extract specific field (with quotes)
cat file.json | jq '.field'

# Extract for shell use (no quotes - use -r)
VERSION=$(cat package.json | jq -r '.version')

# Extract nested field
echo '{"user":{"name":"John"}}' | jq '.user.name'

# Array access
cat file.json | jq '.[0]'

# Multiple fields
cat file.json | jq '.name, .age'

# Handle missing keys (default value)
cat file.json | jq '.missing // "default"'
```

## Advanced Examples

```bash
# Sample input for examples below:
# [{"name": "Alice", "age": 30, "category": "A"},
#  {"name": "Bob", "age": 20, "category": "B"},
#  {"name": "Carol", "age": 35, "category": "A"}]

# Filter arrays
cat data.json | jq '.[] | select(.age > 25)'
# Output: {"name": "Alice", ...}, {"name": "Carol", ...}

# Map transformation
cat data.json | jq '.[] | {name, age}'
# Output: {"name": "Alice", "age": 30}, ...

# Collect into array
cat data.json | jq '[.[] | .name]'
# Output: ["Alice", "Bob", "Carol"]

# Group by field
cat data.json | jq 'group_by(.category)'
# Output: [[Alice, Carol], [Bob]]

# Sort array
cat data.json | jq 'sort_by(.age) | reverse'
# Output: Carol, Alice, Bob (by age descending)

# Count elements
cat data.json | jq '. | length'
# Output: 3

# Conditional logic
cat data.json | jq '.[] | if .age > 25 then .name else empty end'
# Output: "Alice", "Carol"

# Format as CSV (use -r for clean output)
cat data.json | jq -r '.[] | [.name, .age] | @csv'
# Output: "Alice",30
#         "Bob",20

# Merge objects
jq -s '.[0] * .[1]' file1.json file2.json
```

## Tips

- Use `-r` when output goes to shell variables or other commands
- Use `// "default"` to handle missing/null keys gracefully
- Use `-e` in scripts to detect null results
