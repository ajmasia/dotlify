# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_doctor::run() {
  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  local issues=0

  # bash version
  if ((BASH_VERSINFO[0] < 4)); then
    # shellcheck disable=SC2059
    ui::warn "$(printf "${MSG_DOCTOR_BASH_OLD:-bash < 4.0 detected (found: %s)}" \
      "$(printf '%s%s%s' "$(theme::warning)" "${BASH_VERSION}" "$(theme::reset)")")"
    issues=$((issues + 1))
  fi

  # stow presence and version
  if ! command -v stow >/dev/null 2>&1; then
    ui::error "${MSG_DOCTOR_STOW_MISSING}"
    issues=$((issues + 1))
  else
    local stow_ver
    stow_ver="$(stow --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
    if [[ -n "$stow_ver" ]]; then
      local major minor patch
      IFS='.' read -r major minor patch <<<"$stow_ver"
      if ((major < 2)) \
        || ((major == 2 && minor < 3)) \
        || ((major == 2 && minor == 3 && patch < 1)); then
        # shellcheck disable=SC2059
        ui::warn "$(printf "${MSG_DOCTOR_STOW_OLD:-stow < 2.3.1 detected (found: %s)}" \
          "$(printf '%s%s%s' "$(theme::warning)" "$stow_ver" "$(theme::reset)")")"
        issues=$((issues + 1))
      fi
    fi
  fi

  # Git repository health checks.
  if ! git -C "$dots_dir" rev-parse --is-inside-work-tree &>/dev/null; then
    ui::warn "${MSG_DOCTOR_NOT_GIT:-Dotfiles directory is not a git repository.}"
    issues=$((issues + 1))
  else
    if [[ -n "$(git -C "$dots_dir" status --porcelain 2>/dev/null)" ]]; then
      ui::warn "${MSG_DOCTOR_UNCOMMITTED:-Dotfiles repo has uncommitted changes.}"
      issues=$((issues + 1))
    fi
    if [[ -z "$(git -C "$dots_dir" remote 2>/dev/null)" ]]; then
      ui::warn "${MSG_DOCTOR_NO_REMOTE:-Dotfiles repo has no remote configured (no offsite backup).}"
      issues=$((issues + 1))
    else
      local ahead
      ahead="$(git -C "$dots_dir" rev-list '@{u}..HEAD' 2>/dev/null | wc -l | tr -d ' ')" || ahead=""
      if [[ -n "$ahead" && "$ahead" -gt 0 ]]; then
        # shellcheck disable=SC2059
        ui::warn "$(printf "${MSG_DOCTOR_UNPUSHED:-Dotfiles repo has %s unpushed commit(s).}" \
          "$(printf '%s%s%s' "$(theme::warning)" "$ahead" "$(theme::reset)")")"
        issues=$((issues + 1))
      fi
    fi
  fi

  # Broken symlinks under $HOME pointing into $DFY_DIR.
  # os::readlink_f resolves the canonical target even for broken links (all
  # but the last path component must exist, which holds for stow-managed files).
  local link link_target
  while IFS= read -r -d '' link; do
    link_target="$(os::readlink_f "$link" 2>/dev/null || true)"
    if [[ -n "$link_target" && "$link_target" == "${dots_dir}"* && ! -e "$link" ]]; then
      # shellcheck disable=SC2059
      ui::warn "$(printf "${MSG_DOCTOR_BROKEN_LINK:-Broken symlink: %s}" \
        "$(printf '%s%s%s' "$(theme::accent)" "$link" "$(theme::reset)")")"
      issues=$((issues + 1))
    fi
  done < <(find "$HOME" -maxdepth 4 -type l -print0 2>/dev/null)

  if ((issues == 0)); then
    ui::ok "${MSG_DOCTOR_OK}"
  else
    # shellcheck disable=SC2059
    ui::info "$(printf "${MSG_DOCTOR_ISSUES:-%s issue(s) found.}" \
      "$(printf '%s%s%s' "$(theme::warning)" "$issues" "$(theme::reset)")")"
  fi
}
