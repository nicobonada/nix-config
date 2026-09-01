{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./adb.nix
    ./amd-cpu.nix
    ./amd-gpu.nix
    ./avahi.nix
    ./bluetooth.nix
    ./container.nix
    ./gaming.nix
    ./greeter.nix
    ./keyring.nix
    ./lab-ca.nix
    ./onepassword.nix
    ./sound.nix
    ./yubi.nix
    ./royal-kludge.nix
    ./ssh.nix
    ./uwsm.nix

    inputs.determinate.nixosModules.default
    inputs.auto-cpufreq.nixosModules.default
  ];

  nix = {
    # Make nix3 commands consistent with this flake's inputs
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;

      trusted-users = [
        "root"
        "@wheel"
      ];

      extra-substituters = [
        "https://cache.numtide.com"
        "https://noctalia.cachix.org"
      ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };

  # Shared by oakhill + seyruun (host-specific bits stay in configuration.nix).
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "America/Toronto";
  networking.networkmanager.enable = true;
  services.logind.settings.Login.HandlePowerKey = "suspend";

  i18n = {
    defaultLocale = "en_CA.UTF-8";
    extraLocaleSettings = {
      LC_COLLATE = "C.UTF-8";
    };
  };

  users.extraUsers.nico = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "i2c" # for external monitor brightness control
    ];
  };

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs; [
    neovim
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
    # openssh + tailscale --ssh: see ./ssh.nix
    gvfs.enable = true;
    locate.enable = true;
    smartd.enable = true;
    journald.extraConfig = "SystemMaxUse=500M";
    fstrim.enable = true;
    upower.enable = true;
    udisks2.enable = true;
    fwupd.enable = true;
    chrony.enable = true;
    tailscale.enable = true;
    # "client" keeps exit-node use available (e.g. Mullvad) when you opt in;
    # do not set a default --exit-node here — leave Mullvad off unless enabled by hand.
    tailscale.useRoutingFeatures = "client";
    # resolved + Tailscale: needed so MagicDNS survives resume. Do not cache
    # NXDOMAIN — a public resolver can answer first while the lab DNS is still
    # coming up after suspend, and that negative would otherwise stick.
    resolved = {
      enable = true;
      settings.Resolve.Cache = "no-negative";
    };
  };

  programs = {
    nh.enable = true;
    # nh.flake = /home/nico/src/nix-config;

    fish.enable = true;

    appimage.enable = true;
    appimage.binfmt = true;

    partition-manager.enable = true;
    partition-manager.package = pkgs.kdePackages.partitionmanager;

    wireshark.enable = true;
    wireshark.package = pkgs.wireshark;

    auto-cpufreq.enable = true;

    niri.enable = true;
  };

  hardware.i2c.enable = true; # used for external monitor brightness control

  security.polkit.enable = true;

  # Allow kde connect via home-manager
  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}
