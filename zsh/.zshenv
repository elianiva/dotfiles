# Start blinking
export LESS_TERMCAP_mb=$(tput bold; tput setaf 4) # blue
# Start bold
export LESS_TERMCAP_md=$(tput bold; tput setaf 4) # blue
# Start stand out
export LESS_TERMCAP_so=$(tput bold; tput setaf 3) # yellow
# End standout
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
# Start underline
export LESS_TERMCAP_us=$(tput smul; tput setaf 5) # magenta
# End Underline
export LESS_TERMCAP_ue=$(tput sgr0)
# End bold, blinking, standout, underline
export LESS_TERMCAP_me=$(tput sgr0)

source "$HOME/.cargo/env"
