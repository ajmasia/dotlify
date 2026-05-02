# Dotfiles Repository Examples

This page shows how to structure a dotfiles repository that works with Dotlify.

## Minimal layout

A dotfiles repository is a regular git repository where each top-level directory is a **package**. Each package mirrors the file paths relative to `$HOME`.

```
~/.dotfiles/
├── git/
│   └── .gitconfig
├── tmux/
│   └── .tmux.conf
├── vim/
│   └── .vimrc
├── bash-aliases/
│   └── .bash_aliases
├── alacritty/
│   └── .config/
│       └── alacritty/
│           └── alacritty.toml
└── profiles/
    ├── home.txt
    └── work.txt
```

The `profiles/` directory is reserved — it is not treated as a package.
Hidden directories (`.git`, `.config`, etc.) are also excluded from package listings.

## Example packages

### git

`git/.gitconfig`:

```ini
[core]
    autocrlf = input
    editor = vim

[alias]
    st = status
    co = checkout
    br = branch
    lg = log --oneline --graph --decorate
```

Apply with:

```bash
dfy link git
```

This creates `~/.gitconfig` as a symlink to `~/.dotfiles/git/.gitconfig`.

---

### tmux

`tmux/.tmux.conf`:

```bash
set -g prefix C-a
unbind C-b
bind C-a send-prefix

set -g mouse on
set -g history-limit 10000
set -g base-index 1
setw -g pane-base-index 1

bind | split-window -h
bind - split-window -v
```

Apply with:

```bash
dfy link tmux
```

---

### XDG config directory (`~/.config/`)

Files under `~/.config/` work the same way — mirror the full path inside the package. GNU Stow resolves symlinks relative to `$HOME`, so the nesting just needs to match.

**Example: Alacritty terminal**

`alacritty/.config/alacritty/alacritty.toml`:

```toml
[window]
opacity = 0.95
padding = { x = 12, y = 10 }

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
size = 13.0

[colors.primary]
background = "#1e1e2e"
foreground = "#cdd6f4"

[colors.normal]
black   = "#45475a"
red     = "#f38ba8"
green   = "#a6e3a1"
yellow  = "#f9e2af"
blue    = "#89b4fa"
magenta = "#cba6f7"
cyan    = "#89dceb"
white   = "#bac2de"
```

Package structure:

```
alacritty/
└── .config/
    └── alacritty/
        └── alacritty.toml
```

Scaffold the package with the subdirectory in one step:

```bash
dfy create alacritty -s .config/alacritty
```

Then either adopt the existing files from `$HOME`:

```bash
dfy adopt alacritty
```

Or place the file manually and apply:

```bash
dfy link alacritty
# → creates ~/.config/alacritty/alacritty.toml → ~/.dotfiles/alacritty/.config/alacritty/alacritty.toml
```

The same pattern applies to any XDG tool: `starship`, `btop`, `nvim`, `kitty`, `hyprland`, etc.

## Example profiles

`profiles/home.txt`:

```
git
tmux
vim
bash-aliases
```

`profiles/work.txt`:

```
git
tmux
vim
```

Apply a profile:

```bash
dfy link --profile home
```

## Starting from scratch

```bash
# 1. Install Dotlify and initialise a new dotfiles repo
curl -fsSL https://raw.githubusercontent.com/ajmasia/dotlify/main/install.sh | bash
dfy init

# 2. Adopt existing config files from $HOME into packages
dfy adopt git
dfy adopt tmux

# 3. Create packages for files you want to track from scratch
dfy create vim
dfy create bash-aliases

# 4. Link everything via a profile
dfy link --profile home

# 5. Push to a remote for safekeeping
cd ~/.dotfiles
git remote add origin <your-remote-url>
git push -u origin main
```

## Restoring on a new machine

When Dotlify is already installed and your dotfiles live in a remote repo:

```bash
# 1. Install Dotlify
curl -fsSL https://raw.githubusercontent.com/ajmasia/dotlify/main/install.sh | bash

# 2. Clone your existing dotfiles repo
git clone <your-remote-url> ~/.dotfiles

# 3. If your repo is not at ~/.dotfiles, tell Dotlify where it is
dfy config set dir ~/my-dots

# 4. Link all packages at once via a profile
dfy link --profile home

# 5. Verify
dfy status --profile home
```

See [Profiles](Profiles) for more on managing multiple machines or environments.
