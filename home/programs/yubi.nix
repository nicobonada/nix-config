{
  # Public FIDO mappings (same class as authorized_keys). Origin/appid: pam://nico.
  # Extra key: pamu2fcfg -n -o pam://nico -i pam://nico >> ~/src/nix-config/home/configs/u2f_keys
  xdg.configFile."Yubico/u2f_keys" = {
    source = ../configs/u2f_keys;
    force = true; # replace the hand-enrolled file on first switch
  };
}
