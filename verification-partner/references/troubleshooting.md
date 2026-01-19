# Troubleshooting

## Check Tool Status

```bash
~/.claude/skills/verification-partner/scripts/verify.py --check-status
```

Shows:
- Tool installation status
- Connection/authentication status
- Specific error messages

## Common Issues

### Cursor Not Connected

```bash
# Check status
cursor agent status

# If not authenticated
cursor login
```

### Copilot Auth Issues

```bash
# Check GitHub CLI authentication
gh auth status

# Re-authenticate if needed
gh auth login
```

### Timeout Errors

- Internal timeout: 3 minutes (180s)
- **Bash tool timeout MUST be 240000ms (4 min)**
- Use `--fast` for quicker results

### No Tools Available

Install at least one:
- Cursor CLI: https://cursor.sh
- GitHub Copilot CLI: `npm install -g @githubnext/github-copilot-cli`
- GitHub CLI (for Copilot): `brew install gh`

## Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| "cursor command not found" | Cursor not installed | Install Cursor CLI |
| "copilot command not found" | Copilot not installed | Install Copilot CLI |
| "Timeout (180s)" | Response took too long | Use `--fast` mode |
| "Not connected" | Auth expired | Re-login to tool |
