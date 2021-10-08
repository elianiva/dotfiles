# Start blinking | blue
set LESS_TERMCAP_mb (printf '\033[1;34m')
# Start bold | blue
set LESS_TERMCAP_md (printf '\033[1;34m')
# Start stand out | yellow
set LESS_TERMCAP_so (printf '\033[1;33m')
# End standout
set LESS_TERMCAP_se (printf '\033[0;10m')
# Start underline | magenta
set LESS_TERMCAP_us (printf '\033[4;35m')
# End Underline
set LESS_TERMCAP_ue (printf '\033[0;10m')
# End bold, blinking, standout, underline
set LESS_TERMCAP_me (printf '\033[0;10m')
set GROFF_NO_SGR 1
