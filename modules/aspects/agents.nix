# Coding-agent configs: the canonical ~/.agents location plus each agent's own
# config directory.
{ den, ... }:
{
  den.aspects.agents.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = "${config.home.homeDirectory}/.dotfiles";
      pi = ".pi/agent";
    in
    {
      xdg.configFile = {
        # opencode configs
        "opencode/opencode.json".source = link "${dotfiles}/agents/opencode/opencode.json";
      };

      home.file = {
        # canonical agents location (shared by all coding agent)
        ".agents/AGENTS.md".source = link "${dotfiles}/agents/AGENTS.md";
        ".agents/skills" = {
          source = link "${dotfiles}/agents/skills";
          recursive = true;
        };

        # pi coding agent related configs
        "${pi}/settings.json".source = link "${dotfiles}/agents/pi/settings.json";
        "${pi}/models.json".source = link "${dotfiles}/agents/pi/models.json";
        "${pi}/package.json".source = link "${dotfiles}/agents/pi/package.json";
        "${pi}/extensions" = {
          source = link "${dotfiles}/agents/pi/extensions";
          recursive = true;
        };
        "${pi}/themes" = {
          source = link "${dotfiles}/agents/pi/themes";
          recursive = true;
        };
        "${pi}/ttsr-rules" = {
          source = link "${dotfiles}/agents/pi/ttsr-rules";
          recursive = true;
        };
        "${pi}/agents" = {
          source = link "${dotfiles}/agents/pi/agents";
          recursive = true;
        };
      };
    };
}
