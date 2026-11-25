{
  custom,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];

  programs = {
    bashmount = {
      enable = true;
      extraConfig = # bash
        ''
          filemanager() {
              ( cd "$1" && ${lib.getExe pkgs.fish} )
          }
        '';
    };

    bat.enable = true;
    btop.enable = true;
    fastfetch.enable = true;
    nix-index.enable = true;
    nix-index-database.comma.enable = true;
    television.enable = true;
    vivid.enable = true;
    yazi.enable = true;
    yazi.shellWrapperName = "y";
    zoxide.enable = true;
  };

  home.packages = with pkgs; [
    # Push to cache.lab.bonada.ca (pull is nix.settings.extra-substituters).
    attic-client
    binutils # strings, for reading binaries
    cowsay
    dua
    duf
    dux-gop
    erdtree
    fd
    htop
    imagemagick # classic image pipeline (identify / magick)
    inxi
    jq
    lazyjournal
    libqalculate
    lsof
    nix-tree
    nixpkgs-track
    pandoc
    patool
    perlPackages.FileMimeInfo
    procs
    (python3.withPackages (ps: [ ps.markdown ])) # agent scripts (trilium-save-note)
    ripgrep
    shellcheck
    systemctl-tui
    sysz
    tree
    typst
    unzip

    custom.nix-pkgs-browse
  ];
}
