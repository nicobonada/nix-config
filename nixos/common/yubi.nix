{ pkgs, ... }:
{
  # sufficient = security key *or* password. Enroll (same origin/appid on both seats):
  #   mkdir -p ~/.config/Yubico
  #   pamu2fcfg -o pam://nico -i pam://nico > ~/.config/Yubico/u2f_keys
  # Extra keys: pamu2fcfg -n -o pam://nico -i pam://nico >> ~/.config/Yubico/u2f_keys
  security.pam.u2f = {
    enable = true;
    control = "sufficient";
    settings = {
      cue = true;
      cue_prompt = "Touch your security key";
      # Host-independent so one u2f_keys file works on oakhill and seyruun.
      origin = "pam://nico";
      appid = "pam://nico";
    };
  };

  # After enroll, a local tap would otherwise stall remote SSH / user-session start.
  security.pam.services.sshd.u2fAuth = false;
  security.pam.services.systemd-user.u2fAuth = false;

  # noctalia-greeter refuses empty submit unless this is on; Enter-with-no-password
  # is how FIDO reaches pam_u2f. Password login still works as usual.
  programs.noctalia-greeter.settings.auth.allow_empty_password = true;

  services = {
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubioath-flutter
  ];
}
