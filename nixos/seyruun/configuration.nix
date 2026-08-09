{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./boot.nix
    ../common
    ./hardware-configuration.nix
  ];

  amd-cpu.enable = true;

  networking.hostName = "seyruun";

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  systemd.sleep.settings.Sleep = { HibernateDelaySec = "1h"; };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
