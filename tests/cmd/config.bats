#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  export XDG_CONFIG_HOME="${HOME}/.config"
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0
  unset EDITOR
}

teardown() {
  teardown_dirs
}

# ---------- usage -----------------------------------------------------------

@test "config with no args shows usage" {
  run "$DOTS_BIN" config
  [ "$status" -eq 0 ]
  [[ "$output" == *"dfy config"* ]]
}

@test "config with unknown verb exits 2" {
  run "$DOTS_BIN" config foo
  [ "$status" -eq 2 ]
}

# ---------- get -------------------------------------------------------------

@test "config get returns value when key is set" {
  local cf="${HOME}/.config/dotlify/config"
  mkdir -p "$(dirname "$cf")"
  printf 'dir=/my/dots\n' >"$cf"
  run "$DOTS_BIN" config get dir
  [ "$status" -eq 0 ]
  [ "$output" = "/my/dots" ]
}

@test "config get shows unset message when key is absent" {
  run "$DOTS_BIN" config get dir
  [ "$status" -eq 0 ]
  [[ "$output" == *"not set"* ]] || [[ "$output" == *"unset"* ]] || [[ "$output" == *"dir"* ]]
}

@test "config get with no key exits 2" {
  run "$DOTS_BIN" config get
  [ "$status" -eq 2 ]
}

# ---------- set -------------------------------------------------------------

@test "config set writes key to config file" {
  run "$DOTS_BIN" config set dir /home/user/dots
  [ "$status" -eq 0 ]
  local cf="${HOME}/.config/dotlify/config"
  grep -q 'dir=/home/user/dots' "$cf"
}

@test "config set updates existing key" {
  local cf="${HOME}/.config/dotlify/config"
  mkdir -p "$(dirname "$cf")"
  printf 'dir=/old/path\n' >"$cf"
  run "$DOTS_BIN" config set dir /new/path
  [ "$status" -eq 0 ]
  grep -q 'dir=/new/path' "$cf"
  ! grep -q 'dir=/old/path' "$cf"
}

@test "config set with missing value exits 2" {
  run "$DOTS_BIN" config set dir
  [ "$status" -eq 2 ]
}

# ---------- list ------------------------------------------------------------

@test "config list shows all supported keys" {
  run "$DOTS_BIN" config list
  [ "$status" -eq 0 ]
  [[ "$output" == *"dir"* ]]
  [[ "$output" == *"lang"* ]]
  [[ "$output" == *"notifications"* ]]
  [[ "$output" == *"check_interval"* ]]
  [[ "$output" == *"remind_interval"* ]]
}

@test "config list shows set value for configured key" {
  local cf="${HOME}/.config/dotlify/config"
  mkdir -p "$(dirname "$cf")"
  printf 'notifications=false\n' >"$cf"
  run "$DOTS_BIN" config list
  [ "$status" -eq 0 ]
  [[ "$output" == *"false"* ]]
}

# ---------- edit ------------------------------------------------------------

@test "config edit opens EDITOR on config file" {
  local record="${HOME}/editor_called"
  local fake_editor="${HOME}/fake_editor.sh"
  printf '#!/usr/bin/env bash\ntouch "%s"\n' "$record" >"$fake_editor"
  chmod +x "$fake_editor"
  export EDITOR="$fake_editor"
  run "$DOTS_BIN" config edit
  [ "$status" -eq 0 ]
  [ -f "$record" ]
}

@test "config edit creates config file if absent" {
  local fake_editor="${HOME}/fake_editor.sh"
  printf '#!/usr/bin/env bash\n' >"$fake_editor"
  chmod +x "$fake_editor"
  export EDITOR="$fake_editor"
  run "$DOTS_BIN" config edit
  [ "$status" -eq 0 ]
  [ -f "${HOME}/.config/dotlify/config" ]
}

@test "config edit exits 1 when EDITOR is unset" {
  unset EDITOR
  run "$DOTS_BIN" config edit
  [ "$status" -eq 1 ]
}
