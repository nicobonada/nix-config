{ lib, ... }:
let
  # Workstation client keys — install on every machine you SSH *to*.
  # Keep comments stable so `authorized_keys` diffs stay readable.
  nicoKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfCbF/qHMrvFvPF3pwN78vu/HV9zLATmy1m0H+9wUl3 nico@seyruun"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiS0WGMF1xtibs+k+4WjkpPCv0stUUGY7E75Nuh2Fib nico@oakhill"
  ];

  # Profile paths so sudoers tracks the active generation (not a frozen store hash).
  nopasswdBins = [
    "/run/current-system/sw/bin/nh"
    "/run/current-system/sw/bin/nixos-rebuild"
  ];
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

  # Scoped elevation for local rebuilds (agents / scripts). Not full passwordless sudo.
  security.sudo.extraRules = [
    {
      users = [ "nico" ];
      commands = map (command: {
        inherit command;
        options = [ "NOPASSWD" ];
      }) nopasswdBins;
    }
  ];

  # Tailscale SSH (identity auth) as primary remote path; classic keys for
  # when the tailnet is down. Requires matching ACLs in tailscale-policy.
  services.tailscale.extraSetFlags = [ "--ssh" ];
}
