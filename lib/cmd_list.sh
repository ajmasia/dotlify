# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

cmd_list::run() {
  local dots_dir
  dots_dir="$(repo::resolve_dir)"

  local -a pkgs
  mapfile -t pkgs < <(repo::list_packages "$dots_dir")

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    # shellcheck disable=SC2059
    ui::info "$(printf "${MSG_LIST_EMPTY:-No packages found in %s}" "$dots_dir")"
    return 0
  fi

  local pkg desc
  for pkg in "${pkgs[@]}"; do
    desc="$(repo::pkg_description "$dots_dir" "$pkg")"
    if [[ -n "$desc" ]]; then
      printf '%s[i]%s %s%s%s %s(%s)%s\n' \
        "$(theme::info)" "$(theme::reset)" \
        "$(theme::text)" "$pkg" "$(theme::reset)" \
        "$(theme::muted)" "$desc" "$(theme::reset)"
    else
      printf '%s[!]%s %s%s%s %s(%s)%s\n' \
        "$(theme::warning)" "$(theme::reset)" \
        "$(theme::text)" "$pkg" "$(theme::reset)" \
        "$(theme::muted)" "${MSG_LIST_NO_README:-no readme}" "$(theme::reset)"
    fi
  done
}
