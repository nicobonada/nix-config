{ config, lib, ... }:
{
  programs.ssh = {
    enable = true;
    # Avoid HM’s default Host * block; we define our own.
    enableDefaultConfig = false;

    # OpenSSH uses the first obtained value per option, so specific Host
    # blocks must come before Host *. Use dag entryBefore for that.
    settings = {
      # --- MagicDNS / Tailscale (day-to-day) ---
      # ForwardAgent only on seats we sit at. Do not enable on Host * / pve /
      # homelab — a compromised remote can use the forwarded agent until disconnect.
      # https://www.1password.dev/ssh/agent/forwarding#security
      seyruun = lib.hm.dag.entryBefore [ "*" ] {
        User = "nico";
        ForwardAgent = true;
      };
      oakhill = lib.hm.dag.entryBefore [ "*" ] {
        User = "nico";
        ForwardAgent = true;
      };
      homelab = lib.hm.dag.entryBefore [ "*" ] {
        User = "nico";
      };
      pve = lib.hm.dag.entryBefore [ "*" ] {
        User = "nico";
      };

      # --- LAN fallbacks when Tailscale is off ---
      # IPs from current LAN; prefer DHCP reservations if they drift.
      seyruun-lan = lib.hm.dag.entryBefore [ "*" ] {
        HostName = "10.0.10.225";
        User = "nico";
        ForwardAgent = true;
      };
      oakhill-lan = lib.hm.dag.entryBefore [ "*" ] {
        HostName = "10.0.10.43";
        User = "nico";
        ForwardAgent = true;
      };
      pve-lan = lib.hm.dag.entryBefore [ "*" ] {
        HostName = "10.0.10.200";
        User = "nico";
      };
      homelab-lan = lib.hm.dag.entryBefore [ "*" ] {
        HostName = "10.0.10.201";
        User = "nico";
      };

      # Local graphical session: talk to this seat's 1Password agent.
      # Inside an SSH TTY, leave IdentityAgent unset so ssh uses forwarded
      # SSH_AUTH_SOCK. IdentityAgent always wins over the env var, so putting
      # it on Host * broke `ssh -A` (remote 1Password dialog on the other niri).
      # Recipe: https://www.1password.dev/ssh/agent/forwarding#remote-workstation
      # /bin/sh so Match exec is correct when $SHELL is fish.
      local-1password-agent = lib.hm.dag.entryBefore [ "*" ] {
        header = ''Match host * exec "/bin/sh -c 'test -z \"$SSH_TTY\"'"'';
        IdentityAgent = "~/.1password/agent.sock";
      };

      "*" = {
        # Offer agent identities (IdentitiesOnly=yes would require a local
        # IdentityFile, which we intentionally do not keep on disk).
        IdentitiesOnly = "no";
        UserKnownHostsFile = "~/.ssh/known_hosts";
        HashKnownHosts = "no";
        # Convenient on a home LAN; pin hosts and switch to "yes" if you want.
        StrictHostKeyChecking = "accept-new";
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };
    };
  };

  # HM links ~/.ssh/config into the store; symlink mode is 0777 and OpenSSH
  # rejects that ("Bad owner or permissions"). Replace with a 0600 copy.
  home.activation.sshConfigMode = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    cfg="${config.home.homeDirectory}/.ssh/config"
    if [[ -L $cfg ]]; then
      real=$(readlink -f "$cfg")
      rm -f "$cfg"
      cp -f "$real" "$cfg"
      chmod 600 "$cfg"
    elif [[ -f $cfg ]]; then
      chmod 600 "$cfg"
    fi
  '';
}

