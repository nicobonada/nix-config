{ ... }:
{
  # Human desktop + CLI integration (niri/Noctalia, not GNOME/Plasma-specific).
  # - setgid op → unlock CLI via desktop app
  # - BrowserSupport wrapper → extension unlock with app
  # - polkitPolicyOwners → system-auth unlock (needs a session polkit agent:
  #   enable Noctalia shell.polkit_agent; do not also run polkit-gnome)
  #
  # Agent Service Account is separate: home/services/onepassword-sa.nix +
  # OP_SERVICE_ACCOUNT_TOKEN_FILE (do not export OP_SERVICE_ACCOUNT_TOKEN in
  # interactive shells — that forces SA mode and skips desktop integration).
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "nico" ];
  };
}
