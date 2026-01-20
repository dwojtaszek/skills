# Installation Reference

## Quick Check

Before installing, check if already available:

```bash
# Unix-like (macOS/Linux)
which fd rg jq fzf bat 2>/dev/null

# Windows PowerShell
Get-Command fd, rg, jq, fzf, bat -ErrorAction SilentlyContinue
```

## macOS (Homebrew)

```bash
brew install fd ripgrep ast-grep jq qsv fzf bat eza zoxide httpie git-delta
```

**Verify:** `fd --version && rg --version && sg --version`

## Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install -y fd-find ripgrep jq fzf bat zoxide httpie git-delta

# ast-grep via npm (requires Node.js)
npm install -g @ast-grep/cli
```

**Ubuntu naming conflicts** - create aliases:
```bash
echo 'alias fd=fdfind' >> ~/.bashrc
echo 'alias bat=batcat' >> ~/.bashrc
source ~/.bashrc
```

Or create symlinks:
```bash
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd
ln -s /usr/bin/batcat ~/.local/bin/bat
# Ensure ~/.local/bin is in PATH
```

**eza and qsv:**
- eza: Ubuntu 24.04+ has it in repos; older versions use cargo
- qsv: Download from [GitHub releases](https://github.com/jqnatividad/qsv/releases) or use cargo

**Verify:** `fd --version && rg --version && sg --version`

## Windows (scoop)

```powershell
scoop install fd ripgrep ast-grep jq fzf bat eza zoxide httpie delta
```

**Verify:** `fd --version; rg --version; sg --version`

## Universal (Cargo)

Works on all platforms. Requires [Rust toolchain](https://rustup.rs/).

**Warning:** Compiles from source - may take 5-10+ minutes, especially for qsv.

```bash
# Core tools (faster)
cargo install fd-find ripgrep bat eza zoxide git-delta --locked

# qsv (slower - many features)
cargo install qsv --locked --bin qsv -F all_features
```

**ast-grep:** Prefer `npm install -g @ast-grep/cli` over cargo for the CLI binary.

## Post-Install Setup

Some tools require additional configuration:

| Tool | Setup Required |
|------|----------------|
| **zoxide** | Add `eval "$(zoxide init bash)"` to ~/.bashrc (or zsh/fish equivalent) |
| **git-delta** | Add pager config to ~/.gitconfig (see [other-tools.md](other-tools.md)) |
| **fzf** | Optional: Add shell keybindings (see [fzf.md](fzf.md)) |

## Tool Not in PATH

```bash
# Unix: Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
```

**Windows:** Restart PowerShell/Terminal to refresh PATH.
