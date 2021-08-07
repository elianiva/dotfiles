nix-shell -p nixUnstable --command "nix build --experimental-features 'nix-command flakes' '.#$1'"
