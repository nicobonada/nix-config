# Secret Service for apps (Brave, secret-tool). The store opens with a
# passphrase-less GPG key, so a YubiKey login does not have to supply one.
# gnome-keyring's PAM unlock needed that password and stayed locked.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.gpg.enable = true;

  # 1Password owns SSH_AUTH_SOCK. Pinentry is unused while the pass
  # key has no passphrase; Qt is there if a prompt ever happens.
  services.gpg-agent = {
    enable = true;
    enableSshSupport = false;
    pinentry.package = pkgs.pinentry-qt;
  };

  programs.password-store = {
    enable = true;
    settings.PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
  };

  services.pass-secret-service.enable = true;

  # D-Bus activation does not see the home profile.
  systemd.user.services.pass-secret-service.Service.Environment = lib.mkAfter [
    "PATH=${
      lib.makeBinPath [
        pkgs.pass
        pkgs.gnupg
        pkgs.coreutils
      ]
    }:/run/current-system/sw/bin"
  ];

  # pass is the store CLI. These talk to org.freedesktop.secrets.
  home.packages = with pkgs; [
    libsecret
    lssecret
  ];
}
