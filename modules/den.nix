# The only file that knows about Den itself.
#
# Den is a library + framework for composing Nix configurations with aspects:
# one aspect bundles the config a single concern needs across every class
# (darwin, homeManager, nixos, ...), and hosts/users/homes just select aspects.
{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [ inputs.den.flakeModule ];

  # Every user gets an OS account (built-in `user` class) and a home-manager
  # environment. This is a user concern, so it is declared at the schema level.
  den.schema.user.classes = lib.mkDefault [
    "user"
    "homeManager"
  ];

  # Global settings for every host, user, and home.
  den.default = {
    darwin.system.stateVersion = 6;
    homeManager.home.stateVersion = "25.11";

    includes = [
      # sets <host.class>.networking.hostName from the host name
      den.batteries.hostname

      # concerns that are configurable from both an OS and a home profile
      den.aspects.packages
      den.aspects.fonts
    ];
  };
}
