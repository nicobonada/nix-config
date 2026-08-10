{ lib, pkgs, config, ... }:
{
  imports = [
    ./jujutsu.nix
  ];

  programs.git = {
    enable = true;

    package = pkgs.gitFull;

    # 1Password SSH commit signing (not GPG).
    # Upstream snippet uses /opt/1Password/op-ssh-sign — wrong on NixOS.
    # Desktop app package ships op-ssh-sign; agent must be unlocked to sign.
    signing = {
      format = "ssh";
      # Public key material (same as 1Password SSH key id_ed25519 / nico@oakhill).
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiS0WGMF1xtibs+k+4WjkpPCv0stUUGY7E75Nuh2Fib";
      signByDefault = true;
      signer = "${pkgs._1password-gui}/bin/op-ssh-sign";
    };

    settings = {
      user.name = "Nicolás Bonada";
      user.email = "nico@bonada.ca";
      alias.st = "status";
      diff.tool = "kdiff3";
      merge.tool = "kdiff3";
      init.defaultBranch = "main";
      pull.rebase = "false";
    };
  };

  programs.delta.enable = true;
  programs.delta.enableGitIntegration = lib.mkIf config.programs.git.enable true;

  home.packages = with pkgs; [
    lazygit
    gh
  ];
}
