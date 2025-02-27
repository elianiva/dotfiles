# git stuff
abbr -a ga    "git add"
abbr -a gc    "git commit"
abbr -a gs    "git status"
abbr -a gd    "git diff"
abbr -a gds   "git diff --staged"
abbr -a gr    "git restore"
abbr -a gpush "git push"

# save current work
abbr -a gwip 'git add -A; git rm (git ls-files --deleted) 2> /dev/null; git commit -m "[WIP]: '(date)'"'

# Logging helpers
# might be useful later idk
# abbr -a gls 'git log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate'
# abbr -a gll 'git log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat'
# abbr -a gdate 'git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative'
# abbr -a gdatelong 'git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short'

# config stuff
abbr -a nvimconf "nvim ~/.config/nvim/init.lua"
abbr -a vnim "nvim" # I got this typo quit a lot

abbr -a ls "eza --colour=always --group-directories-first --sort=name"

# shortcut for youtube-dl when downloading music
abbr -a ytmusic 'yt-dlp -f251 -x --embed-metadata --embed-thumbnail'
