#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0
}

teardown() {
  teardown_dirs
}

@test "list shows [i] and description for package with README" {
  make_package nvim .config/nvim/init.vim
  printf '# nvim\n\nNeovim configuration\n' >"${DFY_DIR}/nvim/README.md"
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"[i]"*"nvim"*"Neovim configuration"* ]]
}

@test "list shows [!] and (no readme) for package without README" {
  make_package zsh .zshrc
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"[!]"*"zsh"*"no readme"* ]]
}

@test "list shows no link status indicators" {
  make_package vim .vimrc
  stow -d "$DFY_DIR" -t "$HOME" vim
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" != *"[+]"* ]]
}

@test "list shows description in parentheses" {
  make_package tmux .tmux.conf
  printf '# tmux\n\nTerminal multiplexer\n' >"${DFY_DIR}/tmux/README.md"
  run "$DOTS_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"(Terminal multiplexer)"* ]]
}
