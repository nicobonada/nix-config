{
  input = {
    keyboard = {
      options = "compose:caps";
      repeat_delay = 250;
      repeat_rate = 40;
    };

    # niri tap-button-map left-middle-right has no Umbriel key. Tap-to-click
    # stays on via Umbriel's default.
    focus.follows_mouse = true;

    cursor = {
      theme = "Bibata-Modern-Ice";
      # niri warp-mouse-to-focus.
      follows_focus = true;
    };
  };
}
