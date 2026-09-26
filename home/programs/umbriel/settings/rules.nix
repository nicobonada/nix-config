let
  monitors = import ../monitors.nix;
in
{
  # niri's noctalia backdrop layer rule (place-within-backdrop) and the
  # xray-off layer rule have no Umbriel keys. Layer blur stays off.
  window_rule = [
    # Every window. blur_optimized false blurs what is behind the window
    # (niri background-effect xray false) instead of a cached backdrop.
    {
      blur = true;
      blur_optimized = false;
    }

    {
      match.app_id = "^(steam_app_[0-9]+|gamescope)$";
      # Opening placement. Proton often has no app-id on the first configure,
      # and Umbriel does not replay opening settings when the id arrives.
      # niri-game-output still does that move on the niri session.
      default_output = monitors.lg;
      vrr = "always";
    }

    {
      # Dynamic, so it still applies once a game publishes the hint.
      match.content_type = "game";
      vrr = "always";
    }

    {
      match.app_id = "^brave-personal$";
      match.at_startup = true;
      default_output = monitors.asus;
    }

    {
      match.app_id = "^brave-work$";
      match.at_startup = true;
      default_output = monitors.lg;
    }

    {
      match.title = "^MikuLogiS\\+$";
      default_fullscreen = false;
    }

    {
      match.app_id = "^steam$";
      match.title = "^notificationtoasts_[0-9]+_desktop$";
      default_floating = true;
      default_position = {
        x = 10;
        y = 10;
        anchor = "bottom_right";
      };
    }

    {
      match.app_id = "^dev\\.noctalia\\.Noctalia\\.Settings$";
      default_floating = true;
      default_floating_size_px = {
        width = 1080;
        height = 920;
      };
    }

    {
      match.app_id = "^com\\.gabm\\.satty$";
      default_floating = true;
    }
  ];
}
