alias sail = ./vendor/bin/sail

alias :q = exit
alias :Q = exit

# git stuff
alias ga = git add
alias gc = git commit
alias gs = git status
alias gd = git diff
alias gds = git diff --staged
alias gr = git restore
alias gpush = git push

def gwip [] {
  git add -A
  git rm (git ls-files --deleted) err> /dev/null
  git commit -m $"[WIP]: (date now)"
}

def gl [] {
    git log --pretty=format:"%h»¦«%s»¦«%aN»¦«%aE»¦«%aD" -n 10
    | lines
    | split column "»¦«" sha1 subject name email date
    | upsert date {|d| $d.date | into datetime}
}
