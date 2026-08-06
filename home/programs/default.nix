{
  imports = [
    ./cli.nix
    ./gui
    # Grok is project-scoped: `nix develop` (flake input grok-config), not HM
    ./media.nix
    ./networking.nix
    ./nix-pkgs-browse.nix
    ./nvim.nix
    ./ssh.nix

    ./fish
    ./git
  ];
}

