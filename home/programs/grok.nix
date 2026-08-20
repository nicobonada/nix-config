# Home-wide Grok Build binary (pkgs/grok). Does not manage ~/.grok/config.toml.
{
  grokPkg,
  lib,
  config,
  ...
}:
let
  checkoutGrok = "${config.home.homeDirectory}/src/grok";
in
{
  home.packages = [ grokPkg ];

  # Prefer the on-disk checkout (git-writable rules/skills), not a store path.
  home.activation.ensureGrokHome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    root=${lib.escapeShellArg checkoutGrok}
    if [[ -x "$root/scripts/ensure-grok-home" ]]; then
      $DRY_RUN_CMD env GROK_CONFIG_ROOT="$root" \
        "$root/scripts/ensure-grok-home" || true
    fi
  '';
}
