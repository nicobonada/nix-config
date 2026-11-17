# GPUI app (herdr-app) and terminal server (herdr-core).
# Separate llm-agents packages; they do not share session state.
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    # Desktop window. Wrapper suffixes herdr-core onto the app PATH so
    # it does not curl-install a core.
    llm.herdr-app
    # hc CLI on the interactive PATH (server stop/status).
    llm.herdr-core
    # compact layout system-toast mod (Noctalia via Freedesktop).
    pkgs.libnotify
  ];

  # New terminals and recovery shells. Kitty already launches fish the
  # same way. The login shell stays bash.
  xdg.configFile."herdr-core/config.toml".text = ''
    shell = ["${lib.getExe pkgs.fish}"]
  '';
}
