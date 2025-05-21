{ pkgs, config, ... }:
let
  email = "51877647+elianiva@users.noreply.github.com";
  name = "elianiva";
in
{
  programs.gh.enable = true;
  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        lightTheme = true;
      };
      git.paging = {
        colorArg = "always";
        useConfig = true;
        externalDiffCommand = "difft";
      };
      git.log.order = "default";
    };
  };
  programs.git = {
    enable = true;
    userName = "${name}";
    userEmail = "${email}";
    extraConfig = {
      credential.helper = "cache --timeout 86400";
      core = {
        compression = 9;
        editor = "nvim";
      };
      diff.external = "difft";
      pull.rebase = false;
      commit.gpgsign = true;
      gpg.format = "ssh";
      # use this command to generate the file
      # echo "$(git config --get user.email) namespaces=\"git\" $(cat ~/.ssh/<MY_KEY>.pub)" >> ~/.ssh/allowed_signers
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      alias = {
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
        c = "commit -S -m";
        ca = "commit -S --amend";
      };
      # Why?
      # - ghq default is https, this omit -p option for the ssh push
      # - https://blog.n-z.jp/blog/2013-11-28-git-insteadof.html
      url = {
        "git@github.com:" = {
          pushInsteadOf = [
            "git://github.com/"
            "https://github.com/"
          ];
        };
      };
      # delta = {
      #   line-numbers = true;
      #   syntax-theme = "base16";
      #   side-by-side = false;
      #   file-modified-label = "modified:";
      #   light = true;
      # };
      difftastic = {
        background = "light";
      };
      init.defaultBranch = "master";
    };
  };
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "${email}";
        name = "${name}";
      };
    };
  };
}
