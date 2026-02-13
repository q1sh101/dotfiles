#!/usr/bin/env bash
# q1sh101 - dotfiles uninstaller
# removes only symlinks that point back to this repo

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

removed=0

unlink() {
  local dst="$1"
  # only remove if it's a symlink pointing into our repo
  if [[ -L "$dst" ]] && [[ "$(readlink -- "$dst")" == "$DOTFILES" || "$(readlink -- "$dst")" == "$DOTFILES/"* ]]; then
    rm -f -- "$dst" || { echo "  error: remove failed for $dst" >&2; return 1; }
    echo "  $dst"
    removed=$((removed+1))
  fi
}

echo "uninstall: $DOTFILES"
echo ""

# --- root ---
unlink "$HOME/.dotfiles"

# --- identity/shell ---
unlink "$HOME/.zshenv"
unlink "$HOME/.zshrc"
unlink "$HOME/.paths"
unlink "$HOME/.aliases"
unlink "$HOME/.functions"

# --- identity/git ---
unlink "$HOME/.config/git/config"
unlink "$HOME/.config/git/ignore"
unlink "$HOME/.config/git/hooks/pre-commit"

# --- identity/gpg ---
unlink "$HOME/.gnupg/gpg.conf"
unlink "$HOME/.gnupg/gpg-agent.conf"

# --- identity/ssh ---
unlink "$HOME/.ssh/config"

# --- identity/tmux ---
unlink "$HOME/.tmux.conf"

# --- apps/alacritty ---
unlink "$HOME/.config/alacritty/alacritty.toml"
unlink "$HOME/.config/alacritty/themes/pixiefloss.toml"

# --- apps/ranger ---
unlink "$HOME/.config/ranger/rc.conf"

# --- apps/ripgrep ---
unlink "$HOME/.config/ripgrep/config"

echo ""
echo "done. removed $removed symlinks."
