# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=bash

init::scaffold() {
  local dir="$1"

  mkdir -p "${dir}/bash-aliases"
  cat >"${dir}/bash-aliases/.bash_aliases" <<'EOF'
# Review, edit, and personalize this file.
# Uncomment the aliases you want to use.

# -- Navigation --
# alias ..='cd ..'
# alias ...='cd ../..'
# alias ll='ls -lah'

# -- Safety --
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# -- System update (uncomment for your OS) --
# alias update='sudo apt update && sudo apt upgrade'   # Debian / Ubuntu
# alias update='brew update && brew upgrade'           # macOS
EOF

  mkdir -p "${dir}/zsh-aliases"
  cat >"${dir}/zsh-aliases/.zsh_aliases" <<'EOF'
# Review, edit, and personalize this file.
# Uncomment the aliases you want to use.

# -- Navigation --
# alias ..='cd ..'
# alias ...='cd ../..'
# alias ll='ls -lah'

# -- Safety --
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# -- System update (uncomment for your OS) --
# alias update='sudo apt update && sudo apt upgrade'   # Debian / Ubuntu
# alias update='brew update && brew upgrade'           # macOS
EOF

  mkdir -p "${dir}/vim"
  cat >"${dir}/vim/.vimrc" <<'EOF'
" Review, edit, and personalize this file.
" Uncomment the settings you want to enable.

" syntax on
" set number
" set relativenumber
" set tabstop=2 shiftwidth=2 expandtab
" set hlsearch incsearch
" set autoindent
EOF

  cat >"${dir}/.gitignore" <<'EOF'
*.swp
*.swo
*~
*.log
.DS_Store
EOF
}

cmd_init::run() {
  local bare=0
  local -a extra_args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --bare)
        bare=1
        shift
        ;;
      *)
        extra_args+=("$1")
        shift
        ;;
    esac
  done

  if [[ ${#extra_args[@]} -gt 0 ]]; then
    # shellcheck disable=SC2059
    printf "${MSG_UNKNOWN_FLAG:-Unknown flag: %s}\n" "${extra_args[0]}" >&2
    printf '%s\n' "${MSG_USAGE_HINT:-Run 'dfy --help' for usage.}" >&2
    exit 2
  fi

  local target="${DFY_DIR:-${HOME}/.dotfiles}"
  # Expand leading ~ to HOME.
  target="${target/#\~/$HOME}"

  # Loop until the user provides a path that does not exist.
  while [[ -e "$target" ]]; do
    # shellcheck disable=SC2059
    ui::warn "$(printf "${MSG_INIT_DIR_EXISTS:-Path already exists: %s. Enter an alternative path: }" "$target")"
    IFS= read -r target
    target="${target/#\~/$HOME}"
  done

  # shellcheck disable=SC2059
  ui::step "$(printf "${MSG_INIT_CREATING:-Initializing dotfiles repo at %s...}" "$target")"
  mkdir -p "$target"

  if ! git -C "$target" init --quiet; then
    exit 1
  fi

  if [[ "$bare" -eq 0 ]]; then
    ui::step "${MSG_INIT_SCAFFOLD:-Scaffolding starter files...}"
    init::scaffold "$target"
  fi

  # Check whether config already stores a dir value.
  local existing_dir
  existing_dir="$(config::get dir)"
  if [[ -n "$existing_dir" && "$existing_dir" != "$target" ]]; then
    # shellcheck disable=SC2059
    ui::warn "$(printf "${MSG_INIT_CONFIG_OVERWRITE:-Config already has dir=%s. Overwrite? [y/N] }" "$existing_dir")"
    local answer
    IFS= read -r answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      # shellcheck disable=SC2059
      ui::info "$(printf "${MSG_INIT_DONE:-Dotfiles repo ready at %s}" "$target")"
      return 0
    fi
  fi

  config::set dir "$target"

  ui::info "${MSG_INIT_REMOTE_HINT:-Link your repo to a remote when ready:}"
  printf '  cd %s\n' "$target"
  printf '  git remote add origin <your-remote-url>\n'
  printf '  git push -u origin main\n'
  printf '\n'

  # shellcheck disable=SC2059
  ui::ok "$(printf "${MSG_INIT_DONE:-Dotfiles repo ready at %s}" "$target")"
  ui::info "${MSG_INIT_NEXT_STEPS:-Next steps:}"
  # shellcheck disable=SC2059
  printf '%s\n' "$(printf "${MSG_INIT_NEXT_REVIEW:-  1. Review and personalize the files in %s}" "$target")"
  printf '%s\n' "${MSG_INIT_NEXT_LINK:-  2. Run: dfy apply <package>}"
  printf '%s\n' "${MSG_INIT_NEXT_ADOPT:-  3. Or adopt existing files: dfy adopt <file>}"
}
