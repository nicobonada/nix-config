{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.trilium-server;

  # Managed config outside dataDir so rebuilds don't fight a live document.db.
  # pkgs.formats.ini → lib.generators.toINI + writeText.
  #
  # Sync host storage:
  #   - Runtime reads: config.ini / env Sync.* **if set**, else document.db options.
  #   - Unattended join: POST /api/setup/sync-from-server (same as first-run UI).
  configIni =
    (pkgs.formats.ini { }).generate "trilium-server-config.ini" (
      {
        General = {
          instanceName = cfg.instanceName;
          noDesktopIcon = true;
          noBackup = cfg.noBackup;
          noAuthentication = cfg.noAuthentication;
        };
        Network = {
          host = cfg.host;
          port = cfg.port;
          https = false;
        };
      }
      // lib.optionalAttrs (cfg.sync.serverHost != null) {
        Sync = {
          syncServerHost = cfg.sync.serverHost;
        }
        // lib.optionalAttrs (cfg.sync.serverTimeout != null) {
          syncServerTimeout = cfg.sync.serverTimeout;
        }
        // lib.optionalAttrs (cfg.sync.proxy != null) {
          syncServerProxy = cfg.sync.proxy;
        };
      }
    );

  baseUrl = "http://${cfg.host}:${toString cfg.port}";
in
{
  # Option path: services.trilium-server (HM convention services.<pkg>).
  # Same name as NixOS services.trilium-server — user accepts possible future
  # home-manager upstream collision.
  options.services.trilium-server = {
    enable = mkEnableOption ''
      Trilium Notes *server* as a systemd user unit (always-on MCP/ETAPI + web UI).

      Use a **separate** dataDir from the Electron desktop app
      (`~/.local/share/trilium-data`). Prefer star topology: each client points
      at one hub; do not share one SQLite file between desktop and this unit.
    '';

    package = mkPackageOption pkgs "trilium-server" { };

    dataDir = mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/trilium-server-data";
      example = "\${config.xdg.dataHome}/trilium-server-data";
      description = ''
        Directory for this server's document.db and local state.
        Must not be the desktop app data directory.
      '';
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Bind address (localhost only by default).";
    };

    port = mkOption {
      type = types.port;
      # Desktop Electron also binds 37840 for its in-process server/MCP.
      # Keep this unit on a different port so both can run (star clients).
      default = 37841;
      description = ''
        HTTP listen port (MCP at http://HOST:PORT/mcp).
        Default 37841 avoids clashing with trilium-desktop (37840).
      '';
    };

    instanceName = mkOption {
      type = types.str;
      default = "trilium-server";
      description = "Trilium instanceName (visible in backend APIs).";
    };

    noBackup = mkOption {
      type = types.bool;
      default = false;
      description = "Disable Trilium's built-in periodic DB backups under dataDir.";
    };

    noAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Allow web UI without password. Keep false on a multi-user machine;
        MCP still uses an ETAPI token either way.
      '';
    };

    sync = {
      serverHost = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "https://notes.example.com";
        description = ''
          Sync hub base URL. Written to config.ini when set, and required for
          unattended bootstrap. No default hub — set explicitly so migration
          is a one-line change.
        '';
      };

      serverTimeout = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "120";
        description = "Optional `[Sync] syncServerTimeout`. Only written if serverHost is set.";
      };

      proxy = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional sync HTTP proxy (config.ini + bootstrap body).";
      };
    };

    bootstrap = {
      enable = mkEnableOption ''
        After trilium-server starts, oneshot join hub if the data dir is still
        uninitialized (POST /api/setup/sync-from-server). No browser.

        Needs `sync.serverHost` and document password via sops
        `trilium/document_password` (see secrets/trilium.yaml). Idempotent once
        the instance reports isInitialized.
      '';

      passwordFile = mkOption {
        type = types.str;
        # Set in config when bootstrap.enable (sops path). Empty default avoids
        # requiring the secret when bootstrap is off.
        default = "";
        description = ''
          Path to the document password (newline-stripped). With bootstrap.enable,
          defaults to the sops-nix secret path for trilium/document_password.
        '';
      };

      waitSeconds = mkOption {
        type = types.ints.positive;
        default = 120;
        description = "How long bootstrap waits for the HTTP API to come up.";
      };
    };
  };

  config = mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ cfg.package ];

        systemd.user.services.trilium-server = {
          Unit = {
            Description = "Trilium Notes server (MCP/ETAPI + web UI)";
            Documentation = [ "https://docs.triliumnotes.org/" ];
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = lib.getExe cfg.package;
            Restart = "on-failure";
            RestartSec = "5";
            ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} -p ${lib.escapeShellArg cfg.dataDir}";
            Environment = [
              "TRILIUM_DATA_DIR=${cfg.dataDir}"
              "TRILIUM_CONFIG_INI_PATH=${configIni}"
            ];
            NoNewPrivileges = true;
            PrivateTmp = true;
          };

          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      }

      (mkIf cfg.bootstrap.enable (
        let
          passwordFile =
            if cfg.bootstrap.passwordFile != "" then
              cfg.bootstrap.passwordFile
            else
              config.sops.secrets."trilium/document_password".path;

          bootstrap = pkgs.writeShellApplication {
            name = "trilium-server-bootstrap";
            runtimeInputs = with pkgs; [
              curl
              jq
              coreutils
            ];
            text = ''
              # Unattended first-run: POST /api/setup/sync-from-server
              # (same body the setup wizard uses). Skips when already initialized
              # or when password is still CHANGE_ME / missing.
              set -euo pipefail

              base=${lib.escapeShellArg baseUrl}
              hub=${lib.escapeShellArg cfg.sync.serverHost}
              pass_file=${lib.escapeShellArg passwordFile}
              proxy=${lib.escapeShellArg (if cfg.sync.proxy != null then cfg.sync.proxy else "")}
              max_wait=${toString cfg.bootstrap.waitSeconds}

              if [[ ! -f $pass_file ]]; then
                echo "trilium-server-bootstrap: missing password file $pass_file (skip)" >&2
                exit 0
              fi
              password=$(tr -d '\n' <"$pass_file")
              if [[ -z $password || $password == CHANGE_ME ]]; then
                echo "trilium-server-bootstrap: set trilium/document_password in secrets/trilium.yaml via sops (not CHANGE_ME)" >&2
                exit 0
              fi

              deadline=$((SECONDS + max_wait))
              status_json=
              while (( SECONDS < deadline )); do
                if status_json=$(curl -fsS --max-time 3 "$base/api/setup/status" 2>/dev/null); then
                  break
                fi
                sleep 1
              done
              if [[ -z $status_json ]]; then
                echo "trilium-server-bootstrap: $base not up after ''${max_wait}s" >&2
                exit 1
              fi

              if jq -e '.isInitialized == true' <<<"$status_json" >/dev/null; then
                echo "trilium-server-bootstrap: already initialized"
                exit 0
              fi

              echo "trilium-server-bootstrap: joining hub $hub …"
              body=$(jq -n \
                --arg host "$hub" \
                --arg proxy "$proxy" \
                --arg password "$password" \
                '{
                  syncServerHost: $host,
                  syncProxy: $proxy,
                  password: $password
                }')

              curl -fsS --max-time 600 \
                -H 'Content-Type: application/json' \
                -d "$body" \
                "$base/api/setup/sync-from-server"

              echo
              echo "trilium-server-bootstrap: setup sync-from-server OK"
              echo "  Mint an ETAPI token on this instance for Grok MCP (one-time)."
            '';
          };
        in
        {
          assertions = [
            {
              assertion = cfg.sync.serverHost != null;
              message = "services.trilium-server.bootstrap.enable requires sync.serverHost";
            }
          ];

          home.packages = [ bootstrap ];

          # Separate sops file so music-backup’s defaultSopsFile stays untouched.
          sops.secrets."trilium/document_password" = {
            sopsFile = ../../secrets/trilium.yaml;
          };

          systemd.user.services.trilium-server-bootstrap = {
            Unit = {
              Description = "Unattended Trilium hub join (setup sync-from-server)";
              # sops-nix must decrypt trilium/document_password before we join
              # the hub (first activation otherwise races and skips with "missing
              # password file").
              After = [
                "trilium-server.service"
                "sops-nix.service"
                "network-online.target"
              ];
              Requires = [ "trilium-server.service" ];
              Wants = [
                "network-online.target"
                "sops-nix.service"
              ];
            };

            Service = {
              Type = "oneshot";
              # Keep unit "active" after success so restart only re-runs join when needed.
              RemainAfterExit = true;
              ExecStart = lib.getExe bootstrap;
            };

            Install = {
              WantedBy = [ "default.target" ];
            };
          };
        }
      ))
    ]
  );
}
