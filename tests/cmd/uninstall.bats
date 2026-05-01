#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0

  # Fake clone dir so --yes does not delete the real repo.
  FAKE_CLONE="$BATS_TEST_TMPDIR/dotlify"
  mkdir -p "$FAKE_CLONE/.git"
  ln -s "$(cd "${BATS_TEST_DIRNAME}/../../lib" && pwd)" "$FAKE_CLONE/lib"
  ln -s "$(cd "${BATS_TEST_DIRNAME}/../../locales" && pwd)" "$FAKE_CLONE/locales"
  export DFY_LIB="$FAKE_CLONE/lib"

  # Pre-populate all files that uninstall removes unconditionally.
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share/bash-completion/completions"
  mkdir -p "$HOME/.local/share/zsh/site-functions"
  mkdir -p "$HOME/.local/share/man/man1"
  ln -s /dev/null "$HOME/.local/bin/dfy"
  touch "$HOME/.local/share/bash-completion/completions/dfy"
  touch "$HOME/.local/share/zsh/site-functions/_dfy"
  touch "$HOME/.local/share/man/man1/dfy.1"
}

teardown() {
  teardown_dirs
}

@test "uninstall --yes removes the dfy symlink" {
  run bash "$DOTS_BIN" --yes uninstall
  [ "$status" -eq 0 ]
  [[ ! -L "$HOME/.local/bin/dfy" ]]
}

@test "uninstall --yes removes bash and zsh completions" {
  run bash "$DOTS_BIN" --yes uninstall
  [ "$status" -eq 0 ]
  [[ ! -f "$HOME/.local/share/bash-completion/completions/dfy" ]]
  [[ ! -f "$HOME/.local/share/zsh/site-functions/_dfy" ]]
}

@test "uninstall --yes removes the man page" {
  run bash "$DOTS_BIN" --yes uninstall
  [ "$status" -eq 0 ]
  [[ ! -f "$HOME/.local/share/man/man1/dfy.1" ]]
}

@test "uninstall prompts for config dir and preserves it when user says no" {
  local config_dir="$HOME/.config/dotlify"
  mkdir -p "$config_dir"

  run bash -c "printf 'n\n' | bash '$DOTS_BIN' uninstall"
  [ "$status" -eq 0 ]
  [[ -d "$config_dir" ]]
}

@test "uninstall --yes is idempotent when files are already absent" {
  rm -f "$HOME/.local/bin/dfy"
  rm -f "$HOME/.local/share/bash-completion/completions/dfy"
  rm -f "$HOME/.local/share/zsh/site-functions/_dfy"
  rm -f "$HOME/.local/share/man/man1/dfy.1"

  run bash "$DOTS_BIN" --yes uninstall
  [ "$status" -eq 0 ]
}
