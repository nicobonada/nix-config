{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  # Type=simple marks noctalia started when the process forks, about a second
  # before it owns org.kde.StatusNotifierWatcher. Qt and Electron tray clients
  # register once and do not retry, so the session target waits for the name.
  waitForTrayWatcher = pkgs.writeShellScript "wait-for-status-notifier-watcher" ''
    set -eu
    name=org.kde.StatusNotifierWatcher
    i=0
    while [ "$i" -lt 150 ]; do
      if ${pkgs.systemd}/bin/busctl --user status "$name" >/dev/null 2>&1; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 0.1
      i=$((i + 1))
    done
    echo "$name was not owned within 15s" >&2
    exit 1
  '';
in
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
  # Forking the process is not the same as owning the tray watcher, so start
  # Noctalia first and hold the session target on noctalia-watcher.service.
  systemd.user.services.noctalia = {
    Unit = {
      After = lib.mkForce [
        "graphical-session-pre.target"
        "sops-nix.service"
      ];
      Before = [ "graphical-session.target" ];
      Wants = [ "sops-nix.service" ];
    };
  };

  systemd.user.services.noctalia-watcher = {
    Unit = {
      Description = "Wait until Noctalia owns the tray watcher";
      After = [ "noctalia.service" ];
      Before = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = 20;
      ExecStart = "${waitForTrayWatcher}";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
