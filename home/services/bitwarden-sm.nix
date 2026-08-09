{ config, pkgs, ... }:
{
  # Bootstrap token for Bitwarden Secrets Manager CLI / Grok (BWS_ACCESS_TOKEN).
  # Encrypted source: secrets/bitwarden-sm.yaml — runtime via sops-nix only
  # (no ~/.config/bitwarden copy). Grok wrapper reads BWS_ACCESS_TOKEN_FILE.
  sops.secrets."bitwarden_sm/access_token" = {
    sopsFile = ../../secrets/bitwarden-sm.yaml;
  };

  # Path only (not the secret value) so shells don't inherit the token string.
  home.sessionVariables.BWS_ACCESS_TOKEN_FILE =
    config.sops.secrets."bitwarden_sm/access_token".path;

  # Interactive shell: Secrets Manager CLI (not the Password Manager desktop app).
  # Agent gets the same package via Grok definition agent-apps.
  home.packages = [ pkgs.bws ];
}
