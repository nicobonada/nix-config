{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    ./keyring.nix
    ./hypr.nix
    ./sound.nix
    ./yubi.nix
  ];

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
      "adbusers"
      "wireshark"
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

    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    smartd.enable = true;

    thermald.enable = true;

    # tlp.enable = true;
    # tlp.settings = {
    #   DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
    #   USB_ALLOWLIST = "32ac:0002"; # Framework HDMI adapter
    # };
    auto-cpufreq.enable = true;

    mullvad-vpn.enable = true;
    mullvad-vpn.package = pkgs.mullvad-vpn;

    journald.extraConfig = "SystemMaxUse=500M";
    logind.lidSwitch = "ignore";
    logind.powerKey = "suspend";

    fstrim.enable = true;

    upower.enable = true;
    udisks2.enable = true;

    dictd.enable = true;

    # Treat 8bitdo ultimate controller as xbox controller
    udev.extraRules = /*udev*/''
      ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="3109", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 2dc8 3109 > /sys/bus/usb/drivers/xpad/new_id'"
    '';
  };

  programs = {
    nh.enable = true;
    # nh.flake = /home/nico/nix-config;

    appimage.enable = true;
    appimage.binfmt = true;

    adb.enable = true;

    wireshark.enable = true;
    wireshark.package = pkgs.wireshark;

    partition-manager.enable = true;
    partition-manager.package = pkgs.kdePackages.partitionmanager;
  };

  security.polkit.enable = true;

  # Allow kde connect via home-manager
  networking.firewall = rec {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}
