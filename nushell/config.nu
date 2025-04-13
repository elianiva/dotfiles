const cfg = ($nu.config-path | path dirname)

source ($cfg | path join "alias.nu")
source ($cfg | path join "ai.nu")
source ($cfg | path join "zoxide.nu")
source ($cfg | path join "bash-env.nu")

use ($cfg | path join "rose-pine-dawn.nu")

bash-env ~/.profile | load-env

let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
}

const history_path = ($nu.data-dir | path join "history.txt")

$env.config = {
  color_config: (rose-pine-dawn),
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

const NU_PLUGIN_DIRS = [
  ($nu.current-exe | path dirname)
  ...$NU_PLUGIN_DIRS
]

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
