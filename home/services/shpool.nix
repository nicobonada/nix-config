{ ... }:
{
  # Persistent grok TUIs. The fish function `grok` attaches one session
  # per directory. Closing kitty detaches; the process stays here.
  services.shpool = {
    enable = true;
    settings = {
      prompt_prefix = "";
      # Fullscreen TUI: ask it to redraw. Skip the vt100 snapshot.
      session_restore_mode = "simple";
      # A list replaces the defaults, so the defaults stay listed.
      # PATH is the kitty fish that typed `grok`.
      # WAYLAND_DISPLAY is how grok Ctrl+V reads screenshot CLIPBOARD
      # (wlr-data-control / wl-paste). It is snapshotted at session
      # create; after a compositor restart, kill and recreate.
      forward_env = [
        "PATH"
        "TERM"
        "LANG"
        "DISPLAY"
        "WAYLAND_DISPLAY"
        "XDG_SESSION_TYPE"
        "DBUS_SESSION_BUS_ADDRESS"
        "SSH_AUTH_SOCK"
      ];
    };
  };

  systemd.user.services.shpool.Unit = {
    # A changed unit is stop-started. Grok TUIs live in this cgroup;
    # stopping it SIGKILLs the agent and the home switch itself.
    # The new binary applies at the next login.
    X-SwitchMethod = "keep-old";
  };
}
