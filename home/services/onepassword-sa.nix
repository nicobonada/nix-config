{ config, ... }:
{
  # Bootstrap token for 1Password Service Account (agent / Grok only).
  # Encrypted source: secrets/onepassword-sa.yaml — runtime via sops-nix only.
  # Grok wrapper loads OP_SERVICE_ACCOUNT_TOKEN from this file path.
  #
  # Interactive human CLI/GUI: nixos/common/onepassword.nix (system wrappers).
  # Do not put OP_SERVICE_ACCOUNT_TOKEN in the login shell — that switches `op`
  # to SA mode and disables desktop integration. Path-only env is fine.
  #
  # SA should be scoped to the automation Secrets vault only; final SA is
  # read-only after import (permissions immutable → rotate SA).
  sops.secrets."onepassword_sa/token" = {
    sopsFile = ../../secrets/onepassword-sa.yaml;
  };

  # Path only (not the secret value) so shells don't inherit the token string.
  home.sessionVariables.OP_SERVICE_ACCOUNT_TOKEN_FILE =
    config.sops.secrets."onepassword_sa/token".path;
}
