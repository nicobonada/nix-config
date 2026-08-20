# Agent-only OpenSSH wrapper (Grok tool PATH). Not for the interactive shell.
#
# Forces `ssh -F <user-config>` so system `/etc/ssh/ssh_config` is ignored
# (avoids store Includes such as systemd-ssh-proxy). Needed when the agent
# runs in a userns that shows root-owned paths as nobody (optional Grok
# `--sandbox`). Harmless when not isolated (user-owned -F config).
{ writeShellApplication, openssh }:
writeShellApplication {
  name = "ssh";
  runtimeInputs = [ openssh ];
  text = ''
        set -euo pipefail

        real_ssh=${openssh}/bin/ssh

        # Honor an explicit -F from the caller (no second -F).
        for arg in "$@"; do
          case "$arg" in
            -F|-F*)
              exec "$real_ssh" "$@"
              ;;
          esac
        done

        user_cfg="''${HOME}/.ssh/config"
        tmp_cfg=
        cfg=

        if [[ -f $user_cfg && ! -L $user_cfg ]]; then
          # Safe regular file (e.g. HM activation 0600 copy).
          cfg=$user_cfg
        else
          # Symlink into the store or missing: copy content to a user-owned temp.
          tmp_cfg=$(mktemp)
          if [[ -e $user_cfg ]]; then
            cp -L "$user_cfg" "$tmp_cfg" 2>/dev/null || true
          fi
          if [[ ! -s $tmp_cfg ]]; then
            cat >"$tmp_cfg" <<'EOF'
    Host *
      IdentityFile ~/.ssh/id_ed25519
      IdentitiesOnly yes
      StrictHostKeyChecking accept-new
    EOF
          fi
          chmod 600 "$tmp_cfg"
          cfg=$tmp_cfg
          trap 'rm -f -- "$tmp_cfg"' EXIT
        fi

        exec "$real_ssh" -F "$cfg" "$@"
  '';
}
