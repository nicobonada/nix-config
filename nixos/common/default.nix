{ pkgs, ... }:
{
  imports = [
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
  users.users.nico = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "adbusers"
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

    lxqt.lxqt-policykit
  ];

  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    gvfs.enable = true;

    locate = {
      enable = true;
      package = pkgs.plocate;
      localuser = null;
    };

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

    tlp.enable = true;
    tlp.settings = {
      DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
      USB_ALLOWLIST = "32ac:0002"; # Framework HDMI adapter
    };

    mullvad-vpn.enable = true;
    mullvad-vpn.package = pkgs.mullvad-vpn;

    journald.extraConfig = "SystemMaxUse=500M";
    logind.lidSwitch = "ignore";
    logind.extraConfig = "HandlePowerKey=suspend";

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
    fish.enable = true;

    # gamemode.enable = true;

    nh.enable = true;
    # nh.flake = /home/nico/nix-config;

    appimage.enable = true;
    appimage.binfmt = true;

    adb.enable = true;
  };

  security.polkit.enable = true;
}
