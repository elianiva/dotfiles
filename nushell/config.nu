const cfg = ($nu.config-path | path dirname)

source ($cfg | path join "bash-env.nu")
source ($cfg | path join "darwin-env.nu")
source ($cfg | path join "brew-env.nu")

bash-env ~/.profile | load-env

source ($cfg | path join "alias.nu")
source ($cfg | path join "ai.nu")

$env.LS_COLORS = (vivid generate rose-pine-dawn)

use ($cfg | path join "rose-pine-dawn.nu")


# zoxide
source ($cfg | path join "zoxide.nu")

# starship
source ($cfg | path join "starship.nu")

let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
}

$env.config = {
  edit_mode: 'vi',
  color_config: (rose-pine-dawn),
  cursor_shape: {
    emacs: "line"
    vi_insert: "line"
    vi_normal: "block"
  },
  shell_integration: {
    osc2: true
    osc7: true
    osc8: true
    osc9_9: false
    osc133: true
    osc633: false
  },
  history: {
    file_format: sqlite
    max_size: 1_000_000
    sync_on_enter: true
    isolation: true
  },
  buffer_editor: "nvim",
  show_banner: false,
  table: {
    mode: "compact"
  },
  completions: {
    case_sensitive: false,
    quick: true,
    partial: true,
    algorithm: "fuzzy",
    external: {
      enable: true
      max_results: 100
      completer: $carapace_completer
    }
  },
  hooks: {
    pre_prompt: [{ ||
      if (which direnv | is-empty) {
        return
      }

      direnv export json | from json | default {} | load-env
      if 'ENV_CONVERSIONS' in $env and 'PATH' in $env.ENV_CONVERSIONS {
        $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
      }
    }]
  }
}
