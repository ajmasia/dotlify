# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

_notify_last_run_file() {
  printf '%s' "${XDG_CONFIG_HOME:-${HOME}/.config}/dotlify/last_run"
}

_notify_now() {
  printf '%s' "$(date +%s)"
}

# Non-blocking post-invocation check. Prints warnings when:
#   - the dotfiles repo has uncommitted changes (checked every check_interval seconds)
#   - dfy has not been used in remind_interval seconds
# Silenced entirely when notifications=false in config, or when no dotfiles dir is set.
notify::check() {
  local enabled
  enabled="$(config::get notifications)"
  enabled="${enabled:-true}"
  if [[ "$enabled" == "false" ]]; then
    return 0
  fi

  local dots_dir="${DFY_DIR:-}"
  if [[ -z "$dots_dir" ]]; then
    dots_dir="$(config::get dir)"
  fi
  if [[ -z "$dots_dir" || ! -d "$dots_dir" ]]; then
    return 0
  fi

  local now
  now="$(_notify_now)"

  local last_run_file
  last_run_file="$(_notify_last_run_file)"

  mkdir -p "$(dirname "$last_run_file")"

  if [[ ! -f "$last_run_file" ]]; then
    printf '%s\n' "$now" >"$last_run_file"
    return 0
  fi

  local last_run
  last_run="$(cat "$last_run_file")"
  local delta=$((now - last_run))

  local check_interval
  check_interval="$(config::get check_interval)"
  check_interval="${check_interval:-86400}"

  local remind_interval
  remind_interval="$(config::get remind_interval)"
  remind_interval="${remind_interval:-604800}"

  if ((delta >= check_interval)); then
    local git_status
    git_status="$(git -C "$dots_dir" status --porcelain 2>/dev/null || true)"
    if [[ -n "$git_status" ]]; then
      printf '\n'
      # shellcheck disable=SC2059
      ui::warn "$(printf "${MSG_NOTIFY_UNCOMMITTED}" "$dots_dir")"
    fi
  fi

  if ((delta >= remind_interval)); then
    local days=$((delta / 86400))
    printf '\n'
    # shellcheck disable=SC2059
    ui::info "$(printf "${MSG_NOTIFY_IDLE}" "$days")"
  fi

  printf '%s\n' "$now" >"$last_run_file"
}
