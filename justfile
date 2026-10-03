# rebuild nix flake for linux (home-manager)
# default `elianiva` is now aarch64-linux (Asahi Fedora Remix)
linux:
    nh home switch --flake .#elianiva --print-build-logs

# explicit aliases
asahi:
    nh home switch --flake .#elianiva --print-build-logs

intel:
    nh home switch --flake .#elianiva@intel --print-build-logs

# rebuild nix flake for darwin/macos
darwin:
    nh darwin switch .

# clean nix store
clean:
    nh clean

update:
    env NIX_CONFIG="access-tokens = github.com=$(gh auth token)" nix flake update
