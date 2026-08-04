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
      seyruun = lib.hm.dag.entryBefore [ "*" ] {
        User = "nico";
      };
      oakhill = lib.hm.dag.entryBefore [ "*" ] {
        User = "nico";
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
      };
      oakhill-lan = lib.hm.dag.entryBefore [ "*" ] {
        HostName = "10.0.10.43";
        User = "nico";
      };
      pve-lan = lib.hm.dag.entryBefore [ "*" ] {
        HostName = "10.0.10.200";
        User = "nico";
      };
      homelab-lan = lib.hm.dag.entryBefore [ "*" ] {
        HostName = "10.0.10.201";
        User = "nico";
      };

      "*" = {
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = "yes";
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

