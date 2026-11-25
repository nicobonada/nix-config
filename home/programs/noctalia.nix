{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  # Age key is set in nico.nix so CalDAV still decrypts if trilium
  # bootstrap is off.
  sops.secrets."noctalia/caldav_password" = {
    sopsFile = ../../secrets/noctalia.yaml;
  };

  # Upstream module (not home-manager's): it ships extraPackages, which
  # HM's copy lacks, and disables both HM module paths itself.
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    # Flake pin so the binary hits noctalia.cachix.org (module defaults
    # to pkgs.noctalia). extraPackages wraps it with ddcutil on Noctalia's
    # own PATH, for external-monitor brightness under the systemd unit.
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    extraPackages = [ pkgs.ddcutil ];
    settings = {
      # ddcutil support is opt-in; the binary itself reaches Noctalia
      # via extraPackages above.
      brightness.enable_ddcutil = true;
      # Idle: lock at 5 min, monitors off at 7.5 min, suspend at 10 min.
      # suspend re-locks first (no-op when already locked); order matches
      # the timeouts.
      idle = {
        behavior_order = [
          "lock"
          "screen-off"
          "suspend"
        ];
        behavior = {
          lock = {
            timeout = 300;
            action = "lock";
            enabled = true;
          };
          screen-off = {
            timeout = 450;
            action = "screen_off";
            enabled = true;
          };
          suspend = {
            timeout = 600;
            action = "lock_and_suspend";
            enabled = true;
          };
        };
      };
      calendar = {
        enabled = true;
        refresh_minutes = 15;
        account.fastmail = {
          type = "caldav";
          name = "Fastmail";
          provider = "custom";
          # Fastmail's advertised host root 404s on PROPFIND; /dav/ is the
          # discovery root (current-user-principal lives under it).
          server_url = "https://caldav.fastmail.com/dav/";
          username = "nico@bonada.ca";
          calendars = [ ];
          credential_source = "file";
          password_file = config.sops.secrets."noctalia/caldav_password".path;
        };
      };
      # Spectrum and other audio-reactive Umbriel effects need this feed.
      # This seat already enabled it in settings.toml; keep it in config so
      # a fresh seat or a state reset still provides audio.
      shell.umbriel_audio_provider_enabled = true;
      # Noctalia appends .png itself.
      shell.screenshot = {
        directory = "~/Pictures/Screenshots";
        filename_pattern = "Screenshot from %Y-%m-%d %H-%M-%S";
      };
    };
  };

  # Calendar password_file is the sops-nix decrypt path.
  # home-manager's unit is Type=simple and After=graphical-session.target.
  # The tray name belongs to status-notifier-watcher.service, which is
  # Type=dbus, so it is active only once the name is owned. This unit is
  # Before=graphical-session.target and After= that service, so the
  # session waits. Noctalia then registers as a host, and a bar restart
  # leaves the name in place.
  systemd.user.services.noctalia = {
    Unit = {
      After = lib.mkForce [
        "graphical-session-pre.target"
        "sops-nix.service"
        "status-notifier-watcher.service"
      ];
      Before = [ "graphical-session.target" ];
      Wants = [
        "sops-nix.service"
        "status-notifier-watcher.service"
      ];
    };
  };
}
