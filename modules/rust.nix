{ pkgs, ... }:

[
  # Rust toolchain
  (pkgs.fenix.complete.withComponents [
    "cargo"
    "clippy"
    "rust-src"
    "rustc"
    "rustfmt"
  ])
  pkgs.rust-analyzer
]
