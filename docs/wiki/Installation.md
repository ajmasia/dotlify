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

## Updating

```bash
dfy update
```

## Uninstalling

```bash
dfy uninstall
```
