nix-shell -p nixUnstable --command "nix build --impure --experimental-features 'nix-command flakes' '.#$1'"
