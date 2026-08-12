{ pkgs, ... }:
let
  custom = import ../../../pkgs { inherit pkgs; };
in
{
  # Copy only; hide (not minimize) so the process stays resident after pick.
  # iconify-on-esc is a no-op-ish path on niri and skips the hide-keep-alive branch.
  dconf.settings."it/mijorus/smile" = {
    auto-paste = false;
    auto-paste-xdotool = false;
    load-hidden-on-startup = true;
    iconify-on-esc = false;
  };

  home.packages = [
    custom.smile
    custom.smile-toggle
  ];
}
