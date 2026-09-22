# Overlay on Umbriel's built-in chords. Unmentioned chords stay, including
# Mod+O overview, Mod+Escape quit, hjkl, Mod+F fullscreen, and Shift+digit
# window moves.
#
# This pin has no action for expel-only, center-all-visible-columns,
# reset-window-height, or shortcut inhibit.
let
  # Hardware keys should still work on the lock screen.
  locked = action: {
    inherit action;
    allow_when_locked = true;
  };
  wheel = action: {
    inherit action;
    cooldown_ms = 150;
  };
in
{
  keybinds = {
    # Bare Mod. Mod+D is unused.
    "Mod" = "spawn:noctalia msg panel-toggle launcher";
    "Mod+N" = "spawn:noctalia msg panel-toggle control-center";
    "Mod+Comma" = "spawn:noctalia msg settings-toggle";
    "Mod+X" = "spawn:noctalia msg panel-toggle session";
    "Mod+Semicolon" = "spawn:noctalia msg panel-toggle launcher //";

    "XF86AudioRaiseVolume" = locked "spawn:noctalia msg volume-up";
    "XF86AudioLowerVolume" = locked "spawn:noctalia msg volume-down";
    "XF86AudioMute" = locked "spawn:noctalia msg volume-mute";
    "XF86MonBrightnessUp" = locked "spawn:noctalia msg brightness-up";
    "XF86MonBrightnessDown" = locked "spawn:noctalia msg brightness-down";

    # Vertical strip: up is previous, down is next.
    "Mod+Page_Up" = "workspace-previous";
    "Mod+Page_Down" = "workspace-next";
    "Mod+Shift+Page_Up" = "workspace-move-up";
    "Mod+Shift+Page_Down" = "workspace-move-down";
    "Mod+Ctrl+Page_Up" = "window-move-to-workspace-previous";
    "Mod+Ctrl+Page_Down" = "window-move-to-workspace-next";

    # Replaces built-in wheel column focus.
    "Mod+WheelUp" = wheel "workspace-previous";
    "Mod+WheelDown" = wheel "workspace-next";
    "Mod+Ctrl+WheelUp" = wheel "window-move-to-workspace-previous";
    "Mod+Ctrl+WheelDown" = wheel "window-move-to-workspace-next";
    "Mod+WheelLeft" = "window-focus-left";
    "Mod+WheelRight" = "window-focus-right";
    "Mod+Shift+WheelUp" = "window-focus-left";
    "Mod+Shift+WheelDown" = "window-focus-right";

    "Mod+Home" = "column-focus-first";
    "Mod+End" = "column-focus-last";

    "Mod+Ctrl+Left" = "output-focus-left";
    "Mod+Ctrl+Down" = "output-focus-down";
    "Mod+Ctrl+Up" = "output-focus-up";
    "Mod+Ctrl+Right" = "output-focus-right";

    "Mod+Shift+Ctrl+Left" = "window-move-to-output-left";
    "Mod+Shift+Ctrl+Down" = "window-move-to-output-down";
    "Mod+Shift+Ctrl+Up" = "window-move-to-output-up";
    "Mod+Shift+Ctrl+Right" = "window-move-to-output-right";

    "Mod+BracketLeft" = "window-consume-or-expel-left";
    "Mod+BracketRight" = "window-consume-or-expel-right";

    "Mod+C" = "column-center";

    "Mod+Minus" = "window-modify-width:-0.1";
    "Mod+Equal" = "window-modify-width:0.1";
    "Mod+Shift+Minus" = "window-modify-height:-0.1";
    "Mod+Shift+Equal" = "window-modify-height:0.1";

    "Mod+V" = "window-toggle-floating";
    "Mod+Shift+V" = "window-focus-switch-floating";

    "Mod+Q" = {
      action = "window-close";
      repeat = false;
    };
    # Alt+Tab style overlay. Tab and Shift+Tab cycle while it is open.
    "Mod+Tab" = {
      action = "spawn:noctalia msg window-switcher";
      repeat = false;
    };

    "Mod+Shift+Slash" = "cheatsheet-toggle";
    "Mod+Shift+P" = "dpms-off";
    # Niri's uwsm stop. Mod+Escape stays the built-in quit.
    "Mod+Shift+E" = "session-quit";

    "Mod+Return" = "spawn:kitty";
    # Brave was Mod+O on niri. O stays overview here.
    "Mod+B" = "spawn:brave-work";
    "Mod+Shift+B" = "spawn:brave-personal";
    "Mod+Alt+B" = "spawn:brave-scratch";
    "Mod+A" = "spawn:satty-last-screenshot";
    "Mod+W" = "spawn:kitten quick-access-terminal --instance-group vol wiremix";

    # No focused-window capture yet (noctalia-dev/noctalia#3380).
    "Mod+S" = "spawn:noctalia msg screenshot-region";
    "Mod+Ctrl+S" = "spawn:noctalia msg screenshot-fullscreen";
    "Print" = "spawn:noctalia msg screenshot-region";
    "Ctrl+Print" = "spawn:noctalia msg screenshot-fullscreen";
    "Shift+Print" = "spawn:satty-last-screenshot";
  };
}
