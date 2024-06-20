{ pkgs, ... }:
{
  imports = [
    ./keyring.nix
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

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is
    # enabled by default, no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nico = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    file
    alsa-utils
    psmisc
    usbutils
    sshfs
    smartmontools
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

    smartd = {
      enable = true;
      notifications.x11.enable = true;
    };

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

    # yubikey stuff
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;
  };

  programs = {
    fish.enable = true;

    gamemode.enable = true;
    gamemode.settings.general.inhibit_screensaver = 0;

    nh.enable = true;
    nh.flake = /home/nico/nix-config;

    appimage.enable = true;
    appimage.binfmt = true;
  };
}
