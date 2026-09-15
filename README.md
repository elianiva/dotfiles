# elianiva's dotfiles

Nix-managed dotfiles for **macOS (nix-darwin + home-manager)** and **Linux (home-manager standalone)** with full feature parity. Built on [Determinate Nix](https://determinate.systems/nix/) (`nixd`).

Here are some of the screenshots from time to time (the config may or may not be still here, idk):

![arch](./screenshots/preview-arch.png)
![arch-new](./screenshots/preview-arch-new.png)
![old](./screenshots/preview-old.png)
![plasma](./screenshots/preview-plasma.png)
![fedora](./screenshots/preview-fedora.png)
![fedora-2](https://github.com/user-attachments/assets/ce263afd-1986-4c55-93a8-10494302c464)
![macos](https://github.com/user-attachments/assets/e6a1be22-b773-4e0c-b022-eedc70fa8ca8)

---

## Architecture

Built with [Den](https://den.denful.dev) — aspect-oriented Nix. Every file under `modules/` is loaded by `import-tree`, and each one contributes either an **aspect** (`den.aspects.<name>`), an **entity** (`den.hosts` / `den.homes`), or a global default. Den resolves those into the flake outputs.

```
flake.nix                             # inputs + evalModules + import-tree, nothing else
└── modules/
    ├── den.nix                       # Den wiring: schema defaults + den.default (stateVersion, …)
    ├── hosts.nix                     # den.hosts (melon) + den.homes (linux)
    ├── user.nix                      # den.aspects.elianiva + platform variants
    ├── _lib/                         # ignored by import-tree: plain data & helpers
    │   ├── identity.nix              # username / home dir / git identity
    │   ├── fonts.nix
    │   └── brews.nix  casks.nix  vp-global-packages.nix
    └── aspects/                      # one concern per file, all platforms
        ├── host-darwin.nix           # melon: system defaults, nixpkgs overlays, home-manager opts
        ├── homebrew.nix              # nix-homebrew taps + homebrew brews/casks
        ├── home-linux.nix            # genericLinux + nixGL + nix.gc
        ├── packages.nix  fonts.nix  rust.nix
        ├── programs.nix              # direnv, bat, btop, fzf, carapace, zoxide, starship
        ├── git.nix  gpg.nix  agents.nix  shell-files.nix  vp-global-packages.nix
        └── nvim.nix  fish.nix  nushell.nix  ghostty.nix  kitty.nix  …
```

Resolved outputs:

```
darwinConfigurations.melon           aarch64-darwin — nix-darwin + home-manager + nix-homebrew
homeConfigurations.elianiva          aarch64-linux  — home-manager standalone
homeConfigurations.elianiva@intel    x86_64-linux
homeConfigurations.elianiva@asahi    aarch64-linux
```

An aspect holds the config a single concern needs in every class it touches, e.g. `aspects/packages.nix` puts CLI tools in `darwin.environment.systemPackages` *and* in (Linux) `homeManager.home.packages`; `aspects/ghostty.nix` holds the config symlink, the macOS `Library/Application Support` symlink, and the Linux nixGL-wrapped package. Hosts/users/homes only pick aspects (`den.aspects.elianiva.includes`, `den.aspects.elianiva-linux.includes`, `den.aspects.melon.includes`).

Shared sources of truth:

| Concern | Defined once | Used by |
|---------|--------------|---------|
| CLI tools & editors | `aspects/packages.nix` | darwin `environment.systemPackages`, linux `home.packages` |
| Rust toolchain (fenix) | `aspects/rust.nix` | same split |
| Fonts (MonaSpace, Inter, Lora, Lilex, Departure Mono, Ioshelfka, Iosevka 34.8 TTC) | `_lib/fonts.nix` via `aspects/fonts.nix` | darwin `fonts.packages`, linux `home.packages` + `fonts.fontconfig` |
| Terminal configs (ghostty/kitty/wezterm) | their own aspect | both — `aspects/ghostty.nix` carries the nixGL wrap *and* the macOS Application Support symlink |
| Direnv integrations, shell programs | `aspects/programs.nix` | both |

Platform extras are thin:

- `aspects/host-darwin.nix` — macOS system defaults, `nixpkgs.overlays` (fenix, jj-starship), `home-manager.useGlobalPkgs`
- `aspects/homebrew.nix` — nix-homebrew taps + `homebrew` brews/casks
- `aspects/home-linux.nix` — `targets.genericLinux`, nixGL, `nix.gc`
- Darwin-only `[ iina ]` and Linux-only `[ pinentry-gnome3, nixGLIntel, lazydocker, zathura ]` live next to the shared list in `aspects/packages.nix`

---

## Prerequisites

- **Nix**: [Determinate Nix](https://determinate.systems/posts/determinate-nix/) is assumed throughout. It ships `nixd` (`determinate-nixd`), manages `/etc/nix/nix.conf` (including `nix.custom.conf`), enables `flakes` + `nix-command` by default, and provides FlakeHub caching. Stock `nix` works too, but commands below use Determinate's layout.
- **Git & curl**: needed to clone and fetch flakes.
- **Identity**: default user is `elianiva` (`/Users/elianiva` on macOS, `/home/elianiva` on Linux) and hostname `melon` — see [`modules/_lib/identity.nix`](./modules/_lib/identity.nix) and the host/home names in [`modules/hosts.nix`](./modules/hosts.nix). If your username/home differs, edit those *before* the first switch (or pass `--impure` with an override — not recommended).
- **Dotfiles location**: `~/.dotfiles` must remain at `~/.dotfiles` — configs are linked via `mkOutOfStoreSymlink` to that path. Moving it breaks all `xdg.configFile`/`home.file` symlinks until you re-switch.

---

## Bootstrap — Empty Linux Box (Determinate Nix)

Tested on Ubuntu/Debian/Fedora/Arch (x86_64-linux). For `aarch64-linux`, see notes at the end.

### 1. Install Determinate Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# restart shell so /nix/var/nix/profiles/default/etc/profile.d/nix.sh is sourced
exec $SHELL -l
nix --version  # should print: nix (Determinate Nix 3.x) 2.28.x
```

Determinate writes:

- `/etc/nix/nix.conf` (managed, includes `nix.custom.conf` and FlakeHub `extra-substituters`)
- `/etc/nix/nix.custom.conf` — your `trusted-users` etc. (installer adds `trusted-users = root <you>`)
- `/nix` store + `determinate-nixd` daemon

Verify daemon:

```bash
sudo determinate-nixd status 2>/dev/null || systemctl status determinate-nixd 2>/dev/null | head -n 20
```

No manual `experimental-features` edit needed — Determinate enables `nix-command flakes` out of the box (`lazy-trees` as well).

### 2. Install git & clone

```bash
# Debian/Ubuntu
sudo apt update && sudo apt install -y git curl

# Fedora
sudo dnf install -y git curl

# Arch
sudo pacman -S --needed git curl
```

```bash
git clone git@github.com:elianiva/dotfiles ~/.dotfiles
# or HTTPS if no SSH key yet:
# git clone https://github.com/elianiva/dotfiles ~/.dotfiles
cd ~/.dotfiles
```

### 3. First switch (no `nh` yet)

`nh` (nix helper) is in `packages.nix` so it will be available *after* the first switch. Bootstrap with `nix run`:

```bash
# From inside ~/.dotfiles
nix run home-manager -- switch --flake .#elianiva --print-build-logs
```

What this does:

- Each `den.homes.<system>.<name>` gets its own `pkgs`: `nixpkgs` with `allowUnfree = true` + `fenix` + `jj-starship` overlays (`modules/hosts.nix`)
- `den.aspects.packages` + `den.aspects.rust` + `den.aspects.fonts` contribute `home.packages` through their Linux branch
- `den.aspects.home-linux` enables `targets.genericLinux` + `nixGL` (`mesa` wrapper), `nix.gc`
- Symlinks everything via `mkOutOfStoreSymlink`, one aspect per tool — `~/.config/nvim`, `~/.config/ghostty`, `fish`, `nushell`, `jjui`, `yazi`, etc. all point into `~/.dotfiles`

**First-run conflict handling:** if you have existing `~/.config/fish`, `~/.bashrc`, etc., home-manager will error with `existing file ... would be clobbered`. Either back up and remove:

```bash
mv ~/.config/fish ~/.config/fish.bak 2>/dev/null; mv ~/.bashrc ~/.bashrc.bak 2>/dev/null
nix run home-manager -- switch --flake .#elianiva --print-build-logs -b bak
# -b bak tells home-manager to move conflicts to *.bak automatically
```

Re-login or source the new shell:

```bash
exec $SHELL -l
# or if using fish/nushell:
# exec fish -l
```

### 4. Daily usage after bootstrap

`nh` and `just` are now in `PATH`:

```bash
# rebuild after editing dotfiles
just linux
# equivalent to: nh home switch --flake .#elianiva --print-build-logs

# update flake inputs
nix flake update
just linux

# garbage collect
just clean   # nh clean
nix-collect-garbage -d

# Determinate upgrade (when Determinate publishes a new Nix)
sudo determinate-nixd upgrade
```

### 5. Post-bootstrap checks

```bash
home-manager generations | head
ghostty --version        # wrapped via nixGL.mesa on non-NixOS
fc-list | grep -i iosevka | head
gpg --list-keys
jj --version
cargo --version          # fenix rust
```

**GPU (nixGL)**: `modules/aspects/ghostty.nix` wraps `ghostty` with `nixGLIntel` + `targets.genericLinux.nixGL.defaultWrapper = "mesa"`. On non-NixOS you need Mesa/Intel drivers from the host. If `ghostty` fails with GL errors, try `nix run nixGL -- ghostty` or install host `mesa-utils`.

**Fonts**: `fonts.fontconfig` is enabled with `defaultFonts.monospace = ["JetBrainsMono"]`. All fonts from `_lib/fonts.nix` are in `home.packages`; `fc-cache -f` runs automatically via home-manager.

### Linux notes & gotchas

- **Username/home mismatch**: edit `modules/_lib/identity.nix` (`homeDirFor`) *before* the first switch, otherwise home-manager creates `/home/elianiva` while your actual `$HOME` is different.
- **aarch64-linux**: `modules/hosts.nix` declares `aarch64-linux` homes (`elianiva`, `elianiva@asahi`) and an `x86_64-linux` one (`elianiva@intel`) — add another `den.homes.<system>.<name>` entry for a new machine. `nixGLIntel` is Intel-only and is already skipped on `isAarch64`.
- **Nix-managed Nix**: `modules/aspects/home-linux.nix` sets `nix.enable = true` (home-manager manages Nix). This is intentional for standalone home-manager — on NixOS you'd disable it. On macOS, `nix.enable = false` because Determinate manages Nix.
- **Docker**: `lazydocker` + `zathura` are Linux-only extras; install Docker Engine separately (`sudo apt install docker.io` etc.) — not managed by this flake.
- **FlakeHub 401 warning** (`unable to download https://cache.flakehub.com/nix-cache-info`): harmless if you haven't run `determinate-nixd auth login`. Either `determinate-nixd login` or ignore — `cache.nixos.org` + `nix-community` are still used via `nixConfig`.

---

## Bootstrap — macOS (Determinate Nix + nix-darwin)

### 1. Install Determinate Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
exec $SHELL -l
nix --version
```

### 2. Install Xcode CLI & clone

```bash
xcode-select --install
# verify
xcode-select -p

git clone git@github.com:elianiva/dotfiles ~/.dotfiles
cd ~/.dotfiles
```

### 3. First switch

`nix-darwin` needs `sudo` on first run to install the system profile and create `/etc/nix/nix.conf` integration. Determinate already manages Nix, so `darwin-config.nix` sets `nix.enable = false`.

```bash
# first time — builds darwin system + home-manager generation
sudo nix run nix-darwin -- switch --flake .

# after that, via just/nh (nh is in systemPackages after first switch)
just darwin
# equivalent to: nh darwin switch .
```

What this does:

- `den.hosts.aarch64-darwin.melon` → `darwinConfigurations.melon`, with `nixpkgs.overlays` = `fenix` + `jj-starship` (`aspects/host-darwin.nix`)
- `den.aspects.homebrew` declaratively taps `homebrew/core`, `cask`, `bundle`, `BarutSRB`, `onevcat` (`mutableTaps = false`)
- `homebrew` brews/casks from `modules/_lib/brews.nix`/`casks.nix` (`onActivation.cleanup = "zap"`)
- `environment.systemPackages` from the darwin branch of `aspects/packages.nix` + `aspects/rust.nix`
- `fonts.packages` from the darwin branch of `aspects/fonts.nix` (includes Iosevka 34.8 TTC)
- `home-manager` user `elianiva` = `den.aspects.elianiva` (every tool aspect + git + gpg), sharing the host pkgs via `useGlobalPkgs`
- Symlinks `~/Library/Application Support/nushell` and `…/com.mitchellh.ghostty` from the nushell/ghostty aspects, plus `~/.config/*`, via `mkOutOfStoreSymlink`

### 4. Daily usage

```bash
just darwin
# or: nh darwin switch .

nix flake update
just darwin

just clean
sudo determinate-nixd upgrade
```

### macOS notes

- **Hostname**: the host name (and `networking.hostName`, via `den.batteries.hostname`) comes from `den.hosts.aarch64-darwin.melon` in `modules/hosts.nix`; change it there or `sudo scutil --set HostName <new>` before switch.
- **Homebrew**: managed declaratively. Do not `brew install` manually — add to `modules/_lib/brews.nix`/`casks.nix`. `mutableTaps = false` means manual `brew tap` will be reverted.
- **Rosetta**: `nix-homebrew.enableRosetta = true` allows x86 brews on Apple Silicon.
- **Touch ID for sudo**: `security.pam.services.sudo_local.touchIdAuth = true` — works after first switch.
- **Determinate `nix.conf`**: `/etc/nix/nix.conf` is owned by Determinate (`!include nix.custom.conf`). Do not edit directly — use `nix.custom.conf` or `nixConfig` in `flake.nix`.

---

## Common Tasks

| Task | macOS | Linux |
|------|-------|-------|
| Rebuild | `just darwin` | `just linux` |
| Update inputs | `nix flake update && just darwin` | `nix flake update && just linux` |
| Check flake | `nix flake check` | same |
| Dry build | `nix build .#darwinConfigurations.melon.system --dry-run` | `nix build .#homeConfigurations.elianiva.activationPackage --dry-run` |
| GC | `just clean` | same |
| Edit identity (user/home/host) | `modules/_lib/identity.nix` + `modules/hosts.nix` | same |
| Add CLI tool | `modules/aspects/packages.nix` | same (shared) |
| Add font | `modules/_lib/fonts.nix` | same |
| Add macOS-only package | `modules/aspects/packages.nix` (`mkDarwin`) | — |
| Add Linux-only package | — | `modules/aspects/packages.nix` (`mkLinux`) |
| Add a tool/config | new file in `modules/aspects/` + add it to `den.aspects.elianiva.includes` (`modules/user.nix`) | same |
| Add a machine | `den.hosts.<system>.<host>` (`modules/hosts.nix`) | `den.homes.<system>.<name>` |
| Add brew/cask | `modules/_lib/brews.nix` / `casks.nix` | n/a (use nixpkgs) |

---

## Troubleshooting

**`existing file … would be clobbered` on first switch** — backup or use `-b bak`:
```bash
nix run home-manager -- switch --flake .#elianiva -b bak
sudo nix run nix-darwin -- switch --flake . -b bak
```

**`attribute 'aarch64-darwin' missing` for `ioshelfka`** — `_lib/fonts.nix` already guards with `if ioshelfka.packages ? system then ... else []`. If you add a new font flake, guard similarly.

**`error: Path 'modules/…' is not tracked by Git`** — `git add modules/…` (Nix only sees git-tracked files for flakes; `modules/_lib` is intentionally not imported as modules, but its files still need to be tracked because aspects `import` them).

**`command not found: nh` before first switch** — expected. Use `nix run nixpkgs#nh -- home switch --flake .#elianiva` or `nix run home-manager -- switch ...` for bootstrap.

**Linux `ghostty` GL errors** — ensure `nixGLIntel` matches your GPU. For AMD/Generic Mesa: change `targets.genericLinux.nixGL.defaultWrapper = "mesa"` is already set; for NVIDIA use `nixGLNvidia`.

**Home not at `~/.dotfiles`** — re-clone to `~/.dotfiles`, or change the `dotfiles` field produced by `modules/_lib/identity.nix` and the `${config.home.homeDirectory}/.dotfiles` paths used by the tool aspects.

---

## License

Personal dotfiles — no license, use at your own risk.
