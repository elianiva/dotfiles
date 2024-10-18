{ config, pkgs, ... }:

# ## FAQ - GPG
#
# - How to list keys?
#   - 1. `gpg --list-secret-keys --keyid-format=long` # The `sec` first section displays same text as `pub` by `gpg --list-keys --keyid-format=long`
# - How to add subkey?
#   - 1. `gpg --edit-key PUBKEY`
#   - 2. `addkey`
#   - 3. `save`
# - How to revoke subkey?
#   - 1. `gpg --edit-key PUBKEY`
#   - 2. `key n` n is the index of subkey
#   - 3. `revkey`
#   - 4. `save`
#   - 5. Replace uploaded pubkey with new one, see https://github.com/kachick/dotfiles/pull/311#issuecomment-1715812324 for detail
# - How to get pubkey to upload?
#   - `gpg --armor --export PUBKEY | clip.exe`
# - How to backup private key?
#   - `gpg --export-secret-keys --armor > gpg-private.keys.bak`
let
  # All gpg-agent timeouts numbers should be specified with the `seconds`
  day = 60 * 60 * 24;
in
{
  # https://github.com/nix-community/home-manager/blob/release-24.05/modules/services/gpg-agent.nix
  services.gpg-agent = {
    enable = pkgs.stdenv.isLinux;

    # Update [darwin.nix](darwin.nix) if changed this section
    #
    # https://superuser.com/questions/624343/keep-gnupg-credentials-cached-for-entire-user-session
    defaultCacheTtl = day * 1;
    # https://github.com/openbsd/src/blob/862f3f2587ccb85ac6d8602dd1601a861ae5a3e8/usr.bin/ssh/ssh-agent.1#L167-L173
    # ssh-agent sets it as infinite by default. So I can relax here (maybe)
    defaultCacheTtlSsh = day * 30;
    maxCacheTtl = day * 7;
    pinentryPackage = pkgs.pinentry-tty;
    enableSshSupport = true;
  };

  # https://github.com/nix-community/home-manager/blob/release-24.05/modules/programs/gpg.nix

  programs.gpg = {
    enable = true;

    # Preferring XDG_DATA_HOME rather than XDG_CONFIG_HOME from following examples
    #   - https://wiki.archlinux.org/title/XDG_Base_Directory
    #   - https://github.com/nix-community/home-manager/blob/5171f5ef654425e09d9c2100f856d887da595437/modules/programs/gpg.nix#L192
    homedir = "${config.xdg.dataHome}/gnupg";

    # - How to read `--list-keys` - https://unix.stackexchange.com/questions/613839/help-understanding-gpg-list-keys-output
    # - Ed448 in GitHub is not yet supported - https://github.com/orgs/community/discussions/45937
    settings = {
      # https://unix.stackexchange.com/questions/339077/set-default-key-in-gpg-for-signing
      # default-key = "<UPDATE_ME_IN_FLAKE>";

      personal-digest-preferences = "SHA512";
    };
  };

  # https://github.com/nix-community/home-manager/blob/release-24.05/modules/programs/password-store.nix
  programs.password-store = {
    enable = true;
  };
}
