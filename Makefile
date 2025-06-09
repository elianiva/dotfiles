linux:
	nh home switch --flake .#elianiva --print-build-logs

darwin:
	nh darwin switch .

clean:
	nh clean
