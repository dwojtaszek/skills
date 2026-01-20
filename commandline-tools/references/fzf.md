# fzf - Fuzzy Finder

Interactive fuzzy finder - turns any list into an interactive picker.

## When to Use

| Tool | Use Case |
|------|----------|
| **fzf** | Interactive selection from any list |
| **grep/rg** | Non-interactive pattern search |
| **Ctrl+R** | Quick single command lookup |

## Quick Comparison

```bash
# fzf: Interactive file selection with preview
fd -t f | fzf --preview 'bat --color=always {}'

# fzf: Better command history search
history | fzf

# fzf: Pick git branch to checkout
git branch | fzf | xargs git checkout

# fzf: Kill process interactively
ps aux | fzf | awk '{print $2}' | xargs kill

# Combine tools: find files, fuzzy select, open in editor
fd -e py | fzf -m --preview 'bat {}' | xargs code
```

## Common Use Cases

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

## Advanced Examples

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

## Shell Integration (Recommended)

```bash
# Add to ~/.bashrc or ~/.zshrc
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d'

# Ctrl+T: Fuzzy file finder
# Ctrl+R: Fuzzy history search
# Alt+C: Fuzzy directory changer
```

## Ubuntu Note

With bat, use `fzf --preview 'batcat {}'`
