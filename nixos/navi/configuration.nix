# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
    ../common

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  swapDevices = [{ device = "/swap"; size = 8192; }];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

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

  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        devices = [ "nodev" ];
        font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSansMono.ttf";
        fontSize = 32;
      };
      efi.canTouchEfiVariables = true;
    };
    # kernelPackages = pkgs.linuxPackages_zen;
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ntfs" ];
    kernel.sysctl = { "dev.i915.perf_stream_paranoid" = 0; };
    initrd.kernelModules = [ "i915" ];
  };

  networking = {
    hostName = "navi";
    networkmanager.enable = true;
    # networkmanager.wifi.backend = "iwd";
  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;
      dpi = 168;
      enableCtrlAltBackspace = true;

      xkb.options = "terminate:ctrl_alt_bksp,compose:caps";
      autoRepeatDelay = 250;
      autoRepeatInterval = 40;

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          rofi
            i3status
            python3Packages.py3status
            i3lock
            dunst
        ];
      };
    };

    libinput = {
      enable = true;
      touchpad.additionalOptions = ''
        Option "TappingButtonMap" "lmr"
      '';
    };
  };
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedTCPPorts = [ 6600 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "21.05";
}
