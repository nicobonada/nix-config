{ inputs, ... }:
{
  imports = [ inputs.umbriel.nixosModules.default ];

  # Session via start-umbriel (not UWSM). Greeter picks it up from sessionPackages.
  programs.umbriel.enable = true;
}
