# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# Supported keys with their defaults, used by config list.
_CONFIG_KEYS=(dir lang notifications check_interval remind_interval)
declare -A _CONFIG_DEFAULTS=(
  [dir]="${HOME}/.dotfiles"
  [lang]="en"
  [notifications]="true"
  [check_interval]="86400"
  [remind_interval]="604800"
)

cmd_config::run() {
  if [[ $# -eq 0 ]]; then
    cmd_help::run_subcmd "config"
    return 0
  fi

  local verb="$1"
  shift

  case "$verb" in
    get) _cmd_config_get "$@" ;;
    set) _cmd_config_set "$@" ;;
    list) _cmd_config_list ;;
    edit) _cmd_config_edit ;;
    --help | -h)
      cmd_help::run_subcmd "config"
      return 0
      ;;
    *)
      # shellcheck disable=SC2059
      ui::error "$(printf "${MSG_CONFIG_UNKNOWN_VERB}" "$verb")"
      cmd_help::run_subcmd "config"
      exit 2
      ;;
  esac
}

_cmd_config_get() {
  if [[ $# -eq 0 ]]; then
    ui::error "${MSG_CONFIG_GET_USAGE}"
    exit 2
  fi
  local key="$1"
  local value
  value="$(config::get "$key")"
  if [[ -n "$value" ]]; then
    printf '%s\n' "$value"
  else
    # shellcheck disable=SC2059
    ui::info "$(printf "${MSG_CONFIG_KEY_UNSET}" "$key" "${_CONFIG_DEFAULTS[$key]:-}")"
  fi
}

_cmd_config_set() {
  if [[ $# -lt 2 ]]; then
    ui::error "${MSG_CONFIG_SET_USAGE}"
    exit 2
  fi
  local key="$1" value="$2"
  config::set "$key" "$value"
  # shellcheck disable=SC2059
  ui::ok "$(printf "${MSG_CONFIG_SET_OK}" "$key" "$value")"
}

_cmd_config_list() {
  local key value default
  printf '%s%-18s %-25s %s%s\n' \
    "$(theme::muted)" "KEY" "VALUE" "DEFAULT" "$(theme::reset)"
  for key in "${_CONFIG_KEYS[@]}"; do
    value="$(config::get "$key")"
    default="${_CONFIG_DEFAULTS[$key]:-}"
    if [[ -n "$value" ]]; then
      printf '%-18s %s%-25s%s %s%s%s\n' \
        "$key" \
        "$(theme::info)" "$value" "$(theme::reset)" \
        "$(theme::muted)" "$default" "$(theme::reset)"
    else
      printf '%-18s %s%-25s%s %s%s%s\n' \
        "$key" \
        "$(theme::muted)" "(unset)" "$(theme::reset)" \
        "$(theme::muted)" "$default" "$(theme::reset)"
    fi
  done
}

_cmd_config_edit() {
  local cf="${XDG_CONFIG_HOME:-${HOME}/.config}/dotlify/config"
  mkdir -p "$(dirname "$cf")"
  if [[ ! -f "$cf" ]]; then
    printf '# Dotlify configuration\n' >"$cf"
  fi
  if [[ -n "${EDITOR:-}" ]]; then
    # shellcheck disable=SC2086
    $EDITOR "$cf"
  else
    ui::error "${MSG_CONFIG_EDIT_NO_EDITOR}"
    exit 1
  fi
}
