{ inputs, pkgs, config, ... }:
{
  imports = [ inputs.grok-config.homeManagerModules.default ];

  programs.grokConfig = {
    enable = true;
    source = "${config.home.homeDirectory}/grok-config";
    # Wrapper prepends agent-apps to PATH for Grok only (see grok-config).
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.grok;
  };
}
