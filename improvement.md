# Nix Configuration Improvements

This document contains recommendations for improving the Nix configuration based on a review of the flake and module files.

### 6. Use Home-Manager Modules for Shell Tools

**Problem:** Several packages are installed but not configured through their HM modules, missing out on shell integration:

- `zoxide` - no shell hooks configured
- `eza` - no aliases configured
- `vivid` - LS_COLORS not set up

**Fix:** Add to `home-common.nix`:
```nix
programs = {
  zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
  };

  eza = {
    enable = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    icons = true;
    git = true;
  };
};
```

For `vivid`, add to shell config:
```nix
programs.nushell.extraConfig = ''
  $env.LS_COLORS = (${pkgs.vivid}/bin/vivid generate molokai)
'';
```

## Nix Best Practices

### 7. Enable Nix Garbage Collection and Store Optimisation

**Problem:** No automatic cleanup configured. The nix store will grow indefinitely.

**Add to `modules/darwin-config.nix`:**
```nix
nix.gc = {
  automatic = true;
  interval = { Hour = 3; Minute = 0; };
  options = "--delete-older-than 7d";
};
nix.optimise.automatic = true;
nix.settings.auto-optimise-store = true;
```

**Add to `modules/linux-home.nix`:**
```nix
nix.gc = {
  automatic = true;
  frequency = "weekly";
  options = "--delete-older-than 7d";
};
nix.settings.auto-optimise-store = true;
```

### 8. Remove Redundant Fenix Overlay

**Problem:** The fenix overlay is applied twice:
1. In `flake.nix`: `overlays = [ fenix.overlays.default ]`
2. In `darwin-config.nix`: `nixpkgs.overlays = [ fenix.overlays.default ]`

**Fix:** Remove the overlay from `darwin-config.nix` since it's already applied in the flake's pkgs import.

### 9. Simplify Unfree Configuration

**Current in `darwin-config.nix` and `linux-home.nix`:**
```nix
allowUnfree = true;
allowUnfreePredicate = (_: true);
```

**Fix:** The predicate is redundant when set to always return true:
```nix
nixpkgs.config.allowUnfree = true;
```

### 10. Add Modern Nix Settings

**Add to both Darwin and Linux configurations:**
```nix
nix.settings = {
  experimental-features = [ "nix-command" "flakes" "repl-flake" ];
  warn-dirty = false;
  # Optional: better build performance
  max-jobs = "auto";
  cores = 0;  # use all available
};
```

## Minor Issues

### 11. Unused Ghostty Input

**Problem:** The `ghostty` input is defined in `flake.nix` but never used. Either:
- Add it to packages if you want to install via Nix
- Remove the input to reduce flake lock size

### 12. Delta vs Difftastic Inconsistency

**Problem:** `delta` is installed and has configuration in `git.nix`, but `lazygit` and `jujutsu` are configured to use `difftastic`.

**Options:**
1. Remove delta if you're using difftastic exclusively
2. Configure different tools for different use cases (e.g., delta for git CLI, difftastic for TUI tools)

### 13. Consider Adding `nh` (Nix Helper) to Darwin

**Observation:** `nh` is installed on Linux but not Darwin. It's useful for both platforms:
```nix
# Add to modules/darwin-packages.nix
nh
```

### 14. Pinentry Package Logic Simplification

**Current in `gpg.nix`:**
```nix
pinentry.package =
  if pkgs.stdenv.isLinux then pkgs.pinentry-gnome3
  else if pkgs.stdenv.isDarwin then pkgs.pinentry_mac
  else pkgs.pinentry-curses;
```

**Observation:** Since `gpg.nix` is imported by both Darwin and Linux configurations (and there's no third platform), this could be simplified by passing the correct package as an argument or using platform-specific imports. However, the current approach is defensive and works fine.

## Quick Reference: Priority Order

1. **Fix duplicate `home.file`** - This is breaking your config
2. **Add `extraSpecialArgs`** - Required for evaluation
3. **Fix `terminals.nix` path** - File not found error
4. **Enable GC** - Prevent disk space issues
5. **Extract common config** - Reduce maintenance burden
6. **Use HM modules for tools** - Better shell integration
