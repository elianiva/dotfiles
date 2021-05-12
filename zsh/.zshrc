### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit wait lucid atload"zicompinit; zicdreplay" blockf for \
    zsh-users/zsh-completions
zinit wait lucid atload'_zsh_autosuggest_start' light-mode for \
    zsh-users/zsh-autosuggestions

###=========== Start of user config =================###
function set_win_title(){
    print -Pn "\e]0;%~\a"
}
precmd_functions+=(set_win_title)
eval "$(starship init zsh)"
setopt autocd   # automatically cd into typed directory.
stty stop undef   # disable ctrl-s to freeze terminal.

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.

# load aliases if exists
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/aliasrc"

# highlights tab completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' # case insensitive

bindkey -v # vi mode
bindkey "jj" vi-cmd-mode # Use jj instead of <Esc>

# history substring function
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# # Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
_fix_cursor() {
   echo -ne '\e[5 q'
}
precmd_functions+=(_fix_cursor)

lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp" >/dev/null
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

bindkey '^[[Z' reverse-menu-complete # fix reverse menu
bindkey '^[[P' delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# clone subdirectory using subversion
git-svn() {
  if [[ ! -z "$1" && ! -z "$2" ]]; then
    echo "Starting clone/copy..."
    repo=$(echo $1 | sed 's/\/$\|.git$//')
    svn export "$repo/trunk/$2"
  else
    echo "Use: git-svn <repository> <subdir>"
  fi
}

run_rs() {
  rustc $1; ./$(echo "$1" | sed -e "s/\.rs$//")
}

__skim_use_tmux__() {
  [ -n "$TMUX_PANE" ] && [ "${SKIM_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ]
}
__skimcmd() {
  __skim_use_tmux__ && echo "sk-tmux -d${SKIM_TMUX_HEIGHT:-40%}" || echo "sk"
}
skim-history-widget() {
  local selected num
  echo -ne "\r"
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 |
    SKIM_DEFAULT_OPTIONS="--height=40% $SKIM_DEFAULT_OPTIONS -n2..,.. --tiebreak=score,index $SKIM_CTRL_R_OPTS --query=${(qqq)LBUFFER} -m" $(__skimcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   skim-history-widget
bindkey '^R' skim-history-widget

skim-redraw-prompt() {
  local precmd
  for precmd in $precmd_functions; do
    $precmd
  done
  zle reset-prompt
}
zle -N skim-redraw-prompt

# don't use `xterm-kitty`
# export TERM=xterm-256color

# # fnm
export PATH=/home/elianiva/.fnm:$PATH
eval "`fnm env`"
