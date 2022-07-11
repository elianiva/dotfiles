# disable greeting
set fish_greeting

# starship prompt
starship init fish | source

# Start X at login
# if status is-login
#     if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
#         exec startx -- -keeptty
#         # dbus-run-session startplasma-wayland
#     else if test -z "$DISPLAY" -a "$XDG_VTNR" = 2
#         # set XDG_SESSION_TYPE     wayland
#         # set QT_QPA_PLATFORMTHEME wayland
#         # set QT_QPA_PLATFORM      wayland
#         # set MOZ_ENABLE_WAYLAND   1
#         # set GDK_BACKEND          wayland
#         # exec sway
#         # exec startx -- -keeptty
#     end
# end

# pnpm
set -gx PNPM_HOME "/home/elianiva/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end
