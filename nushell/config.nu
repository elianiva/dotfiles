$env.__NIX_DARWIN_SET_ENVIRONMENT_DONE = 1

$env.PATH = [
    $"($env.HOME)/.nix-profile/bin"
    $"/etc/profiles/per-user/($env.USER)/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/usr/sbin"
    "/bin"
    "/sbin"
]
$env.NIX_PATH = [
    $"darwin-config=($env.HOME)/.nixpkgs/darwin-configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
]
$env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
$env.TERMINFO_DIRS = [
    $"($env.HOME)/.nix-profile/share/terminfo"
    $"/etc/profiles/per-user/($env.USER)/share/terminfo"
    "/run/current-system/sw/share/terminfo"
    "/nix/var/nix/profiles/default/share/terminfo"
    "/usr/share/terminfo"
]
$env.XDG_CONFIG_DIRS = [
    $"($env.HOME)/.nix-profile/etc/xdg"
    $"/etc/profiles/per-user/($env.USER)/etc/xdg"
    "/run/current-system/sw/etc/xdg"
    "/nix/var/nix/profiles/default/etc/xdg"
]
$env.XDG_DATA_DIRS = [
    $"($env.HOME)/.nix-profile/share"
    $"/etc/profiles/per-user/($env.USER)/share"
    "/run/current-system/sw/share"
    "/nix/var/nix/profiles/default/share"
]
$env.NIX_USER_PROFILE_DIR = $"/nix/var/nix/profiles/per-user/($env.USER)"
$env.NIX_PROFILES = [
    "/nix/var/nix/profiles/default"
    "/run/current-system/sw"
    $"/etc/profiles/per-user/($env.USER)"
    $"($env.HOME)/.nix-profile"
]

$env.ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"
$env.ANTHROPIC_AUTH_TOKEN = "-"

if ($"($env.HOME)/.nix-defexpr/channels" | path exists) {
    $env.NIX_PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.nix-defexpr/channels")
}

if (false in (ls -l `/nix/var/nix`| where type == dir | where name == "/nix/var/nix/db" | get mode | str contains "w")) {
    $env.NIX_REMOTE = "daemon"
}

# --- END STARTUP CONFIG ---

const cfg = ($nu.config-path | path dirname)

source ($cfg | path join "bash-env.nu")

bash-env ~/.profile | load-env
brew shellenv | bash-env | load-env

source ($cfg | path join "alias.nu")
source ($cfg | path join "ai.nu")
source ($cfg | path join "zoxide.nu")

use ($cfg | path join "rose-pine-dawn.nu")

let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
}

const history_path = ($nu.data-dir | path join "history.txt")

$env.config = {
  edit_mode: 'vi',
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
