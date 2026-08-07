{
  config,
  lib,
  pkgs,
  ...
}:
let
  beetsLiveDb = "${config.home.homeDirectory}/.config/beets/library.db";
  beetsState = "${config.home.homeDirectory}/.config/beets/state.pickle";
  stagingDir = "${config.xdg.dataHome}/beets-backup";
  musicDir = "${config.home.homeDirectory}/music";

  # Decrypted by sops-nix at activation (age key: ~/.config/sops/age/keys.txt).
  passwordFile = config.sops.secrets."music_backup/restic_password".path;
  envFile = config.sops.templates."music-backup.env".path;

  music-backup = pkgs.writeShellApplication {
    name = "music-backup";
    runtimeInputs = with pkgs; [
      restic
      sqlite
      coreutils
    ];
    # Env path is a sops-nix runtime path, not constant for shellcheck.
    excludeShellChecks = [ "SC1090" ];
    text = ''
      # Prerequisites for a real backup run:
      #   - sops-nix activated secrets (age key at ~/.config/sops/age/keys.txt)
      #   - B2 app key material in secrets/music-backup.yaml (not CHANGE_ME)
      #   - restic repo password + RESTIC_REPOSITORY in that same sops file
      #   - ~/music directory present (writer host; typically seyruun)
      #   - optional but expected: ~/.config/beets/library.db (sqlite-snapshotted
      #     into XDG data before restic; missing DB is a warning only)
      #   - network to Backblaze
      # Separate from hypervisor VM dumps (different B2 bucket / job).
      set -euo pipefail

      env_file=${lib.escapeShellArg envFile}
      password_file=${lib.escapeShellArg passwordFile}
      staging=${lib.escapeShellArg stagingDir}
      music=${lib.escapeShellArg musicDir}
      live_db=${lib.escapeShellArg beetsLiveDb}
      state_pickle=${lib.escapeShellArg beetsState}

      if [[ ! -f $env_file ]]; then
        echo "music-backup: missing sops template $env_file (skip)" >&2
        exit 0
      fi
      if [[ ! -f $password_file ]]; then
        echo "music-backup: missing sops secret restic password at $password_file" >&2
        exit 1
      fi
      if [[ ! -d $music ]]; then
        echo "music-backup: missing music dir $music (skip)" >&2
        exit 0
      fi

      set -a
      source "$env_file"
      set +a

      : "''${RESTIC_REPOSITORY:?RESTIC_REPOSITORY missing from sops template}"
      if [[ -z ''${B2_ACCOUNT_ID:-} || -z ''${B2_ACCOUNT_KEY:-} \
         || ''${B2_ACCOUNT_ID} == CHANGE_ME || ''${B2_ACCOUNT_KEY} == CHANGE_ME ]]; then
        echo "music-backup: B2 credentials still CHANGE_ME in sops (skip)" >&2
        exit 0
      fi
      export RESTIC_PASSWORD_FILE="$password_file"
      export RESTIC_REPOSITORY

      mkdir -p "$staging"
      chmod 700 "$staging"

      # Consistent SQLite snapshot (never restic the live DB while beets may write).
      if [[ -f $live_db ]]; then
        sqlite3 "$live_db" ".backup '$staging/library.db'"
      else
        echo "music-backup: warning: no live beets DB at $live_db" >&2
      fi
      if [[ -f $state_pickle ]]; then
        cp -a "$state_pickle" "$staging/state.pickle"
      fi

      # Thin retention for ~130G media; not the 3-copy VM rclone policy.
      keep_daily="''${RESTIC_KEEP_DAILY:-3}"
      keep_weekly="''${RESTIC_KEEP_WEEKLY:-1}"

      restic backup \
        --one-file-system \
        --tag music \
        --tag beets \
        "$music" \
        "$staging"

      restic forget \
        --tag music \
        --keep-daily "$keep_daily" \
        --keep-weekly "$keep_weekly" \
        --prune

      restic snapshots --tag music --latest 5
    '';
  };

  music-backup-init = pkgs.writeShellApplication {
    name = "music-backup-init";
    runtimeInputs = with pkgs; [
      restic
      coreutils
    ];
    excludeShellChecks = [ "SC1090" ];
    text = ''
      # One-time restic init for the B2 repository in sops.
      # Same prerequisites as music-backup (sops secrets + valid B2 key, not CHANGE_ME).
      set -euo pipefail

      env_file=${lib.escapeShellArg envFile}
      password_file=${lib.escapeShellArg passwordFile}

      if [[ ! -f $env_file || ! -f $password_file ]]; then
        echo "music-backup-init: sops secrets not available (run home-manager switch with age key)" >&2
        exit 1
      fi

      set -a
      source "$env_file"
      set +a

      : "''${RESTIC_REPOSITORY:?RESTIC_REPOSITORY missing from sops template}"
      if [[ ''${B2_ACCOUNT_ID:-} == CHANGE_ME || ''${B2_ACCOUNT_KEY:-} == CHANGE_ME ]]; then
        echo "music-backup-init: set real B2 keys in secrets/music-backup.yaml via sops first" >&2
        exit 1
      fi
      export RESTIC_PASSWORD_FILE="$password_file"
      export RESTIC_REPOSITORY

      restic init
      echo "Initialized $RESTIC_REPOSITORY"
    '';
  };
in
{
  home.packages = [
    music-backup
    music-backup-init
    pkgs.restic
    pkgs.sops
    pkgs.age
  ];

  sops = {
    defaultSopsFile = ../../secrets/music-backup.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      "music_backup/b2_account_id" = { };
      "music_backup/b2_account_key" = { };
      "music_backup/restic_password" = { };
      "music_backup/restic_repository" = { };
    };

    templates."music-backup.env" = {
      content = ''
        B2_ACCOUNT_ID=${config.sops.placeholder."music_backup/b2_account_id"}
        B2_ACCOUNT_KEY=${config.sops.placeholder."music_backup/b2_account_key"}
        RESTIC_REPOSITORY=${config.sops.placeholder."music_backup/restic_repository"}
        RESTIC_KEEP_DAILY=3
        RESTIC_KEEP_WEEKLY=1
      '';
    };
  };

  # Manual: music-backup / music-backup-init
  # Scheduled: daily; skips if ~/music missing or B2 still CHANGE_ME.
  systemd.user.services.music-backup = {
    Unit = {
      Description = "Restic backup of music library and beets state to B2";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
      ConditionPathIsDirectory = musicDir;
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe music-backup;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
  };

  systemd.user.timers.music-backup = {
    Unit = {
      Description = "Daily restic music/beets backup";
      ConditionPathIsDirectory = musicDir;
    };
    Timer = {
      OnCalendar = "*-*-* 03:30:00";
      Persistent = true;
      RandomizedDelaySec = "20m";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
