# SPDX-License-Identifier: GPL-3.0-or-later

# Error messages
MSG_BASH_TOO_OLD="dots requires bash >= 4 (found: %s). Please upgrade."
MSG_UNKNOWN_FLAG="Unknown flag: %s"
MSG_UNKNOWN_SUBCMD="Unknown subcommand: '%s'"
MSG_SUGGEST_SUBCMD="  Did you mean: %s"
MSG_USAGE_HINT="Run 'dots --help' for usage."
MSG_NOT_IMPLEMENTED="%s: not implemented yet."

# Help — structural labels
MSG_HELP_USAGE="Usage: dots [options] <subcommand> [args]"
MSG_HELP_SUBCMDS_HEADER="Subcommands:"
MSG_HELP_OPTS_HEADER="Global options:"
MSG_VERSION_LINE="v%s (GPL-3.0-or-later)"

# Subcommand one-liners
MSG_SUBCMD_INSTALL="Stow packages from your dotfiles repo"
MSG_SUBCMD_REMOVE="Unstow packages"
MSG_SUBCMD_ADOPT="Adopt an existing file into a package"
MSG_SUBCMD_LIST="List available packages"
MSG_SUBCMD_STATUS="Show stow status"
MSG_SUBCMD_DOCTOR="Check system health"
MSG_SUBCMD_HELP="Show this help message"

# Option descriptions
MSG_OPT_HELP="Show this help message"
MSG_OPT_VERSION="Show version"
MSG_OPT_NO_COLOR="Disable color output"
MSG_OPT_DRY_RUN="Simulate without applying changes"
MSG_OPT_PROFILE="Use named profile"
MSG_OPT_DIR="Dotfiles directory (default: ~/dotfiles)"
MSG_OPT_YES="Auto-confirm prompts"
MSG_OPT_LANG="Override language (en, es)"

# Per-subcommand usage lines
MSG_HELP_INSTALL="Usage: dots install [packages...]"
MSG_HELP_REMOVE="Usage: dots remove [packages...]"
MSG_HELP_ADOPT="Usage: dots adopt <file> <package>"
MSG_HELP_LIST="Usage: dots list"
MSG_HELP_STATUS="Usage: dots status"
MSG_HELP_DOCTOR="Usage: dots doctor"
