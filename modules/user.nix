# The user aspect: everything "elianiva" is, regardless of the machine.
{ den, ... }:
{
  den.aspects.elianiva = {
    includes = [
      # OS account + home directory on any OS, and home.username/homeDirectory
      # for standalone home-manager.
      den.batteries.define-user
      # sets darwin.system.primaryUser / nixos wheel+networkmanager
      den.batteries.primary-user

      # user environment
      den.aspects.programs
      den.aspects.vp-global-packages
      den.aspects.git
      den.aspects.gpg
      den.aspects.agents
      den.aspects.shell-files

      # one aspect per tool / dotfile directory
      den.aspects.nvim
      den.aspects.fish
      den.aspects.helix
      den.aspects.yazi
      den.aspects.nushell
      den.aspects.zellij
      den.aspects.fastfetch
      den.aspects.jjui
      den.aspects.herdr
      den.aspects.hunk
      den.aspects.qmd
      den.aspects.kitty
      den.aspects.wezterm
      den.aspects.ghostty
      den.aspects.karabiner
    ];
  };

  # Same user, two environments. The darwin host uses `den.aspects.elianiva`
  # directly; the Linux homes use this variant, which only adds the
  # non-NixOS-specific plumbing.
  den.aspects.elianiva-linux.includes = [
    den.aspects.elianiva
    den.aspects.home-linux
  ];
}
