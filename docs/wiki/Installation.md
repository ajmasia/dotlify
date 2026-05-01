# Installation

## Requirements

- Linux (kernel ≥ 4.x)
- Bash ≥ 4.0
- GNU Stow ≥ 2.3.1
- figlet

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

## Updating

```bash
dfy update
```

## Uninstalling

```bash
dfy uninstall
```
