{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./boot.nix
    ../common
    ./hardware-configuration.nix
  ];

  amd-cpu.enable = true;

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "seyruun";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Toronto";

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandlePowerKey = "suspend";
  systemd.sleep.settings.Sleep = { HibernateDelaySec = "1h"; };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
