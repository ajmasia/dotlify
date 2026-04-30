# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_status::run() {
  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  # shellcheck disable=SC2059
  ui::info "$(printf "${MSG_STATUS_DOTFILES:-Dotfiles: %s}" "$dots_dir")"

  local -a pkgs
  mapfile -t pkgs < <(repo::list_packages "$dots_dir")

  local -a linked=() conflicts=()
  local pkg marker
  for pkg in "${pkgs[@]+"${pkgs[@]}"}"; do
    marker="$(repo::package_status "$dots_dir" "$pkg")"
    case "$marker" in
      ✓) linked+=("$pkg") ;;
      !) conflicts+=("$pkg") ;;
    esac
  done

  if [[ ${#linked[@]} -eq 0 ]]; then
    ui::info "${MSG_STATUS_NONE}"
  else
    # shellcheck disable=SC2059
    ui::info "$(printf "${MSG_STATUS_LINKED:-Linked packages (%s):}" "${#linked[@]}")"
    local p
    for p in "${linked[@]}"; do
      printf '  %s\n' "$p"
    done
  fi

  if [[ ${#conflicts[@]} -gt 0 ]]; then
    # shellcheck disable=SC2059
    ui::warn "$(printf "${MSG_STATUS_CONFLICTS:-Conflicts (%s):}" "${#conflicts[@]}")"
    for p in "${conflicts[@]}"; do
      printf '  %s\n' "$p"
    done
  fi
}
