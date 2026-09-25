{
  input = {
    keyboard = {
      options = "compose:caps";
      repeat_delay = 250;
      repeat_rate = 40;
    };

    # LMR: one finger left, two middle, three right. Same as niri
    # tap-button-map "left-middle-right". Tap-to-click stays on by default.
    touchpad.tap_button_map = "left_middle_right";

    focus.follows_mouse = true;

    cursor = {
      theme = "Bibata-Modern-Ice";
      # niri warp-mouse-to-focus.
      follows_focus = true;
    };
  };
}
