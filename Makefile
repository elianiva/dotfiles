.PHONY: update
update:
	home-manager switch --flake .#elianiva --print-build-logs

clean:
	nix-collect-garbage -d
