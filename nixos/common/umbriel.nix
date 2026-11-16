{ inputs, pkgs, ... }:
{
  imports = [ inputs.umbriel.nixosModules.default ];

  # Session via start-umbriel (not UWSM). Greeter picks it up from sessionPackages.
  programs.umbriel.enable = true;

  # Umbriel's portal covers ScreenCast/Screenshot/InputCapture; FileChooser
  # was GTK. Luciole ships luciole.portal; GTK stays fallback.
  xdg.portal = {
    extraPortals = [
      inputs.luciole.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    config.umbriel."org.freedesktop.impl.portal.FileChooser" = [
      "luciole"
      "gtk"
    ];
  };
}
