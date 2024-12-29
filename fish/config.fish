# disable greeting
set fish_greeting

# starship prompt
starship init fish | source

# zoxide
zoxide init fish --cmd cd | source

# pnpm
set -gx PNPM_HOME "/home/elianiva/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end

function zellij_tab_name_update --on-event fish_preexec
    if set -q ZELLIJ
        set title (string split ' ' $argv)[1]
        command nohup zellij action rename-tab $title >/dev/null 2>&1
    end
end

function fish_mode_prompt
  switch $fish_bind_mode
    case default
      echo -en "\e[2 q"
    case insert
      echo -en "\e[6 q"
    case replace_one
      echo -en "\e[4 q"
    case visual
      echo -en "\e[2 q"
      set_color -o brwhite
    case '*'
      echo -en "\e[2 q"
  end
  set_color normal
end

if status is-interactive
    eval (zellij setup --generate-auto-start fish | string collect)
end
