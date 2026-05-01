#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later

setup() {
  # shellcheck source=tests/test_helper.bash
  source "${BATS_TEST_DIRNAME}/../../tests/test_helper.bash"
  setup_home
  setup_dots_dir
  DOTS_BIN="${BATS_TEST_DIRNAME}/../../bin/dfy"
  export THEME_COLORS_ENABLED=0

  # Fake clone dir: lib/ symlinked to real lib so the binary can source it;
  # completions/ copied so cmd_update can refresh them.
  FAKE_CLONE="$BATS_TEST_TMPDIR/dotlify"
  mkdir -p "$FAKE_CLONE/.git" "$FAKE_CLONE/completions"
  ln -s "$(cd "${BATS_TEST_DIRNAME}/../../lib" && pwd)" "$FAKE_CLONE/lib"
  ln -s "$(cd "${BATS_TEST_DIRNAME}/../../locales" && pwd)" "$FAKE_CLONE/locales"
  cp "${BATS_TEST_DIRNAME}/../../completions/dfy.bash" "$FAKE_CLONE/completions/"
  cp "${BATS_TEST_DIRNAME}/../../completions/_dfy" "$FAKE_CLONE/completions/"
  export DFY_LIB="$FAKE_CLONE/lib"

  # Fake git: logs all args, exits 0 by default.
  GIT_CALL_LOG="$BATS_TEST_TMPDIR/git_calls"
  export GIT_CALL_LOG
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat >"$BATS_TEST_TMPDIR/bin/git" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" >>"$GIT_CALL_LOG"
EOF
  chmod +x "$BATS_TEST_TMPDIR/bin/git"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

teardown() {
  teardown_dirs
}

@test "update calls git pull in clone dir" {
  run bash "$DOTS_BIN" update
  [ "$status" -eq 0 ]
  grep -q "pull" "$GIT_CALL_LOG"
  grep -q "\-C" "$GIT_CALL_LOG"
}

@test "update refreshes bash completion when already installed" {
  local bash_comp="$HOME/.local/share/bash-completion/completions/dfy"
  mkdir -p "$(dirname "$bash_comp")"
  printf 'old-content\n' >"$bash_comp"

  run bash "$DOTS_BIN" update
  [ "$status" -eq 0 ]
  [[ "$(cat "$bash_comp")" != "old-content" ]]
}

@test "update exits 1 with message when clone dir has no .git" {
  rm -rf "$FAKE_CLONE/.git"
  run bash "$DOTS_BIN" update
  [ "$status" -eq 1 ]
  [[ "$output" == *"git"* ]]
}
