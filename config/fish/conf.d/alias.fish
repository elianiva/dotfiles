# git stuff
alias ga="git add"
alias gc="git commit"
alias gs="git status"
alias gd="git diff"
alias gr="git restore"

# save current work
alias gwip='git add -A; git rm (git ls-files --deleted) 2> /dev/null; git commit -m "[WIP]: '(date)'"'

# Logging helpers
alias gls='git log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate'
alias gll='git log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat'
alias gdate='git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative'
alias gdatelong='git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short'

# config stuff
alias nvimconf="nvim ~/.config/nvim/init.vim"
alias swayconf="nvim ~/.config/sway/config"
alias barconf="nvim ~/.config/waybar/config"
alias kittyconf="nvim ~/.config/kitty/kitty.conf"
alias zshconf="nvim ~/.zshrc"
alias awsconf="nvim ~/.config/awesome/rc.lua"
alias aliasconf="nvim ~/.config/aliasrc"
alias vnim="nvim" # I got this typo quit a lot

# exit vim-like
alias :Q="exit"
alias :q="exit"

alias ls="exa --colour=always --group-directories-first --sort=name"
