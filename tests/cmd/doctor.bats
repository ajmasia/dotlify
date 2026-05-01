#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0
  export GIT_AUTHOR_NAME="Test"
  export GIT_AUTHOR_EMAIL="test@test.com"
  export GIT_COMMITTER_NAME="Test"
  export GIT_COMMITTER_EMAIL="test@test.com"
}

teardown() {
  teardown_dirs
}

# Initialise DFY_DIR as a git repo with a local bare remote and an initial commit.
_setup_clean_git_repo() {
  local bare_dir
  bare_dir="$(mktemp -d)"
  git -C "$bare_dir" init -q --bare
  git -C "$DFY_DIR" init -q
  git -C "$DFY_DIR" remote add origin "$bare_dir"
  printf 'placeholder\n' >"${DFY_DIR}/.keep"
  git -C "$DFY_DIR" add -A
  git -C "$DFY_DIR" commit -q -m "init"
  git -C "$DFY_DIR" push -q -u origin HEAD
  printf '%s' "$bare_dir"
}

@test "doctor reports broken symlinks pointing into DFY_DIR" {
  make_package vim .vimrc
  stow -d "$DFY_DIR" -t "$HOME" vim
  # Break the symlink by removing the package file
  rm "${DFY_DIR}/vim/.vimrc"
  run "$DOTS_BIN" doctor
  [ "$status" -eq 0 ]
  [[ "$output" == *".vimrc"* ]]
}

@test "doctor warns when stow < 2.3.1" {
  local mock_dir
  mock_dir="$(mktemp -d)"
  cat >"${mock_dir}/stow" <<'MOCK'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then
  printf 'stow (GNU Stow) version 2.2.0\n'
  exit 0
fi
exec stow "$@"
MOCK
  chmod +x "${mock_dir}/stow"
  run env PATH="${mock_dir}:${PATH}" "$DOTS_BIN" doctor
  rm -rf "$mock_dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"2.2.0"* ]] || [[ "$output" == *"stow"* ]]
}

@test "doctor reports ok when everything is fine" {
  local bare_dir
  bare_dir="$(_setup_clean_git_repo)"
  run "$DOTS_BIN" doctor
  rm -rf "$bare_dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok"* ]] || [[ "$output" == *"good"* ]] || [[ "$output" == *"orden"* ]]
}

@test "doctor warns when dotfiles dir is not a git repo" {
  run "$DOTS_BIN" doctor
  [ "$status" -eq 0 ]
  [[ "$output" == *"git"* ]]
}

@test "doctor warns when dotfiles repo has uncommitted changes" {
  local bare_dir
  bare_dir="$(_setup_clean_git_repo)"
  printf 'dirty\n' >"${DFY_DIR}/untracked.txt"
  run "$DOTS_BIN" doctor
  rm -rf "$bare_dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"uncommitted"* ]] || [[ "$output" == *"commitear"* ]]
}

@test "doctor warns when dotfiles repo has no remote" {
  git -C "$DFY_DIR" init -q
  printf 'placeholder\n' >"${DFY_DIR}/.keep"
  git -C "$DFY_DIR" add -A
  git -C "$DFY_DIR" commit -q -m "init"
  run "$DOTS_BIN" doctor
  [ "$status" -eq 0 ]
  [[ "$output" == *"remote"* ]]
}

@test "doctor warns when dotfiles repo has unpushed commits" {
  local bare_dir
  bare_dir="$(_setup_clean_git_repo)"
  printf 'new\n' >"${DFY_DIR}/new.txt"
  git -C "$DFY_DIR" add -A
  git -C "$DFY_DIR" commit -q -m "unpushed"
  run "$DOTS_BIN" doctor
  rm -rf "$bare_dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"unpushed"* ]] || [[ "$output" == *"pushear"* ]]
}
