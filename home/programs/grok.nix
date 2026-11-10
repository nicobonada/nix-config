# Home-wide Grok Build binary (pkgs/grok). Does not manage ~/.grok/config.toml.
{
  grokPkg,
  lib,
  config,
  pkgs,
  ...
}:
let
  checkoutGrok = "${config.home.homeDirectory}/src/grok";
  # Activation PATH is not the user/agent PATH; sync-portable-config is env python3.
  ensureGrokPath = lib.makeBinPath [ pkgs.python3 ];
  # writeShellApplication PATH is runtimeInputs only. Copy the TUI
  # package onto the agent PATH so `tuicr review` works in tool shells.
  grok = grokPkg.override {
    extraAgentApps = lib.optional (
      config.programs.tuicr.enable && config.programs.tuicr.package != null
    ) config.programs.tuicr.package;
  };
in
{
  home.packages = [ grok ];
  # Desktop launches may not inherit a full user PATH.
  home.sessionVariables.GROK_BIN = lib.getExe grok;

  # Prefer the on-disk checkout (git-writable rules/skills), not a store path.
  home.activation.ensureGrokHome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    root=${lib.escapeShellArg checkoutGrok}
    if [[ -x "$root/scripts/ensure-grok-home" ]]; then
      $DRY_RUN_CMD env \
        PATH=${lib.escapeShellArg ensureGrokPath}''${PATH:+:$PATH} \
        GROK_CONFIG_ROOT="$root" \
        "$root/scripts/ensure-grok-home" || true
    fi
  '';
}
