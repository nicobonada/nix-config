{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ./adb.nix
    ./amd-cpu.nix
    ./amd-gpu.nix
    ./avahi.nix
    ./bluetooth.nix
    ./container.nix
    ./fish.nix
    ./gaming.nix
    ./keyring.nix
    ./hypr.nix
    ./sound.nix
    ./yubi.nix
  ];

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  i18n = {
    defaultLocale = "en_CA.UTF-8";
    extraLocaleSettings = { LC_COLLATE = "C.UTF-8"; };
  };
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nico = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
  };

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    file
    psmisc
    usbutils
    sshfs
    smartmontools
  ];

  services = {
    printing.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    gvfs.enable = true;

    locate.enable = true;

    smartd.enable = true;

    mullvad-vpn.enable = true;
    mullvad-vpn.package = pkgs.mullvad-vpn;

    journald.extraConfig = "SystemMaxUse=500M";

    fstrim.enable = true;

    upower.enable = true;
    udisks2.enable = true;

    dictd.enable = true;

    fwupd.enable = true;

    power-profiles-daemon.enable = true;

    chrony.enable = true;
  };

  programs = {
    nh.enable = true;
    # nh.flake = /home/nico/nix-config;

    appimage.enable = true;
    appimage.binfmt = true;

    partition-manager.enable = true;
    partition-manager.package = pkgs.kdePackages.partitionmanager;

    wireshark.enable = true;
    wireshark.package = pkgs.wireshark;
  };

  security.polkit.enable = true;

  # Allow kde connect via home-manager
  networking.firewall = rec {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}
