# OpenCode 2 TUI. llm-agents keeps v1 as `opencode` (binary opencode)
# and v2 as `opencode2` so they can coexist.
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
  programs.opencode = {
    enable = true;
    package = llm.opencode2;
  };

  # llm-agents ships v2 as `opencode2` so v1 could coexist. Scripts, rules,
  # and ACP clients expect the bare `opencode` name.
  home.packages = [
    (pkgs.runCommand "opencode-alias" { } ''
      mkdir -p $out/bin
      ln -s ${lib.getExe llm.opencode2} $out/bin/opencode
    '')
  ];

  # Nix owns the binary; skip the in-app updater.
  home.sessionVariables.OPENCODE_DISABLE_AUTOUPDATE = "1";
}
