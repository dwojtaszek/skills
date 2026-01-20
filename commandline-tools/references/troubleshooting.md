# Troubleshooting

## Package Manager Not Found

**Homebrew (macOS):**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Scoop (Windows):**
```powershell
irm get.scoop.sh | iex
```

**apt (Linux):** For non-Debian systems, use Cargo as universal fallback.

## Ubuntu Naming Conflicts

`fd` is installed as `fdfind` and `bat` as `batcat`.

**Solutions:**
```bash
# Option 1: Aliases in ~/.bashrc
alias fd=fdfind
alias bat=batcat

# Option 2: Symlinks
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd
ln -s /usr/bin/batcat ~/.local/bin/bat

# Option 3: Use full names
fdfind -e js
batcat file.js
```

## Tool Not in PATH

**Unix-like:**
```bash
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
```

**Windows:** Restart PowerShell/Terminal to refresh PATH.

## Common Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| "command not found" | Not installed or not in PATH | Install tool or add to PATH |
| "permission denied" | Script not executable | `chmod +x script` |
| "No such file or directory" | Wrong path | Check file path |

## Tool-Specific Notes

- **ripgrep:** Respects `.gitignore` by default. Use `--no-ignore` to search all files.
- **ast-grep:** Only works with structured code (JS, TS, Python, Go, Rust). NOT Markdown.
- **fzf:** Interactive tool. Use `--filter` for non-interactive mode.
- **bat:** On Ubuntu, installed as `batcat`. Use alias or symlink.
- **qsv:** Has 100+ commands. Use `qsv --list` to see all.
- **zoxide:** Learns over time. Needs multiple visits before shortcuts work. Requires shell init.
- **git-delta:** Only enhances git output. Must configure git to use it as pager.
- **fd:** On Ubuntu, installed as `fdfind`. Create alias for convenience.
- **eza:** Ubuntu 24.04+ has it in repos. Older versions need cargo.
