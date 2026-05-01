#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  LIB_DIR="${BATS_TEST_DIRNAME}/../../lib"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/config.sh"

  export HOME
  HOME="$(mktemp -d)"
  export XDG_CONFIG_HOME="${HOME}/.config"
}

teardown() {
  rm -rf "$HOME"
}

# ---------- config::write_defaults ------------------------------------------

@test "write_defaults writes behavioural keys" {
  config::write_defaults
  local cf="${XDG_CONFIG_HOME}/dotlify/config"
  grep -q "^lang=" "$cf"
  grep -q "^notifications=" "$cf"
  grep -q "^check_interval=" "$cf"
  grep -q "^remind_interval=" "$cf"
}

@test "write_defaults does not write dir" {
  config::write_defaults
  local cf="${XDG_CONFIG_HOME}/dotlify/config"
  ! grep -q "^dir=" "$cf"
}

@test "write_defaults does not overwrite existing keys" {
  config::set dir /custom/path
  config::write_defaults
  local cf="${XDG_CONFIG_HOME}/dotlify/config"
  grep -q "^dir=/custom/path$" "$cf"
}

@test "write_defaults is idempotent" {
  config::write_defaults
  config::write_defaults
  local cf="${XDG_CONFIG_HOME}/dotlify/config"
  local count
  count="$(grep -c "^lang=" "$cf")"
  [ "$count" -eq 1 ]
}

# ---------- config::get / config::set round-trip ----------------------------

@test "config::get returns value after config::set" {
  config::set interval 300
  local val
  val="$(config::get interval)"
  [ "$val" = "300" ]
}

@test "config::get returns empty when key is absent" {
  local val
  val="$(config::get nonexistent)"
  [ -z "$val" ]
}

@test "config::set updates existing key" {
  config::set lang en
  config::set lang es
  local val
  val="$(config::get lang)"
  [ "$val" = "es" ]
  local count
  count="$(grep -c "^lang=" "${XDG_CONFIG_HOME}/dotlify/config")"
  [ "$count" -eq 1 ]
}
