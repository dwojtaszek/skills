# qsv - Ultra-fast CSV Toolkit

Blazingly fast CSV processing with 100+ specialized commands.

## When to Use

| Tool | Use Case |
|------|----------|
| **qsv** | Quick CSV ops, large files, ETL pipelines |
| **pandas** | Complex analysis, ML, multi-step workflows |
| **Excel** | Interactive exploration, visualizations |

## Quick Comparison

```bash
# qsv: Instant stats on huge file
qsv stats sales.csv  # Handles millions of rows

# qsv: SQL queries without database
qsv sql "SELECT product, SUM(revenue) FROM sales WHERE date > '2024-01-01' GROUP BY product" sales.csv

# qsv: Join two CSVs (fast)
qsv join user_id users.csv user_id orders.csv

# Combine with other tools
qsv select revenue,date sales.csv | qsv stats | jq '.'
```

## Common Use Cases

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

## Advanced Examples

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

# Sample random rows
qsv sample 100 data.csv

# Transpose rows/columns
qsv transpose data.csv
```

## Note

Optimized for large CSV files (millions of rows). Use `qsv --list` to see all 100+ commands.
