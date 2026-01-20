# Other Tools Reference

## eza (Modern ls)

Modern `ls` replacement with colors and icons.

```bash
# Long format with icons
eza -l

# Tree view
eza --tree

# Sort by modification time
eza -l --sort=modified

# Show hidden files
eza -la

# Long format with git status
eza -l --git

# Tree with depth limit
eza --tree --level=2

# Only directories
eza -D

# Group directories first
eza --group-directories-first
```

---

## httpie (HTTP Client)

User-friendly HTTP client (better than curl for APIs).

```bash
# GET request
http GET https://api.example.com/users

# POST with JSON data
http POST https://api.example.com/users name=John age=30

# POST with headers
http POST https://api.example.com/data Authorization:"Bearer token"

# Authentication
http --auth user:pass GET https://api.example.com/protected

# Form data
http --form POST https://api.example.com/upload file@/path/to/file.jpg

# Save session
http --session=mysession POST https://api.example.com/login username=user password=pass

# Use saved session
http --session=mysession GET https://api.example.com/profile
```

---

## zoxide (Smart CD)

Smart `cd` that learns your directory patterns.

```bash
# Jump to directory matching "project"
z project

# Match multiple keywords
z doc downloads

# Query without jumping
zoxide query proj

# Interactive selection (with fzf)
zi

# List all tracked directories
zoxide query -l
```

**Post-Installation Setup:**
```bash
# Bash: Add to ~/.bashrc
eval "$(zoxide init bash)"

# Zsh: Add to ~/.zshrc
eval "$(zoxide init zsh)"

# Fish: Add to ~/.config/fish/config.fish
zoxide init fish | source
```

Note: Learns over time. Needs multiple visits before shortcuts work.

---

## git-delta (Better Git Diffs)

Syntax-highlighted git diffs with side-by-side view.

```bash
# View diff (after configuration)
git diff

# View commit
git show HEAD

# Compare branches
git diff main..feature

# Side-by-side diff
git diff --side-by-side
```

**Post-Installation Setup** - Add to `~/.gitconfig`:
```ini
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    light = false
    line-numbers = true
    side-by-side = true

[merge]
    conflictstyle = diff3

[diff]
    colorMoved = default
```

Note: Only enhances git output. Must configure git to use it as pager.
