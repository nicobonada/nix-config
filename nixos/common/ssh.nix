{ lib, ... }:
let
  # Workstation client keys — install on every machine you SSH *to*.
  # Keep comments stable so `authorized_keys` diffs stay readable.
  nicoKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfCbF/qHMrvFvPF3pwN78vu/HV9zLATmy1m0H+9wUl3 nico@seyruun"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiS0WGMF1xtibs+k+4WjkpPCv0stUUGY7E75Nuh2Fib nico@oakhill"
  ];

  # Profile path so sudoers tracks the active generation (not a frozen store hash).
  # Agents use nixos-rebuild (not nh): nh elevates via `sudo env … switch-to-configuration`,
  # so NOPASSWD on the nh binary never matched activation anyway.
  nopasswdRebuild = "/run/current-system/sw/bin/nixos-rebuild";
in
{
  users.users.nico.openssh.authorizedKeys.keys = nicoKeys;

  services.openssh = {
    enable = true;
    settings = {
      # Keys + Tailscale SSH only. Console/physical login still uses local auth.
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # Classic OpenSSH: no root. Tailscale SSH root is a separate policy
      # (tailscale-policy ssh rules) used for remote activation.
      PermitRootLogin = "no";
    };
  };

  # Scoped elevation for local OS rebuilds (agents / scripts). Not full passwordless sudo.
  security.sudo.extraRules = [
    {
      users = [ "nico" ];
      commands = [
        {
          command = nopasswdRebuild;
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Tailscale SSH (identity auth) as primary remote path; classic keys for
  # when the tailnet is down. Requires matching ACLs in tailscale-policy.
  services.tailscale.extraSetFlags = [ "--ssh" ];
}
