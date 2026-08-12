{ pkgs, lib, ... }:
let
  # Patch: --start-hidden must hold() or the process exits immediately (no
  # Flatpak portal keep-alive on niri). Warm instance → instant Mod+E activate.
  smile = pkgs.smile.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./smile-hold-start-hidden.patch ];
  });

  # Prefer D-Bus Activate (ms) over spawning Python (hundreds of ms+).
  smileToggle = pkgs.writeShellApplication {
    name = "smile-toggle";
    runtimeInputs = [ smile ];
    text = ''
      # Already resident: show/raise without a cold start (ms via D-Bus).
      # busctl is on the NixOS system profile.
      # shellcheck disable=SC1083 # a{sv} is a busctl type signature, not a shell brace
      if busctl --user call it.mijorus.smile /it/mijorus/smile \
          org.gtk.Application Activate 'a{sv}' 0 &>/dev/null; then
        exit 0
      fi
      # No daemon yet (pre-startup / killed): full launch.
      exec smile
    '';
  };
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
    smile
    smileToggle
  ];
}
