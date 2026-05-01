# Dotlify Wiki

Dotlify (`dfy`) is a Bash framework on top of [GNU Stow](https://www.gnu.org/software/stow/) for managing dotfiles on Linux.

## Pages

- [Installation](Installation) — install and update Dotlify
- [Commands](Commands) — full subcommand reference
- [Configuration](Configuration) — config file and environment variables
- [Profiles](Profiles) — managing multiple dotfile sets
- [Examples](Examples) — example dotfiles repository layout and packages

## Quick start

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/ajmasia/dotlify/main/install.sh | bash

# Bootstrap a dotfiles repository
dfy init

# Link a package into $HOME
dfy apply vim

# Absorb an existing file into a package
dfy adopt vim ~/.vimrc
```

## License

GPL-3.0-or-later — see [LICENSE](https://github.com/ajmasia/dotlify/blob/main/LICENSE).
