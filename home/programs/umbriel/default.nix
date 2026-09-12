{ inputs, ... }:
{
  imports = [ inputs.umbriel.homeModules.default ];

  # Stock packaged config: leave settings unset so HM does not write
  # ~/.config/umbriel/config.toml.
  programs.umbriel.enable = true;
}
