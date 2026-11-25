# Local-first task manager (TUI + agent CLI). Package from llm-agents;
# pin ghcr.io/raine/aven in homelab stacks/aven-sync to the same version.
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  aven = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.aven;
in
{
  home.packages = [ aven ];

  # Nix owns the binary; skip aven's GitHub release check.
  home.sessionVariables.AVEN_NO_UPDATE_CHECK = "1";

  # Read-only to aven (symlink). Edit this file instead of `aven config set`.
  xdg.configFile."aven/config.yaml".text = ''
    update:
      automatic_checks: false

    sync:
      enabled: true
      interval_seconds: 30

    project:
      overrides:
        - project: nix-config
          paths: ["~/src/nix-config"]
        - project: homelab
          paths: ["~/src/homelab"]
        - project: grok
          paths: ["~/src/grok"]
        - project: opencode
          paths: ["~/src/opencode"]
        - project: personal
          paths: ["~/src/CV"]
  '';

  # Foreground `aven daemon` (not `daemon install`, which writes its own unit).
  # Idles until this database is set up or joined.
  systemd.user.services.aven-daemon = {
    Unit = {
      Description = "Aven sync daemon";
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe aven} daemon";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
