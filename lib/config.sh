# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

_config_file() {
  printf '%s' "${XDG_CONFIG_HOME:-${HOME}/.config}/dotlify/config"
}

# Print the value of <key> from the config file, or empty if absent.
config::get() {
  local key="$1"
  local cf
  cf="$(_config_file)"
  [[ -f "$cf" ]] || return 0
  local line
  line="$(grep -m1 "^${key}=" "$cf" 2>/dev/null || true)"
  if [[ -n "$line" ]]; then
    printf '%s' "${line#"${key}="}"
  fi
}

# Write default values for all known keys that are not already set.
# dir is written with the resolved $HOME path so no literal ~ appears.
config::write_defaults() {
  local -A defaults=(
    [dir]="${HOME}/.dotfiles"
    [lang]="en"
    [notifications]="true"
    [check_interval]="86400"
    [remind_interval]="604800"
  )
  local key
  for key in dir lang notifications check_interval remind_interval; do
    local current
    current="$(config::get "$key")"
    if [[ -z "$current" ]]; then
      config::set "$key" "${defaults[$key]}"
    fi
  done
}

# Set <key>=<value> in the config file, creating it if necessary.
config::set() {
  local key="$1" value="$2"
  local cf
  cf="$(_config_file)"
  local cf_dir
  cf_dir="$(dirname "$cf")"
  mkdir -p "$cf_dir"

  if [[ ! -f "$cf" ]]; then
    printf '%s=%s\n' "$key" "$value" >"$cf"
    return
  fi

  if grep -q "^${key}=" "$cf" 2>/dev/null; then
    local tmp
    tmp="$(mktemp)"
    grep -v "^${key}=" "$cf" >"$tmp" || true
    printf '%s=%s\n' "$key" "$value" >>"$tmp"
    mv "$tmp" "$cf"
  else
    printf '%s=%s\n' "$key" "$value" >>"$cf"
  fi
}
