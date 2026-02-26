#!/usr/bin/env bash
# q1sh101 - dotfiles symlink deployer

set -euo pipefail

_dotfiles="$(cd "$(dirname "$0")" && pwd)"
_backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"


link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")" || { echo "  error: mkdir failed for $dst" >&2; return 1; }
  # backup real files (not symlinks) before overwriting
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mkdir -p "$_backup"
    mv -- "$dst" "$_backup/" || { echo "  error: backup failed for $dst" >&2; return 1; }
    echo "  backup: $dst -> $_backup/"
  fi
  ln -sf -- "$src" "$dst" || { echo "  error: link failed: $dst" >&2; return 1; }
  echo "  $dst"
}

echo "dotfiles: $_dotfiles"
echo ""

# --- root (~/.dotfiles -> repo, convenience shortcut) ---
ln -sfn "$_dotfiles" "$HOME/.dotfiles"
echo "  ~/.dotfiles"

# --- identity/shell ---
link "$_dotfiles/identity/shell/.zshenv"    "$HOME/.zshenv"
link "$_dotfiles/identity/shell/.zshrc"     "$HOME/.zshrc"
link "$_dotfiles/identity/shell/.paths"     "$HOME/.paths"
link "$_dotfiles/identity/shell/.aliases"   "$HOME/.aliases"
link "$_dotfiles/identity/shell/.functions" "$HOME/.functions"

# --- identity/git ---
link "$_dotfiles/identity/git/config"           "$HOME/.config/git/config"
link "$_dotfiles/identity/git/ignore"           "$HOME/.config/git/ignore"
link "$_dotfiles/identity/git/hooks/pre-commit" "$HOME/.config/git/hooks/pre-commit"

# --- identity/gpg ---
link "$_dotfiles/identity/gpg/gpg.conf"       "$HOME/.gnupg/gpg.conf"
link "$_dotfiles/identity/gpg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"

# --- identity/ssh ---
link "$_dotfiles/identity/ssh/config" "$HOME/.ssh/config"

# --- identity/tmux ---
link "$_dotfiles/identity/tmux/tmux.conf" "$HOME/.tmux.conf"
link "$_dotfiles/identity/shell/git-status" "$HOME/.local/bin/git-status"

# --- apps/alacritty ---
link "$_dotfiles/apps/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# --- apps/ranger ---
link "$_dotfiles/apps/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"

# --- apps/ripgrep ---
link "$_dotfiles/apps/ripgrep/config" "$HOME/.config/ripgrep/config"

# --- permissions ---
chmod 700 "$HOME/.gnupg" 2>/dev/null || true
chmod 700 "$HOME/.ssh" 2>/dev/null || true
chmod +x "$_dotfiles/identity/git/hooks/pre-commit"
chmod +x "$_dotfiles/identity/shell/git-status"
chmod +x "$_dotfiles/theme/build"
chmod +x "$_dotfiles/uninstall.sh"

echo ""
echo "done. reload: exec zsh"
