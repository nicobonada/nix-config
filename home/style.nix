{
  inputs,
  pkgs,
  config,
  ...
}:
let
  inherit (config.stylix.fonts) monospace sansSerif;
  uiSize = toString config.stylix.fonts.sizes.applications;
  # qt6ct wants the size in the same quoted string as the family.
  qtFonts = {
    fixed = ''"${monospace.name},${uiSize}"'';
    general = ''"${sansSerif.name},${uiSize}"'';
  };
in
{
  # Fonts, Stylix palette, and toolkit theming (GTK/Qt).
  # Kitty font/theme stay in programs/kitty.nix - not managed here.
  imports = [ inputs.stylix.homeModules.stylix ];

  fonts.fontconfig = {
    enable = true;
    # CSS generics / browsers (GTK/Qt use stylix.fonts.* directly).
    defaultFonts = {
      sansSerif = [ "Inter" ];
      serif = [ "Source Serif 4" ];
      monospace = [ "Comic Code Ligatures" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  home.packages = with pkgs; [
    font-awesome_5
    comic-neue
    # Explicit install so pickers (LibreOffice, etc.) list it; also stylix.fonts.serif.
    source-serif
    # Explicit install so Typst / pickers list it; also stylix.fonts.sansSerif.
    inter
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
      # Document / CSS serif generic — pairs with Inter.
      serif = {
        package = pkgs.source-serif;
        name = "Source Serif 4";
      };
      # Private desktop font; installed outside nixpkgs.
      monospace.name = "Comic Code Ligatures";

      sizes = {
        # GTK + Qt UI text (one knob). Terminal size is kitty's own setting.
        applications = 12;
        desktop = 12;
      };
    };

    targets = {
      fish.enable = true;
      vivid.enable = true;
      yazi.enable = true;
      jjui.enable = true;
      bat.enable = true;
      zathura.enable = true;

      # Opt-in: fonts and dark Kanagawa (adw-gtk3 CSS). No fonts-only
      # path in Stylix. Qt is separate below: Stylix's Kvantum theme
      # paints menus and toolbars with unreadable contrast.
      gtk.enable = true;
      qt.enable = false;
    };
  };

  # Fusion is Qt's built-in style (qt6ct's own fallback). Set it so a
  # stale qt6ct.conf cannot bring Kvantum back. Fonts still follow the
  # Stylix application size. Do not set qt.style.name: that exports
  # QT_STYLE_OVERRIDE, which is what pinned this session to Kvantum.
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    qt5ctSettings = {
      Appearance.style = "Fusion";
      Fonts = qtFonts;
    };
    qt6ctSettings = {
      Appearance.style = "Fusion";
      Fonts = qtFonts;
    };
  };
}
