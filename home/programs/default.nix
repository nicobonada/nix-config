{
  imports = [
    ./check-inputs.nix
    ./cli.nix
    ./direnv.nix
    ./gui
    # Grok is project-scoped: `nix develop` / direnv (flake input grok-config), not HM
    ./media.nix
    ./networking.nix
    ./nix-pkgs-browse.nix
    ./nvim.nix
    ./ssh.nix

    ./fish
    ./git
  ];
}

