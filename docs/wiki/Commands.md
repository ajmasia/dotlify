# Commands

## Global options

| Flag | Short | Description |
|------|-------|-------------|
| `--dir <path>` | `-d` | Dotfiles repository path |
| `--profile <name>` | `-p` | Active profile |
| `--lang <lang>` | `-l` | UI language (`en` or `es`) |
| `--yes` | `-y` | Skip confirmation prompts |
| `--dry-run` | | Preview changes, write nothing |
| `--no-color` | | Disable coloured output |
| `--version` | | Print version and exit |
| `--help` | | Show usage and exit |

Global flags are accepted before or after the subcommand.

---

## dfy init

```
dfy init [--dir <path>] [--bare]
```

Initialise a new dotfiles git repository. Creates the directory, scaffolds starter packages (`bash-aliases`, `zsh-aliases`, `vim`), and writes `dir=<path>` to the config file.

`--bare` skips the scaffold and creates only the git repository.

---

## dfy apply

```
dfy apply <pkg...> [--profile <name>]
```

Link one or more packages into `$HOME` using stow. With `--profile`, links every package listed in the profile file.

Exits with code 3 when a target already exists as a real file — use `dfy adopt` to absorb it first.

---

## dfy unlink

```
dfy unlink <pkg...> [--profile <name>]
```

Remove the symlinks created by `dfy apply`. The files in the dotfiles repository are not affected.

---

## dfy adopt

```
dfy adopt <pkg> [--yes]
```

Move an existing `$HOME` file into the `<pkg>` package directory and replace it with a symlink. Prompts for confirmation unless `--yes` is given.

---

## dfy status

```
dfy status [--profile <name>]
```

Show the link status of all packages:

| Symbol | Meaning |
|--------|---------|
| `[+]` | Linked |
| `[-]` | Not linked |
| `[!]` | Conflict (real file in `$HOME`) |

---

## dfy list

```
dfy list
```

List all packages with their one-line description from the package `README.md`.

---

## dfy info

```
dfy info <pkg>
```

Display the `README.md` of a package. Opens in `$EDITOR` when set; falls back to `cat`.

---

## dfy create

```
dfy create <pkg> [-s <subdir>] [--yes]
```

Scaffold a new package directory with a README template. The `-s`/`--subdir` flag pre-creates a subdirectory inside the package (e.g. `-s .config/btop` creates `<pkg>/.config/btop/`).

---

## dfy doctor

```
dfy doctor
```

Check for broken symlinks pointing into the dotfiles repository and warn about stow versions that are too old.

---

## dfy update

```
dfy update
```

Pull the latest changes from the Dotlify clone and refresh shell completions.

---

## dfy config

```
dfy config get <key>
dfy config set <key> <value>
```

Read or write a key from `~/.config/dotlify/config`. See [Configuration](Configuration) for supported keys.

---

## dfy uninstall

```
dfy uninstall [--yes]
```

Remove the `dfy` symlink, shell completions, and man page. Optionally removes the clone directory and configuration.

---

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Generic error |
| 2 | Usage error (bad arguments, unknown subcommand) |
| 3 | Conflict (target file exists) |
| 4 | Missing runtime dependency |
