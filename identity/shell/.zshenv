# q1sh101 - zshenv
# first file zsh loads - environment only

# --- path dedup ---
typeset -U PATH path                   # prevent duplicates in nested shells / tmux

# --- locale ---
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# --- xdg base directories ---
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# --- default programs ---
export EDITOR="nvim"
export VISUAL="nvim"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export DELTA_PAGER="less -FRX"

# --- security ---
umask 077                              # new files: owner-only
export SSH_ASKPASS=""
export SSH_ASKPASS_REQUIRE="never"

# --- history (zero disk trace) ---
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=0                              # .zshrc overrides to 888888 for RAM recall
export SAVEHIST=0
# env unsupported? -> seal-history in .functions
# new tool? add: export TOOLNAME_HISTORY="/dev/null" (or "" if /dev/null unsupported)
export LESSHISTFILE="/dev/null"
export NODE_REPL_HISTORY=""
export DENO_REPL_HISTORY=""
export PYTHON_HISTORY="/dev/null"
export SQLITE_HISTORY="/dev/null"
export MYSQL_HISTFILE="/dev/null"
export PSQL_HISTORY="/dev/null"
export REDISCLI_HISTFILE="/dev/null"
export GDBHISTFILE=""
export R2_HISTORY="/dev/null"
