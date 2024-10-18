.PHONY: update
update:
	home-manager switch --flake .#elianiva

clean:
	nix-collect-garbage -d
