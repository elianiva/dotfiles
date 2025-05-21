linux:
	nh home switch --flake .#elianiva --print-build-logs

darwin:
	nh darwin switch --flake .#

clean:
	nh clean
