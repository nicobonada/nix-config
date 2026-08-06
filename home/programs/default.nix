{
  imports = [
    ./cli.nix
    ./gui
    # Grok is project-scoped (nix develop), not home-manager — see ~/grok-config
    ./media.nix
    ./networking.nix
    ./nix-pkgs-browse.nix
    ./nvim.nix
    ./ssh.nix

    ./fish
    ./git
  ];
}

