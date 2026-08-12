{ writeShellApplication, smile }:
# Prefer D-Bus Activate (ms) over spawning Python (hundreds of ms+).
writeShellApplication {
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
}
