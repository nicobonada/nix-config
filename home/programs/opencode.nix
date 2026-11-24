# OpenCode 2 TUI. llm-agents keeps v1 as `opencode` (binary opencode)
# and v2 as `opencode2` so they can coexist.
{
  inputs,
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

  # Nix owns the binary; skip the in-app updater.
  home.sessionVariables.OPENCODE_DISABLE_AUTOUPDATE = "1";
}
