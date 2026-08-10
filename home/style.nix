{ inputs, pkgs, ... }:
{
  # Fonts, Stylix palette, and toolkit theming (GTK/Qt).
  # Kitty font/theme stay in programs/gui/kitty.nix — not managed here.
  imports = [ inputs.stylix.homeModules.stylix ];

  fonts.fontconfig = {
    enable = true;
    # CSS generics / browsers (GTK/Qt use stylix.fonts.* directly).
    defaultFonts = {
      sansSerif = [ "Inter" ];
      monospace = [ "Comic Code Ligatures" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  home.packages = with pkgs; [
    font-awesome_5
    comic-neue
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-color-emoji
  ];

  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
    polarity = "dark";

    fonts = {
      # UI chrome (GTK/Qt, fontconfig sans-serif / system-ui).
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      # Private desktop font; installed outside nixpkgs.
      monospace.name = "Comic Code Ligatures";

      sizes = {
        # GTK + Qt UI text (one knob). Terminal size is kitty's own setting.
        applications = 12;
        desktop = 12;
      };
    };

    # icons = {
    #   enable = true;
    #   dark = "Papirus-Dark";
    # };

    targets = {
      fish.enable = true;
      vivid.enable = true;
      yazi.enable = true;
      jjui.enable = true;
      bat.enable = true;

      # Opt-in: applies fonts *and* dark Kanagawa theming (adw-gtk3 CSS + Qt/Kvantum).
      # No fonts-only path in Stylix — size alone is not available.
      gtk.enable = true;
      qt.enable = true;
    };
  };
}
