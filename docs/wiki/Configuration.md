# Configuration

Dotlify reads `~/.config/dotlify/config` (or `$XDG_CONFIG_HOME/dotlify/config`).
The format is plain `key=value` lines; lines starting with `#` and blank lines are ignored.

## Supported keys

| Key | Default | Description |
|-----|---------|-------------|
| `dir` | `~/.dotfiles` | Path to your dotfiles repository |
| `lang` | `en` | UI language: `en` or `es` |
| `notifications` | `true` | Enable passive git-status checks after each invocation |
| `check_interval` | `86400` | Seconds between git-status checks (24 h) |
| `remind_interval` | `604800` | Seconds before showing an idle reminder (7 days) |

## Example config

```ini
dir=/home/user/.dotfiles
lang=en
notifications=true
check_interval=43200
remind_interval=259200
```

## Environment variables

Environment variables take precedence over the config file.

| Variable | Description |
|----------|-------------|
| `DFY_DIR` | Path to the dotfiles repository |
| `DFY_PROFILE` | Active profile name |
| `DFY_LANG` | UI language (`en` or `es`) |
| `DFY_DRY_RUN` | Set to `1` to preview changes |
| `DFY_YES` | Set to `1` to skip confirmation prompts |
| `DFY_NO_COLOR` | Set to `1` to disable coloured output |
| `NO_COLOR` | Standard UNIX no-colour convention |

## Managing config from the CLI

```bash
dfy config get dir
dfy config set check_interval 43200
dfy config set notifications false
```

## Passive notifications

When `notifications=true` (the default), Dotlify checks the dotfiles repository for uncommitted changes after each invocation, but only when `check_interval` seconds have elapsed since the last check.

If `remind_interval` seconds have passed since the last invocation, an idle reminder is shown.

Both checks are non-blocking — they never alter the exit code of the command that was run.

To disable:

```bash
dfy config set notifications false
```
