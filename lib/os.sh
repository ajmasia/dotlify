# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

# Return one of: debian ubuntu arch fedora rhel unknown.
# Reads /etc/os-release; falls back to "unknown" on missing file.
os::distro_id() {
  local os_release="/etc/os-release"
  if [[ ! -f "$os_release" ]]; then
    printf 'unknown'
    return
  fi
  local id id_like
  id="$(grep -m1 '^ID=' "$os_release" | cut -d= -f2 | tr -d '"')"
  id_like="$(grep -m1 '^ID_LIKE=' "$os_release" 2>/dev/null | cut -d= -f2 | tr -d '"' || true)"
  case "$id" in
    debian | ubuntu | arch | fedora | rhel)
      printf '%s' "$id"
      ;;
    *)
      case "$id_like" in
        *debian* | *ubuntu*) printf 'debian' ;;
        *arch*) printf 'arch' ;;
        *fedora* | *rhel*) printf 'fedora' ;;
        *) printf 'unknown' ;;
      esac
      ;;
  esac
}
