# homebrew shellenv; guarded so it doesn't break on Linux
if (which brew | is-not-empty) {
  brew shellenv | bash-env | load-env
}
