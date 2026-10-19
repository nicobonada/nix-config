{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  # Seat age key (same file as trilium). Needed here so the CalDAV secret
  # decrypts even if trilium bootstrap is off.
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.secrets."noctalia/caldav_password" = {
    sopsFile = ../../secrets/noctalia.yaml;
  };

  # home-manager ships programs.noctalia (since 03f4cd46); do not also import
  # inputs.noctalia.homeModules.default or enable is declared twice.
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    # Flake pin so the binary hits noctalia.cachix.org (HM defaults to pkgs.noctalia).
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
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
