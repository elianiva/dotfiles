linux:
	home-manager switch --flake .#elianiva --print-build-logs

darwin:
	darwin-rebuild switch --flake .#

clean:
	nix-collect-garbage -d
