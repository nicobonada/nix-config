{ inputs, config, ... }:
{
  imports = [ inputs.grok-config.homeManagerModules.default ];

  programs.grokConfig = {
    enable = true;
    source = "${config.home.homeDirectory}/grok-config";
  };
}
