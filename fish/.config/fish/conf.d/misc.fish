function fish_clipboard_paste
    set -l data
    if not type -q xclip
        # Return if `xclip` failed.
        return 1
    end
    set data (xclip -o)
    if test -n "$data"
        commandline -i -- "'$data'"
    end
end
