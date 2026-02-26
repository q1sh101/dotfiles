# q1sh101 - zshrc

# --- history (RAM-only) ---
HISTSIZE=888888                                # in RAM only, for recall
SAVEHIST=0                                     # nothing written to disk
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS

# --- safety ---
setopt NO_CLOBBER                              # prevent > overwrite (use >| to force)

# --- system ---
ulimit -n 2048

# --- keybindings ---
# Ctrl+s is tmux prefix; disable terminal flow-control freeze (XON/XOFF).
[[ -t 0 ]] && stty -ixon 2>/dev/null || true

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^k" up-line-or-beginning-search
bindkey "^j" down-line-or-beginning-search

# --- completion ---
autoload -Uz compinit && compinit -d "$ZSH_COMPDUMP"
zstyle ':completion:*' menu select

# --- prompt ---
autoload -Uz vcs_info
precmd() {
  vcs_info
  export GPG_TTY=$(tty)                            # GPG_TTY survives tmux reattach
  print -Pn "\e]0;A T O M X\a"
  _git_rprompt                                     # RPROMPT: branch + status (in .functions)
}
zstyle ':vcs_info:git:*' formats '%b'

PROMPT='%B%F{cyan}%1~%f %(?.%F{green}.%F{red})$❱%f%b '

# --- source ---
[ -f "$HOME/.paths" ]     && source "$HOME/.paths"
[ -f "$HOME/.aliases" ]   && source "$HOME/.aliases"
[ -f "$HOME/.functions" ] && source "$HOME/.functions"

# --- tools ---
# fzf
if [[ -o interactive ]] && [[ -t 0 && -t 1 ]] && command -v fzf &>/dev/null; then
  if fzf --zsh &>/dev/null; then
    eval "$(fzf --zsh)"
  else
    for d in /usr/share/fzf /usr/share/doc/fzf/examples /usr/share/fzf/shell ~/.fzf/shell; do
      [ -f "$d/key-bindings.zsh" ] && source "$d/key-bindings.zsh"
      [ -f "$d/completion.zsh" ]   && source "$d/completion.zsh"
    done
  fi
fi

# zoxide
# note: stores visited dirs on disk (~/.local/share/zoxide/db.zo)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# --- local (machine-specific, not in git) ---
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
