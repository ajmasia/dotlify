# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_status::run() {
  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  # shellcheck disable=SC2059
  ui::info "$(printf "${MSG_STATUS_DOTFILES:-Dotfiles: %s}" \
    "$(printf '%s%s%s' "$(theme::accent)" "$dots_dir" "$(theme::reset)")")"

  if [[ -n "${DFY_PROFILE:-}" ]]; then
    # shellcheck disable=SC2059
    ui::info "$(printf "${MSG_STATUS_PROFILE:-Active profile: %s}" \
      "$(printf '%s%s%s' "$(theme::accent)" "${DFY_PROFILE}" "$(theme::reset)")")"
  else
    ui::info "${MSG_STATUS_NO_PROFILE:-(no active profile)}"
  fi

  printf '\n'

  local -a pkgs
  mapfile -t pkgs < <(repo::list_packages "$dots_dir")

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    ui::info "${MSG_STATUS_NONE}"
    return 0
  fi

  local pkg marker
  for pkg in "${pkgs[@]}"; do
    marker="$(repo::package_status "$dots_dir" "$pkg")"
    case "$marker" in
      ✓) ui::ok "$pkg" ;;
      !) ui::warn "$(printf '%s%s%s — %s' \
        "$(theme::warning)" "$pkg" "$(theme::reset)" \
        "${MSG_STATUS_CONFLICT_HINT:-target exists, run: dfy adopt}")" ;;
      *) ui::off "$pkg" ;;
    esac
  done
}
