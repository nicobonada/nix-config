# Shipped chords are written here. Leaving them out did not keep arrow focus.
#
# Not copied, because this file sets them to something else:
# Mod+Comma (settings), Mod+WheelUp/Down (workspace), Mod+Q (close, no repeat).
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
  workspaceBinds = builtins.listToAttrs (
    builtins.concatMap (n: [
      {
        name = "Mod+${toString n}";
        value = "workspace-switch:${toString n}";
      }
      {
        name = "Mod+Shift+${toString n}";
        value = "window-move-to-workspace:${toString n}";
      }
      {
        name = "Mod+KP_${toString n}";
        value = "workspace-switch:${toString n}";
      }
      {
        name = "Mod+Shift+KP_${toString n}";
        value = "window-move-to-workspace:${toString n}";
      }
    ]) (builtins.genList (i: i + 1) 9)
  );
in
{
  keybinds = workspaceBinds // {
    # Shipped focus. Shift+Left/Right move the column; Shift+Up/Down move the window.
    "Mod+Left" = "window-focus-left";
    "Mod+Right" = "window-focus-right";
    "Mod+Up" = "window-focus-up";
    "Mod+Down" = "window-focus-down";
    "Mod+H" = "window-focus-left";
    "Mod+J" = "window-focus-down";
    "Mod+K" = "window-focus-up";
    "Mod+L" = "window-focus-right";
    "Mod+Shift+Left" = "column-move-left";
    "Mod+Shift+Right" = "column-move-right";
    "Mod+Shift+Up" = "window-move-up";
    "Mod+Shift+Down" = "window-move-down";
    "Mod+Shift+H" = "column-move-left";
    "Mod+Shift+J" = "window-move-down";
    "Mod+Shift+K" = "window-move-up";
    "Mod+Shift+L" = "column-move-right";

    "Mod+Escape" = "session-quit";
    "Mod+F1" = "window-focus-next";
    "Mod+Period" = "window-consume-right";
    "Mod+R" = "window-cycle-primary-extent";
    "Mod+Shift+R" = "window-cycle-primary-extent-back";
    "Mod+F" = "window-toggle-fullscreen";
    "Mod+Ctrl+F" = "window-toggle-maximize";
    "Mod+M" = "window-toggle-maximize-to-edges";
    "Mod+T" = "window-toggle-floating";
    "Mod+P" = "window-toggle-pinned";
    "Mod+O" = {
      action = "overview-toggle";
      repeat = false;
    };

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

    "Mod+Minus" = "window-modify-primary-extent:-0.1";
    "Mod+Equal" = "window-modify-primary-extent:0.1";
    "Mod+Shift+Minus" = "window-modify-secondary-extent:-0.1";
    "Mod+Shift+Equal" = "window-modify-secondary-extent:0.1";

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
    "Mod+W" = "spawn:kitten quick-access-terminal --instance-group vol wiremix";

    # No focused-window capture yet (noctalia-dev/noctalia#3380).
    "Mod+S" = "spawn:noctalia msg screenshot-region";
    "Mod+Ctrl+S" = "spawn:noctalia msg screenshot-fullscreen";
    "Print" = "spawn:noctalia msg screenshot-region";
    "Ctrl+Print" = "spawn:noctalia msg screenshot-fullscreen";
  };
}
