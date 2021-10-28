set key_bindings_path "$HOME/.nix-profile/share/skim/key-bindings.fish"

if test -f $key_bindings_path
  source $key_bindings_path
  skim_key_bindings
end
