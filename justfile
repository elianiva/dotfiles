# rebuild nix flake for linux (home-manager)
linux:
    nh home switch --flake .#elianiva --print-build-logs

# rebuild nix flake for darwin/macos
darwin:
    nh darwin switch .

# clean nix store
clean:
    nh clean
