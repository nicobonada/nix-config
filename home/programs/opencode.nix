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

  # Packages the agent needs on PATH (rules/nix.md formatter, agent
  # scripts like trilium-save-note). Interactive-only CLI tools stay in
  # home/programs/cli.nix.
  home.packages = with pkgs; [
    binutils # strings, for reading binaries
    imagemagick # classic image pipeline (identify / magick)
    nixfmt
    (python3.withPackages (ps: [ ps.markdown ])) # agent scripts (trilium-save-note)
    unzip

    # llm-agents ships v2 as `opencode2` so v1 could coexist. Scripts, rules,
    # and ACP clients expect the bare `opencode` name.
    (pkgs.runCommand "opencode-alias" { } ''
      mkdir -p $out/bin
      ln -s ${lib.getExe llm.opencode2} $out/bin/opencode
    '')
    # Desktop client. Shares the same sessions as the CLI.
    llm.opencode2-desktop
  ];

  # Nix owns the binary; skip the in-app updater.
  home.sessionVariables.OPENCODE_DISABLE_AUTOUPDATE = "1";
}
