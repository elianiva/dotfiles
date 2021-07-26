# Start blinking | blue
export LESS_TERMCAP_mb=$(printf '\033[1;34m')
# Start bold | blue
export LESS_TERMCAP_md=$(printf '\033[1;34m')
# Start stand out | yellow
export LESS_TERMCAP_so=$(printf '\033[1;33m')
# End standout
export LESS_TERMCAP_se=$(printf '\033[0;10m')
# Start underline | magenta
export LESS_TERMCAP_us=$(printf '\033[4;35m')
# End Underline
export LESS_TERMCAP_ue=$(printf '\033[0;10m')
# End bold, blinking, standout, underline
export LESS_TERMCAP_me=$(printf '\033[0;10m')
export GROFF_NO_SGR=1

source "$HOME/.cargo/env"
if [ -e /home/elianiva/.nix-profile/etc/profile.d/nix.sh ]; then . /home/elianiva/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
