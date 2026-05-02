# Installation

## Requirements

- Linux (kernel ≥ 4.x) or macOS (10.15+)
- Bash ≥ 4.0
- GNU Stow ≥ 2.3.1
- figlet

### macOS prerequisites

macOS ships with bash 3.2 and does not include Stow or figlet.
Install the required tools with [Homebrew](https://brew.sh):

```bash
brew install bash stow figlet
```

Ensure `/opt/homebrew/bin` (Apple Silicon) or `/usr/local/bin` (Intel) is in your `PATH` so the Homebrew bash is picked up.

## Nix

If you use Nix, Dotlify provides a flake. All runtime dependencies
(`bash` ≥ 4, `stow`, `figlet`) are bundled — nothing else to install.

### Install

```bash
nix profile install github:ajmasia/dotlify
```

### Upgrade

```bash
nix profile upgrade dotlify
```

### Remove

```bash
nix profile remove dotlify
```

### Home Manager

```nix
# flake.nix inputs
inputs.dotlify.url = "github:ajmasia/dotlify";

# home.nix
home.packages = [ inputs.dotlify.packages.${pkgs.system}.default ];
```

### nix run (no install)

```bash
nix run github:ajmasia/dotlify -- init
```

### Man page

The man page lands at `~/.nix-profile/share/man/man1/dfy.1`.
On non-NixOS systems, add it to `MANPATH`:

```bash
export MANPATH="$HOME/.nix-profile/share/man:$MANPATH"
```

---

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/ajmasia/dotlify/main/install.sh | bash
```

The script:
1. Clones Dotlify to `~/.local/share/dotlify`
2. Symlinks `dfy` into `~/.local/bin`
3. Installs shell completions (bash and zsh)
4. Installs the man page to `~/.local/share/man/man1/dfy.1`

## Manual install

```bash
git clone https://github.com/ajmasia/dotlify ~/.local/share/dotlify
bash ~/.local/share/dotlify/install.sh
```

The clone path must remain stable — `~/.local/bin/dfy` is a symlink into it.

## Post-install

Add `~/.local/bin` to your `PATH` if it isn't already:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Source the bash completion (add to `~/.bashrc`):

```bash
source ~/.local/share/bash-completion/completions/dfy
```

For zsh, add to `~/.zshrc` before `compinit`:

```bash
fpath=(~/.local/share/zsh/site-functions $fpath)
```

### macOS: man page

Add the user man directory to `MANPATH` if `man dfy` returns nothing:

```bash
export MANPATH="$HOME/.local/share/man:$MANPATH"
```

## Restoring on a new machine

If you already have a dotfiles repo in a remote, the setup on a new machine is:

```bash
# 1. Install Dotlify
curl -fsSL https://raw.githubusercontent.com/ajmasia/dotlify/main/install.sh | bash

# 2. Clone your existing dotfiles repo
git clone <your-remote-url> ~/.dotfiles

# 3. If the repo lives somewhere other than ~/.dotfiles, set the path
dfy config set dir ~/my-dots

# 4. Link your packages (or a profile if you use one)
dfy link git tmux vim bash-aliases
# or:
dfy link --profile home
```

No `dfy init` needed — that command is only for creating a new repo from scratch.

## Updating

```bash
dfy update
```

## Uninstalling

```bash
dfy uninstall
```
