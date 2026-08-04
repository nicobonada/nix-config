{ inputs, pkgs, lib, config, ... }:
let
  realGrok = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.grok;
  chatDir = "${config.home.homeDirectory}/chat";

  # Resolve session storage root: repo root if inside a git/jj work tree,
  # otherwise ~/chat (must already exist — do not create it).
  # Honors an explicit --cwd from the user.
  grokWithSessionCwd = pkgs.writeShellApplication {
    name = "grok";
    runtimeInputs = [
      pkgs.git
      pkgs.jujutsu
    ];
    text = ''
      set -euo pipefail

      has_cwd=0
      prev=""
      for arg in "$@"; do
        if [ "$prev" = "--cwd" ]; then
          has_cwd=1
        fi
        case "$arg" in
          --cwd) prev=--cwd ;;
          --cwd=*) has_cwd=1; prev="" ;;
          *) prev="" ;;
        esac
      done

      if [ "$has_cwd" -eq 0 ]; then
        session_cwd=""
        if root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
          session_cwd="$root"
        elif root="$(jj root 2>/dev/null)"; then
          session_cwd="$root"
        else
          session_cwd=${lib.escapeShellArg chatDir}
          if [ ! -d "$session_cwd" ]; then
            echo "grok: not inside a git/jj repo, and $session_cwd does not exist." >&2
            echo "Create that directory for general (non-repo) sessions, or pass --cwd." >&2
            exit 1
          fi
        fi
        set -- --cwd "$session_cwd" "$@"
      fi

      exec ${lib.getExe realGrok} "$@"
    '';
  };
in
{
  imports = [ inputs.grok-config.homeManagerModules.default ];

  programs.grokConfig = {
    enable = true;
    source = "${config.home.homeDirectory}/grok-config";
    # Outer grok-config wrapper prepends agent-apps PATH; this package sets
    # session --cwd (repo root or ~/chat) then execs the real binary.
    package = grokWithSessionCwd;
  };
}
