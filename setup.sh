#!/usr/bin/env bash
# q1sh101 - dotfiles symlink deployer

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")" || { echo "  error: mkdir failed for $dst" >&2; return 1; }
  # backup real files (not symlinks) before overwriting
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mkdir -p "$BACKUP"
    mv -- "$dst" "$BACKUP/" || { echo "  error: backup failed for $dst" >&2; return 1; }
    echo "  backup: $dst -> $BACKUP/"
  fi
  ln -sf -- "$src" "$dst" || { echo "  error: link failed: $dst" >&2; return 1; }
  echo "  $dst"
}

echo "dotfiles: $DOTFILES"
echo ""

# --- root (~/.dotfiles -> repo, convenience shortcut) ---
ln -sfn "$DOTFILES" "$HOME/.dotfiles"
echo "  ~/.dotfiles"

# --- identity/shell ---
link "$DOTFILES/identity/shell/.zshenv"    "$HOME/.zshenv"
link "$DOTFILES/identity/shell/.zshrc"     "$HOME/.zshrc"
link "$DOTFILES/identity/shell/.paths"     "$HOME/.paths"
link "$DOTFILES/identity/shell/.aliases"   "$HOME/.aliases"
link "$DOTFILES/identity/shell/.functions" "$HOME/.functions"

# --- identity/git ---
link "$DOTFILES/identity/git/config"           "$HOME/.config/git/config"
link "$DOTFILES/identity/git/ignore"           "$HOME/.config/git/ignore"
link "$DOTFILES/identity/git/hooks/pre-commit" "$HOME/.config/git/hooks/pre-commit"

# --- identity/gpg ---
link "$DOTFILES/identity/gpg/gpg.conf"       "$HOME/.gnupg/gpg.conf"
link "$DOTFILES/identity/gpg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"

# --- identity/ssh ---
link "$DOTFILES/identity/ssh/config" "$HOME/.ssh/config"

# --- identity/tmux ---
link "$DOTFILES/identity/tmux/tmux.conf" "$HOME/.tmux.conf"

# --- apps/alacritty ---
link "$DOTFILES/apps/alacritty/alacritty.toml"     "$HOME/.config/alacritty/alacritty.toml"
link "$DOTFILES/apps/alacritty/themes/pixiefloss.toml" "$HOME/.config/alacritty/themes/pixiefloss.toml"

# --- apps/ranger ---
link "$DOTFILES/apps/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"

# --- apps/ripgrep ---
link "$DOTFILES/apps/ripgrep/config" "$HOME/.config/ripgrep/config"

# --- permissions ---
chmod 700 "$HOME/.gnupg" 2>/dev/null || true
chmod 700 "$HOME/.ssh" 2>/dev/null || true
chmod +x "$DOTFILES/identity/git/hooks/pre-commit"
chmod +x "$DOTFILES/uninstall.sh"

echo ""
echo "done. reload: exec zsh"
