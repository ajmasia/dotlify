#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  LIB_DIR="${BATS_TEST_DIRNAME}/../../lib"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/theme.sh"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/ui.sh"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/config.sh"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/notify.sh"

  # Redirect i18n strings manually (no full binary load needed)
  MSG_NOTIFY_UNCOMMITTED="Your dotfiles repo has uncommitted changes. Run: git -C %s status"
  MSG_NOTIFY_IDLE="You haven't used dfy in %d days. Run 'dfy help' to see what's available."

  # Isolated HOME and XDG so config and last_run don't touch real files
  export HOME
  HOME="$(mktemp -d)"
  export XDG_CONFIG_HOME="${HOME}/.config"
  unset DFY_DIR
}

teardown() {
  rm -rf "$HOME"
}

# Helper: create a fake git repo under $1 with optional dirty state
_make_dots_repo() {
  local dir="$1" dirty="${2:-0}"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" config user.email "test@test.com"
  git -C "$dir" config user.name "Test"
  touch "$dir/placeholder"
  git -C "$dir" add placeholder
  git -C "$dir" commit -q -m "init"
  if [[ "$dirty" == "1" ]]; then
    echo "change" >>"$dir/placeholder"
  fi
}

# Helper: write last_run timestamp
_write_last_run() {
  local ts="$1"
  mkdir -p "${XDG_CONFIG_HOME}/dotlify"
  printf '%s\n' "$ts" >"${XDG_CONFIG_HOME}/dotlify/last_run"
}

# ---------- toggle -------------------------------------------------------

@test "notify::check skips when notifications=false" {
  local dots
  dots="$(mktemp -d)"
  _make_dots_repo "$dots" 1
  export DFY_DIR="$dots"
  config::set notifications false

  run notify::check
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# ---------- first run -------------------------------------------------------

@test "no last_run file: file is created, no message printed" {
  local dots
  dots="$(mktemp -d)"
  _make_dots_repo "$dots" 0
  export DFY_DIR="$dots"

  run notify::check
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ -f "${XDG_CONFIG_HOME}/dotlify/last_run" ]
}

# ---------- delta < check_interval ------------------------------------------

@test "delta below check_interval: no message" {
  local dots
  dots="$(mktemp -d)"
  _make_dots_repo "$dots" 1
  export DFY_DIR="$dots"
  config::set check_interval 86400
  _write_last_run "$(date +%s)"  # now = delta ~0

  run notify::check
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# ---------- delta >= check_interval, clean repo -----------------------------

@test "delta above check_interval, clean repo: no message" {
  local dots
  dots="$(mktemp -d)"
  _make_dots_repo "$dots" 0
  export DFY_DIR="$dots"
  config::set check_interval 0
  config::set remind_interval 9999999999
  _write_last_run "0"

  run notify::check
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# ---------- delta >= check_interval, dirty repo -----------------------------

@test "delta above check_interval, dirty repo: uncommitted-changes warning" {
  local dots
  dots="$(mktemp -d)"
  _make_dots_repo "$dots" 1
  export DFY_DIR="$dots"
  config::set check_interval 0
  config::set remind_interval 9999999999
  _write_last_run "0"

  run notify::check
  [ "$status" -eq 0 ]
  [[ "$output" == *"uncommitted changes"* ]]
}

# ---------- delta >= remind_interval ----------------------------------------

@test "delta above remind_interval: idle reminder shown" {
  local dots
  dots="$(mktemp -d)"
  _make_dots_repo "$dots" 0
  export DFY_DIR="$dots"
  config::set check_interval 999999
  config::set remind_interval 0
  _write_last_run "0"

  run notify::check
  [ "$status" -eq 0 ]
  [[ "$output" == *"days"* ]]
}

# ---------- exit code -------------------------------------------------------

@test "warnings do not alter exit code" {
  local dots
  dots="$(mktemp -d)"
  _make_dots_repo "$dots" 1
  export DFY_DIR="$dots"
  config::set check_interval 0
  config::set remind_interval 9999999999
  _write_last_run "0"

  notify::check
  [ "$?" -eq 0 ]
}

# ---------- no DOTS_DIR -----------------------------------------------------

@test "notify::check is a no-op when DFY_DIR is unset and config has no dir" {
  unset DFY_DIR

  run notify::check
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
