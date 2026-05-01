# Profiles

A profile is a plain-text file that lists one package name per line.
It lets you define named sets of packages and apply them in one command.

## File location

Profiles live under `<dotfiles-repo>/profiles/`, one file per profile:

```
~/.dotfiles/
└── profiles/
    ├── home.txt
    ├── work.txt
    └── minimal.txt
```

## Format

```
# home profile
bash-aliases
vim
tmux
git
```

Lines starting with `#` and blank lines are ignored.
Surrounding whitespace is stripped from package names.

## Using profiles

Apply all packages in a profile:

```bash
dfy apply --profile home
```

Unlink all packages in a profile:

```bash
dfy unlink --profile work
```

Preview what a profile would do:

```bash
dfy --dry-run apply --profile minimal
```

## Checking status with a profile

```bash
dfy status --profile home
```

This filters the status output to only show packages listed in the profile.

## Per-machine profiles

A common pattern is one profile per machine:

```
profiles/
├── laptop.txt
├── desktop.txt
└── server.txt
```

Then apply the right profile at bootstrap time:

```bash
dfy apply --profile laptop
```
