# if [ "$TERM_PROGRAM" != "vscode" ]; then
#   if [[ $(/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
#   then
#     shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
#     exec $(which fish) $LOGIN_OPTION
#   fi
# fi

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

