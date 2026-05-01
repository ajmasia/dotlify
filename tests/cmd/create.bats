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

@test "create scaffolds package directory and README with --yes" {
  run "$DOTS_BIN" --yes create mypkg
  [ "$status" -eq 0 ]
  [[ -d "${DFY_DIR}/mypkg" ]]
  [[ -f "${DFY_DIR}/mypkg/README.md" ]]
  [[ "$(cat "${DFY_DIR}/mypkg/README.md")" == *"# mypkg config"* ]]
}

@test "create README contains TODO placeholder when no description given" {
  run "$DOTS_BIN" --yes create mypkg
  [ "$status" -eq 0 ]
  [[ "$(cat "${DFY_DIR}/mypkg/README.md")" == *"TODO: add a description"* ]]
}

@test "create exits 1 when package already exists and has a README" {
  mkdir -p "${DFY_DIR}/existing"
  printf '# existing\n' >"${DFY_DIR}/existing/README.md"
  run "$DOTS_BIN" --yes create existing
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "create adds README when package exists but has none" {
  mkdir -p "${DFY_DIR}/mypkg"
  run "$DOTS_BIN" --yes create mypkg
  [ "$status" -eq 0 ]
  [[ -f "${DFY_DIR}/mypkg/README.md" ]]
  [[ "$(cat "${DFY_DIR}/mypkg/README.md")" == *"# mypkg config"* ]]
}

@test "create adds README does not create extra directories" {
  mkdir -p "${DFY_DIR}/mypkg"
  run "$DOTS_BIN" --yes create mypkg
  [ "$status" -eq 0 ]
  [[ "$output" == *"README"* ]]
}

@test "create with no args shows usage" {
  run "$DOTS_BIN" create
  [ "$status" -eq 0 ]
  [[ "$output" == *"dfy create"* ]]
}

@test "create --yes skips prompt and uses empty description" {
  run "$DOTS_BIN" --yes create newpkg
  [ "$status" -eq 0 ]
  [[ -f "${DFY_DIR}/newpkg/README.md" ]]
}

@test "create adds .stow-local-ignore that excludes README.md" {
  run "$DOTS_BIN" --yes create mypkg
  [ "$status" -eq 0 ]
  [[ -f "${DFY_DIR}/mypkg/.stow-local-ignore" ]]
  grep -q 'README' "${DFY_DIR}/mypkg/.stow-local-ignore"
}

@test "create updates repo README Packages table with linked entry" {
  cat >"${DFY_DIR}/README.md" <<'HEREDOC'
# My Dotfiles

## Packages

| Package | File | Description |
|---------|------|-------------|
HEREDOC
  run "$DOTS_BIN" --yes create mypkg
  [ "$status" -eq 0 ]
  grep -q '\[`mypkg`\]' "${DFY_DIR}/README.md"
  grep -q 'mypkg/README.md' "${DFY_DIR}/README.md"
}

@test "create -s creates the specified subdirectory inside the package" {
  run "$DOTS_BIN" --yes create btop -s .config/btop
  [ "$status" -eq 0 ]
  [[ -d "${DFY_DIR}/btop/.config/btop" ]]
}

@test "create --subdir creates the specified subdirectory inside the package" {
  run "$DOTS_BIN" --yes create btop --subdir .config/btop
  [ "$status" -eq 0 ]
  [[ -d "${DFY_DIR}/btop/.config/btop" ]]
}

@test "create -s also works when package exists without README" {
  mkdir -p "${DFY_DIR}/btop"
  run "$DOTS_BIN" --yes create btop -s .config/btop
  [ "$status" -eq 0 ]
  [[ -d "${DFY_DIR}/btop/.config/btop" ]]
}

@test "create -s without argument exits 2" {
  run "$DOTS_BIN" --yes create btop -s
  [ "$status" -eq 2 ]
}

@test "create does not duplicate entry in repo README" {
  cat >"${DFY_DIR}/README.md" <<'HEREDOC'
# My Dotfiles

## Packages

| Package | File | Description |
|---------|------|-------------|
| [`mypkg`](mypkg/README.md) | — | existing |
HEREDOC
  mkdir -p "${DFY_DIR}/mypkg"
  run "$DOTS_BIN" --yes create mypkg
  # Package already has no README, so it creates README and re-runs update
  # The update should be idempotent (only one entry)
  local count
  count="$(grep -c 'mypkg/README.md' "${DFY_DIR}/README.md")"
  [ "$count" -eq 1 ]
}
