# Dotlify Wiki

Dotlify (`dfy`) is a Bash framework on top of [GNU Stow](https://www.gnu.org/software/stow/) for managing dotfiles on Linux and macOS.

## Pages

- [Installation](Installation) — install and update Dotlify
- [Commands](Commands) — full subcommand reference
- [Configuration](Configuration) — config file and environment variables
- [Profiles](Profiles) — managing multiple dotfile sets
- [Examples](Examples) — example dotfiles repository layout and packages

## Quick start

**First time — new dotfiles repo:**

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/ajmasia/dotlify/main/install.sh | bash

# Bootstrap a dotfiles repository
dfy init

# Absorb an existing file into a package, then link it
dfy adopt vim
dfy link vim
```

**Existing repo — new machine:**

```bash
# Install Dotlify, then clone your repo
git clone <your-remote-url> ~/.dotfiles

# Link everything at once
dfy link --profile home
```

## License

GPL-3.0-or-later — see [LICENSE](https://github.com/ajmasia/dotlify/blob/main/LICENSE).
