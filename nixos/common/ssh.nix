{ lib, ... }:
let
  # Workstation client keys — install on every machine you SSH *to*.
  # Keep comments stable so `authorized_keys` diffs stay readable.
  nicoKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfCbF/qHMrvFvPF3pwN78vu/HV9zLATmy1m0H+9wUl3 nico@seyruun"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiS0WGMF1xtibs+k+4WjkpPCv0stUUGY7E75Nuh2Fib nico@oakhill"
  ];
in
{
  users.users.nico.openssh.authorizedKeys.keys = nicoKeys;

  services.openssh = {
    enable = true;
    settings = {
      # Leave passwords on until LAN + key paths are verified on all hosts,
      # then flip these to false (and KbdInteractiveAuthentication false).
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Tailscale SSH (identity auth) as primary remote path; classic keys for
  # when the tailnet is down. Requires matching ACLs in tailscale-policy.
  services.tailscale.extraSetFlags = [ "--ssh" ];
}
