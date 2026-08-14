{ inputs, lib, pkgs, ... }:
let
  custom = import ../../pkgs { inherit pkgs; };
in
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
    cowsay
    dgop
    dua
    duf
    erdtree
    fd
    htop
    inxi
    jq
    lazyjournal
    libqalculate
    lsof
    nix-tree
    nixpkgs-track
    patool
    perlPackages.FileMimeInfo
    procs
    ripgrep
    shellcheck
    systemctl-tui
    sysz
    tree

    custom.nix-pkgs-browse
  ];
}
