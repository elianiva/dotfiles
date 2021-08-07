final: prev: {
  my = {
    jdt-language-server = (
      prev.callPackage ./jdtls.nix {
        inherit (import <nixpkgs> {});
      }
    );
    awesome-git = prev.awesome.overrideAttrs (
      old: {
        version = "master";

        src = prev.fetchFromGitHub {
          owner = "awesomewm";
          repo = "awesome";
          rev = "8a81745d4d0466c0d4b346762a80e4f566c83461";
          sha256 = "031x69nfvg03snkn7392whg3j43ccg46h6fbdcqj3nxqidgkcf76";
        };
      }
    );
  };
}
