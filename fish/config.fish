# disable greeting
set fish_greeting

# starship prompt
starship init fish | source

# pnpm
set -gx PNPM_HOME "/home/elianiva/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end

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

# opam configuration
source /home/elianiva/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
