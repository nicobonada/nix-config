{
  writeShellApplication,
  curl,
  jq,
  coreutils,
  lib,
}:
# Factory: unattended first-run POST /api/setup/sync-from-server.
# Module supplies baseUrl / hub / passwordFile / stampFile / proxy / waitSeconds.
{
  baseUrl,
  hub,
  passwordFile,
  stampFile,
  proxy ? "",
  waitSeconds ? 60,
}:
writeShellApplication {
  name = "trilium-server-bootstrap";
  runtimeInputs = [
    curl
    jq
    coreutils
  ];
  text = ''
    # Unattended first-run: POST /api/setup/sync-from-server
    # (same body the setup wizard uses). Skips when already initialized
    # or when password is still CHANGE_ME / missing.
    #
    # Stamp only after a real answer from the server. A missing password
    # or a server that never came up must stay unstamped so the next
    # start tries again. Wiping the data dir removes the stamp.
    set -euo pipefail

    base=${lib.escapeShellArg baseUrl}
    hub=${lib.escapeShellArg hub}
    pass_file=${lib.escapeShellArg passwordFile}
    stamp=${lib.escapeShellArg stampFile}
    proxy=${lib.escapeShellArg proxy}
    max_wait=${toString waitSeconds}

    mark_done() {
      mkdir -p "$(dirname "$stamp")"
      touch "$stamp"
    }

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
      mark_done
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
    mark_done
  '';
}
